module error_codes
    implicit none
    integer, parameter :: &
        err_missing_program_input=100, &
        err_f_open=101, &
        err_f_read=102, &
        err_f_write=103, &
        err_f_close=104, &
        err_memory_alloc=105
end module error_codes