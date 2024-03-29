 .data
 .eqv height 6
 .eqv width 7
 .eqv size 42
 .eqv chances 3
 intro: .asciiz "/Users/khuenguyen/Desktop/ASSCA/intro.txt"
 outtro: .asciiz "/Users/khuenguyen/Desktop/ASSCA/outtro.txt"
 buffer_intro: .space 10000
 buffer_outro: .space 10000                 
 undoPlayer1: .asciiz "Player 1 undo ? Press 'y' to repick or any other key to continue\n"
 undoPlayer2: .asciiz "Player 2 undo ? Press 'y' to repick or any other key to continue\n"
 totalUndos: .asciiz "Total undos left: "
 gameTie: .asciiz "\nNo more moves available. Game tied !!\n( 0 o 0 )\n"
 ramdomplayer1: .asciiz "\nPlayer 1 will start the game\n"
 ramdomplayer2: .asciiz "\nPlayer 2 will start the game\n"
 pickColor: .asciiz "Pick a piece: x or o: "
 repickColor: .asciiz "\nGame haven't even started and you already made a wrong input.\nTry again (-_-)\n"
 player1Prompt: .asciiz "\nPlayer 1's turn, choose a column(1-7): "
 player2Prompt: .asciiz "\nPlayer 2's turn, choose a column(1-7): "
 invalidInput: .asciiz "Invalid input: Choose from 1 to 7!!!\n"
 invalidInputFull: .asciiz "Invalid input: Column_Full."
 firstViolation: .asciiz "Try again, 2 chances left!\n(=____=)\n"
 secondViolation: .asciiz "Try another column, last chance!\n \(°^°)/\n"
 disqualified: .asciiz "You violated 3 times !!!( X _ X )\n"
 player1Win: .asciiz "\nPlayer 1 wins!<(^_^)>\n"
 player2Win: .asciiz "\nPlayer 2 wins!<(^_^)>\n"
 restartPrompt: .asciiz "Press 1 to restart\n"
 .text

 Game_Start:
 li $v0, 13 
 la $a0, intro 
 li $a1, 0
 syscall
 move $t0, $v0
 li $v0, 14
 move $a0, $t0
la $a1, buffer_intro 
li $a2, 10000         
syscall
li $v0,4
la $a0,buffer_intro
syscall
li $v0,16
move $a0,$s6
syscall
# system call for read
# file descriptor
    # address of buffer read
