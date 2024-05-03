.data
down: .asciiz "\n"
input_string:   .space  50      # Array to store input string
array:          .space  200     # Array to store the converted value from input string to float
array_op:       .space  100     # Array to store operator ()+-*/^! and store index of the float array
array_temp:     .space  100     # A temp array to store operator for Shunting-yard algorithm
array_post:     .space  100     # An array to store expression in the postfix form
array_cal:      .space  100     # A calculated array from postfix array
b_float:        .word   0       # Count the number behind floating point
temp_float:     .float  0.0     # Temp float to convert from string
input_p: .asciiz "Please insert your expression or enter quit to end program: "
error_p: .asciiz "You inserted an invalid character in your expression"
result_p: .asciiz "Result: "
unbalanced_p: .asciiz "You inserted unbalanced parentheses in your expression"
quit_p: .asciiz "quit"
quit_c: .asciiz "You entered quit"
file_name: .asciiz "/Users/phongpham/Documents/Documents - PP's Mac/Ktmt/BTL/calc_log.txt"
buffer: .space 32
buffer_out: .space 32
tenf: .float 10.0
onef: .float 1.0
M:    .float 0.0
index: .word 0
length: .word 0
.text
begin:
    li $v0, 13 # system call for open file
    la $a0, file_name # output file name
    li $a1, 1 # Open for writing (flags are 0: read, 1: write) 
    li $a2, 0 # mode is ignored
    syscall # open a file ( file descriptor returned in $v0) 
    move $s6, $v0 # save the file descriptor
main:
    # Input prompt
    li $v0, 4
    la $a0, input_p
    syscall
    # Read user input
    li $v0, 8             
    la $a0, input_string  
    li $a1, 50            
    syscall
    # check if user want to quit
    j check_quit
not_quit:
    # If user don't want to quit, continue
    la $t0, input_string
    la $t2, array
    l.s $f1, tenf
    la $t8, array_op
    li $t9, 0
    li $t7, 0
    
read_loop:
    lb $t1, 0($t0)        
    beq $t1, 10, end_read  # If meet \n, finished reading
    # If meet floating point, jump to handle floating point
    beq $t1, 46, dot_found
    blt $t1, 48, not_digit # ASCII '0'
    bgt $t1, 57, not_digit # ASCII '9'

    # Convert asciiz to int, then convert to float
    subi $t1, $t1, 48      # Convert to int
    l.s $f10, temp_float   # Load temp
    mul.s $f10, $f10, $f1  # Mul by 10
    mtc1 $t1, $f11         # Move int to floating-point
    cvt.s.w $f11, $f11
    add.s $f10, $f10, $f11 # Add the current float to the temp value that mul by 10
    s.s $f10, temp_float   # Store the temp value back

    # Check the next character in input string
    lb $t5, 1($t0)         
    beq $t5, 46, continue_read
    blt $t5, 48, store_array # ASCII '0'
    bgt $t5, 57, store_array # ASCII '9'
    j continue_read
store_array:    
    # If the next character not number, store temp to array, reset temp
    l.s $f10, temp_float
    s.s $f10, 0($t2)
    addi $t2, $t2, 4
    ###
    sb $t9, 0($t8)
    addi $t9, $t9, 1
    addi $t8, $t8, 1
    addi $t7, $t7, 1
    #reset temp
    s.s $f0, temp_float
    j continue_read

dot_found:
    li $t6, 1              # counter
    lb $t5, -1($t0)
    beq $t5, 77, error     # if the previous character is M then error
    lb $t5, 1($t0)
    blt $t5, 48, error
    bgt $t5, 57, error     # if the next character is not a number then error
    addi $t0, $t0, 1       # skip the dot
dot_loop:
    lb $t5, 0($t0)
    
    blt $t5, 48, dot_end
    bgt $t5, 57, dot_end

    # Update the number behind the floating point with the same method
    subi $t5, $t5, 48
    lw $t4, b_float
    mul $t4, $t4, 10
    add $t4, $t4, $t5
    sw $t4, b_float
    mul $t6, $t6, 10       # Update counter
    addi $t0, $t0, 1       

    j dot_loop

dot_end:
    # Convert behind float and counter to float, then div behind float by counter
    lw $t4, b_float
    mtc1 $t4, $f4
    mtc1 $t6, $f6
    cvt.s.w $f4, $f4
    cvt.s.w $f6, $f6
    div.s $f4, $f4, $f6
    # Add temp float with the calculated behind float, the store to array
    l.s $f10, temp_float
    add.s $f10, $f10, $f4
    s.s $f10, 0($t2)
    addi $t2, $t2, 4
    ###
    sb $t9, 0($t8)
    addi $t9, $t9, 1
    addi $t8, $t8, 1
    addi $t7, $t7, 1
    #reset temp
    s.s $f0, temp_float
    #reset b
    li $t6, 0
    sw $t6, b_float
    j read_loop

