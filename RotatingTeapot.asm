# Alexander Chatron-Michaud, 260611509

.data  # start data segment with bitmapDisplay so that it is at 0x10010000
.globl bitmapDisplay # force it to show at the top of the symbol table
bitmapDisplay:  .space 0x80000 # Reserve space for memory mapped bitmap display
bitmapBuffer:   .space 0x80000 # Reserve space for an "offscreen" buffer
width:          .word 512 # Screen Width in Pixels
height:         .word 256 # Screen Height in Pixels
Result: .space 16
M: .float
331.3682, 156.83034, -163.18181, 1700.7253
-39.86386, -48.649902, -328.51334, 1119.5535
0.13962941, 1.028447, -0.64546686, 0.48553467
0.11424224, 0.84145665, -0.52810925, 6.3950152
R: .float
0.9994, 0.0349, 0, 0
-0.0349, 0.9994, 0, 0
0, 0, 1, 0
0, 0, 0, 1

.text 

main:		
		addi $s0, $0, 0x00006600 	#set clear color
		addi $s1, $0, 0x00ffffff	#set drawpoint color
mainLoop:	add $a0, $0, $s0		#put clear color in a0 for clear buffer
		jal ClearBuffer			#clear buffer
		jal drawTeapot			#print a teapot in buffer
		jal rotateTeapot		#rotate lineData for next teapot
		jal CopyBuffer			#copy current teapot into image
		j mainLoop 			#continue process
exit:		addi $v0, $0, 10 		#exit program
		syscall

########################################################################################

rotateTeapot:	addi $sp, $sp, -4
		sw $ra, 0($sp)
		add $t8, $0, $0			#start counter at zero
		lw $t9, LineCount		#get counter
		mul $t9, $t9, 32		#set counter max
rotateLoop:		
		la $a0, R			#load R
		la $a1, LineData($t8)		#load lineData + t8
		la $a2, Result 			#load Result
		jal MatrixMult			#put mult of matrix in Result
		
		lwc1 $f1, 0($s6)		#first value in f1
		swc1 $f1, LineData($t8)		#store in slot
		
		addi $t8, $t8, 4		#increment address
		la $a1, LineData($t8)		#load lineData + t8
		
		lwc1 $f1, 4($s6)		#second value in f1
		swc1 $f1, LineData($t8)		#store in slot
		
		addi $t8, $t8, 4		#increment address
		la $a1, LineData($t8)		#load lineData + t8
		
		lwc1 $f1, 8($s6)		#third value in f1
		swc1 $f1, LineData($t8)		#store in slot
		
		addi $t8, $t8, 4		#increment address
		la $a1, LineData($t8)		#load lineData + t8
		
		lwc1 $f1, 12($s6)		#fourth value in f1
		swc1 $f1, LineData($t8)		#store in slot
		
		addi $t8, $t8, 4		#increment t8 to next line
		bne $t8, $t9, rotateLoop	#if we still have more to go, keep transforming points
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

########################################################################################

	
drawTeapot:     addi $sp, $sp, -8
		sw $ra, 0($sp)	
		add $t8, $0, $0			#start counter at zero
		lw $t9, LineCount		#get counter
		mul $t9, $t9, 32		#set counter max
		
teapotLoop:	la $a0, M			#load M
		la $a1, LineData($t8)		#load lineData + t8
		la $a2, Result 			#load Result
		jal MatrixMult			#put mult of matrix in Result
		
		lwc1 $f2, 0($s6)
		lwc1 $f4, 12($s6)
		div.s $f2, $f2, $f4		#x/w
		round.w.s $f10, $f2		#x/w in x0
		lwc1 $f2, 4($s6)
		lwc1 $f4, 12($s6)
		div.s $f2, $f2, $f4		#y/w
		round.w.s $f11, $f2		#y/w in y0
		addi $t8, $t8, 16		#increment t0 to next line
		la $a0, M			#load M
		la $a1, LineData($t8)		#load lineData + t8
		la $a2, Result 			#load Result
		jal MatrixMult			#put mult of matrix in Result
		lwc1 $f2, 0($s6)
		lwc1 $f4, 12($s6)
		div.s $f2, $f2, $f4		#x/w
		round.w.s $f12, $f2		#x/w in x1
		lwc1 $f2, 4($s6)
		lwc1 $f4, 12($s6)
		div.s $f2, $f2, $f4		#y/w
		round.w.s $f13, $f2		#y/w in y1
		addi $t8, $t8, 16		#increment t8 to next line
		
		
		mfc1 $a0, $f10
		mfc1 $a1, $f11
		mfc1 $a2, $f12
		mfc1 $a3, $f13
		
		bne $a1, $a3, nt01dx
		addi $a3, $a3, 1
		
