.globl main 
.equ STDOUT, 1
.equ STDIN, 0
.equ __NR_READ, 63
.equ __NR_WRITE, 64
.equ __NR_EXIT, 93

.text
main:
	# main() prolog
	addi sp, sp, -24        # 20 bytes buffer + 4 bytes for saved ra
	sw ra, 20(sp)           # Save return address just above buffer

	# print prompt
	la a0, prompt
	call puts

	# buffer is at sp
	mv a0, sp
	call gets

	# print what user typed
	mv a0, sp
	call puts

	# epilog: restore and return
	lw ra, 20(sp)           # Load possibly overwritten return address
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
# puts(), gets(), getchar(), putchar()
##############################################################

getchar:
    addi sp, sp, -4         
    sw x0, 0(sp)            

    li a0, STDIN            
    addi a1, sp, 0          
    li a2, 1                
    li a7, __NR_READ        
    ecall                   

    lw a0, 0(sp)            
    addi sp, sp, 4          
    ret

puts:
    addi sp, sp, -8          
    sw ra, 4(sp)             
    mv t0, a0                

puts_loop:
    lb a0, 0(t0)             
    beq a0, x0, puts_exit    
    jal putchar              
    addi t0, t0, 1           
    j puts_loop              

puts_exit:
    li a0, 10                
    jal putchar              
    li a0, 0                 
    lw ra, 4(sp)             
    addi sp, sp, 8           
    ret

putchar:
    addi sp, sp, -1          
    sb a0, 0(sp)             

    li a0, STDOUT            
    addi a1, sp, 0           
    li a2, 1                 
    li a7, __NR_WRITE        
    ecall                   

    lbu a0, 0(sp)            
    addi sp, sp, 1           
    ret

gets:
    addi sp, sp, -12         
    sw ra, 8(sp)             
    sw a0, 4(sp)             

    mv t0, a0                

gets_loop:
    sw t0, 0(sp)             
    jal getchar              
    lw t0, 0(sp)             

    blt a0, x0, gets_exit
    sb a0, 0(t0)             
    addi t0, t0, 1           

    li t1, 10
    bne a0, t1, gets_loop    

    sb x0, 0(t0)             
    lw a0, 4(sp)             
    sub a0, t0, a0           

gets_exit:
    lw ra, 8(sp)             
    addi sp, sp, 12          
    ret

.data
prompt:   .ascii  "Enter a message: "
prompt_end:

.word 0
sekret_data:
.word 0x73564753, 0x67384762, 0x79393256, 0x3D514762, 0x0000000A
