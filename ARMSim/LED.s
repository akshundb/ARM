.equ SWI_GetTicks, 0x6d @ Gets current time 
.equ Sec1, 1000 @ 1 seconds interval
.equ Point1Sec, 100 @ 0.1 seconds interval
.equ EmbestTimerMask, 0x7fff  @ 15 bit mask for timer values
.equ Top15bitRange, 0x0000ffff @(2^15) -1 = 32,767
.equ SWI_Exit,0x11

.global _start
.text


_start:

LED:
	mov r0,	#0x02 			;make LED 2 Glow
	swi 0x201 			;glow LED
	
	bl Wait 			;get time gap	
	
	mov r0,#0x01
	swi 0x201
	
	bl Wait
	
	bal LED

Wait:
	ldr r10,=Sec1
	ldr r7, =EmbestTimerMask
	ldr r8, =Top15bitRange
	swi SWI_GetTicks
	mov r1,r0
	and r1,r1,r7 @ T1 in 15 bits

WaitLoop:
	swi SWI_GetTicks
	mov r2,r0 @ get T2
	and r2,r2,r7 @ T2 in 15 bits
	cmp r2,r1 
	bge simpleTime @ ? T2>T1
	sub r9,r8,r1 @ TIME = Top15bitRange-T1+T2
	add r9,r9,r2 @ TIME
	bal checkInt

simpleTime:
	sub r9,r2,r1 @ TIME = T2-T1

checkInt:
	cmp r9,r10
	blt WaitLoop

	bx lr

	swi SWI_Exit

Exit:
	swi SWI_Exit @ stop executing

.data
.align
.end
