#!/bin/bash
function define_parameters {
	ok_status=0
	err_missing_program_input=100
	err_f_open=101
	err_f_read=102
	err_f_write=103
	err_f_close=104
	err_memory_alloc=105

	progress_file='progress.log'

	grids_path='../input_data/grids/'
	kmt_file_2km=${grids_path}'2km/kmt_2km.ieeer8'
	angles_file_2km=${grids_path}'2km/anglet_2km.ieeer8'
	thickness_file_2km=${grids_path}'2km/thickness_2km_600x640.txt'
	in_bay_mask_file=${grids_path}'2km/3d_bay_mask_2km.ieeer8'
	in_sea_mask_file=${grids_path}'2km/3d_sea_mask_2km.ieeer8'
	out_bay_mask_file=${grids_path}'115m/3d_bay_mask_115m.ieeer8'
	out_sea_mask_file=${grids_path}'115m/3d_sea_mask_115m.ieeer8'

	in_model_nc_prefix='run001.pop.h.'
	out_files_suffix='.ieeer8'
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
	# input_data_dir='../../../data/boundary_conditions/2km_in_data/'
	# tmp_data_path='../../../data/boundary_conditions/tmp_data/'
	# out_data_path='../../../data/boundary_conditions/out_data/'

	bin_tmp_dir=${tmp_data_path}"tmp_bin_data/"
	bin_spread_dir=${tmp_data_path}"spread_data/"
	bin_merged_dir=${tmp_data_path}"merged_data/"
	bin_interp_dir=${tmp_data_path}"interp_data/"

#	parameters_list=( 'TEMP' 'SALT' 'UVEL' 'VVEL' 'SSH')
#	params_to_avg_in=( 'UVEL' 'VVEL')
#	params_to_avg_out=( 'SU' 'SV')

	parameters_list=( 'NO3')
	compiler='ifort'
	netcdf_inc='-I/apl/tryton/netcdf/4.4-intel/include'
	netcdf_lib='-L/apl/tryton/netcdf/4.4-intel/lib -lnetcdff -L/apl/tryton/hdf5/1.8.16-intel/lib -L/apl/tryton/netcdf/4.4-intel/lib -lnetcdf -lnetcdf'
	# compiler='gfortran'
	# netcdf_inc='-I/opt/local/include'
	# netcdf_lib='-L/opt/local/lib -lnetcdff -lnetcdf'
	commonL='../common_code/messages.f90 ../common_code/error_codes.f90'
}
