program poissonSolver

    use error_codes
    use messages

    implicit none
!---------------------------------------------------
! Spreading restart data on entire grid using 
! poisson solver


    integer, parameter :: dp = selected_real_kind(15, 307)
    integer, parameter :: max_len = 512
    integer, parameter :: ms = 1000, grid_type = 1
    real(kind=dp), parameter :: ct = 1.e-5

    !--- data arrays
    real*8, dimension(:, :, :), allocatable :: in_data, out_data, mask
    real*8, dimension(:, :), allocatable :: jnk, ilevmsk, sor, res
    real*8 tmp_sum, mean_val
    integer i, j, zctr, z_lev
    integer status
    integer in_x, in_y, in_z
    character(len=max_len) in_f_name, out_f_name, mask_f_name
    character(len=5) in_xs, in_ys, in_zs
    call read_input_parameters(in_f_name, out_f_name, mask_f_name, in_xs, in_ys, in_zs, status)
    if(status .eq. -1) call handle_error(msg_missing_program_input_err, err_missing_program_input)

    read(in_xs,*)  in_x
    read(in_ys,*)  in_y
    read(in_zs,*)  in_z

    allocate(in_data(in_x, in_y, in_z))
    allocate(out_data(in_x, in_y, in_z))
    allocate(mask(in_x, in_y, in_z))
    allocate(jnk(in_x, in_y))
    allocate(ilevmsk(in_x, in_y))
    allocate(sor(in_x, in_y))
    allocate(res(in_x, in_y))

    open(101,file=trim(in_f_name),form='unformatted',status='old', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)
    read(101, rec = 1) in_data
    close(101)
    open(102,file=trim(out_f_name),form='unformatted',status='replace', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)
    open(103,file=trim(mask_f_name),form='unformatted',status='old', & 
          convert='big_endian',access='direct',recl=in_x*in_y*in_z*8)
    read(103,rec=1) mask
    close(103)
!----- read in data
    do z_lev=1,in_z
        ilevmsk(:,:) = 1
        jnk(:,:) = dble(in_data(:,:, z_lev))

        zctr=0
        tmp_sum=0.
        mean_val=0.
        do j = 55, 95
          do i = 310, 380
            if(mask(i,j,z_lev).eq.1) then
              zctr=zctr+1
              tmp_sum=tmp_sum+jnk(i,j)
            endif
          enddo
        enddo
        if(zctr.ne.0) then
            mean_val=tmp_sum/dble(zctr)
        endif
        where(mask(:,:,z_lev).ne.1)
          jnk = mean_val
          ilevmsk = 0
        endwhere
        !data extrapolation using poisson solver
        call extrap(jnk,ilevmsk,sor,res,in_x,in_y,ms,ct,'restart data',grid_type)
        out_data(:, :, z_lev) = jnk
    enddo
    if(index(mask_f_name, 'bay') .ne. 0) then
      do z_lev = 10,in_z
        out_data(:,:,z_lev) = out_data(:,:,z_lev-1)
      enddo
    endif

    write(102, rec=1) out_data
    close(102)
end program

subroutine read_input_parameters(in_f_name, out_f_name, mask_f_name, in_x, in_y, in_z, status)
    implicit none
    character(len=512), intent(out) :: in_f_name, out_f_name, mask_f_name
    character(len=5), intent(out) :: in_x, in_y, in_z
    integer, intent(out) :: status
    status = 0
    call getarg(1, in_f_name)
    call getarg(2, out_f_name)
    call getarg(3, mask_f_name)
    call getarg(4, in_x)
    call getarg(5, in_y)
    call getarg(6, in_z)
    if(in_f_name == '' .or. out_f_name == '' .or. mask_f_name == '' .or. &
        in_x == '' .or. in_y == '' .or. in_z == '') status = -1
end subroutine

subroutine handle_error(message, status)
    implicit none
    character(len=*), intent(in) :: message
    integer, intent(in) :: status
    write(*,*) trim(message)
    call exit(status)
end subroutine




      subroutine extrap (a, land, sor, res, il, jl, maxscn, crit, text, gtype)
    implicit none
