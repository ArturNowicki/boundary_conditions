#!/bin/bash
function define_parameters {
	ok_status=0
	err_missing_program_input=100
	err_f_open=101
	err_f_read=102
	err_f_write=103
	err_f_close=104
	err_memory_alloc=105

	grids_path='../input_data/grids/'
	kmt_file_2km=${grids_path}'2km/kmt_2km.ieeer8'
	angles_file_2km=${grids_path}'2km/anglet_2km.ieeer8'
	thickness_file_2km=${grids_path}'2km/thickness_2km_600x640.txt'
	in_bay_mask_file=${grids_path}'2km/3d_bay_mask_2km.ieeer8'
	in_sea_mask_file=${grids_path}'2km/3d_sea_mask_2km.ieeer8'
	out_bay_mask_file=${grids_path}'115m/3d_bay_mask_115m.ieeer8'
	out_sea_mask_file=${grids_path}'115m/3d_sea_mask_115m.ieeer8'

	in_model_nc_prefix='waterpuck_hydro.pop.h.'
	in_add_mask='2015-12'
	out_files_suffix='.ieeer8'

	progress_file="progress_${in_add_mask}.log"

	x_in=600
	y_in=640
	z_in=21
	x_out=1000
	y_out=640
	z_out=33
	out_grid_size="115m"

	input_data_dir='/users/work/mjanecki/archive/waterpuck_hydro/ocn/2015/'
	tmp_data_path='/users/work/anowicki/FF_WP/tmp_data/'${in_add_mask}'/'
	out_data_path='/users/work/anowicki/FF_WP/boundary_115m/2015/'

	bin_tmp_dir=${tmp_data_path}"tmp_bin_data/"
	bin_spread_dir=${tmp_data_path}"spread_data/"
	bin_merged_dir=${tmp_data_path}"merged_data/"
	bin_interp_dir=${tmp_data_path}"interp_data/"

	parameters_list=( 'TEMP' 'SALT' 'UVEL' 'VVEL' 'SSH')
	params_to_avg_in=( 'UVEL' 'VVEL')
	params_to_avg_out=( 'SU' 'SV')

	compiler='ifort'
	comp_flags='-assume byterecl'
	netcdf_inc='-I/apl/tryton/netcdf/4.4-intel/include'
	netcdf_lib='-L/apl/tryton/netcdf/4.4-intel/lib -lnetcdff -L/apl/tryton/hdf5/1.8.16-intel/lib -L/apl/tryton/netcdf/4.4-intel/lib -lnetcdf -lnetcdf'
	commonL='../common_code/messages.f90 ../common_code/error_codes.f90'
}