not_digit:
    beq $t1, 40, ins_op
    beq $t1, 41, ins_op
    beq $t1, 42, ins_op
    beq $t1, 43, ins_op
    beq $t1, 45, ins_op
    beq $t1, 46, ins_op
    beq $t1, 47, ins_op
    beq $t1, 33, ins_op
    beq $t1, 77, ins_op
    beq $t1, 94, ins_op
    # If current character is not in the valid list, jump to error
error:    
    li $v0, 4
    la $a0, error_p
    syscall
    li $v0, 10             # syscall 10: exit
    syscall
    
ins_op:    
    sb $t1, 0($t8)
    addi $t8, $t8, 1
    addi $t7, $t7, 1
    addi $t0, $t0, 1       
    j read_loop

continue_read:
    addi $t0, $t0, 1       
    j read_loop

end_read:
    la $t1, input_string
    sub $t0, $t0, $t1
    sw $t0, length
    sw $t7, index
    lw $t0, index
    la $t1, array_op
    la $t3, array_post
    la $t4, array_temp
    li $t7, 0 # Counter for array temp
    li $t5, 0
shunting_yard:
    lb $t2, 0($t1)
    beqz $t0, end_shunting_yard
    blt $t2, 33, store_idx
    beq $t2, 40, store_open
    beq $t2, 41, store_close
    beq $t2, 42, store_mul	
    beq $t2, 43, store_add
    beq $t2, 45, store_sub
    beq $t2, 47, store_div
    beq $t2, 33, store_fac
    beq $t2, 77, store_ans
    beq $t2, 94, store_pow
    
store_idx:
    j push_to_post
store_open:
    li $t6, 0
    j push_to_temp
store_close:
    li $t6, 0
    subi $t4, $t4, 1
find_open:
    ###
    beqz $t7, unbalanced
    lb $t8, 0($t4)
    beq $t8, 40, open_found
    sb $t8, 0($t3)
    addi $t3, $t3, 1
    subi $t7, $t7, 1
    subi $t4, $t4, 1
    j find_open
open_found:
    addi $t1, $t1, 1
    subi $t7, $t7, 1
    subi $t0, $t0, 1
    j shunting_yard
store_mul:
    li $t6, 2
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post
store_add:
    li $t6, 1
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post
store_sub:
    li $t6, 1
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post
store_div:
    li $t6, 2
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post
store_fac:
    j push_to_post
store_ans:
    j push_to_post
store_pow:
    li $t6, 3
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post
pre_push_to_temp:
    addi $t4, $t4, 1
push_to_temp:
    addi $t5, $t6, 0  
    sb $t2, 0($t4)
    addi $t1, $t1, 1
    addi $t4, $t4, 1
    addi $t7, $t7, 1
    subi $t0, $t0, 1
    j shunting_yard 

push_to_post:
    sb $t2, 0($t3)
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    subi $t0, $t0, 1
    j shunting_yard 

pre_push_temp_to_post:
    subi $t4, $t4, 1
push_temp_to_post:
    beqz $t7, pre_push_to_temp
    lb $t8, 0($t4)
    j precedence
back:
    bgt $t6, $t5, pre_push_to_temp
    sb $t8, 0($t3)
    addi $t3, $t3, 1
    subi $t7, $t7, 1
    subi $t4, $t4, 1
    j push_temp_to_post
precedence:
    beq $t8, 42, tok_mul_div	
    beq $t8, 43, tok_add_sub
    beq $t8, 45, tok_add_sub
    beq $t8, 47, tok_mul_div
    beq $t8, 94, tok_pow
    li $t5, 0
    j back
tok_mul_div:
    li $t5, 2
    j back
tok_add_sub:
    li $t5, 1
    j back
 tok_pow:
    li $t5, 3
    j back   
end_shunting_yard:    
    bnez $t7, all_temp_to_post
    j calculate
all_temp_to_post:
    subi $t4, $t4, 1
move_loop:
    lb $t8, 0($t4)
    beq $t8, 40, unbalanced
    sb $t8, 0($t3)
    addi $t3, $t3, 1
    subi $t7, $t7, 1
    subi $t4, $t4, 1
    bnez  $t7, move_loop
    j calculate
unbalanced:
    li $v0, 4
    la $a0, unbalanced_p
    syscall
    li $v0, 10             # syscall 10: exit
    syscall
calculate:
    la $t0, array_post
    la $t1, array
    la $t2, array_cal
    # t3 cuoi post fix