nt01dx:		jal DrawLine
		
		bne $t8, $t9, teapotLoop	#if we still have more to go, draw more lines
		lw $ra, 0($sp)
		addi $sp, $sp, 8
		jr $ra
####################################################################################		
#preconditions: clear color is in a0		
		
ClearBuffer: 					
		la  $t1, 0x10110000  		#end address
		la  $t0, 0x10090000 		#set start address
		add $t4, $a0, $0 		#set t4 to the clear color
ClearBufferLoop:
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		sw $t4, ($t0) 			#save t4's word into address t0
		addi $t0, $t0, 4    		#go to next pixel
		bne $t1, $t0, ClearBufferLoop 	#if we haven't reached the end do next pixel
		jr $ra				#return to ra if done
		
####################################################################################
#preconditions: none

CopyBuffer:					
		la  $t0, 0x10090000  		#start address of buffer
		la  $t1, 0x10110000  		#end address of buffer
		la  $t3, 0x10010000 		#start address of image
CopyBufferLoop: 
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		lw  $t4, ($t0) 			#load word of current pixel in buffer to t4
		sw $t4, ($t3) 			#save t4's word into current image pixel t3
		addi $t0, $t0, 4    		#go to next pixel in buffer
		addi $t3, $t3, 4		#go to next pixel in image
		bne $t1, $t0, CopyBufferLoop 	#if we haven't reached the end do next pixel
		jr $ra				#return to ra if done
		
####################################################################################
#preconditions: point color in s1, x coord in a0, y coord in a1

DrawPoint:					
		la  $t4, 0x10090000  		#start address of buffer
		blt $a0, $0, ExitDrawPoint	#if x<0 exit
		blt $a1, $0, ExitDrawPoint	#if y<0 exit
		bgt $a0, 512, ExitDrawPoint	#if x>512 exit
		bgt $a1, 512, ExitDrawPoint	#if y>512 exit
		add $t5, $a0, $0		#x in t5			#b + 4(x + 512y)
		mul $t6, $a1, 512		#pseudoinstruction, puts 512y in t6
		add $t6, $t5, $t6		#x+512y in t7
		mul $t6, $t6, 4			#4(x+512y) in t7
		add $t6, $t4, $t6		#b+4(x+512y) in t7
		sw $s1, ($t6)			#save s1's word into address t7	
ExitDrawPoint:	jr $ra	

####################################################################################
#preconditions: x0 in a0, y0 in a1, x1 in a2, y2 in a3
		
DrawLine:					
		sw $ra, 4($sp)
		addi $t0, $0, 1			#offSetX = 1
		addi $t1, $0, 1			#offsetY = 1
		sub $t2, $a2, $a0		#dX = x1 - x0
		sub $t3, $a3, $a1		#dY = y1 - y0
		blt $t2, $0, DXNegative		#if (dx < 0)
		j DXPositive			#else skip
DXNegative:	sub $t2, $0, $t2		#dX = -dX
		addi $t0, $0, -1		#offSetX = -1																			
DXPositive:	
		blt $t3, $0, DYNegative		#if (dY < 0)
		j DYPositive			#else skip
DYNegative:	sub $t3, $0, $t3		#dY = -dY
		addi $t1, $0, -1		#offSetY = -1
DYPositive:	
		jal DrawPoint			#drawpoint(x,y)
		bgt $t2, $t3, DXGreater		#if (dX > dY)
		j DYGreater			#else go to DYGreater
DXGreater:	
		add $t7, $t2, $0		#error = dX
		sll $t3, $t3, 1			#dY = dY*2
		sll $t2, $t2, 1			#dX = dX*2
DXLoop:		sub $t7, $t7, $t3		#error = error - 2dY
		blt $t7, $0, DXErrorNeg		#if (error<0)
		j DXErrorPos
DXErrorNeg:	add $a1, $a1, $t1		#y=y+offsety
		add $t7, $t7, $t2		#error = error + 2dX
DXErrorPos:	add $a0, $a0, $t0		#x=x+offsetx
		jal DrawPoint			#drawpoint(x,y)
		bne $a0, $a2, DXLoop		#while x is not than x1
		j EndDrawLine
