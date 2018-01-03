# COE 0147 Snake Project
# Alec Cantor, Alex Blackson, and Dylan Miao
# apc47@pitt.edu, arb171@pitt.edu, dtm32@pitt.edu

.data
wall: .ascii "****************************************  ******************  **"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                    *****************                         *"
"*                    *                                         *"
"*                    * ***************                         *"
"*                    * *                                       *"
"*                    * *                                       *"
"*                    * *                                       *"
"*                    * *                                       *"
"*                    ***                                       *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"                                                          
"*                                                              *"
"*                          **********************              *"
"*                          *                    *              *"
"*                          *                    *              *"
"*                          *   ***************  *              *"
"*                          *   *                *              *"
"*                          *                 *  *              *"
"*                          *   ***************  *              *"
"*                                               *              *"
"*                                               *              *"
"*                          **********************              *"
"*                                                              *"
"*                                                              *"                                                            
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"
"*                                                              *"                                                            
"*                                                              *"
"*         * *                                                  *"
"*         * *                                                  *"
"*         * *                                                  *"
"*         * *                                                  *"
"*********** *                          *************************"
"            *                          *                        "
"*************                          *  **********************"
"*                                      *  *                    *"
"*                                      *  *                    *"
"*                                      *  *                    *"                                                         
"*                                      *  *                    *"
"*                                      *  *                    *"
"*                                      *  *                    *"
"****************************************  ******************  **"

#snakeHead: .space 2
#snakeBody: .space 76
#snakeTail: .space 2
snakeBody: .space 80
snakeHead: .space 4
snakeTail: .space 4
ExitMessage1: .asciiz "Game Over.\nThe playing time was\n"
ExitMessage2: .asciiz " ms. The game score\nwas "
ExitMessage3: .asciiz " frogs."


.text

#main method 
_main:
	jal _drawWall		# Setup and display walls
	jal _setFrog		# Setup frogs on board

# initializes local vairables 
_main1:	
	li $s3, 0	# Set initial diretion to s3 = direction (0- right, 1-down, 2-left, 3-up)
	li $s4, 0 	# Continue variable (0 - TRUE, 1 - FALSE/EXIT)
	li $s6, 0 	# Stores total playing time of the game to be displayed in the exit function
	
# _gameLoop will repeat as long the snake isn't at the maximum length or a special case is reached to exit
_gameLoop:
	addi $a0, $s3, 0
	jal _readKeyboard
	addi $s3, $v0, 0 #s3 will store returned value from readKeyboard
	#add $v0, $v0, $v0
	#based on key direction, snake will try to move in all three directions
	_tryRight:
		bne $s3, 0, _tryDown
		jal _moveRight
		j _testRepeat
	_tryDown:
	 	bne $s3, 1, _tryLeft
		jal _moveDown
		j _testRepeat
	_tryLeft:
		bne $s3, 2, _tryUp
		jal _moveLeft
		j _testRepeat
	_tryUp:
		jal _moveUp
		j _testRepeat
	 _testRepeat: 
	 	jal _delay
	 	blt $s7, $k0, _gameLoop #gameLoop will run five times until we hve end game figured out, now it's only repeating 5 times
	 	beq $s7, $k0, _mainExit #gameLoop will exit as long the maximum length k0 has not been reached
	
# void _mainExit()
	# diplays final message of total score and playing time
_mainExit:
	li $v0, 4
	la $a0, ExitMessage1
	syscall
	li $v0, 1
	add $a0, $s6, $zero
	syscall
	li $v0, 4
	la $a0, ExitMessage2
	syscall
	li $v0, 1
	addi $a0, $s7, -8
	syscall
	li $v0, 4
	la $a0, ExitMessage3
	syscall
	li $v0, 10
	syscall
	
# void _drawWall()
	#   sets up the walls
	# 
	# trashes:   $t4-$t7
	# returns:   none
	#
_drawWall:
	li $t5, 0x10010000 #loads first corner into t1 t0 print	
	li $t7, 0x25 #sets compare char 
_setWall: 
	beq $t4, 4096, _setSnake #loops through each LED
	lbu $t6, 0($t5) #loads char into t6
	sgt $a2, $t6, $t7 #sets color to OFF or RED
        jal _setLED #turns on LED
        addi $a0, $a0, 1 #moves to next LED
        beq $a0, 64, _moveLEDY
        bne $a0, 64, _setWall2
        _moveLEDY:
        	addi $a0, $0, 0 #reset x
        	addi $a1, $a1, 1 #move down y
        	J _setWall2
        _setWall2: 
        	addi $t5, $t5, 1 #moves to next wall char
        	addi $t4, $t4, 1 #increments loop to 4096
		J _setWall