# hardcoded buffer length
# read file
# system call for open file
# input file name
# Open for reading (flags are 0: read, 1: write)
# mode is ignored
# open a file (file descriptor returned in $v0)
# save the file descriptor
 add $s3,$zero,$zero
 add $s4,$zero,chances
 add $s5,$zero,chances
 add $s6,$zero,chances #
 			## s6 and s7 store number of chances
 add $s7,$zero,chances #
 jal makeMatrix
 move $s0,$v0
 playAgain:
  add $s3,$zero,$zero
 add $s4,$zero,chances
 add $s5,$zero,chances
 add $s6,$zero,chances #
 			## s6 and s7 store number of chances
 add $s7,$zero,chances #
 move $a0,$s0
 jal emptyMatrix
 li $a1, 100  #Here you set $a1 to the max bound.
 li $v0, 42  #generates the random number.
 syscall
 add $a0, $a0, 100  #Here you add the lowest bound
 addi $t0,$zero,2
 div $a0,$t0
 mfhi $s1
 addi $s1,$s1,1
 beq $s1,1,player1Start
 beq $s1,2,player2Start
 	FirstColor:
 	li $v0,4
 	la $a0,pickColor
 	syscall
 	li $v0,12
 	syscall
 	move $s2,$v0
 	beq $v0,'x',gameplay
 	beq $v0,'o',gameplay
 	li $v0,4
 	la $a0,repickColor
 	syscall
 	j FirstColor
 gameplay:
 beq $s1,1,player1Turn
 beq $s1,2,player2Turn
 undo:
 jal printMatrix
 beq $s3,0,checkWin


 li $v0,4
 la $a0,totalUndos
 syscall
 beq $s1,1,player1Repick
 beq $s1,2,player2Repick
 player1Repick:
 li $v0,1
 move $a0,$s6
 syscall
 li $v0,11
 addi $a0,$zero,'\n'
 syscall
 slt $t0,$zero,$s6
 beq $t0,1,repick1
 j checkWin
 player2Repick:
 li $v0,1
 move $a0,$s7
 syscall
 li $v0,11
 addi $a0,$zero,'\n'
 syscall
 slt $t0,$zero,$s7
 beq $t0,1,repick2
 j checkWin
 ########
 checkWin:
 addi $s3,$s3,1	# address in a1   offset in a2  element in a3
 slti $t0,$s3,size
 beq $t0,0,tieGame
 slti $t0,$a2,21
 li $v0,0
 beq $t0,1,checkDown
 afterCheckDown:
 beq $v0,4,endGame
 li $v0,0
 j checkRight
 afterCheckLR:
 beq $v0,4,endGame
 li $v0,0
 j checkURDL
 aftercheckURDL:
 beq $v0,4,endGame
 li $v0,0
 j checkULDR
 aftercheckULDR:
 beq $v0,4,endGame
 j tooglelayer
 changeColor:
 beq $s2,'o',changeRed
 beq $s2,'x',changeYellow
 li $v0,10
 syscall
 
 
 ############################################################
 makeMatrix:  # making the Board, address stored in $v0
 add $t0,$zero,height
 mul  $t0,$t0,width
 li $v0,9
 move $a0,$t0
 syscall
 jr $ra
 emptyMatrix:
 li $t1,0
 addi $t0,$zero,size
 while: # while index < size 
   add $t2,$a0,$t1
   sb $zero,0($t2)
   addi $t1,$t1,1
   bne $t1,$t0,while
   jr $ra
   
   
   
 ############################################################   
 printMatrix: # print matrix, address stored in $a1
 li $t1,0
 addi $t0,$zero,size
 print:
   li $v0,11
   addi $a0,$zero,' '
   syscall
   li $v0,11
   addi $a0,$zero,'|'
   syscall
   li $v0,11
   addi $a0,$zero,' '
   syscall
   add $t2,$a1,$t1
   lb $t2,0($t2)
   beq $t2,'x',printy
   beq $t2,'o',printr
   beq $t2,$zero,printNULL
   print_while:
   addi $t1,$t1,1
   addi $t6,$zero,width
   div $t1,$t6
   mfhi $t6
   beq $t6,0,printEndl
   endPrint:
   bne $t1,$t0,print  
   jr $ra
 printy:
   	li $v0,11
 	addi $a0,$zero,'x'
 	syscall
 	j print_while
 printr:
   	li $v0,11
 	addi $a0,$zero,'o'
 	syscall
 	j print_while

 printNULL:
   	li $v0,11
 	addi $a0,$zero,'*'
 	syscall
 	j print_while
 printEndl:
 	li $v0,11
   	addi $a0,$zero,' '
   	syscall
 	li $v0,11
   	addi $a0,$zero,'|'
   	syscall
   	li $v0,11
 	addi $a0,$zero,'\n'
 	syscall
 	j endPrint
 insert:  # address in a1. col in a0, element in a2
 	addi $t0,$zero,height
 	addi $t0,$t0,-1
 	mul $t0,$t0,width
 	add $t0,$t0,$a0
 	addi $t0,$t0,-1
 	findspace:
 	add $t1,$a1,$t0
 	lb $t1,0($t1)
 	beq $t1,$zero,drop
 	addi $t0,$t0,-width
 	slt $t2,$t0,$zero
 	beq $t2,1,fullRow
 	j findspace
 	drop:
 	add $t1,$a1,$t0
 	sb $a2,0($t1)
 	move $a1,$s0
 	move $a3,$a2
 	move $a2,$t0
 	j undo
 
 
 player1Turn:
 	li $v0,4
 	la $a0,player1Prompt
 	syscall
 	li $v0,5
 	syscall
 	slt $t0,$zero,$v0
 	beq $t0,0,invalidCol
 	addi $t0,$zero,width
 	addi $t0,$t0,1
 	slt $t0,$v0,$t0
 	beq $t0,0,invalidCol
 	move $a0,$v0
 	move $a1,$s0
 	move $a2,$s2
 	j insert
 player2Turn:
 	li $v0,4
 	la $a0,player2Prompt
 	syscall
 	li $v0,5
 	syscall
 	slt $t0,$zero,$v0
 	beq $t0,0,invalidCol
 	addi $t0,$zero,width
 	addi $t0,$t0,1
 	slt $t0,$v0,$t0
 	beq $t0,0,invalidCol
 	move $a0,$v0
 	move $a1,$s0
 	move $a2,$s2
 	j insert
 	
 	
 player1Start:
 	li $v0,4
 	la $a0,ramdomplayer1
 	syscall
 	j FirstColor
 player2Start:
 	li $v0,4
 	la $a0,ramdomplayer2
 	syscall
 	j FirstColor
 
 checkDown: # address in a1   offset in a2  element in a3
 	addi $t0,$zero,height
 	mul $t0,$t0,width  # t0 has the max index
 	addi $t1,$zero,0   # t1 is how much you add to offset
 	addi $t2,$zero,0   # t2 is current index ( offset + 7i )
 	checkDwhile:
 	add $t2,$a2,$t1
 	slt $t3,$t2,$t0
 	beq $t3,0,afterCheckDown
 	addi $v0,$v0,1
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	addi $t1,$t1,width
 	beq $t2,$a3,checkDwhile
 	addi $v0,$v0,-1
 	j afterCheckDown
 	
 endGame:
 	beq $s1,1,player1W
 	beq $s1,2,player2W
 	restart:
 	li $v0,4
 	la $a0,restartPrompt
 	syscall
 	li $v0,5
 	syscall
 	beq $v0,1,playAgain
 	li $v0, 13 
 la $a0, outtro 
 li $a1, 0
 syscall
 move $t0, $v0
 li $v0, 14
 move $a0, $t0
