#!/bin/bash
function define_parameters {

# set compiler configuration
	compiler='ifort'
	comp_flags='-assume byterecl'
	netcdf_inc='-I/apl/tryton/netcdf/4.4-intel/include'
	netcdf_lib='-L/apl/tryton/netcdf/4.4-intel/lib -lnetcdff -L/apl/tryton/hdf5/1.8.16-intel/lib -L/apl/tryton/netcdf/4.4-intel/lib -lnetcdf -lnetcdf'
	commonL='../common_code/messages.f90 ../common_code/error_codes.f90'

# set data folders
	in_model_nc_prefix='waterpuck_hydro.pop.h.'
	input_data_dir='/users/work/mjanecki/archive/waterpuck_hydro/ocn/'${data_year}'/'
	tmp_data_path='/users/work/anowicki/FF_WP/tmp_data/'${in_add_mask}'/'
	out_data_path='/users/work/anowicki/FF_WP/boundary_115m/'${data_year}'/'

# set calculated parameters
#	parameters_list=('TEMP' 'SALT' 'HU' 'SSH' 'UVEL' 'VVEL')
	parameters_list=('spC' 'spChl' 'diatC' 'diatChl' 'diazC' 'diazChl' 'zooC' 'O2' 'NH4' 'SiO3' 'NO3' 'PO4' 'DOC')
	params_to_avg_in=('UVEL' 'VVEL')
	params_to_avg_out=('SU' 'SV')
	params_transport=('UH' 'VH')

#--------------------------------------------------------------

	ok_status=0
	err_missing_program_input=100
	err_f_open=101
	err_f_read=102
	err_f_write=103
	err_f_close=104
	err_memory_alloc=105

	progress_file="progress_${in_add_mask}.log"

	bin_tmp_dir=${tmp_data_path}"tmp_bin_data/"
	bin_spread_dir=${tmp_data_path}"spread_data/"
	bin_merged_dir=${tmp_data_path}"merged_data/"
	bin_interp_dir=${tmp_data_path}"interp_data/"

	x_in=600
	y_in=640
	z_in=21
	x_out=1000
	y_out=640
### change this also in interpolate_data.m!!!!
	z_out=33 # waterpuck
#	z_out=26 # findfish
	out_grid_size="115m"
	out_files_suffix='.ieeer8'

	grids_path='../input_data/grids/'
	kmt_file_2km=${grids_path}'2km/kmt_2km.ieeer8'
	angles_file_2km=${grids_path}'2km/anglet_2km.ieeer8'
	thickness_file_2km=${grids_path}'2km/thickness_2km_600x640.txt'
	in_bay_mask_file=${grids_path}'2km/3d_bay_mask_2km.ieeer8'
	in_sea_mask_file=${grids_path}'2km/3d_sea_mask_2km.ieeer8'
	out_bay_mask_file=${grids_path}${out_grid_size}'/3d_bay_mask_'${out_grid_size}'.ieeer8'
	out_sea_mask_file=${grids_path}${out_grid_size}'/3d_sea_mask_'${out_grid_size}'.ieeer8'
}
