.data
down: .asciiz "\n"
		.align 2
input_string:   .space  256      # Array to store input string
		.align 2
array:          .space  256     # Array to store the converted value from input string to float
		.align 2
array_op:       .space  256     # Array to store operator ()+-*/^! and store index of the float array
		.align 2
array_temp:     .space  256     # A temp array to store operator for Shunting-yard algorithm
		.align 2
array_post:     .space  256     # An array to store expression in the postfix form
		.align 2
array_cal:      .space  256     # A calculated array from postfix array
b_float:        .word   0       # Count the number behind floating point
temp_float:     .float  0.0     # Temp float to convert from string
input_p: .asciiz "Please insert your expression or enter quit to end program: "
error_p: .asciiz "You inserted an invalid character in your expression\n"
result_p: .asciiz "Result: "
unbalanced_p: .asciiz "You inserted unbalanced parentheses in your expression\n"
quit_p: .asciiz "quit"
quit_c: .asciiz "You entered quit\n"
quit_program: .asciiz "Quiting program"
again_p: .asciiz "Please insert your expression again"
file_name: .asciiz "/Users/phongpham/Documents/Documents - PP's Mac/Ktmt/BTL/calc_log.txt"
buffer: .space 32
buffer_out: .space 32
buffer_f: .space 32
tenf: .float 10.0
onef: .float 1.0
M:    .float 0.0
index: .word 0
length: .word 0
neg_one: .float -1.0
.text
begin:
    # Open file
    li $v0, 13 
    la $a0, file_name 
    li $a1, 1 
    li $a2, 0 
    syscall 
    move $s6, $v0 
    
main:
    # Input prompt
    li $v0, 54
    la $a0, input_p
    la $a1, input_string  
    li $a2, 64            
    syscall
    beq $a1, -2, end_program
    li $v0, 15     
    move $a0, $s6 
    la $a1 , input_p 
    li $a2 , 60
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
    li $v0, 59
    la $a0, error_p
    la $a1, again_p
    syscall
    
    li $v0, 15     
    move $a0, $s6 
    la $a1 , down
    li $a2 , 1
    syscall
    
    li $v0, 15     
    move $a0, $s6 
    la $a1 , error_p 
    li $a2 , 53
    syscall 
    
    li $v0, 15     
    move $a0, $s6 
    la $a1 , down
    li $a2 , 1
    syscall 
    
    j main
    
ins_op:    
    sb $t1, 0($t8)         	# insert valid operator to array
    addi $t8, $t8, 1
    addi $t7, $t7, 1       
    addi $t0, $t0, 1       
    j read_loop

continue_read:
    addi $t0, $t0, 1       
    j read_loop

end_read:                  	# prepare 1 stack of array temp, and 1 array of postfix form
    la $t1, input_string
    sub $t0, $t0, $t1
    sw $t0, length
    sw $t7, index
    lw $t0, index
    la $t1, array_op
    la $t3, array_post
    la $t4, array_temp
    li $t7, 0 			# Counter for array temp
    li $t5, 0
    
shunting_yard:             	# start the algorithm
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
    j push_to_post         	# if it is an index, push directly to postfix array
    
store_open:                	# if it is an open bracket, set priority to 0 then push diretly to temp stack
    li $t6, 0
    j push_to_temp
    
store_close:               	# if it is an close bracket, set priority to 0 then pop every operator in the temp stack to push the postfix array until see an open bracket
    li $t6, 0
    subi $t4, $t4, 1
find_open:
    ###
    beqz $t7, unbalanced   	# reach the end of the stack but no open found, then it is an error
    lb $t8, 0($t4)
    beq $t8, 40, open_found	# countinue the algorithm
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
    li $t6, 2			# set priority to 2
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post	# if the current priority is greater than the previous, we push it to temp, else we push all the smaller or equal priority to post
    
store_add:
    li $t6, 1			# set priority to 2
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post	# if the current priority is greater than the previous, we push it to temp, else we push all the smaller or equal priority to post
    
store_sub:
    la $a2, array_op		# check if the current sub operator is unary or not
    beq $a2, $t1, unary
    lb $a1, -1($t1)
    beq $a1, 40, unary
    beq $a1, 42, unary	
    beq $a1, 43, unary
    beq $a1, 45, unary
    beq $a1, 47, unary
    # beq $a1, 94, unary_pow	# further extension
    li $t6, 1
    bgt $t6, $t5, push_to_temp	# if not, do the same as addition operator
    j pre_push_temp_to_post
