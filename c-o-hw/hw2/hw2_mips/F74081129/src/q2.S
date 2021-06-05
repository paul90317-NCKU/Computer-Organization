main:
    addi $a0, $zero, 10 # n = 10
    addi $a1, $zero, 5  # m = 5
    jal pascal          # call pascal(10, 5)
    j exit

pascal:
    addi $sp, $sp, -4
    sw $ra, 0($sp)    # Save $ra register into stack

    #--------------------------------------#
    #  \^o^/   Write your code here~  \^o^/#
    addi $v0 $zero 1
    beq $a0 $a1 return
    beq $zero $a1 return
    addi $sp $sp -8
    sw $a0 0($sp)
    sw $a1 4($sp)
    addi $a0 $a0 -1
    addi $a1 $a1 -1
    jal pascal
    lw $a0 0($sp)
    lw $a1 4($sp)
    addi $t0 $v0 0
    addi $sp $sp 4
    sw $t0 0($sp)
    addi $a0 $a0 -1
    jal pascal
    lw $t0 0($sp)
    add $v0 $t0 $v0
    addi $sp $sp 4
    #--------------------------------------#

return:
    lw $ra, 0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4
    jr $ra

exit:
#addi $a0 $v0 0
#addi $v0 $zero 1
#syscall