.data
	array: .space 200
	intNum: .word
	floatNum: .double
	const: .float 0
	stack: .space 64	
	const1:	.double 100000000 10000000000000000 0 10 1 -1		#constant
	expression: .space 100
	resultfile:.space 100
	file: .asciiz "calc_log.txt"
	prompt: .asciiz "\nPlease insert your expression: "
	invalid: .asciiz "You inserted an invalid character in your expression"
	result: .asciiz "\nResult: "
	quit: .asciiz "quit"
	matherror: .asciiz "Math error"
.text
###############################################################
open_file_write:	# Open file (to writing)
	li $v0, 13
	la $a0, file
	li $a1, 1
	li $a2, 0
	syscall
	move $s7, $v0
	
#######################################################################
main:	# Enter string input of expression by user and write it to file
	li $v0, 4
	la $a0, prompt
	syscall
	li $v0, 8
	la $a0, expression
	li $a1, 100
	syscall
	
	li $t9, 0
	li $s0, 0
	
check: #check valid characters
	lb $t8, expression($t9)
	beq $t8, 10, write # 10: line feed
	beq $t8, ' ', continue
	beq $t8, '0', continue
	beq $t8, '1', continue
	beq $t8, '2', continue
	beq $t8, '3', continue
	beq $t8, '4', continue
	beq $t8, '5', continue
	beq $t8, '6', continue
	beq $t8, '7', continue
	beq $t8, '8', continue
	beq $t8, '9', continue
	beq $t8, '+', continue
	beq $t8, '-', continue
	beq $t8, '*', continue
	beq $t8, '/', continue2
	beq $t8, '.', continue1
	beq $t8, 'M', continue
	beq $t8, '^', continue
	beq $t8, '!', continue
	beq $t8, '(', continue3
	beq $t8, ')', continue
	beq $t8, 'q', forceQuit

		
error:	li $v0, 4 	# if the character is not allowed -> print error prompt
	la $a0, invalid
	syscall
	j reset
math_error:
	li $v0, 4 	# if the character is not allowed -> print error prompt
	la $a0, matherror
	syscall
	j reset
#######################################################################			
continue: #excute loop
	addi $t9, $t9, 1
	j check
continue1: #chech valid decimal number
	addi $t9, $t9, -1
	lb $t4, expression($t9)
	beq $t4, '\0', math_error
	beq $t4, 'M', math_error
	beq $t4, '+', math_error
	beq $t4, '-', math_error
	beq $t4, '*', math_error
	beq $t4, '/', math_error
	beq $t4, '^', math_error
	beq $t4, '!', math_error
	addi $t9, $t9, 2
	lb $t4, expression($t9)
	beq $t4, 'M', math_error
	j check
continue2:
	addi $t9, $t9, 1
	lb $t7, expression($t9)
	beq $t7, '0', error
	beq $t7, '/', error
	j check
continue3:
	addi $t9, $t9, -1
	lb $t4, expression($t9)
	beq $t4, '0', math_error
	beq $t4, '1', math_error
	beq $t4, '2', math_error
	beq $t4, '3', math_error
	beq $t4, '4', math_error
	beq $t4, '5', math_error
	beq $t4, '6', math_error
	beq $t4, '7', math_error
	beq $t4, '8', math_error
	beq $t4, '9', math_error
	addi $t9, $t9, 2
	j check
#######################################################################
write:
	###############################################################
	# Write to file just open
	li $v0, 15
	move $a0, $s7
	la $a1, prompt
	li $a2, 32
	syscall
	###############################################################
	li $v0, 15
	move $a0, $s7
	la $a1, expression
	move $a2, $t9
	syscall