read_postfix:    
    lb $t4, 0($t0)
    ###
    beq $t0, $t3, end_main
    blt $t4, 33, cal_idx
    beq $t4, 42, cal_mul	
    beq $t4, 43, cal_add
    beq $t4, 45, cal_sub
    beq $t4, 47, cal_div
    beq $t4, 33, cal_fac ##
    beq $t4, 77, cal_ans ##
    beq $t4, 94, cal_pow ##
cal_idx:
    mul $t4, $t4, 4
    l.s $f1, array($t4)
    s.s $f1, 0($t2)
    addi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_mul:
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    mul.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_add:
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    add.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_sub:
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    sub.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_div:
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    div.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_fac:
    l.s $f1, -4($t2)

    cvt.w.s $f3, $f1
    cvt.s.w $f4, $f3
    c.eq.s $f1, $f4
    bc1f error
    l.s $f3, onef
    l.s $f4, onef
    l.s $f5, onef
    
fac_loop:
    mul.s $f4, $f4, $f3
    c.eq.s $f1, $f3
    bc1t end_fac   
    add.s $f3, $f3, $f5
    j fac_loop
end_fac:
    s.s $f4, -4($t2)
    addi $t0, $t0, 1
    j read_postfix    
cal_ans:
    l.s $f1, M
    s.s $f1, 0($t2)
    addi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_pow:
    l.s $f1, -8($t2)
    l.s $f6, -8($t2)
    l.s $f2, -4($t2)

    cvt.w.s $f3, $f2
    cvt.s.w $f4, $f3
    c.eq.s $f2, $f4
    bc1f error
    l.s $f3, onef
    l.s $f4, onef
pow_loop:
    mul.s $f1, $f1, $f6
    add.s $f4, $f4, $f3
    c.eq.s $f2, $f4
    bc1t end_pow
    j pow_loop
end_pow:
    s.s $f1, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
                    
end_main:
    li $v0, 4
    la $a0, result_p
    syscall
    la $t1, array_cal
    l.s $f1, 0($t1)
    li $v0, 2
    mov.s $f12, $f1
    syscall
    s.s $f1, M
    li $v0, 4
    la $a0, down
    syscall
    lw $t9, length
    addi $t9, $t9, 1
    li $v0, 15 # system call for write to file     
    move $a0, $s6 # file descriptor
    la $a1 , input_string # address of buffer from which to write 
    move $a2 , $t9 # hardcoded buffer length
    syscall # write to file
    l.s $f10, tenf
    li $t0, 0	
float_to_string:
    cvt.w.s $f3, $f1
    cvt.s.w $f4, $f3
    c.eq.s $f1, $f4
    li $v0, 2
    mov.s $f12, $f4
    syscall
    bc1t end_float_to_string
    mul.s $f1, $f1, $f10
    addi $t0, $t0, 1
    j float_to_string
end_float_to_string:
    cvt.w.s $f3, $f1
    mfc1 $t1, $f3
    addi $t3, $zero, 10 # Load divisor (10)
    addi $t4, $zero, 0  # Initialize index for buffer
divide_loop:
    div $t1, $t3        # Divide integer by 10
    mfhi $t5            # Remainder stored in $t3
    addi $t5, $t5, 48   # Convert remainder to ASCII
    sb $t5, buffer($t4) # Store ASCII character in buffer
    addi $t4, $t4, 1    # Increment buffer index

    mflo $t1            # Quotient stored in $t0
    bnez $t1, divide_loop
    subi $t4, $t4, 1
    li $t6, 0
    li $t7, 0
swap_loop:
    lb $t5, buffer($t4)
    sb $t5, buffer_out($t6)
    addi $t6, $t6, 1
    beqz $t4, end_swap
    beq $t6, $t0, add_dot
    subi $t4, $t4, 1
    addi $t7, $t7, 1
    j swap_loop
add_dot:
    li $t5, 46
    sb $t5, buffer_out($t6)
    addi $t6, $t6, 1
    subi $t4, $t4, 1
    j swap_loop
end_swap:
    li $v0, 15 # system call for write to file     
    move $a0, $s6 # file descriptor
    la $a1 , buffer_out # address of buffer from which to write 
    move $a2 , $t6 # hardcoded buffer length
    syscall # write to file
    j main
check_quit:
    ###
    la $t0, input_string
    la $t1, quit_p
    lb $t2, 0($t0)   
    lb $t3, 0($t1)   

    beqz $t2, not_quit  # Kết thúc vòng lặp nếu gặp ký tự kết thúc chuỗi ('\0')
    bne $t2, $t3, not_quit  # Nếu ký tự không khớp, thoát khỏi vòng lặp
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j quit
quit:
    li $v0, 4
    la $a0, quit_c
    syscall
end_program:
li $v0, 16 # system call for close file
move $a0 , $s6 # f i l e descriptor to close
syscall # close file
    li $v0, 10             # syscall 10: exit
    syscall
