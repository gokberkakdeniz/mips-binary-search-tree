# MIT License

# Copyright (c) 2021 Gökberk AKDENİZ

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

.data
list:           # where build menu input stored
    .word       -9999:32
tree:           # root node of the tree
    .word       -9999, 0, 0, 0
empty_node:     # empty for printing 'x'
    .word       -9999, 0, 0, 0
tree_height:    # height of the tree
    .word       0
menu_string:    
    .ascii      "> available options:\n"
    .ascii      "  1) build\n"
    .ascii      "  2) insert\n"
    .ascii      "  3) find\n"
    .ascii      "  4) print\n"
    .ascii      "  5) exit\n"
    .ascii      "  6) run tests (must be run first or never)\n"
    .asciiz     "$ operation: "
menu_invalid:  
    .asciiz     "> invalid input.\n"
menu_prompt:
    .asciiz     "$ operation: "
build_prompt:  
    .asciiz     "$ number (-9999 to stop): "
number_prompt: 
    .asciiz     "$ number: "
exiting_msg:   
    .asciiz     "> closing...\n"
inserted_msg:   
    .asciiz     "> insertion address: "
found_msg:
    .asciiz     "> found at address "
not_found_msg:
    .asciiz     "> not found.\n"

# start: test codes, mostly from ass2_mainFunction_v2.asm
firstList: 
    .word 8, 3, 6, 10, 13, 7, 4, 5, -9999
secondList:
    .word 8, 3, 6, 6, 10, 13, 7, 4, 5, -9999
thirdList:
    .word 8, 3, 6, 10, 13, -9999, 7, 4, 5, -9999
fourthList:
    .word 8, 3, 10, 1, 6, 14, 4, 7, 13, -9999
failf: 
    .asciiz " failed\n"
passf: 
    .asciiz " passed\n"
buildTest: 
    .asciiz " Build test"
insertTest: 
    .asciiz " Insert test"
findTest: 
    .asciiz " Find test"
assertNumber: 
    .word 0
# end: test codes, mostly from ass2_mainFunction_v2.asm

.text
.globl main

main:
    la      $s1, tree_height
    j       menu_loop

menu_loop:
    li      $v0, 4              # prints menu
    la      $a0, menu_string
    syscall

    li      $v0, 5              # reads option number
    syscall
    
    # jumps related execution parts...
    beq     $v0, 1, run_build
    beq     $v0, 2, run_insert
    beq     $v0, 3, run_find
    beq     $v0, 4, run_print
    beq     $v0, 5, exit
    beq     $v0, 6, test

    li      $v0, 4              # prints invalid option message
    la      $a0, menu_invalid
    syscall

    j       menu_loop
    
run_build:
    la      $a0, list     # reads numbers from input and pushes to array
    jal     read_integers

    la      $a0, list
    la      $a1, tree
    jal     build

    j       menu_loop

read_integers: # (arr: &int)
    move    $t0, $a0

    li      $v0, 4              # prints input message
    la      $a0, build_prompt
    syscall

    li      $v0, 5              # reads integer
    syscall

    move    $a0, $t0

    sw		$v0, 0($a0)         # pushes to array
    
    add     $a0, $a0, 4         # iterates array pointer
    bne     $v0, -9999, read_integers
    
    jr      $ra


run_insert:
    li      $v0, 4              # prints input message
    la      $a0, number_prompt
    syscall

    li      $v0, 5              # reads option number
    syscall

    move    $a0, $v0            # value argument
    la      $a1, tree           # tree argument
    jal     insert

    move    $t0, $v0

    li      $v0, 4              # prints insertion message
    la      $a0, inserted_msg
    syscall

    move    $a0, $t0            # prints return value (insertion address)
    li      $v0, 1              
    syscall

    li      $a0, '\n'           # prints new line
    li      $v0, 11              
    syscall

    j       menu_loop

run_find:
    li      $v0, 4              # prints input message
    la      $a0, number_prompt
    syscall

    li      $v0, 5              # reads option number
    syscall

    move    $a0, $v0            # value argument
    la      $a1, tree           # tree argument
    jal     find

    beq     $v0, 1, print_not_found

    li      $v0, 4
    la      $a0, found_msg
    syscall

    li      $v0, 1
    move    $a0, $v1
    syscall

    li      $v0, 11
    li      $a0, '\n'
    syscall

    j       menu_loop
    print_not_found:
    li      $v0, 4
    la      $a0, not_found_msg
    syscall

    j       menu_loop

run_print:
    la      $a0, tree           # tree argument
    jal     print
    
    j       menu_loop