#######################################################################
infix_to_postfix:
	li $t9, 0 # use for expression
	li $t7, 0 # use for array
	move $t0, $sp # $t0 is stack pointer
	li $t6, ' ' # add white space \
	li $t2, 0	# count minus
	li $t1, 0	#chech '(' whether already yet
	condition:
		addi $t9, $t9 ,-1
       		lb $t4, expression($t9) # detect negetive number
		addi $t9, $t9 ,1
		lb $t8, expression($t9)	
		addi $t9, $t9 ,1
		lb $t3, expression($t9)
		beq $t8, 10, moreStep
		beq $t8, '(', addIm1
		beq $t8, ')', readClose
		beq $t8, '0', readNum
		beq $t8, '1', readNum
		beq $t8, '2', readNum
		beq $t8, '3', readNum
		beq $t8, '4', readNum
		beq $t8, '5', readNum
		beq $t8, '6', readNum
		beq $t8, '7', readNum
		beq $t8, '8', readNum
		beq $t8, '9', readNum
		beq $t8, 'M', readNum
		beq $t8, '.', readNum
		beq $t8, '+', readOp_st
		beq $t8, '-', checkNegative
		beq $t8, '*', readOp_nd
		beq $t8, '/', readOp_nd
		beq $t8, '^', readOp_rd
		beq $t8, '!', readFac
		#######################################################################
		readNum:
			bnez $t2, minus
		   gt:	sb $t8, array($t7)
			addi $t7, $t7, 1
			j condition
			minus:
				bnez $t1, gt
				beq $t3, '1', gt
				beq $t3, '2', gt
				beq $t3, '3', gt
				beq $t3, '4', gt
				beq $t3, '5', gt
				beq $t3, '6', gt
				beq $t3, '7', gt
				beq $t3, '8', gt
				beq $t3, '9', gt
				beq $t8, '+', skipit
				beq $t8, '-', skipit
				sb $t8, array($t7)
				addi $t7, $t7, 1	
			minus1:	beqz $t2, condition
				addi $t2, $t2, -1
				sb $t6, array($t7)
				addi $t7, $t7, 1
				lb $t5, 0($t0)
				addi $t0, $t0, 1
				sb $t5, array($t7)
				addi $t7, $t7, 1
				j minus1
				skipit:
					sb $t8, array($t7)
					addi $t7, $t7, 1
					j condition
		#######################################################################
		readOp_st:
			jal checkPositive
			sb $t6, array($t7)
			addi $t7, $t7, 1
			lb $t5, 0($t0)
			beq $t5, '+', addArray
			beq $t5, '-', addArray
			beq $t5, '*', addArray
			beq $t5, '/', addArray
			beq $t5, '^', addArray
			beq $t5, '(', addIm
			j addIm
			addArray:
				sb $t5, array($t7)
				addi $t7, $t7, 1
				addi $t0, $t0, 1
				j readOp_st
			checkPositive:
				beq $t4, '+', pushStack
				beq $t4, '-', pushStack
				beq $t4, '*', pushStack
				beq $t4, '/', pushStack
				j ra
		#######################################################################
		checkNegative:
			beq $t4, '+', checkOnemore
			beq $t4, '-', checkOnemore
			beq $t4, '*', checkOnemore
			beq $t4, '/', checkOnemore
			beq $t4, '^', checkOnemore
			beq $t4, '(', checkOnemore
			beq $t3, '-', pushStack
			beq $t3, '+', pushStack
			j readOp_st
			
			checkOnemore:
				li $s1,0
				beq $t3, '0', readNum
				beq $t3, '1', readNum
				beq $t3, '2', readNum
				beq $t3, '3', readNum
				beq $t3, '4', readNum
				beq $t3, '5', readNum
				beq $t3, '6', readNum
				beq $t3, '7', readNum
				beq $t3, '8', readNum
				beq $t3, '9', readNum
				beq $t3, '-', pushStack
				beq $t3, '+', pushStack
				beq $t3, '(', pushStack
				j readOp_st
				pushStack:
					beq $t1, 1, goto
					addi $t2, $t2, 1
				  goto:	sb $t6, array($t7)
					addi $t7, $t7, 1
					li $t3, '0'
					sb $t3, array($t7)
					addi $t7, $t7, 1
					sb $t6, array($t7)
					addi $t7, $t7, 1
					addi $t0, $t0, -1
					sb $t8, 0($t0)
					j condition
		#######################################################################		
		readOp_nd:
			sb $t6, array($t7)
			addi $t7, $t7, 1
			lb $t5, 0($t0)
			beq $t5, '+', addIm
			beq $t5, '-', addIm
			beq $t5, '*', addArray1
			beq $t5, '/', addArray1
			beq $t5, '^', addArray1
			j addIm
			addArray1:
				sb $t5, array($t7)
				addi $t7, $t7, 1
				addi $t0, $t0, 1
				j readOp_nd
		#######################################################################
		readOp_rd:
			sb $t6, array($t7)
			addi $t7, $t7, 1
			lb $t5, 0($t0)
			beq $t5, '+', addIm
			beq $t5, '-', addIm
			beq $t5, '*', addIm
			beq $t5, '/', addIm
			beq $t5, '^', addArray1
			j addIm
		#######################################################################	
		readFac:
			sb $t6, array($t7)
			addi $t7, $t7, 1
			sb $t8, array($t7)
			addi $t7, $t7, 1
			j condition
		#######################################################################	
		addIm:
			addi $t0, $t0, -1
			sb $t8, 0($t0)
			j condition
		#######################################################################
		addIm1:
			li $t1, 1
		   	addi $t0, $t0, -1
			sb $t8, 0($t0)
			j condition
		#######################################################################
		readClose:
			beq $t0, $sp, math_error
			lb $t5, 0($t0)
			beq $t5, '(', deleteOp	
			addi $t0, $t0, 1	
			sb $t6, array($t7)			
			addi $t7, $t7, 1
			sb $t5, array($t7)
			addi $t7, $t7, 1
			j readClose
		#######################################################################	
		deleteOp:
			li $t1, 0
			addi $t0, $t0, 1
			lb $t5, 0($t0)
			beq $t5, '(', condition
			bnez $t2, minus1
			j condition
