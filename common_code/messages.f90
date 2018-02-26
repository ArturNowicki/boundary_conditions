module messages
    implicit none
    character(len=512), parameter :: &
    msg_missing_program_input_err = "Wrong/missing input parameters", &
    msg_memory_alloc_err = "Error allocating memory", &
    msg_memory_dealloc_err = "Error deallocating memory"
end module messages