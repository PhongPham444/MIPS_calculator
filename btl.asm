.data
down: .asciiz "\n"
input_string:   .space  50      # Chuỗi nhập từ bàn phím
array:          .space  200     # Mảng chứa số dạng float
array_op:       .space  100     # Mang chua operator ()+-*/^!
array_temp:     .space  100     # Mang tam thoi
b_float:        .word   0       # Luu phia sau dau cham dong
temp_float:     .float  0.0     # Biến tạm để lưu số dạng float
tenf: .float 10.0
onef: .float 1.0
.text
main:
    # Nhập chuỗi từ bàn phím
    li $v0, 8             # syscall 8: read_string
    la $a0, input_string  # Địa chỉ bắt đầu của chuỗi
    li $a1, 50            # Độ dài tối đa của chuỗi
    syscall

    # Load $t0 with the address of the input_string
    la $t0, input_string
    la $t2, array
    l.s $f1, tenf
    la $t8, array_op
    li $t9, 0

read_loop:
    lb $t1, 0($t0)        # Load ký tự từ chuỗi
    beq $t1, 10, end_read
    # Kiểm tra xem ký tự hiện tại có phải là số hay không
    beq $t1, 46, dot_found
    blt $t1, 48, not_digit # ASCII '0'
    bgt $t1, 57, not_digit # ASCII '9'

    # Nếu là số, chuyển đổi thành float
    subi $t1, $t1, 48      # Chuyển sang giá trị số thập phân
    l.s $f10, temp_float   # Load giá trị float từ biến tạm
    mul.s $f10, $f10, $f1  # Nhân cho 10 để thêm chữ số mới
    mtc1 $t1, $f11         # Move integer to floating-point
    cvt.s.w $f11, $f11
    add.s $f10, $f10, $f11 # Thêm số mới vào giá trị float
    s.s $f10, temp_float   # Lưu giá trị float mới vào biến tạm

    # Kiểm tra xem ký tự tiếp theo có phải là dấu chấm hay không
    lb $t5, 1($t0)         # Load ký tự tiếp theo
    beq $t5, 46, continue_read # Nếu là dấu chấm, vong tiep theo
    blt $t5, 48, store_array # ASCII '0'
    bgt $t5, 57, store_array # ASCII '9'
    j continue_read
store_array:    
    # Neu khong phai la so thi luu lai bien do vao array
    l.s $f10, temp_float
    s.s $f10, 0($t2)
    addi $t2, $t2, 4
    ###
    sb $t9, 0($t8)
    addi $t9, $t9, 1
    addi $t8, $t8, 1
    #reset temp
    s.s $f0, temp_float
    j continue_read

dot_found:
    li $t6, 1              # Khởi tạo biến đếm số chữ số sau dấu chấm động
    addi $t0, $t0, 1
dot_loop:
    lb $t5, 0($t0)         # Load ký tự tiếp theo
    # Kiểm tra xem ký tự tiếp theo có phải là số hay không
    blt $t5, 48, dot_end
    bgt $t5, 57, dot_end

    # Nếu là số, cập nhật biến đếm và tiếp tục
    subi $t5, $t5, 48
    lw $t4, b_float
    mul $t4, $t4, 10
    add $t4, $t4, $t5
    sw $t4, b_float
    mul $t6, $t6, 10       # Tăng biến đếm lên 1
    addi $t0, $t0, 1       # Di chuyển con trỏ sang phải

    j dot_loop

dot_end:
    lw $t4, b_float
    mtc1 $t4, $f4
    mtc1 $t6, $f6
    cvt.s.w $f4, $f4
    cvt.s.w $f6, $f6
    div.s $f4, $f4, $f6
    l.s $f10, temp_float
    add.s $f10, $f10, $f4
    s.s $f10, 0($t2)
    addi $t2, $t2, 4
    ###
    sb $t9, 0($t8)
    addi $t9, $t9, 1
    addi $t8, $t8, 1
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
    beq $t1, 136, ins_op
    
error:    
    li $v0, 1
    move $a0, $t1
    syscall
    li $v0, 10             # syscall 10: exit
    syscall
    
ins_op:    
    sb $t1, 0($t8)
    addi $t8, $t8, 1
    addi $t0, $t0, 1       # Di chuyển con trỏ sang phải
    j read_loop

continue_read:
    addi $t0, $t0, 1       # Di chuyển con trỏ sang phải
    j read_loop

end_read:
    # Kết thúc chương trình
    la $t0, array
    l.s $f1, 0($t0)
    l.s $f2, 4($t0)
    add.s $f1, $f2, $f1
    li $v0, 2
    mov.s $f12, $f1
    syscall
    la $t1, array_op
    lb $t2, 1($t1)
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 10             # syscall 10: exit
    syscall