#######################################################################
moreStep:	#push all operater that left in stack into postfix string
	sb $t6, array($t7)
	addi $t7, $t7, 1
	lb $t5, 0($t0)
	addi $t0, $t0, 1
	beq $t5, '(', moreStep1
	sb $t5, array($t7)
	addi $t7, $t7, 1
	lb $t5, 0($t0)
	beq $t5, '+', moreStep
	beq $t5, '-', moreStep
	beq $t5, '*', moreStep
	beq $t5, '/', moreStep
	beq $t5, '^', moreStep
	beq $t5, '(', moreStep1
	sb $t8, array($t7)
	j Implement_calculation
	moreStep1:
		j moreStep
	
#######################################################################
Implement_calculation:
	li $t9, 0
	li $t6, 0
	li $t5, 10	
	li $s2, 0 	# intNum pointer
	li $s3, 0 	# floatNum pointer
	calculate:
		addi $t9, $t9 ,-1
		lb $t4, array($t9)	# previuous value of array with $t8 is main value
		addi $t9, $t9, 1
		lb $t8, array($t9)	# main value use for calculate
		addi $t9, $t9, 1
		lb $t7, array($t9)	# next value of array with $t8 is main value
		beq $t8, 10, printnew
		beq $t8, ' ', skipSpace
		beq $t8, '0', saveNum
		beq $t8, '1', saveNum
		beq $t8, '2', saveNum
		beq $t8, '3', saveNum
		beq $t8, '4', saveNum
		beq $t8, '5', saveNum
		beq $t8, '6', saveNum
		beq $t8, '7', saveNum
		beq $t8, '8', saveNum
		beq $t8, '9', saveNum
		beq $t8, 'M', readM
		beq $t8, '.', calcDot
		beq $t8, '+', calcAdd
		beq $t8, '-', calcSub
		beq $t8, '*', calcMul
		beq $t8, '/', calcDiv
		beq $t8, '^', calcPow
		beq $t8, '!', calcFactor
		###############################################################
		saveNum:
			beq $t4, '-', saveNegative
			blt $t6, 0, saveNegative
			subi $t8, $t8, '0'
			mul $t6, $t6, $t5
			add $t6, $t6, $t8
			j calculate
			saveNegative:
					subi $t8, $t8, '0'
					sub $t8, $0, $t8
					mul $t6, $t6, $t5
					add $t6, $t6, $t8
					j calculate
		###############################################################
		readM:
			addi $s3, $s3, 8
			s.d $f30, floatNum($s3)
			addi $t9, $t9, 1
			li $t6, 0
			j calculate
		###############################################################
		calcDot:
			addi $s2, $s2, 4
			sw $t6, intNum($s2)
			lwc1 $f2, intNum($s2)
			cvt.d.w $f2, $f2
			addi $s2, $s2, -4
			li $t7, 10
			li $s1, 0
			mtc1 $s1, $f28
			cvt.d.w $f28, $f28
			calcDot1:
				lb $t8, array($t9)
				addi $t9 ,$t9, 1
				beq $t8, ' ', saveFloat
			
				subi $t8, $t8, '0'
				
				addi $s2, $s2, 4
				sw $t8, intNum($s2)
				lwc1 $f4, intNum($s2)
				cvt.d.w $f4, $f4
				addi $s2, $s2, -4
				
				addi $s2, $s2, 4
				sw $t5, intNum($s2)
				lwc1 $f6, intNum($s2)
				cvt.d.w $f6, $f6
				addi $s2, $s2, -4
				
				
				div.d $f4, $f4, $f6
				
				c.lt.d $f2, $f28
				bc1t change
		      nownow5:	add.d $f2, $f2, $f4
				mul $t5, $t5, $t7
				
				j calcDot1
				change:
					sub.d $f4, $f28, $f4
					j nownow5
			saveFloat:
				addi $s3, $s3, 8
				s.d $f2, floatNum($s3)
				li $t6, 0
				li $t5, 10
				
				j calculate
		###############################################################
		skipSpace:
			beq $t9, 1, backCalculate
			beq $t4, '+', backCalculate
			beq $t4, '-', backCalculate
			beq $t4, '*', backCalculate
			beq $t4, '/', backCalculate
			beq $t4, '^', backCalculate
			beq $t4, '!', backCalculate
			beq $t4, ' ', backCalculate
			addi $s2, $s2, 4
			sw $t6, intNum($s2)
			lwc1 $f2, intNum($s2) 
			cvt.d.w $f2, $f2
			addi $s2, $s2, -4
			addi $s3, $s3, 8
			s.d $f2, floatNum($s3)
			
			li $t6, 0
			j calculate
			backCalculate:
				j calculate
		###############################################################
		calcAdd:
			l.d $f4, floatNum($s3)
			addi $s3, $s3, -8
			l.d $f2, floatNum($s3)
			addi $s3, $s3, -8
			add.d $f2, $f2, $f4
			addi $s3, $s3, 8
			s.d $f2, floatNum($s3)
			
			j calculate
		###############################################################
		calcSub:
			beq $t7, '0', backCalculate
			beq $t7, '1', backCalculate
			beq $t7, '2', backCalculate
			beq $t7, '3', backCalculate
			beq $t7, '4', backCalculate
			beq $t7, '5', backCalculate
			beq $t7, '6', backCalculate
			beq $t7, '7', backCalculate
			beq $t7, '8', backCalculate
			beq $t7, '9', backCalculate
			l.d $f4, floatNum($s3)
			addi $s3, $s3, -8
			l.d $f2, floatNum($s3)
			addi $s3, $s3, -8
			sub.d $f2, $f2, $f4
			addi $s3, $s3, 8
			s.d $f2, floatNum($s3)
			
			j calculate
		###############################################################
		calcMul:
			l.d $f4, floatNum($s3)
			addi $s3, $s3, -8
			l.d $f2, floatNum($s3)
			addi $s3, $s3, -8
			mul.d $f2, $f2, $f4
			addi $s3, $s3, 8
			s.d $f2, floatNum($s3)
			
			j calculate
		###############################################################
		calcDiv:
			l.d $f4, floatNum($s3)
			addi $s3, $s3, -8
			l.d $f2, floatNum($s3)
			addi $s3, $s3, -8
			div.d $f2, $f2, $f4
			addi $s3, $s3, 8
			s.d $f2, floatNum($s3)
				
			j calculate
		###############################################################
		calcPow:
			l.d $f4, floatNum($s3)
			addi $s3, $s3, -8
			l.d $f2, floatNum($s3)
			addi $s3, $s3, -8
			
			mov.d $f6, $f2
			li $t3, 0
			mtc1 $t3, $f8
			cvt.d.w $f8, $f8
			
			jal checkPow
			
			li $t3, 1
			mtc1 $t3, $f10
			cvt.d.w $f10, $f10
			
			c.lt.d $f4, $f8
			bc1t powNegative
			
			c.eq.d $f4, $f8
			bc1f pow
			
			addi $s3, $s3, 8
			s.d $f10, floatNum($s3)
			j calculate
			checkPow:
				c.eq.d $f4, $f8
				bc1t checkPow1
				j ra
				checkPow1:
					c.eq.d $f2, $f8
					bc1t math_error
					j ra
			pow:	
				c.eq.d $f4, $f10
				bc1t savePow
				sub.d $f4, $f4, $f10
				mul.d $f2, $f2, $f6
				j pow
				
				savePow:
					addi $s3, $s3, 8
					s.d $f2, floatNum($s3)
					
					j calculate
			
			powNegative:
				sub.d $f4, $f8, $f4
			powNegative1:
				c.eq.d $f4, $f10
				bc1t savePowNegative
				sub.d $f4, $f4, $f10
				mul.d $f2, $f2, $f6
				j powNegative1
				savePowNegative:
					div.d $f2, $f10, $f2
					j savePow
		###############################################################			
		calcFactor:
			l.d $f4, floatNum($s3)
			addi $s3, $s3, -8
			
			li $t3, 0
			mtc1 $t3, $f8
			cvt.d.w $f8, $f8
			c.lt.d $f4, $f8
			bc1t math_error
			mov.d $f2, $f4
			
			li $t3, 0
			mtc1 $t3, $f8
			cvt.d.w $f8, $f8
			
			li $t3, 1
			mtc1 $t3, $f10
			cvt.d.w $f10, $f10
			factor:
				c.lt.d $f4, $f8
				bc1t math_error
				c.eq.d $f4, $f10
				bc1t saveFactor
				sub.d $f4, $f4, $f10
				mul.d $f2, $f2, $f4
				j factor
				saveFactor:
					addi $s3, $s3, 8
					s.d $f2, floatNum($s3)
					
					j calculate
