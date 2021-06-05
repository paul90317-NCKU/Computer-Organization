main:
    addi $a0, $zero, 19654 # a0= 19654
    addi $a1, $zero, 100654  # a1=100654
    addi $a2, $zero, 10065  # a2= 10065
    jal average     # call average
    j exit

average:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)    # Save $ra register into stack
    #--------------------------------------#
    #  \^o^/   Write your code here~  \^o^/#
    add $v0, $a0, $a1
    add $v0, $v0, $a2
    #--------------------------------------#
    lw $ra, 0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4
    jr $ra

exit:
#addi $a0 $v0 0
#addi $v0 $zero 1
#syscall