la $a1, buffer_outro 
li $a2, 10000
syscall
li $v0,4
la $a0,buffer_outro
syscall
li $v0,16
move $a0,$s6
syscall
 	li $v0,10
 	syscall
 	player1W:
 	li $v0,4
 	la $a0,player1Win
 	syscall
 	j restart
 	player2W:
 	li $v0,4
 	la $a0,player2Win
 	syscall
 	j restart
 tooglelayer:
 	beq $s1,1,changeP2
 	beq $s1,2,changeP1
 	changeP2:
 	addi $s1,$s1,1
 	j changeColor
 	changeP1:
 	addi $s1,$s1,-1
 	j changeColor
changeRed:
	add $s2,$zero,'x'
	j gameplay
changeYellow:
	add $s2,$zero,'o'
	j gameplay
 checkRight:
 	add $t0,$zero,$a2
 	addi $t3,$zero,width
 	div $t0,$t3
 	mfhi $t0
 	sub $t0,$t3,$t0
 	add $t0,$a2,$t0  # t0 has max index
 	addi $t1,$zero,1   # t1 is how much you add to offset
 	addi $t2,$zero,0   # t2 is current index ( offset + 7i )
 	checkRightWhile:
 	addi $v0,$v0,1
 	add $t2,$a2,$t1
 	slt $t3,$t2,$t0
 	beq $t3,0,checkLeft
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	addi $t1,$t1,1
 	beq $t2,$a3,checkRightWhile
 	j checkLeft
 	checkLeft:
 	addi $t0,$t0,-width
 	addi $t1,$zero,-1   # t1 is how much you add to offset
 	addi $t2,$zero,0   # t2 is current index ( offset + 7i )
 	checkLeftWhile:
 	add $t2,$a2,$t1
 	slt $t3,$t2,$t0
 	beq $t3,1,afterCheckLR
 	addi $v0,$v0,1
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	addi $t1,$t1,-1
 	beq $t2,$a3,checkLeftWhile
 	addi $v0,$v0,-1
 	j afterCheckLR
 checkURDL:
 	addi $t0,$zero,height
 	mul $t0,$t0,width  # t0 has the max index
 	addi $t1,$zero,-6   # t1 is how much you add to offset
 	addi $t2,$a2,0   # t2 is current index ( offset + 7i )
 	checkURWhile:
 	addi $v0,$v0,1
 	addi $t3,$zero,width
 	addi $t4,$t2,1
 	div $t4,$t3
 	mfhi $t3
 	beq $t3,0,checkDL
 	add $t2,$a2,$t1
 	slt $t3,$zero,$t2
 	beq $t3,0,checkDL
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	addi $t1,$t1,-6   
 	beq $t2,$a3,checkURWhile
 	j checkDL
 	checkDL:
 	addi $t1,$zero,6   # t1 is how much you add to offset
 	addi $t2,$a2,6   # t2 is current index ( offset + 7i )
 	checkDLWhile:
 	addi $t3,$zero,width
 	div $t2,$t3
 	mfhi $t3
 	beq $t3,0,atLimit
 	add $t2,$a2,$t1
 	slt $t3,$t2,$t0
 	beq $t3,0,aftercheckURDL
 	
 	addi $v0,$v0,1
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	addi $t1,$t1,6
 	beq $t2,$a3,checkDLWhile
 	addi $v0,$v0,-1
 	j aftercheckURDL
 checkULDR:
 	addi $t0,$zero,height
 	mul $t0,$t0,width  # t0 has the max index
 	addi $t1,$zero,-8   # t1 is how much you add to offset
 	addi $t2,$a2,0   # t2 is current index ( offset + 7i )
 	checkULWhile:
 	addi $v0,$v0,1
 	addi $t3,$zero,width
 	div $t2,$t3
 	mfhi $t3
 	beq $t3,0,checkDR
 	add $t2,$a2,$t1 	
 	slt $t3,$zero,$t2
 	beq $t3,0,checkDR
 	
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	addi $t1,$t1,-8
 	beq $t2,$a3,checkULWhile
 	j checkDR
 	checkDR:
 	addi $t1,$zero,8   # t1 is how much you add to offset
 	addi $t2,$a2,0   # t2 is current index ( offset + 7i )
 	checkDRWhile:
 	add $t2,$a2,$t1
 	addi $t4,$t2,1
 	addi $t3,$zero,width
 	div $t4,$t3
 	mfhi $t3
 	beq $t3,0,atLimit2
 	slt $t3,$t2,$t0
 	beq $t3,0,aftercheckULDR
 	addi $v0,$v0,1
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	addi $t1,$t1,8
 	beq $t2,$a3,checkDRWhile
 	addi $v0,$v0,-1
 	j aftercheckULDR
 repick1:
 	li $v0,4
 	la $a0,undoPlayer1
 	syscall
 	li $v0,12
 	syscall
 	beq $v0,'y',yes
 	j checkWin
 	addi $s6,$s6,-1
 	add $t2,$s0,$a2
 	sb $zero,0($t2)
 	li $v0,11
 	addi $a0,$zero,'\n'
 	syscall
 	jal printMatrix
 	j gameplay
 repick2:
 	li $v0,4
 	la $a0,undoPlayer2
 	syscall
 	li $v0,12
 	syscall
 	beq $v0,'y',yes
 	j checkWin
 	yes:
 	addi $s7,$s7,-1
 	add $t2,$s0,$a2
 	sb $zero,0($t2)
 	li $v0,11
 	addi $a0,$zero,'\n'
 	syscall
 	jal printMatrix
 	j gameplay
 invalidCol:
 	li $v0,4
 	la $a0,invalidInput
 	syscall
 	beq $s1,1,player1Wrong
 	beq $s1,2,player2Wrong
 	player2Wrong:
 	addi $s5,$s5,-1
 	beq $s5,2,firstTime
 	beq $s5,1,secondTime
 	beq $s5,0,noMore
 	player1Wrong:
 	addi $s4,$s4,-1
 	beq $s4,2,firstTime
 	beq $s4,1,secondTime
 	beq $s4,0,noMore
 	firstTime:
 	li $v0,4
 	la $a0,firstViolation
 	syscall
 	j gameplay
 	secondTime:
 	li $v0,4
 	la $a0,secondViolation
 	syscall
 	j gameplay
 	noMore:
 	li $v0,4
 	la $a0,disqualified
 	syscall
 	beq $s1,1,player2W
 	j player1W
 fullRow:
 	li $v0,4
 	la $a0,invalidInputFull
 	syscall
 	beq $s1,1,player1Wrong
 	beq $s1,2,player2Wrong
 tieGame:
 	li $v0,4
 	la $a0,gameTie
 	syscall
 	j restart
atLimit:
	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	bne $t2,$a3,aftercheckURDL
 	addi $v0,$v0,1
 	j aftercheckURDL
 atLimit2:
 	add $t2,$a1,$t2
 	lb $t2,0($t2)
 	bne $t2,$a3,aftercheckULDR
 	addi $v0,$v0,1
 	j aftercheckULDR