# void _setFrog()
	# sets up the frogs
	# 
	# trashes:   $t4-t6
	# returns:   none
	#
_setFrog:
	li $a2, 0x3 	# Sets color to GREEN
	li $t4, 0 	# Reset counter $t4
	li $t5, 0	# Reset $t5, $t6
	li $t6, 0
	li $k0, 8	# Initializes k0 to the original length of the snake
	_setFrog2:
		beq $t4, 32, _setFrogExit	# Begin loop to count to 32
		li $a1, 64 			# Set max RAND value
		li $v0, 42			# Generate random num for x
		syscall
		move $t5, $a0			# Store random num x in $t5
		syscall 			# Generate random num for y
		move $t6, $a0			# Store y rand into $t6
		move $a0, $t5			# stores x rand into a0
		move $a1, $t6 			# stores y rand into a1
		addi $sp, $sp, -4 		# Push $ra onto stack
		move $sp, $ra
		jal _getLED			# Call _getLED for random coordinate
		move $ra, $sp			# Pop $ra off stack
		addi $sp, $sp, 4
		beq $v0, 0, _setFrog3		# Branch if LED is OFF
		addi $t4, $t4, 1 		# Increment loop variable
		j _setFrog2
        _setFrog3: 
        	#addi $sp, $sp, 4 #pop ra off stack
		#move $ra, $sp
		addi $sp, $sp, -4	# Push $ra onto stack
		move $sp, $ra
        	jal _setLED 
        	move $ra, $sp		# Pop $ra off stack
        	addi $sp, $sp, 4
        	addi $k0, $k0, 1	# Maximum length of snake, so that the main loop will exit if all the frogs are eaten
        	addi $t4, $t4, 1	# Increment loop variable
       		j _setFrog2 
       	_setFrogExit:
       		j _main1
       		
       		
       		
# void _setSnake()
	#draws and animates snake
	# 
	# returns:   none
	#
_setSnake:
	addi $s7, $0, 8		# Body length variable
	la $s0, snakeBody	# snakeBody address into $s0
	sw $s0, snakeTail	# Set snakeTail to first address in snakeBody
	move $s2, $s0		# Store snakeTail address in $s2
	addi $s1, $s0, 14	# Store address of snakeHead in $s1
	sw $s1, snakeHead	# Set snakeHead to last address in snakeBody
	li $a2, 2		# Sets color to YELLOW
	li $a0, 11		# Sets column to 11
	li $a1, 31		# Sets row to 31
	sb $a0, 0($s1)		# Store address of HEAD x
	sb $a1, 1($s1)		# Store address of HEAD y
	jal _setLED		# Draws HEAD
	
	# Draw rest of BODY array
	li $a0, 4		# Start with TAIL, first address in BODY
	sb $a0, 0($s0)
	sb $a1, 1($s0)
	jal _setLED 
	li $a0, 5
	sb $a0, 2($s0)
	sb $a1, 3($s0)
	jal _setLED 
	li $a0, 6
	sb $a0, 4($s0)
	sb $a1, 5($s0)
	jal _setLED 
	li $a0, 7
	sb $a0, 6($s0)
	sb $a1, 7($s0)
	jal _setLED 
	li $a0, 8
	sb $a0, 8($s0)
	sb $a1, 9($s0)
	jal _setLED 
	li $a0, 9
	sb $a0, 10($s0)
	sb $a1, 11($s0)
	jal _setLED 
	li $a0, 10
	sb $a0, 12($s0)
	sb $a1, 13($s0)
	jal _setLED
	J _setFrog		# Jump to set frog

	
# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=yellow, 3=green
	#
	# arguments: $a0 is x, $a1 is y, $a2 is color
	# trashes:   $t0-$t3
	# returns:   none
	#	
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008 # base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra
	

# int _getLED(int x, int y)
	#  returns the value of the LED at position (x,y)
	#
	#  arguments: $a0 holds x, $a1 holds y
	#  trashes:   $t0-$t2
	#  returns:   $v0 holds the value of the LED (0, 1, 2 or 3)
	#
_getLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	jr   $ra
	