unary:				# if it is an unary operator, we change it to *-1, push -1 to postfix array, and push * to temp as normal
    li $s1, -1
    sb $s1, 0($t3)
    li $s2, 42
    sb $s2, 0($t4)
    li $t5, 2			# set priority of * to 2
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    subi $t0, $t0, 1
    addi $t4, $t4, 1
    addi $t7, $t7, 1
    j shunting_yard
    
store_div:			# do as mul operator
    li $t6, 2
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post
    
store_fac:			# ! has the highest priority so push directly to postfix 
    j push_to_post
    
store_ans:			# treat M as a normal number
    j push_to_post
    
store_pow:			# set priority to 3 then compare and do the same
    li $t6, 3
    bgt $t6, $t5, push_to_temp
    j pre_push_temp_to_post
    
pre_push_to_temp:		# set back the current pointer to new data to push
    addi $t4, $t4, 1
push_to_temp:			# push to temp stack, update the previous to the current priority
    addi $t5, $t6, 0  
    sb $t2, 0($t4)
    addi $t1, $t1, 1
    addi $t4, $t4, 1
    addi $t7, $t7, 1
    subi $t0, $t0, 1
    j shunting_yard 

push_to_post:			# push to postfix array
    sb $t2, 0($t3)
    addi $t1, $t1, 1
    addi $t3, $t3, 1
    subi $t0, $t0, 1
    j shunting_yard 

pre_push_temp_to_post:		# move back the pointer to get operator
    subi $t4, $t4, 1
push_temp_to_post:		
    beqz $t7, pre_push_to_temp	# re-check if the current stack is null or not
    lb $t8, 0($t4)
    j precedence		# find the priority of the current operator
back:				# label to go back
    bgt $t6, $t5, pre_push_to_temp	#if greater priority, add the pointer to new to push to temp
    sb $t8, 0($t3)		# if smaller or equal priority, continue pop the temp stack to push to postfix
    addi $t3, $t3, 1
    subi $t7, $t7, 1
    subi $t4, $t4, 1
    j push_temp_to_post		# loop to check next operator in stack
precedence:			# get priority to return to back
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
    
end_shunting_yard:    		# end, if the stack not null, pop it to push to postfix
    bnez $t7, all_temp_to_post
    j calculate
all_temp_to_post:
    subi $t4, $t4, 1
move_loop:
    lb $t8, 0($t4)
    beq $t8, 40, unbalanced	# if we found an open bracket left in temp, it means missing close brack to delete open bracket
    sb $t8, 0($t3)
    addi $t3, $t3, 1
    subi $t7, $t7, 1
    subi $t4, $t4, 1
    bnez  $t7, move_loop
    j calculate			# if the stack is null, go to calculate the postfix
    
unbalanced:			# handle unblanced brackets and jump back to main
    li $v0, 59
    la $a0, unbalanced_p
    la $a1, again_p
    syscall
    
    lw $t9, length
    addi $t9, $t9, 1
    li $v0, 15    
    move $a0, $s6 
    la $a1 , input_string
    move $a2 , $t9 
    syscall 
    
    li $v0, 15     
    move $a0, $s6 
    la $a1 , unbalanced_p 
    li $a2 , 55
    syscall 
    
    li $v0, 15     
    move $a0, $s6 
    la $a1 , down
    li $a2 , 1
    syscall 
    
    j main
    
calculate:
    la $t0, array_post
    la $t1, array
    la $t2, array_cal		# treat as a stack
    				# t3 is the final address of the postfix array
read_postfix:    
    lb $t4, 0($t0)
    ###
    beq $t0, $t3, end_main	# reached the final address
    beq $t4, -1, cal_neg
    blt $t4, 33, cal_idx
    beq $t4, 42, cal_mul	
    beq $t4, 43, cal_add
    beq $t4, 45, cal_sub
    beq $t4, 47, cal_div
    beq $t4, 33, cal_fac ##
    beq $t4, 77, cal_ans ##
    beq $t4, 94, cal_pow ##
cal_neg:			# load -1.0 to push to cal array
    l.s $f1, neg_one
    s.s $f1, 0($t2)
    addi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_idx:			# use the index to find the value in float array, then push to cal array
    mul $t4, $t4, 4
    l.s $f1, array($t4)
    s.s $f1, 0($t2)
    addi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_mul:			# binary operator, pop 2 previous in cal array, calculate then push
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    mul.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_add:			# binary operator, pop 2 previous in cal array, calculate then push
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    add.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_sub:			# binary operator, pop 2 previous in cal array, calculate then push
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    sub.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_div:			# binary operator, pop 2 previous in cal array, calculate then push
    l.s $f1, -8($t2)
    l.s $f2, -4($t2)
    c.eq.s $f2, $f30
    bc1t error
    div.s $f3, $f1, $f2
    s.s $f3, -8($t2)
    subi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
