program poissonSolver

    use error_codes
    use messages

    implicit none
!---------------------------------------------------
! Spreading restart data on entire grid using 
! poisson solver


    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, parameter :: max_len = 512

    !--- data arrays
    real*8, dimension(:, :, :), allocatable :: in_data1, in_data2, out_data, mask1, mask2
    integer i, j, k
    integer status
    integer in_x, in_y, in_z
    character(len=max_len) in_f1_name, in_f2_name, out_f_name, mask_f1_name, mask_f2_name
    character(len=5) in_xs, in_ys, in_zs
    call read_input_parameters(in_f1_name, in_f2_name, out_f_name, mask_f1_name, mask_f2_name, &
                               in_xs, in_ys, in_zs, status)
    if(status .eq. -1) call handle_error(msg_missing_program_input_err, err_missing_program_input)

    read(in_xs,*)  in_x
    read(in_ys,*)  in_y
    read(in_zs,*)  in_z

    allocate(in_data1(in_x, in_y, in_z))
    allocate(in_data2(in_x, in_y, in_z))
    allocate(out_data(in_x, in_y, in_z))
    allocate(mask1(in_x, in_y, in_z))
    allocate(mask2(in_x, in_y, in_z))

    open(101,file=trim(in_f1_name),form='unformatted',status='old', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)
    read(101, rec = 1) in_data1
    open(102,file=trim(in_f2_name),form='unformatted',status='old', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)
    read(102, rec = 1) in_data2
    close(102)

    open(103,file=trim(mask_f1_name),form='unformatted',status='old', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)
    read(103,rec=1) mask1
    close(103)
    open(104,file=trim(mask_f2_name),form='unformatted',status='old', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)
    read(104,rec=1) mask2
    close(104)


    open(105,file=trim(out_f_name),form='unformatted',status='replace', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)

    ! write(102, rec=1) out_data
    close(102)
end program

subroutine read_input_parameters(in_f1_name, in_f2_name, out_f_name, &
                                 mask_f1_name, mask_f2_name, &
                                 in_x, in_y, in_z, status)
    implicit none
    character(len=512), intent(out) :: in_f1_name, in_f2_name, out_f_name
    character(len=512), intent(out) :: mask_f1_name, mask_f2_name
    character(len=5), intent(out) :: in_x, in_y, in_z
    integer, intent(out) :: status
    status = 0
    call getarg(1, in_f1_name)
    call getarg(2, in_f2_name)
    call getarg(3, out_f_name)
    call getarg(4, mask_f1_name)
    call getarg(5, mask_f2_name)
    call getarg(6, in_x)
    call getarg(7, in_y)
    call getarg(8, in_z)
    if(in_f1_name == '' .or. in_f2_name == '' .or. out_f_name == '' .or. &
        mask_f1_name == '' .or. mask_f2_name == '' .or. &
        in_x == '' .or. in_y == '' .or. in_z == '') status = -1
end subroutine

subroutine handle_error(message, status)
    implicit none
    character(len=*), intent(in) :: message
    integer, intent(in) :: status
    write(*,*) trim(message)
    call exit(status)
end subroutine