# int readKeyboard(int currDir)
	#  returns the direction to move based upon the current keyboard status and current direction
	#  0 = right, 1 = down, 2 = left, 3 = up
	#
	#  arguments: 	$s3 holds current direction
	#  trashes:	$t0-
	#  returns:	$v0 holds new direction (0, 1, 2, 3)
	#
_readKeyboard:
	la $t0, 0xffff0000 	# Checks to see if button is pressed
	lb $t1, 0($t0)
	#j _buttonPressed
	bne $t1, $zero, _buttonPressed
	
	_sameDir:
		add $v0, $a0, $zero ## returns current state if no button is pressed
		#add $v0, $zero, $t1
		jr $ra
	
	_buttonPressed:
		la $t0, 0xffff0004
		lbu $t1, 0($t0)
		#tests all possible key options
		_testRight:
			bne $t1, 0xe3, _testDown
			beq $s3, 2, _returnToMain
			addi $v0, $zero, 0
			jr $ra
			
		_testDown: 
			bne $t1, 0xe1, _testLeft
			beq $s3, 3, _returnToMain
			addi $v0, $zero, 1
			jr $ra
		
		_testLeft:
			bne $t1, 0xe2, _testUp
			beq $s3,0, _returnToMain
			addi $v0, $zero, 2
			jr $ra
		
		_testUp:
			bne $t1, 0xe0, _testB
			beq $s3, 1, _returnToMain
			addi $v0, $zero, 3
			jr $ra
		#_returnToMain allows the snake to retain the same direction if user attempts a 180 degree turn
		_returnToMain:
			add $v0, $s3, $zero 
			jr $ra
		
		_testB:
			# if b is pressed, program will exit
			bne $t1, 0x42, _sameDir
			j _mainExit

## void _moveRight()
	#  moves snake right one pixel 
	#
	#  snakeBody previously stored in $s0
	#  snakeTail address stored in $s2
	#  snakeHead address stored in $s1
	#  trashes:	$t0
	#  returns:   none
_moveRight:
	# Set new head
	lb $a0, 0($s1)		# Load x address of current HEAD
	lb $a1, 1($s1)		# Load y address of current HEAD

	addi $t0, $s0, 78	# Address of end of array
	bne $s1, $t0, _moveRightHead0
	add $s1, $s0, $zero	# Return to beginning of array
	j _moveRightHead1
	
	_moveRightHead0:
	addi $s1, $s1, 2	# Increment head address
	_moveRightHead1:
	
	bne $a0, 63, _moveRightCont
	li $a0, 0 
	j _moveRightCont2
	_moveRightCont:
	addi $a0, $a0, 1	# Add 1 to x to move RIGHT
	_moveRightCont2:
	li $a2, 2		# Sets color to YELLOW
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _getLED		# Check to make sure next dot is clear
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	add $a3, $v0, $zero
	bne $a3, 0, _checkNextDot # if next dot isn't clear, check what it is
	sb $a0, 0($s1)		# Save new HEAD x
	sb $a1, 1($s1)		# Save new HEAD y
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn on new head
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address

	# Delete old tail
	lb $a0, 0($s2)		# Load x and y of old TAIL
	lb $a1, 1($s2)
	sb $zero, 0($s2)	# Set old TAIL to 0,0
	sb $zero, 0($s2)
	
	addi $t0, $s0, 78	# Address of end of array
	bne $s2, $t0, _moveRightTail0
	add $s2, $s0, $zero	# Return to beginning of array
	j _moveRightTail1
	
	_moveRightTail0:
	addi $s2, $s2, 2	# Increment TAIL address
	_moveRightTail1:
	
	li $a2, 0		# Set color to OFF
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn off old tail
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	jr $ra

## void _moveLeft()
	#  moves snake left one pixel 
	#
	#  snakeBody previously stored in $s0
	#  snakeTail address stored in $s2
	#  snakeHead address stored in $s1
	#  trashes:	$t0
	#  returns:   none