build: # (list: &int[], tree: &node)
    move    $t5, $a0
    move    $t6, $a0

    addi    $sp, $sp, -4        #  preserves return address
    sw      $ra, 0($sp)

build_loop: 
    # builds tree with insert  macro until element -9999 
    lw      $t7, 0($t6)
    beq		$t7, -9999, build_loop_done

    move    $a0, $t7
    jal     insert
    add     $t6, $t6, 4
    j       build_loop

build_loop_done:
    move    $a0, $t5

    lw      $ra, 0($sp)         # restores return address
    addi    $sp, $sp, 4

    jr $ra

insert: # (value: int, tree: &node) -> &node
    move    $t0, $a0
    move    $t1, $a1
    li      $t8, 1              # to calculate height of the node after insertion

insert_rec:
    lw      $t2, 0($t1)         # node value 

    beq		$t2, -9999, insert_empty_or_equal   # if empty tree
    beq		$t2, $t0, insert_empty_or_equal     # if equals
    bgt		$t2, $t0, insert_left               # if value < current node
    blt		$t2, $t0, insert_right              # if value > current node

insert_empty_or_equal:
    sw      $t0, 0($t1)
    
    lw      $t2, 0($s1)
    blt     $t8, $t2, skip_write_1              # checks if height of tree to replace
    sw      $t8, 0($s1)
    skip_write_1:
    move    $v0, $s1

    jr      $ra

insert_left:
    lw      $t3, 4($t1)
    la      $t4, 4($t1)
    addi    $t8, $t8, 1
    beq     $t3, 0, insert_malloc   # no left child
    move    $t1, $t3
    j       insert_rec

insert_right:
    lw      $t3, 8($t1)
    la      $t4, 8($t1)
    addi    $t8, $t8, 1
    beq     $t3, 0, insert_malloc   # no right child
    move    $t1, $t3
    j       insert_rec
    
insert_malloc:
    move    $t7, $a0
    li      $v0, 9
    li      $a0, 16
    syscall
    move    $a0, $t7

    sw      $v0, 0($t4)

    sw      $t0, 0($v0)
    sw      $zero, 4($v0)
    sw      $zero, 8($v0)
    sw      $t1, 12($v0)

    lw      $t2, 0($s1)
    blt     $t8, $t2, skip_write_2
    sw      $t8, 0($s1)
    skip_write_2:

    jr      $ra

find: # (value: int, tree: &node) -> (0) | (1, &node)
    move    $t0, $a0
    move    $t1, $a1

find_rec:
    lw      $t2, 0($t1)             # node value 

    beq		$t2, -9999, find_failed # if empty tree
    beq		$t2, $t0, find_succeed  # if equals
    bgt		$t2, $t0, find_left     # if value < current node
    blt		$t2, $t0, find_right    # if value > current node

find_left:
    lw      $t3, 4($t1)             # loads address of left child
    beq     $t3, 0, find_failed     # no left child
    move    $t1, $t3                # runs find_rec with left child
    j       find_rec

find_right:
    lw      $t3, 8($t1)             # loads address of right child
    beq     $t3, 0, find_failed     # no right child
    move    $t1, $t3                # runs find_rec with right child
    j       find_rec

find_failed:
    li      $v0, 1
    jr      $ra

find_succeed:
    li      $v0, 0
    move    $v1, $t1
    jr      $ra

print: # (tree: &node)
    move    $t0, $sp
    addi    $sp, $sp, -8

    li      $t6, 1          # to detect the end of level
    sw      $t6, 0($sp)     # i selected address 1 because
                            # address 0 means no child
                            
    sw      $a0, 4($sp)     # pushes address of root node
    
    li      $t8, 0          # level counter
    li      $t9, 0          # node counter for level
    lw      $s2, 0($s1)     # tree height

