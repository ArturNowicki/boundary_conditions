program main
    use error_codes
    use messages

    implicit none

    integer, parameter :: sp = selected_real_kind(6, 37)
    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, parameter :: max_len = 512
    integer, parameter :: in_x=600, in_y=640, in_z=21

    character(len=max_len) in_path, in_f1, out_f1, f_name, thickness_file, kmt_file

    integer status
    integer ii, jj, kk, in_k
    real(kind = sp), dimension(in_z) :: thickness_array
    real(kind = dp), dimension(in_x, in_y, in_z) :: in_variable
    real(kind = dp), dimension(in_x, in_y) :: kmt, out_variable
    real(kind = dp) depth_sum

    call read_input_parameters(in_path, in_f1, out_f1, thickness_file, kmt_file, status)
    if(status .eq. -1) call handle_error(msg_missing_program_input_err, err_missing_program_input)

! read thickness array
    open(unit=101, file=thickness_file, status='old', action='read')
    read(101, *) thickness_array
    close(101)

! read kmt
    f_name = kmt_file
    open(102, file = trim(kmt_file), access = 'direct', status = 'old', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    read(102, rec=1) kmt
    close(102)

! read data
    f_name = trim(in_path)//trim(in_f1)
    open(103, file = trim(f_name), access = 'direct', status = 'old', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*in_z*8)
    read(103, rec=1) in_variable
    close(103)

    out_variable = 0
    do ii = 1, in_x
        do jj = 1, in_y
            in_k = int(kmt(ii,jj))
            depth_sum = 0
            do kk = 1, in_k
                out_variable(ii, jj) = out_variable(ii,jj) + &
                in_variable(ii, jj, kk)*thickness_array(kk)
                depth_sum = depth_sum + thickness_array(kk)
            enddo
            if(in_k.gt.0) then
                out_variable(ii, jj) = out_variable(ii, jj)/depth_sum
            endif
        enddo
    enddo
    where (kmt.eq.0)
        out_variable = in_variable(1,1,1)
    endwhere
! write data
    f_name = trim(in_path)//trim(out_f1)
    open(104, file = trim(f_name), access = 'direct', status = 'replace', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    write(104, rec=1) out_variable
    close(104)

end program

subroutine read_input_parameters(in_path, in_f1, out_f1, thickness_file, kmt_file, status)
    implicit none
    character(len=512), intent(out) :: in_path, in_f1, out_f1, thickness_file, kmt_file
    integer, intent(out) :: status
    status = 0
    call getarg(1, in_path)
    call getarg(2, in_f1)
    call getarg(3, out_f1)
    call getarg(4, thickness_file)
    call getarg(5, kmt_file)
    if(in_path == '' .or. in_f1 == '' .or. out_f1 == '' &
        .or. thickness_file == '' .or. kmt_file == '') status = -1
end subroutine

subroutine handle_error(message, status)
    implicit none
    character(len=*), intent(in) :: message
    integer, intent(in) :: status
    write(*,*) trim(message)
    call exit(status)
end subroutine