#######################################################################					
ra:
	jr $ra
#######################################################################	
printnew:
	la $a0, result
	li $v0, 4
	syscall
	
	li $v0, 15
	move $a0, $s7
	la $a1, result
	li $a2, 9
	syscall
	
	l.d $f30, floatNum($s3)		#use for M
	
	l.d $f12, floatNum($s3)
	li $v0, 3
	syscall
#######################################################################
cvt_to_string:
	li $t2, 0
	li $s4, 0
	mov.d $f4, $f30
	l.d $f28, const1($s4)
	addi $s4, $s4, 8
	l.d $f26, const1($s4)
	addi $s4, $s4, 8
	l.d $f24, const1($s4)
	addi $s4, $s4, 8
	l.d $f10, const1($s4)
	addi $s4, $s4, 8
	l.d $f8, const1($s4)
	addi $s4, $s4, 8
	l.d $f6, const1($s4)
	
	cvt.w.d $f22, $f30
	cvt.d.w $f22, $f22
	c.lt.d $f22, $f24
	bc1t saveNe
	
nownow2:
	mov.d $f16, $f22
	jal intPart
			
	add.d $f20, $f4, $f24	
	mul.d $f22, $f22, $f26
	mul.d $f20, $f20, $f26
	
	sub.d $f20, $f20, $f22
	div.d $f22, $f20, $f28
	
	round.w.d $f18, $f22
	cvt.d.w $f18, $f18
	
	sub.d $f14, $f22, $f18
	
	c.lt.d $f14, $f24
	bc1t subnow
