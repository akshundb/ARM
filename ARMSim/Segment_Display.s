.equ SWI_GetTicks, 0x6d @ Gets current time 
.equ Sec1, 1000 @ 1 seconds interval
.equ Point1Sec, 100 @ 0.1 seconds interval
.equ EmbestTimerMask, 0x7fff  @ 15 bit mask for timer values
.equ Top15bitRange, 0x0000ffff @(2^15) -1 = 32,767
.equ SWI_Exit,0x11

.equ SEG_A,0x80
.equ SEG_B,0x40
.equ SEG_C,0x20
.equ SEG_D,0x08
.equ SEG_E,0x04
.equ SEG_F,0x02
.equ SEG_G,0x01
.equ SEG_P,0x10

.global _start

.text

_start:
	mov r3, #0			; r3 = 0
LED:
	ldr r2,=Digits			; r2 point to Digits
	ldr r0,[r2,r3,lsl#2]		; r0 = [r2 + r3*4]
	
	swi 0x200			; glow display 
	
	bl Wait				; time gap
	
	add r3,r3,#1			; r3 = r3 + 1
	cmp r3,#10			; if r3 < 10
	subeq r3,r3,#10 		; ...r3 = r3 - 10
	
	bal LED

Wait:
	ldr r10,=Sec1
	ldr r7, =EmbestTimerMask
	ldr r8, =Top15bitRange
	swi SWI_GetTicks
	mov r1,r0
	and r1,r1,r7 			@ T1 in 15 bits

WaitLoop:
	swi SWI_GetTicks
	mov r2,r0 			@ get T2 in r2
	and r2,r2,r7 			@ T2 in 15 bits in r2
	
	cmp r2,r1 			@ compare T1 and T2

	bge simpleTime 			@ if T2>T1 use simple time subroutine
	
	sub r9,r8,r1 			@ TIME(r9) = Top15bitRange-T1+T2
	add r9,r9,r2		        @ TIME(r9) = Top15bitRange-T1+T2
	
	bal checkInt

simpleTime:
	sub r9,r2,r1 			@ TIME(r9) = T2-T1

checkInt:
	cmp r9,r10
	blt WaitLoop
	bx lr
	
Exit:
	swi SWI_Exit

.data
.align

Digits:
	.word	SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G @0
	.word	SEG_B|SEG_C@1
	.word	SEG_A|SEG_B|SEG_D|SEG_E|SEG_F @2
	.word	SEG_A|SEG_B|SEG_C|SEG_D|SEG_F @3
	.word	SEG_B|SEG_C|SEG_F|SEG_G @4
	.word	SEG_A|SEG_G|SEG_F|SEG_C|SEG_D @5
	.word	SEG_A|SEG_G|SEG_E|SEG_D|SEG_C|SEG_F @6
	.word	SEG_A|SEG_B|SEG_C @7
	.word	SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @8
	.word	SEG_A|SEG_B|SEG_C|SEG_D|SEG_F|SEG_G @8
	.word 0 @ Blank Display
.end
