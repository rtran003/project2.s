.globl main
.equ STDOUT, 1
.equ STDIN, 0
.equ __NR_READ, 63
.equ __NR_WRITE, 64
.equ __NR_EXIT, 93

.text
main:
    # main() prolog
    addi sp, sp, -24
    sw ra, 20(sp)

    # main() body
    li a7, __NR_WRITE  # Syscall for write
    li a0, STDOUT      # File descriptor (stdout)
    la a1, prompt      # Address of prompt
    li a2, prompt_end - prompt  # Calculate length of prompt
    ecall

    la a0, buf         # Load buffer address into a0
    call gets          # Read input

    la a0, buf         # Load buffer address into a0 again
    call puts          # Print input

    # main() epilog
    lw ra, 20(sp)
    addi sp, sp, 24
    ret

.space 12288

sekret_fn:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, sekret_data
    call puts
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

##############################################################
# Implementations of puts() and gets()
##############################################################

# gets Function (reads input into buffer in a0)
gets:
    addi sp, sp, -16            # Allocate stack space
    sw ra, 12(sp)               # Save return address

    mv a1, a0                   # Store buffer address in a1
    read_loop:
        li a7, __NR_READ        # Syscall for read
        li a0, STDIN            # File descriptor (stdin)
        mv a1, a1               # Address of buffer
        li a2, 1                # Read 1 byte at a time
        ecall                   # Invoke syscall

        blez a0, end_read       # Exit if read fails (EOF case)

        lb t1, 0(a1)            # Load the read character
        addi a1, a1, 1          # Move buffer pointer

        li t2, 0x0A             # Check for newline
        beq t1, t2, end_read

        j read_loop             # Continue reading

    end_read:
    sb zero, 0(a1)              # Null-terminate the string
    sub a0, a1, a0              # Return length of string

    lw ra, 12(sp)               # Restore return address
    addi sp, sp, 16             # Deallocate stack space
    ret                         # Return

# puts Function (prints string stored in a0)
puts:
    addi sp, sp, -16            # Allocate stack space
    sw ra, 12(sp)               # Save return address

    mv a1, a0                   # Store string address in a1
    print_loop:
        lb t1, 0(a1)            # Load a character
        beqz t1, end_puts       # Stop if null terminator
        li a7, __NR_WRITE       # Syscall for write
        li a0, STDOUT           # File descriptor (stdout)
        mv a1, a1               # Character address
        li a2, 1                # Write one character
        ecall                   # Invoke syscall

        addi a1, a1, 1          # Move to next character
        j print_loop            # Repeat

    end_puts:
    la a1, newline              # Address of newline string
    li a7, __NR_WRITE           # Syscall for write
    li a0, STDOUT               # File descriptor
    li a2, 1                    # Write 1 byte ('\n')
    ecall                       # Invoke syscall

    lw ra, 12(sp)               # Restore return address
    addi sp, sp, 16             # Deallocate stack space
    ret                         # Return

.data
prompt:   .ascii  "Enter a message: "
prompt_end:

.word 0
sekret_data:
.word 0x73564753, 0x67384762, 0x79393256, 0x3D514762, 0x0000000A
newline:  .asciz "\n"  # Newline string
buf:      .space 100  # Buffer for input
