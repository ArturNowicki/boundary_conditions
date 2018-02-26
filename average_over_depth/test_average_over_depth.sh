#!/bin/bash
# Created by Artur Nowicki on 26.01.2018.
ok_status=0
err_missing_program_input=100
err_f_open=101
err_f_read=102
err_f_write=103
err_f_close=104
err_memory_alloc=105

in_path='../../data/boundary_conditions/tmp_bin_data/'
in_file1='2018-01-01-46800_UVEL_0600_0640_0021_0001.ieeer8'
out_file1='2018-01-01-68400_SU_0600_0640_0001_0001.ieeer8'
thickness_file='../../data/grids/2km/thickness_2km_600x640.txt'
kmt_file='../../data/grids/2km/kmt_2km.ieeer8'
bad_thickness_file='../../data/grids/2km/bad_thickness_file.txt'

source ./../common_code/assertions.sh
total_tests=0
failed_tests=0


echo "Compile program."
gfortran ../common_code/messages.f90 ../common_code/error_codes.f90 average_over_depth.f90 -o average_over_depth
if [[ $? -ne 0 ]]; then
	exit
fi

expected_error_code=${ok_status}
echo "-------------------------"
echo "Test missing all parameters"
./average_over_depth ${in_path} ${kmt_file}
assertNotEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test missing thickness_file"
./average_over_depth ${in_path} ${in_file1} ${out_file1} 'missing_file.txt' ${kmt_file}
assertNotEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test corrupted thickness_file"
./average_over_depth ${in_path} ${in_file1} ${out_file1} ${bad_thickness_file} ${kmt_file}
assertNotEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test read binary"
./average_over_depth ${in_path} 'bad_in_file.bin' ${out_file1} ${thickness_file} ${kmt_file}
assertNotEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test write binary"
./average_over_depth ${in_path} ${in_file1} 'bad/out_file.bin' ${thickness_file} ${kmt_file}
assertNotEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test all ok"
expected_error_code=${ok_status}
./average_over_depth ${in_path} ${in_file1} ${out_file1} ${thickness_file} ${kmt_file}
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo
echo "-------------------------"
echo "TESTING RESULTS:"
echo "Tests failed: ${failed_tests} out of ${total_tests}"

if [[ ${failed_tests} -ne 0 ]]; then
	exit
fi

echo "-------------------------"
echo "Start actual script:"

in_var1='VVEL'
in_var2='UVEL'
out_var1='SV'
out_var2='SU'
in_p_len=${#in_path}

# for in_f1 in ${in_path}*${in_var2}*; do
# 	# echo ${in_f1:0:23}
# 	in_file1=${in_f1:${in_p_len}}
# 	IFS='_' read -r date_time rest_f_name <<< "$in_file1"
# 	out_file1=${date_time}'_'${out_var2}${rest_f_name:4}
# 	echo "-------------------"
# 	echo ${in_file1} ${out_file1}
# 	./average_over_depth ${in_path} ${in_file1} ${out_file1} ${thickness_file} ${kmt_file}
# done