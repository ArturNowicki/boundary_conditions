program main
    use error_codes
    use messages

    implicit none

    integer, parameter :: sp = selected_real_kind(6, 37)
    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, parameter :: max_len = 512
    integer, parameter :: in_x=600, in_y=640

    character(len=max_len) ssh_file, hu_file, s_file, t_file

    integer status
    integer ii, jj
    real(kind = dp), dimension(in_x, in_y) :: ssh, hu, s_bar, transp

    call read_input_parameters(ssh_file, hu_file, s_file, t_file, status)
    if(status .eq. -1) call handle_error(msg_missing_program_input_err, err_missing_program_input)

! read data
    call read_data(ssh_file, ssh, in_x, in_y)
    call read_data(hu_file, hu, in_x, in_y)
    call read_data(s_file, s_bar, in_x, in_y)
    transp = s_bar*(hu+ssh)
! write data
    open(102, file = trim(t_file), access = 'direct', status = 'replace', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    write(102, rec=1) transp
    close(102)

end program

subroutine read_data(in_file, in_var, in_x, in_y)
    implicit none
    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, intent(in) :: in_x, in_y
    character(len=512), intent(in) :: in_file
    real(kind = dp), dimension(in_x, in_y), intent(out) :: in_var
    open(101, file = trim(in_file), access = 'direct', status = 'old', &
        form = 'unformatted', convert = 'big_endian', recl = in_x*in_y*8)
    read(101, rec=1) in_var
    close(101)
end subroutine

subroutine read_input_parameters(ssh_file, hu_file, s_file, t_file, status)
    implicit none
    character(len=512), intent(out) :: ssh_file, hu_file, s_file, t_file
    integer, intent(out) :: status
    status = 0
    call getarg(1, ssh_file)
    call getarg(2, hu_file)
    call getarg(3, s_file)
    call getarg(4, t_file)
    if(ssh_file == '' .or. hu_file == '' .or. s_file == '' &
        .or. t_file == '') status = -1
end subroutine

subroutine handle_error(message, status)
    implicit none
    character(len=*), intent(in) :: message
    integer, intent(in) :: status
    write(*,*) trim(message)
    call exit(status)
end subroutine