!    inputs:

!    a       = array with land areas to be filled. land areas contain
!              initial guess field.
!    land    = mask = (0, non zero) to indicate (land, non land) area
!    il      = number of points along 1st dimension to be filled
!    jl      = number of points along 2nd dimension to be filled
!    maxscn  = maximum number of passes allowed in relaxation
!    crit    = criterion for ending relaxation before "maxscn" limit
!    text    = character string (up to 15 chars) to identify data
!    gtype   = grid type = (1,2) to identify (ocean, atmosphere) grid
!    sor     = scratch area
!    res     = scratch area


!    outputs:

!    a       = array with extrapolated values in land areas.
!              non land areas remain unchanged.

!    author:      r. c. pacanowski      e-mail=> rcp@gfdl.gov
!=======================================================================

      logical done
!#include "stdunits.h"
      integer :: gtype
      character*(*) :: text
      real*8, parameter :: c0=0.0, p25=0.25
      real*8, dimension(il,jl) :: a, land, res, sor
      integer i,j,il,jl,n, maxscn
      real*8 :: relc, crit, absres,resmax, minres, maxres, neighbours

!-----------------------------------------------------------------------

!    solve a simple poisson eqn by relaxation to extrapolate data into
!    land areas using values over non land areas as boundary values.

!    note: sucessive calls to extrap will require fewer scans beacuse
!          the initial guess field over land areas gets better with
!          each call.
!-----------------------------------------------------------------------
!    check on the grid type: atmosphere or ocean

      if (gtype .ne. 1 .and. gtype .ne. 2) then
        write (6,98) gtype
        stop '=>extrap'
      endif     

!-----------------------------------------------------------------------
!    set the relaxation coefficient to zero over ocean or air
!    relc is somewhat arbitrary
!-----------------------------------------------------------------------

      relc = 0.6
      do j=1,jl
        do i=1,il
              if (land(i,j) .eq. 0) then
                sor(i,j) = relc
              else
                sor(i,j) = c0
              endif
        enddo
      enddo

!-----------------------------------------------------------------------
!    iterate until errors are acceptable.
!-----------------------------------------------------------------------
    
      n = 0
100   continue
        resmax = c0
        done   = .true.
        n    = n + 1
        do j=2,jl-1
          do i=2,il-1
              res(i,j) = p25*(a(i-1,j) + a(i+1,j) + a(i,j-1) + a(i,j+1)) - a(i,j)
          enddo
        enddo
        res = res * sor
        a = a + res
        maxres = maxval(res)
        minres = minval(res)
        absres = max(-minres, maxres)
        if (absres .gt. crit) done = .false.
        resmax = max(absres,resmax)
        ! do j=2,jl-1
        !   do i=2,il-1
        !     res(i,j) = res(i,j)*sor(i,j)
        !     a(i,j) = a(i,j) + res(i,j)
        !     absres = abs(res(i,j))
        !     if (absres .gt. crit) done = .false.
        !     resmax = max(absres,resmax)
        !   enddo
        ! enddo

!-----------------------------------------------------------------------
!      set conditions at edge of grid
!-----------------------------------------------------------------------

        if (gtype .eq. 10) then

!        use cyclic or no flux conditions on ocean grids

          do j=1,jl
            a(1,j)  = a(il-1,j)
            a(il,j) = a(2,j)

          enddo
        elseif (gtype .eq. 20) then

!        always put cyclic conditions on atmosphere grids

          do j=1,jl
            a(1,j)  = a(il-1,j)
            a(il,j) = a(2,j)
          enddo
        endif

!      no flux condition at northern and southern boundaries

        do i=1,il
          a(i,1)  = a(i,2)
          a(i,jl) = a(i,jl-1)
          enddo

      if (.not. done .and. n .le. maxscn) go to 100

      ! write (6,99) text, n, resmax

   
99    format (1x,'==> Extrapolated ',a15,' into land using ', i4, &
' scans.  max residual=', g14.7)
98    format (1x,'==> Error:   gtype =',i6,' in extrap')


      return
      
      end


