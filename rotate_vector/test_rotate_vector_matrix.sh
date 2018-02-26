#!/bin/bash
# Created by Artur Nowicki on 18.01.2018.

# Program error codes:
ok_status=0
err_missing_program_input=100
err_f_open=101
err_f_read=102
err_f_write=103
err_f_close=104
err_memory_alloc=105

source ./../common_code/assertions.sh
total_tests=0
failed_tests=0

in_file1='../../data/boundary_conditions/tmp_bin_data/2018-01-01-68400_SU_0600_0640_0001_0001.ieeer8'
in_file2='../../data/boundary_conditions/tmp_bin_data/2018-01-01-68400_SV_0600_0640_0001_0001.ieeer8'

out_file1='../../data/boundary_conditions/tmp_bin_data/2018-01-01-68400_SU_ROT_0600_0640_0001_0001.ieeer8'
out_file2='../../data/boundary_conditions/tmp_bin_data/2018-01-01-68400_SV_ROT_0600_0640_0001_0001.ieeer8'

angle_file1='../../data/grids/2km/anglet_2km.ieeer8'
kmt_file='../../data/grids/2km/kmt_2km.ieeer8'


echo "Compile program."
gfortran ../common_code/messages.f90 ../common_code/error_codes.f90 rotate_vector_matrix.f90 -o rotate_vector_matrix
if [[ $? -ne 0 ]]; then
	exit
fi

echo "-------------------------"
echo "Test missing parameters"
expected_error_code=${err_missing_program_input}
./rotate_vector_matrix ${in_file1} ${in_file2} ${out_file1} ${out_file2}
assertEquals ${expected_error_code} $?
failed_tests=$((failed_tests+$?))
total_tests=$((total_tests+1))

echo "-------------------------"
echo "Test all ok"
expected_error_code=${ok_status}
./rotate_vector_matrix ${in_file1} ${in_file2} ${out_file1} ${out_file2} ${angle_file1} ${kmt_file}
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

