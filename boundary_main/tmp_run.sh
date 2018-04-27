#!/bin/bash

define_parameters

for in_fpath in ${input_data_dir}*${in_model_nc_prefix}*${in_add_mask}*'.nc'; do
	echo ${in_fpath}
done
