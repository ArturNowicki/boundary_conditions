#!/bin/bash
# Created by Artur Nowicki on 06.02.2018.

source ../settings/settings.sh
if [[ $? -ne 0 ]]; then
	exit
fi

function compile_programs {
	echo "Compile netcdf_to_bin.f90."
	${compiler} ${commonL} ${netcdf_inc} ../netcdf_to_binary/netcdf_to_bin.f90 -o netcdf_to_bin  ${netcdf_lib}
	if [[ $? -ne 0 ]]; then
		exit
	fi
	echo "Compile average_over_depth.f90."
	${compiler} ${commonL} ../average_over_depth/average_over_depth.f90 -o average_over_depth
	if [[ $? -ne 0 ]]; then
		exit
	fi
	echo "Compile rotate_vector_matrix.f90"
	${compiler} ${commonL} ../rotate_vector/rotate_vector_matrix.f90 -o rotate_vector_matrix
	if [[ $? -ne 0 ]]; then
		exit
	fi
	echo "Compile poisson_solver.f90."
	${compiler} ${commonL} ../poisson_solver/poisson_solver.f90 -o poisson_solver
	if [[ $? -ne 0 ]]; then
		exit
	fi
	echo "Compile data_merge.f90."
	${compiler} ${commonL} ../data_merge/data_merge.f90 -o data_merge
	if [[ $? -ne 0 ]]; then
		exit
	fi
}

function make_dir {
	if [[ ! -d $1 ]]; then
		mkdir $1
		if [[ $? -ne 0 ]]; then
			exit
		fi
	fi

}

function run_netcdf_to_bin {
	echo "Converting to binary files"
	for in_fpath in ${input_data_dir}*${in_model_nc_prefix}*${in_add_mask}*'.nc'; do
		hour=${in_fpath:(-8):5}
		case $hour in
		    '03600'|'25200'|'46800'|'68400')
			in_file=${in_fpath/${input_data_dir}}
			date_time=${in_file/${in_model_nc_prefix}}
			date_time=${date_time/'.nc'}
			for parameter_name in "${parameters_list[@]}"; do
				./netcdf_to_bin ${in_fpath} ${parameter_name} ${date_time} ${bin_tmp_dir}
				if [ $? -ne 0 ]; then
					exit
				fi
			done
		gzip ${in_fpath}
		esac

	done
}

