.section entry, "ax"
.global _start
.type _start, @function

_start:
    mv s0, zero
    la sp, _stack_pointer
    jal _trm_init