print_loop:
    bge     $t8, $s2, print_loop_done

    move    $t7, $ra        # preservers and restores variables
    move    $t6, $a0        # and deques
    addi    $a0, $t0, -4
    jal dequeue
    move    $a0, $t6
    move    $ra, $t7        

    move    $t1, $v0        # loads node address

    bne     $t1, 1, not_end_of_level
    addi    $t8, $t8, 1     # increases level
    li      $t9, 0          # resets node counter for new level
    addi    $sp, $sp, -4    # to detect the next level's end
    li      $t6, 1
    sw      $t6, 0($sp)
    
    move    $t6, $a0        # preserves a0
    li      $v0, 11         # prints new line
    li      $a0, '\n'
    syscall
    move    $a0, $t6        # restores a0

    j       print_loop

    not_end_of_level:

    move    $t7, $ra        # preserves return address

    lw      $t3, 4($t1)     # pushes left child's address
    bne     $t3, 0, skip_fake_node_1
    la      $t3, empty_node
    skip_fake_node_1:
    jal     print_push_node

    lw      $t3, 8($t1)     # pushes right child's address
    bne     $t3, 0, skip_fake_node_2
    la      $t3, empty_node
    skip_fake_node_2:
    jal     print_push_node

    move    $ra, $t7        #  restores return address
    
    move    $t6, $a0        # preserves a0
    # prints node value
    li      $v0, 1          
    lw      $a0, 0($t1)
    bne     $a0, -9999, skip_print_x
    li      $v0, 11 
    li      $a0, 'x'
    skip_print_x:
    syscall
    move    $a0, $t6        # restores a0

    ble     $t8, 0, print_space
    li      $t6, 2
    div		$t9, $t6
    mfhi    $t6
    beq     $t6, 1, print_space

    move    $t6, $a0        # preserves a0
    li      $v0, 11
    li      $a0, '-'
    syscall
    move    $a0, $t6        # restores a0

    j       print_char_done

    print_space:
    move    $t6, $a0        # preserves a0
    li      $v0, 11
    li      $a0, ' '
    syscall
    move    $a0, $t6        # restores a0

    print_char_done:
    addi    $t9, $t9, 1     # increases level node counter
    
    j       print_loop

print_loop_done:
    move    $sp, $t0        # resets stack
                            # since the algortihm stopped at the deepest level
                            # 2^(n+1) + 1 nodes are strill in the stack
    jr      $ra

print_push_node:
    addi    $sp, $sp, -4
    sw      $t3, 0($sp)     # pushes address of root node
    jr      $ra

dequeue: # (top: &int) -> int
    lw      $v0, 0($a0)
    move    $t1, $a0        # address of value to be written
    addi    $t2, $t1, -4    # address of value to be moved

dequeue_loop:
    ble     $t1, $sp, dequeue_done

    lw      $t3, 0($t2)     # move previous value (n-1 --> n)
    sw		$t3, 0($t1)

    addi    $t1, $t1, -4    # cell to be written
    addi    $t2, $t2, -4    # cell to be moved
    j       dequeue_loop

dequeue_done:
    addi    $sp, $sp, 4
    jr      $ra

exit:
    li      $v0, 4
    la      $a0, exiting_msg
    syscall

    li      $v0, 10
    syscall

# start: from ass2_mainFunction_v2.asm
test:
    la $s0, tree

    # build a tree using the firstList
    la      $a0, firstList
    la      $a1, tree
    jal     build

    # Start of the test cases----------------------------------------------------

    # check build procedure
    lw $t0, 4($s0) # address of the left child of the root
    lw $a0, 0($t0) # real value of the left child of the root
    li $a1, 3 # expected value of the left child of the root
    la $a2, buildTest # the name of the test
    # if left child != 3 then print failed 
    jal assertEquals

    # check insert procedure
    li $a0, 11 # new value to be inserted
    move $a1, $s0 # address of the root
    jal insert
    # no need to reload 11 to $a0
    lw $a1, 0($v0) # value from the returned address
    la $a2, insertTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure
    li $a0, 11 # search value
    move $a1, $s0 # adress of the root
    jal find 
    # no need to reload 11 to $a0
    lw $a1, 0($v1) # value from the found adress
    la $a2, findTest # the name of the test
    # if returned address's value != 11 print failed 
    jal assertEquals

    # check find procedure 2
    # 44 should not be on the list
    # v0 should return 1
    li $a0, 44 # search value
    move $a1, $s0 # adress of the root
    jal find
    move $a0, $v0 # result of the search
    li $a1, 1 # expected result of the search
    la $a2, findTest # the name of the test
    # if returned value of $v0 != 0 print failed
    jal assertEquals

    move $a0, $s0
    jal print # print tree for visual inspection

    # End of the test cases----------------------------------------------------

    j       menu_loop

assertEquals:
    move $t2, $a0
    # increment count of total assertions.
    la $t0, assertNumber
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0) 

    # print the test number
    add $a0, $t1, $zero
    li $v0, 1
    syscall
    
    # print the test name
    move $a0, $a2
    li $v0, 4
    syscall

    # print passed or failed.
    beq $t2, $a1, passed
    la $a0, failf
    li $v0, 4
    syscall
    jr      $ra

passed:
    la $a0, passf
    li $v0, 4
    syscall
    jr      $ra

# end: from ass2_mainFunction_v2.asm
