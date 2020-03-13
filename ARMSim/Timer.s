.equ SWI_GetTicks, 0x6d @ Gets current time 
.equ Sec1, 10000 @ 10 seconds interval
.equ Point1Sec, 100 @ 0.1 seconds interval
.equ EmbestTimerMask, 0x7fff  @ 15 bit mask for timer values
.equ Top15bitRange, 0x0000ffff @(2^15) -1 = 32,767

.global _start

.text

_start:

Wait:
	ldr r10,=Sec1			; r10 = time gap
	ldr r7, =EmbestTimerMask	; r7 = timer mask
	ldr r8, =Top15bitRange		; Top15Range
	
	swi SWI_GetTicks 		; get current time in r0
	mov r1,r0			; move current  time in r1 (T1)
	and r1,r1,r7 			; T1 in 15 bits

WaitLoop:
	swi SWI_GetTicks 		; get current time in r0
	mov r2,r0 			; get T2
	and r2,r2,r7 			; T2 in 15 bits
	
	cmp r2,r1 			; compare T2 an T1
	bge simpleTime 			; if T2>T1 simple time
	
	sub r9,r8,r1 			; TIME(r9) = Top15bitRange-T1+T2
	add r9,r9,r2 			; TIME(r9) = Top15bitRange-T1+T2
	
	bal checkInt			; to avoid getting in the simpleTime subroutine

simpleTime:
	sub r9,r2,r1 			; TIME(r9) = T2-T1

checkInt:
	cmp r9,r10 			; compare T2-T1 (r9) to required time gap (r10)
	blt WaitLoop			; if(T2-T1 < time gap) goto WaitLoop


Exit:
	swi 0x11 

.data

.align