function run_calculate_su_sv {
	echo "Calculate SU and SV"
	for ii in 0 1; do
		parameter_name=${params_to_avg_in[${ii}]}
		for in_f in ${bin_tmp_dir}*${parameter_name}*${out_files_suffix}; do
			in_file=${in_f/${bin_tmp_dir}}
			IFS='_' read -r date_time rest_f_name <<< "$in_file"
			tmp_str=${date_time}'_'${params_to_avg_out[${ii}]}${rest_f_name:${#parameter_name}}
			out_file="${tmp_str/0021/0001}"
			./average_over_depth ${bin_tmp_dir} ${in_file} ${out_file} ${thickness_file_2km} ${kmt_file_2km}
			if [ $? -ne 0 ]; then
				exit
			fi
		done
	done
}

function run_rotate_vectors {
	echo "Rotate SU and SV"
	for in_file1 in ${bin_tmp_dir}*${params_to_avg_out}*${out_files_suffix}; do
		in_file2="${in_file1/${params_to_avg_out[0]}/${params_to_avg_out[1]}}"
		./rotate_vector_matrix ${in_file1} ${in_file2} ${in_file1} ${in_file2} \
		${angles_file_2km} ${kmt_file_2km}
		if [ $? -ne 0 ]; then
			exit
		fi
	done
	for var_name in ${params_to_avg_in[@]}; do
		rm ${bin_tmp_dir}*$var_name*
	done
}

function run_poisson_solver {
	echo "Poisson solver"
	files_to_process=`ls -1 ${bin_tmp_dir}*${out_files_suffix} | wc -l`
	files_ctr=1
	for in_file in ${bin_tmp_dir}*${out_files_suffix}; do
		progress_msg="Processing file ${files_ctr} of ${files_to_process}: ${in_file/${bin_tmp_dir}}"
		echo -ne ${progress_msg} '\r'
		((files_ctr++))
		out_file=${bin_spread_dir}${in_file/${bin_tmp_dir}}
		let z_dim=10#${out_file:(-16):4}
		out_file_sea=${out_file/${out_files_suffix}}"_sea${out_files_suffix}"
		./poisson_solver ${in_file} ${out_file_sea} ${in_sea_mask_file} ${x_in} ${y_in} ${z_dim}
		if [ $? -ne 0 ]; then
			exit
		fi
		out_file_bay=${out_file/${out_files_suffix}}"_bay${out_files_suffix}"
		./poisson_solver ${in_file} ${out_file_bay} ${in_bay_mask_file} ${x_in} ${y_in} ${z_dim}
		if [ $? -ne 0 ]; then
			exit
		fi
	done
	echo -ne '\n'
}

function run_interpolation {
	echo "Interpolation"
	in_path="'"${bin_spread_dir}"'"
	out_path="'"${bin_interp_dir}"'"
	grid_size="'"${out_grid_size}"'"
	matlab -nosplash -nodisplay -nodesktop -r "try; interpolate_data(${in_path}, ${out_path}, ${grid_size}); catch ME; display(ME.identifier); display(ME.message);  display(ME.stack); display(ME.cause); exit(1); end; quit"
	if [ $? -ne 0 ]; then
		echo "Matlab error!"
		exit
	fi
}

function run_data_merge {
	echo "Data merge"
	for in_file_bay in ${bin_interp_dir}*"bay"*; do
		in_file_sea=${in_file_bay/"bay"/"sea"}
		out_file=${out_data_path}${in_file_bay/${bin_interp_dir}}
		out_file=${out_file/"_bay"}
		let z_dim=10#${out_file:(-16):4}
		./data_merge ${in_file_sea} ${in_file_bay} ${out_file} ${out_sea_mask_file} ${out_bay_mask_file} ${x_out} ${y_out} ${z_dim}
		if [ $? -ne 0 ]; then
			exit
		fi
	done
}

# ----------------------------------------------------------------
# ------------------------------MAIN------------------------------
# ----------------------------------------------------------------

define_parameters

if [[ ! -d ${input_data_dir} ]]; then
	echo "WRONG INPUT DIRECTORY!!!"
	echo ${input_data_dir}
	exit
fi
make_dir ${tmp_data_path}
make_dir ${bin_tmp_dir}
make_dir ${bin_spread_dir}
make_dir ${bin_merged_dir}
make_dir ${bin_interp_dir}
make_dir ${out_data_path}

if [[ $1 == 'compile' ]]; then
	compile_programs
else
	if [[ ! -f netcdf_to_bin || ! -f average_over_depth || ! -f rotate_vector_matrix \
	|| ! -f poisson_solver || ! -f interpolate_data.m || ! -f data_merge ]]; then
		echo "Compile all needed modules first!"
		exit
	fi
	read progress_status <${progress_file}
	if [[ ${progress_status} -eq 0 ]]; then
		run_netcdf_to_bin
		((progress_status++))
		echo ${progress_status} > ${progress_file}
	fi
	if [[ ${progress_status} -eq 1 ]]; then
		run_calculate_su_sv
		((progress_status++))
		echo ${progress_status} > ${progress_file}
	fi
	if [[ ${progress_status} -eq 2 ]]; then
		run_rotate_vectors
		((progress_status++))
		echo ${progress_status} > ${progress_file}
	fi
	if [[ ${progress_status} -eq 3 ]]; then
		run_poisson_solver
		((progress_status++))
		echo ${progress_status} > ${progress_file}
		exit
		rm ${bin_tmp_dir}*${out_files_suffix}
	fi
	if [[ ${progress_status} -eq 4 ]]; then
		run_interpolation
		((progress_status++))
		echo ${progress_status} > ${progress_file}
		rm ${bin_spread_dir}*${out_files_suffix}
	fi
	if [[ ${progress_status} -eq 5 ]]; then
		run_data_merge
		((progress_status++))
		echo ${progress_status} > ${progress_file}
		rm ${bin_interp_dir}*${out_files_suffix}
	fi
	echo "Done."
fi
