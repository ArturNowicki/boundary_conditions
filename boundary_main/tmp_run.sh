#!/bin/bash

source ../settings/settings.sh
if [[ $? -ne 0 ]]; then
	echo "Wrong parametters file."
	exit
fi

define_parameters

for in_fpath in ${input_data_dir}*${in_model_nc_prefix}*${in_add_mask}*'.nc'; do
	echo ${in_fpath}
done