nownow1:
	sub.d $f22, $f22, $f18
	j afterdot
	
nownow:	
	mul.d $f22, $f22, $f28
	c.eq.d $f22, $f24
	bc1f afterdot1
	j write_result_into_file	
	subnow:
		sub.d $f18, $f18, $f8
		j nownow1
	saveNe:
		li $s1, '-'
		sb $s1, resultfile($t2)
		addi $t2, $t2, 1
		mul.d $f4, $f4, $f6
		mul.d $f22, $f22, $f6
		j nownow2
	intPart:
		li $t1, 0
		li $t4, 0
		cvt.w.d $f16, $f16
		mfc1 $s1, $f16
		li $s2, 10
		beqz $s1, printIntnow
		countNum:
			beq $s1, 0, printInt
			div $s1, $s2
			mflo $s1
			mfhi $s4
			addi $s4, $s4, '0'
			addi $t4, $t4, 1
			sb $s4, stack($t4)
			j countNum
		printIntnow:
			addi $s1, $s1, '0'
			sb $s1, resultfile($t2)
			addi $t2, $t2, 1
			j stackdot
		printInt:
			beqz $t4, stackdot
			lb $s1, stack($t4)
			addi $t4, $t4, -1
			sb $s1, resultfile($t2)
			addi $t2, $t2, 1	
			j printInt
			stackdot:
				li $s1, '.'
				sb $s1, resultfile($t2)
				addi $t2, $t2, 1
				j ra
		
	afterdot:
		li $t1, 0
		li $t4, 0
		cvt.w.d $f18, $f18
		mfc1 $s1, $f18
		li $s2, 10
		countNum1:
			beq $s1, 0, printAfterdot
			div $s1, $s2
			mflo $s1
			mfhi $s4
			addi $s4, $s4, '0'
			addi $t4, $t4, 1
			sb $s4, stack($t4)
			j countNum1
			printAfterdot:
				beqz $t4, nownow
				lb $s1, stack($t4)
				addi $t4, $t4, -1
				sb $s1, resultfile($t2)
				addi $t2, $t2, 1	
				j printAfterdot
	afterdot1:
		li $t1, 0
		li $t4, 0
		cvt.w.d $f22, $f22
		mfc1 $s1, $f22
		li $s2, 10
		countNum2:
			beq $s1, 0, printAfterdot2
			div $s1, $s2
			mflo $s1
			mfhi $s4
			addi $s4, $s4, '0'
			addi $t4, $t4, 1
			sb $s4, stack($t4)
			j countNum2
			printAfterdot2:
				beqz $t4, write_result_into_file
				lb $s1, stack($t4)
				addi $t4, $t4, -1
				sb $s1, resultfile($t2)
				addi $t2, $t2, 1	
				j printAfterdot2