cal_fac:			# unary operator, pop a previous in cal array, calculate then push, check if it is an int
    l.s $f1, -4($t2)

    cvt.w.s $f3, $f1
    cvt.s.w $f4, $f3
    c.eq.s $f1, $f4
    bc1f error
    c.lt.s $f1, $f30
    bc1t error
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
    
cal_ans:			# load M value, treat as a number
    l.s $f1, M
    s.s $f1, 0($t2)
    addi $t2, $t2, 4
    addi $t0, $t0, 1
    j read_postfix
    
cal_pow:			# binary operator, pop 2 previous in cal array, calculate then push, check if the exponent is an int
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
    li $v0, 57
    la $a0, result_p
    
    la $t1, array_cal
    l.s $f1, 0($t1)
    mov.s $f12, $f1
    syscall
    
    s.s $f1, M
    
    lw $t9, length
    addi $t9, $t9, 1
    li $v0, 15    
    move $a0, $s6 
    la $a1 , input_string
    move $a2 , $t9 
    syscall 
    
    li $v0, 15     
    move $a0, $s6 
    la $a1 , result_p 
    li $a2 , 8
    syscall 
    
    l.s $f10, tenf
    li $t0, 0	
    cvt.w.s $f3, $f1
    addi $t3, $zero, 10
    mfc1 $t1, $f3		# take $t1 as an int of an result float
    
    cvt.s.w $f5, $f3
    sub.s $f5, $f1, $f5		# take $f5 as an decimal part of result float
    li $t6, 46
    sb $t6, buffer($t4)
    addi $t4, $t4, 1
    li $t6, 0
    bltz $t1, less_than_z
    j divide_int_loop
less_than_z:
    neg $t1, $t1		# abs all the value, then add "-" in buffer to print in .txt
    neg.s $f5, $f5
    li $t5, 45
    sb $t5, buffer_out($t6)
    addi $t6, $t6, 1
divide_int_loop:
    div $t1, $t3        # Divide integer by 10
    mfhi $t5            # Remainder stored in $t3
    addi $t5, $t5, 48   # Convert remainder to ASCII
    sb $t5, buffer($t4) # Store ASCII character in buffer
    addi $t4, $t4, 1    # Increment buffer index

    mflo $t1            # Quotient stored in $t0
    bnez $t1, divide_int_loop
    subi $t4, $t4, 1
    j swap_loop
swap_loop:
    lb $t5, buffer($t4)
    sb $t5, buffer_out($t6)
    addi $t6, $t6, 1
    beqz $t4, end_swap
    subi $t4, $t4, 1
    addi $t7, $t7, 1
    j swap_loop
end_swap:
    li $v0, 15 
    move $a0, $s6 
    la $a1 , buffer_out 
    move $a2 , $t6 
    syscall 
    li $t6, 0
    l.s $f10, tenf
begin_float:
    beq $t6, 16, end_float	# get 16 index after floating point
    mul.s $f5, $f5, $f10
    cvt.w.s $f3, $f5
    mfc1 $t1, $f3
    addi $t1, $t1, 48
    
    sb $t1, buffer_f($t6)
    cvt.s.w $f7, $f3
    sub.s $f5, $f5, $f7
    addi $t6, $t6, 1
    j begin_float
end_float:
    li $v0, 15 
    move $a0, $s6 
    la $a1 , buffer_f 
    li $a2 , 16 
    syscall 
    
    li $v0, 15    
    move $a0, $s6 
    la $a1 , down 
    li $a2 , 1 
    syscall 
    
    li $v0, 15    
    move $a0, $s6 
    la $a1 , down 
    li $a2 , 1 
    syscall 
    
    j main
check_quit:
    ###
    la $t0, input_string
    la $t1, quit_p
check_quit_loop:
    lb $t2, 0($t0)   
    lb $t3, 0($t1)   
    
    beqz $t3, quit
    beqz $t2, not_quit  
    bne $t2, $t3, not_quit
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j check_quit_loop
quit:
    li $v0, 59
    la $a0, quit_c
    la $a1, quit_program
    syscall
    
    li $v0, 15     
    move $a0, $s6 
    la $a1 , down
    li $a2 , 1
    syscall
    
    li $v0, 15 
    move $a0, $s6 
    la $a1 , quit_c 
    li $a2 , 16 
    syscall 
    
end_program:
    li $v0, 16 
    move $a0 , $s6 
    syscall
    li $v0, 10            
    syscall