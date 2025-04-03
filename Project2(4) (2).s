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
	la a0, prompt
	call puts

	mv a0, sp
	call gets

	mv a0, sp
	call puts

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
# Add your implementation of puts() and gets() below here
##############################################################

getchar:
    # Prolog: no need to save stack items (leaf procedure)
    addi sp, sp, -4         # Adjust stack to make room for 1 word
    sw x0, 0(sp)            # Zero out the stack space

    li a0, STDIN            # Load STDIN code into a0
    addi a1, sp, 0          # Load address of the buffer into a1
    li a2, 1                # We want to read 1 byte (1 character)
    li a7, __NR_READ        # System call for reading (read system call)
    ecall                   # Execute system call

    lw a0, 0(sp)            # Load the character we just read into a0
    addi sp, sp, 4          # Restore stack pointer
    ret

puts:
    # Prolog
    addi sp, sp, -8          # Make room for 2 items on the stack
    sw ra, 4(sp)             # Save return address (ra) into stack
    mv t0, a0                # Copy string pointer to t0 (local pointer)

puts_loop:
    lb a0, 0(t0)             # Load byte from string into a0
    beq a0, x0, puts_exit    # If it's a null terminator, exit
    jal putchar              # Call putchar to print the character
    addi t0, t0, 1           # Move to the next character
    j puts_loop              # Continue loop

puts_exit:
    li a0, 10                # Put newline character (ASCII 10)
    jal putchar              # Print newline
    li a0, 0                 # Return 0 (successful execution)
    lw ra, 4(sp)             # Restore return address (ra)
    addi sp, sp, 8           # Restore stack pointer
    ret

putchar:
    # Prolog: leaf procedure
    addi sp, sp, -1          # Adjust stack by 1 byte
    sb a0, 0(sp)             # Store the character into stack

    li a0, STDOUT            # Load STDOUT code into a0
    addi a1, sp, 0           # Load address of the buffer into a1
    li a2, 1                 # We want to write 1 byte
    li a7, __NR_WRITE        # System call for writing (write system call)
    ecall                   # Execute system call

    lbu a0, 0(sp)            # Load the character we just wrote back into a0
    addi sp, sp, 1           # Restore stack pointer
    ret

gets:
    # Prolog: a0 contains addr pointer s
    addi sp, sp, -12         # Make room for 3 items on the stack
    sw ra, 8(sp)             # Save return address (ra)
    sw a0, 4(sp)             # Save the address of the buffer (s)

    # Body
    mv t0, a0                # Copy buffer address to t0 (local pointer)

gets_loop:
    sw t0, 0(sp)             # Save the buffer pointer into stack
    jal getchar              # Call getchar to read a character
    lw t0, 0(sp)             # Restore the buffer pointer from stack

    # If the read-in char is negative, exit the loop (end of input)
    blt a0, x0, gets_exit
    sb a0, 0(t0)             # Store the character in the buffer
    addi t0, t0, 1           # Increment the buffer pointer

    # Check for newline (ASCII 10) character
    li t1, 10
    bne a0, t1, gets_loop    # If not newline, continue reading

    sb x0, 0(t0)             # Null-terminate the string
    lw a0, 4(sp)             # Load the original buffer pointer into a0
    sub a0, t0, a0           # Return the length of the string

gets_exit:
    lw ra, 8(sp)             # Restore return address (ra)
    addi sp, sp, 12          # Restore stack pointer
    ret



.data
prompt:   .ascii  "Enter a message: "
prompt_end:

.word 0
sekret_data:
.word 0x73564753, 0x67384762, 0x79393256, 0x3D514762, 0x0000000A