#######################################################################
write_result_into_file:	
	addi $t2, $t2, -1
	lb $t1, resultfile($t2)
	beq $t1, '.', delstr1
	beq $t1, '0', delstr
nowwrite:	
	li $v0, 15
	move $a0, $s7
	la $a1, resultfile
	li $a2, 34
	syscall
	
	j result_file_reset
	delstr:
		li $t1, ' '
		sb $t1, resultfile($t2)
		j write_result_into_file
	delstr1:
		li $t1, ' '
		sb $t1, resultfile($t2)
		j nowwrite
#######################################################################
result_file_reset:
	li $t1, 34
	li $t2, 0
	li $t3, 0
	resetfile:
		beq $t1, $t2, reset
		sb $t3, resultfile($t2)
		addi $t2, $t2,1 
		j resetfile
#######################################################################
reset:
	li $t1, 0	
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s6, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	j main
#######################################################################
forceQuit:
	addi $t9, $t9 ,1
	lb $t8, expression($t9)
	beq $t8, 'u', quit1
	quit1:
		addi $t9, $t9 ,1
		lb $t8, expression($t9)
		beq $t8, 'i', quit2
		j error
		quit2:
			addi $t9, $t9 ,1
			lb $t8, expression($t9)
			beq $t8, 't', exit
			j error
#######################################################################			
exit:
	li $v0, 10
	syscall