_moveLeft:
	# Set new head
	lb $a0, 0($s1)		# Load x address of current HEAD
	lb $a1, 1($s1)		# Load y address of current HEAD

	addi $t0, $s0, 78	# Address of end of array
	bne $s1, $t0, _moveLeftHead0
	add $s1, $s0, $zero	# Return to beginning of array
	j _moveLeftHead1
	
	_moveLeftHead0:
	addi $s1, $s1, 2	# Increment head address
	_moveLeftHead1:
	
	bne $a0, 0, _moveLeftCont
	li $a0, 63
	j _moveLeftCont2
	_moveLeftCont:
	addi $a0, $a0, -1	# Subtract 1 from x to move LEFT
	_moveLeftCont2:
	li $a2, 2		# Sets color to YELLOW
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _getLED		# Check to make sure next dot is clear
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	add $a3, $v0, $zero
	bne $a3, 0, _checkNextDot # if next dot isn't clear, check what it is
	sb $a0, 0($s1)		# Save new HEAD x
	sb $a1, 1($s1)		# Save new HEAD y
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn on new head
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	
	# Delete old tail
	lb $a0, 0($s2)		# Load x and y of old TAIL
	lb $a1, 1($s2)
	sb $zero, 0($s2)	# Set old TAIL to 0,0
	sb $zero, 0($s2)
	addi $t0, $s0, 78	# Address of end of array
	bne $s2, $t0, _moveLeftTail0
	add $s2, $s0, $zero	# Return to beginning of array
	j _moveLeftTail1
	
	_moveLeftTail0:
	addi $s2, $s2, 2	# Increment TAIL address
	_moveLeftTail1:
	
	li $a2, 0		# Set color to OFF
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn off old tail
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	jr $ra

## void _moveUp()
	#  moves snake up one pixel 
	#
	#  snakeBody previously stored in $s0
	#  snakeTail address stored in $s2
	#  snakeHead address stored in $s1
	#  trashes:	$t0
	#  returns:   none
_moveUp:
	# Set new head
	lb $a0, 0($s1)		# Load x address of current HEAD
	lb $a1, 1($s1)		# Load y address of current HEAD

	addi $t0, $s0, 78	# Address of end of array
	bne $s1, $t0, _moveUpHead0
	add $s1, $s0, $zero	# Return to beginning of array
	j _moveUpHead1
	
	_moveUpHead0:
	addi $s1, $s1, 2	# Increment head address
	_moveUpHead1:
	
	bne $a1, 0, _moveUpCont
	li $a1, 63
	j _moveUpCont2
	_moveUpCont:
	addi $a1, $a1, -1	# Add 1 to y to move DOWN
	_moveUpCont2:
	li $a2, 2		# Sets color to YELLOW
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _getLED		# Check to make sure next dot is clear
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	add $a3, $v0, $zero
	bne $a3, 0, _checkNextDot #if next dot isn't clear, check what it is
	sb $a0, 0($s1)		# Save new HEAD x
	sb $a1, 1($s1)		# Save new HEAD y
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn on new head
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address

	# Delete old tail
	lb $a0, 0($s2)		# Load x and y of old TAIL
	lb $a1, 1($s2)
	sb $zero, 0($s2)	# Set old TAIL to 0,0
	sb $zero, 0($s2)

	addi $t0, $s0, 78	# Address of end of array
	bne $s2, $t0, _moveUpTail0
	add $s2, $s0, $zero	# Return to beginning of array
	j _moveUpTail1
	
	_moveUpTail0:
	addi $s2, $s2, 2	# Increment TAIL address
	_moveUpTail1:
	
	li $a2, 0		# Set color to OFF
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn off old tail
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	jr $ra

## void _moveDown()
	#  moves snake down one pixel 
	#
	#  snakeBody previously stored in $s0
	#  snakeTail address stored in $s2
	#  snakeHead address stored in $s1
	#  trashes:	$t0
	#  returns:   none
_moveDown:
	# Set new head
	lb $a0, 0($s1)		# Load x address of current HEAD
	lb $a1, 1($s1)		# Load y address of current HEAD

	addi $t0, $s0, 78	# Address of end of array
	bne $s1, $t0, _moveDownHead0
	add $s1, $s0, $zero	# Return to beginning of array
	j _moveDownHead1
	
	_moveDownHead0:
	addi $s1, $s1, 2	# Increment head address
	_moveDownHead1:
	
	bne $a1, 63, _moveDownCont
	li $a1, 0
	j _moveDownCont2
	_moveDownCont:
	addi $a1, $a1, 1	# Add 1 to y to move DOWN
	_moveDownCont2:
	li $a2, 2		# Sets color to YELLOW
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _getLED		# Check to make sure next dot is clear
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	add $a3, $v0, $zero
	bne $a3, 0, _checkNextDot #if next dot isn't clear, check what it is
	sb $a0, 0($s1)		# Save new HEAD x
	sb $a1, 1($s1)		# Save new HEAD y
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn on new head
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address

	# Delete old tail
	lb $a0, 0($s2)		# Load x and y of old TAIL
	lb $a1, 1($s2)
	sb $zero, 0($s2)	# Set old TAIL to 0,0
	sb $zero, 0($s2)

	addi $t0, $s0, 78	# Address of end of array
	bne $s2, $t0, _moveDownTail0
	add $s2, $s0, $zero	# Return to beginning of array
	j _moveDownTail1
	
	_moveDownTail0:
	addi $s2, $s2, 2	# Increment TAIL address
	_moveDownTail1:
	
	li $a2, 0		# Set color to OFF
	# Call _setLED function
	addi $sp, $sp, -4	# Decrement stack address
	move $sp, $ra
	jal _setLED		# Turn off old tail
	move $ra, $sp
	addi $sp, $sp, 4	# Restore stack address
	jr $ra

