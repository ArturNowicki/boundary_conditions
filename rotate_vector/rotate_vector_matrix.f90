program main

    use error_codes
    use messages

    implicit none

    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, parameter :: max_len = 512
    integer, parameter :: in_x=600, in_y=640

    real(kind=dp), dimension(in_x, in_y) :: kmt
    real(kind=dp), dimension(in_x, in_y) :: in_v1, in_v2, out_v1, out_v2, angles1
    character(len=max_len) f1in_name, f2in_name, f1out_name, f2out_name, f1_angles, f_kmt
    integer ii, jj
    integer status
    real(kind=dp) tmp_val

    call read_input_parameters(f1in_name, f2in_name, f1out_name, f2out_name, f1_angles, f_kmt, status)
    if(status .eq. -1) call handle_error(msg_missing_program_input_err, err_missing_program_input)

! read vector 1st component
    open(101, file = trim(f1in_name), access = 'direct', status = 'old', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    read(101, rec=1) in_v1
    close(101)
! read vector 2nd component
    open(102, file = trim(f2in_name), access = 'direct', status = 'old', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    read(102, rec=1) in_v2
    close(102)
! read input angles
    open(103, file = trim(f1_angles), access = 'direct', status = 'old', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    read(103, rec=1) angles1
    close(103)
! read input angles
    open(104, file = trim(f_kmt), access = 'direct', status = 'old', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    read(104, rec=1) kmt
    close(104)

    tmp_val = in_v1(1,1)
    do ii=1, in_x
        do jj=1, in_y
            out_v1(ii,jj) = in_v1(ii,jj)*cos(angles1(ii,jj)) - in_v2(ii,jj)*sin(angles1(ii,jj))
            out_v2(ii,jj) = in_v1(ii,jj)*sin(angles1(ii,jj)) + in_v2(ii,jj)*cos(angles1(ii,jj))
        enddo
    enddo

    where(kmt.eq.0)
        out_v1 = tmp_val
        out_v2 = tmp_val
    endwhere

! write vector 1st component
    open(105, file = trim(f1out_name), access = 'direct', status = 'replace', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    write(105, rec=1) out_v1
    close(105)
! write vector 2nd component
    open(106, file = trim(f2out_name), access = 'direct', status = 'replace', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    write(106, rec=1) out_v2
    close(106)

end program

subroutine read_input_parameters(f1in_name, f2in_name, f1out_name, f2out_name, f1_angles, f_kmt, status)
    implicit none
    character(len=512), intent(out) :: f1in_name, f2in_name, f1out_name, f2out_name, f1_angles, f_kmt
    integer, intent(out) :: status
    status = 0
    call getarg(1, f1in_name)
    call getarg(2, f2in_name)
    call getarg(3, f1out_name)
    call getarg(4, f2out_name)
    call getarg(5, f1_angles)
    call getarg(6, f_kmt)
    if(f1in_name == '' .or. f2in_name == '' &
        .or. f1out_name == '' .or. f2out_name == '' &
        .or. f1_angles == '' .or. f_kmt == '') status = -1
end subroutine

subroutine handle_error(message, status)
    implicit none
    character(len=*), intent(in) :: message
    integer, intent(in) :: status
    write(*,*) trim(message)
    call exit(status)
end subroutine