DYGreater:	
		add $t7, $t2, $0		#error = dY
		sll $t3, $t3, 1			#dY = dY*2
		sll $t2, $t2, 1			#dX = dX*2
DYLoop:		sub $t7, $t7, $t2		#error = error - 2dX
		blt $t7, $0, DYErrorNeg		#if (error<0)
		j DYErrorPos
DYErrorNeg:	add $a0, $a0, $t0		#x=x+offsetx
		add $t7, $t7, $t3		#error = error + 2dY
DYErrorPos:	add $a1, $a1, $t1		#y=y+offsety
		jal DrawPoint			#drawpoint(x,y)
		
		bne $a1, $a3, DYLoop		#while y is not than y1
		j EndDrawLine
EndDrawLine:	lw $ra, 4($sp)
		jr $ra

####################################################################################
#preconditions: Matrix in a0, Vector in a1, Result in a2
		
MatrixMult:	
		la $s4, ($a0)			#load address of Matrix into s4
		la $s5, ($a1)			#load address of Vector into s5
		la $s6, ($a2)			#load address of Result into s6
		lwc1 $f4, 0($s4)		#load matrix(0)
		lwc1 $f6, 0($s5)		#load vector(0)
		mul.s $f16, $f4, $f6		#product in f16
		mov.s $f18, $f16		#first product in f18
		lwc1 $f4, 4($s4)		#load matrix(4)
		lwc1 $f6, 4($s5)		#load vector(4)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second product in f18
		lwc1 $f4, 8($s4)		#load matrix(8)
		lwc1 $f6, 8($s5)		#load vector(8)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third product in f18
		lwc1 $f4, 12($s4)		#load matrix(12)
		lwc1 $f6, 12($s5)		#load vector(12)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third+fourth product in f18
		swc1 $f18, 0($s6)		#put f18 in result(0)
		
		lwc1 $f4, 16($s4)		#load matrix(16)
		lwc1 $f6, 0($s5)		#load vector(0)
		mul.s $f16, $f4, $f6		#product in f16
		mov.s  $f18, $f16		#first product in f18
		lwc1 $f4, 20($s4)		#load matrix(20)
		lwc1 $f6, 4($s5)		#load vector(4)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second product in f18
		lwc1 $f4, 24($s4)		#load matrix(24)
		lwc1 $f6, 8($s5)		#load vector(8)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third product in f18
		lwc1 $f4, 28($s4)		#load matrix(28)
		lwc1 $f6, 12($s5)		#load vector(12)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third+fourth product in f18
		swc1 $f18, 4($s6)		#put f18 in result(4)
		
		lwc1 $f4, 32($s4)		#load matrix(32)
		lwc1 $f6, 0($s5)		#load vector(0)
		mul.s $f16, $f4, $f6		#product in f16
		mov.s $f18, $f16		#first product in f18
		lwc1 $f4, 36($s4)		#load matrix(36)
		lwc1 $f6, 4($s5)		#load vector(4)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second product in f18
		lwc1 $f4, 40($s4)		#load matrix(40)
		lwc1 $f6, 8($s5)		#load vector(8)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third product in f18
		lwc1 $f4, 44($s4)		#load matrix(44)
		lwc1 $f6, 12($s5)		#load vector(12)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third+fourth product in f18
		swc1 $f18, 8($s6)		#put f18 in result(8)
		
		lwc1 $f4, 48($s4)		#load matrix(48)
		lwc1 $f6, 0($s5)		#load vector(0)
		mul.s $f16, $f4, $f6		#product in f16
		mov.s $f18, $f16		#first product in f18
		lwc1 $f4, 52($s4)		#load matrix(52)
		lwc1 $f6, 4($s5)		#load vector(4)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second product in f18
		lwc1 $f4, 56($s4)		#load matrix(56)
		lwc1 $f6, 8($s5)		#load vector(8)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third product in f18
		lwc1 $f4, 60($s4)		#load matrix(60)
		lwc1 $f6, 12($s5)		#load vector(12)
		mul.s $f16, $f4, $f6		#product in f16
		add.s $f18, $f18, $f16		#first+second+third+fourth product in f18
		swc1 $f18, 12($s6)		#put f18 in result(12)
		jr $ra
		
		
		
		
								
																														
																																			
																																										
																																																	
																																																															