# void checkNextDot(int nextColorValue, int head x, int head y)
	# only called when the next color is not black
	# handles eating frogs and wrapping around walls
	# a0 - head x, a1 - head y
	# a2 - nextColorValue
	# trashes - $t0-
_checkNextDot:
	beq $a3, 1, _dealWall
	beq $a3, 2, _mainExit
	beq $a3, 3, _eatFrog
	_dealWall:
		bne $s3, 0, _handleDown
		_handleRight:
			#if the snake is heading right, it will try going down next
			addi $a0, $a0, -1
			addi $a1, $a1, 1
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 1
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake will then try to go up
			addi $a1, $a1, -2
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 3
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake has no available moves, game over
			j _mainExit
			
		_handleDown:
			bne $s3, 1, _handleLeft
			#if the snake is heading down, it will try going left next
			addi $a0, $a0, -1
			addi $a1, $a1, -1
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 2
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake will then try to go right
			addi $a0, $a0, 2
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 0
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake has no available moves, game over
			j _mainExit
			
		_handleLeft:
			bne $s3, 2, _handleUp
			#if the snake is heading left, it will try going up next
			addi $a0, $a0, 1
			addi $a1, $a1, -1
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 3
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake will then try to go down
			addi $a1, $a1, 2
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 1
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake has no available moves, game over
			j _mainExit
			
		_handleUp:
			#if the snake is heading up, it will try going right next
			addi $a0, $a0, 1
			addi $a1, $a1, 1
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 0
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake will then try to go left
			addi $a0, $a0, -2
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _getLED		# Check to make sure next dot is clear
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			li $s3, 2
			beq $v0, 0, _nextLEDBlack
			beq $v0, 3, _nextLEDGreen
			#if this point is reached, snake has no available moves, game over
			j _mainExit
			
		_nextLEDBlack:
			sb $a0, 0($s1)		# Save new HEAD x
			sb $a1, 1($s1)		# Save new HEAD y
			# Call _setLED function
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _setLED		# Turn on new head
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
	
			# Delete old tail
			lb $a0, 0($s2)		# Load x and y of old TAIL
			lb $a1, 1($s2)
			sb $zero, 0($s2)	# Set old TAIL to 0,0
			sb $zero, 0($s2)

			addi $t0, $s0, 78	# Address of end of array
			bne $s2, $t0, _moveTail0
			add $s2, $s0, $zero	# Return to beginning of array
			j _moveTail1
	
			_moveTail0:
			addi $s2, $s2, 2	# Increment TAIL address
			_moveTail1:
			
			li $a2, 0		# Set color to OFF
			# Call _setLED function
			addi $sp, $sp, -4	# Decrement stack address
			move $sp, $ra
			jal _setLED		# Turn off old tail
			move $ra, $sp
			addi $sp, $sp, 4	# Restore stack address
			jr $ra 			# Jumps back to main 
			
		_nextLEDGreen:
			j _eatFrog
	
	_eatFrog: 
		# When frog is eaten, tail will remain in its original location and the snake will get longer
		# Therefore, all tail operations will be skipped entrely
		sb $a0, 0($s1)		# Save new HEAD x
		sb $a1, 1($s1)		# Save new HEAD y
		# Call _setLED function
		li $a2, 2
		addi $sp, $sp, -4	# Decrement stack address
		move $sp, $ra
		jal _setLED		# Turn on new head
		move $ra, $sp
		addi $sp, $sp, 4	# Restore stack address
		addi $s7, $s7, 1 	# increments the length of snake
		jr $ra 			# skips rest of move method and jumps back to main



# void delay()
	# delays game by 200ms and increments runtime variable
_delay:
	li $v0, 32
	li $a0, 200
	syscall
	addi $s6, $s6, 200 # increments runtime variable
	jr $ra
