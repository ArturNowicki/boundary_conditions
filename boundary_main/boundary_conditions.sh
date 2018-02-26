#!/bin/bash
# Created by Artur Nowicki on 06.02.2018.
function define_parameters {
	ok_status=0
	err_missing_program_input=100
	err_f_open=101
	err_f_read=102
	err_f_write=103
	err_f_close=104
	err_memory_alloc=105

	progress_file='../input_data/config/progress.log'

	grids_path='../input_data/grids/'
	kmt_file_2km=${grids_path}'2km/kmt_2km.ieeer8'
	angles_file_2km=${grids_path}'2km/anglet_2km.ieeer8'
	thickness_file_2km=${grids_path}'2km/thickness_2km_600x640.txt'

	in_model_nc_prefix='hydro.pop.h.'
	x_in=600
	y_in=640
	z_in=21
	x_out=1000
	y_out=640
	z_out=33
	out_grid_size="115m"
	input_data_dir='/users/work/anowicki/FF_WP/2km_data/'
	tmp_data_path='/users/work/anowicki/FF_WP/tmp_data/'
	out_data_path='/users/work/anowicki/FF_WP/boundary_115m/'

	bin_tmp_dir="${tmp_data_path}tmp_bin_data/"
	bin_spread_dir="${tmp_data_path}spread_data/"
	bin_out_dir="${tmp_data_path}out_data/"

	parameters_list=( 'TEMP' 'SALT' 'UVEL' 'VVEL' 'SSH')
	params_to_avg_in=( 'UVEL' 'VVEL')
	params_to_avg_out=( 'SU' 'SV')
}

function compile_programs {
	echo "Compile netcdf_to_bin.f90."
	ifort ../common_code/messages.f90 ../common_code/error_codes.f90 -I/apl/tryton/netcdf/4.4-intel/include ../netcdf_to_binary/netcdf_to_bin.f90 -o netcdf_to_bin -L/apl/tryton/netcdf/4.4-intel/lib -lnetcdff -L/apl/tryton/hdf5/1.8.16-intel/lib -L/apl/tryton/netcdf/4.4-intel/lib -lnetcdf -lnetcdf
	if [[ $? -ne 0 ]]; then
		exit
	fi
	echo "Compile average_over_depth.f90."
	ifort ../common_code/messages.f90 ../common_code/error_codes.f90 ../average_over_depth/average_over_depth.f90 -o average_over_depth
	if [[ $? -ne 0 ]]; then
		exit
	fi
	echo "Compile rotate_vector_matrix."
	ifort ../rotate_vector/rotate_vector_matrix.f90 -o rotate_vector_matrix
	if [[ $? -ne 0 ]]; then
		exit
	fi
	echo "Compile poisson_solver.f90."
	ifort ../poisson_solver/poisson_solver.f90 -o poisson_solver
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
	for in_fpath in ${input_data_dir}*'2016-06'*'.nc'; do
		in_file=${in_fpath/${input_data_dir}}
		echo ${in_file}
		date_time=${in_file/${in_model_nc_prefix}}
		date_time=${date_time/'.nc'}
		for parameter_name in "${parameters_list[@]}"
			do
			./netcdf_to_bin ${in_fpath} ${parameter_name} ${date_time} ${bin_tmp_dir}
			if [ $? -ne 0 ]; then
				exit
			fi
		done
		gzip ${in_fpath}
	done
}

function run_calculate_su_sv {
	echo "Calculate SU and SV"
	for ii in 0 1; do
		parameter_name=${params_to_avg_in[${ii}]}
		for in_f in ${bin_tmp_dir}*${parameter_name}*; do
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
	for in_file1 in ${bin_tmp_dir}*${params_to_avg_out}*; do
		in_file2="${in_file1/${params_to_avg_out[0]}/${params_to_avg_out[1]}}"
		./rotate_vector_matrix ${in_file1} ${in_file2} ${in_file1} ${in_file2} ${angles_file_2km} ${kmt_file_2km}
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
	for in_file in ${bin_tmp_dir}*; do
		out_file=${bin_spread_dir}${in_file/${bin_tmp_dir}}
		z_dim_str=${out_file:(-16):4}
		let z_dim=10#${z_dim_str}
		./poisson_solver ${in_file} ${out_file} ${x_in} ${y_in} ${z_dim}
		if [ $? -ne 0 ]; then
			exit
		fi
	done
}

function run_interpolation {
	echo "Interpolation"
	in_path="'"${bin_spread_dir}"'"
	out_path="'"${out_data_path}"'"
	grid_size="'"${out_grid_size}"'"
	matlab -nosplash -nodisplay -nodesktop -r "try; interpolate_data(${in_path}, ${out_path}, ${grid_size}); catch; exit(1); end; quit"
#	matlab -nosplash -nodisplay -nodesktop -r "interpolate_data(${in_path}, ${out_path}, ${grid_size}); quit"
	if [ $? -ne 0 ]; then
		echo "Matlab error!"
		exit
	fi
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
make_dir ${bin_tmp_dir}
make_dir ${bin_spread_dir}
make_dir ${bin_out_dir}


if [[ $1 == 'compile' ]]; then
	compile_programs
else
	if [[ ! -f netcdf_to_bin || ! -f average_over_depth || ! -f rotate_vector_matrix  || ! -f poisson_solver ]]; then
		echo "Compile all needed modules first!"
		exit
	fi
	read progress_status <${progress_file}
	if [[ ${progress_status} -eq 0 ]]; then
		run_netcdf_to_bin
		(( progress_status = progress_status + 1 ))
		echo ${progress_status} > ${progress_file}
	fi
	if [[ ${progress_status} -eq 1 ]]; then
		run_calculate_su_sv
		(( progress_status = progress_status + 1 ))
		echo ${progress_status} > ${progress_file}
	fi
	if [[ ${progress_status} -eq 2 ]]; then
		run_rotate_vectors
		(( progress_status = progress_status + 1 ))
		echo ${progress_status} > ${progress_file}
	fi
	if [[ ${progress_status} -eq 3 ]]; then
		run_poisson_solver
		(( progress_status = progress_status + 1 ))
		rm ${bin_tmp_dir}*.ieeer8
		echo ${progress_status} > ${progress_file}
	fi
	if [[ ${progress_status} -eq 4 ]]; then
		run_interpolation
		(( progress_status = progress_status + 1 ))
		rm ${bin_spread_dir}*.ieeer8
		echo ${progress_status} > ${progress_file}
	fi
	echo "Done."
fi
