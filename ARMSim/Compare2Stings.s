.equ SWI_Open, 0x66  @ Open File
.equ SWI_Close, 0x68 @ Close File
.equ SWI_Exit, 0x11  @ EXIT
.equ SWI_PrStr, 0x69 @ Write String
.equ SWI_RdInt, 0x6c @ Read Integer
.equ SWI_RdStr, 0x6a @ Read String

.global _start
.text

_start:

;Open File
	ldr r0,=FileName
	mov r1,#0
	swi SWI_Open
	ldr r1,=FileHandle
	str r0,[r1]

;Reading string 1
	ldr r0,=FileHandle
	ldr r0,[r0]
	ldr r1,=string_1
	mov r2,#50
	swi SWI_RdStr

;Reading string_2
	ldr r0,=FileHandle
	ldr r0,[r0]
	ldr r1,=string_2
	mov r2,#50
	swi SWI_RdStr


FindLength:
	mov r4,#0			; r4 ... length of string 1
	mov r5,#0			; r5 ... length of string 2
	ldr r0,=string_1		; r0 ... address of string 1
	ldr r1,=string_2		; r1 ... address of string 2

Count_Loop:		
	ldrb r2,[r0],#1
	ldrb r3,[r1],#1
	
	cmp r2,#0			; string 1 eof ?
	addne r4,r4,#1			; length(string1) = length(string1) + 1
	
	cmp r3,#0			; string 2 eof ?
	addne r5,r5,#1			; length(string2) = length(string2) + 1
	
	add r2,r2,r3			
	cmp r2, #0
	bne Count_Loop


Print_String_1:
	ldr r0,=string_1
	swi 0x02

CompareLength:
	cmp r4,r5
	beq equalTo			
	bne notEqual

equalTo:					
	
	ldr r0,=string_1		;r0 ... address of string 1		
	ldr r1,=string_2		;r1 ... address of string 2

equalTo_Loop:
	
	ldrb r2,[r0],#1			;r2 = ++[r0]
	ldrb r3,[r1],#1			;r3 = ++[r1]
	
	cmp r2,r3			
	bne  notEqual
	
	cmp r2,#0			;eof string_1 and string_2
	bne equalTo_Loop		;if eof not reached

	ldr r0,=equal			;print " = "
	swi 0x02
	bal Print_string_2

notEqual:
	ldr r0,=strNotEqual		;print " != "
	swi 0x02
	bal Print_string_2

Print_string_2:
	ldr r0,=string_2
	swi 0x02

EOF:
	ldr r0, =FileHandle 		;get address of file handle
	ldr r0, [r0] 			;get value at address of file handle
	swi SWI_Close			;close (the file handle address in r0)

Exit:
	swi SWI_Exit 			;EXIT

.data
.align 8
	string_2: .skip 100
	string_1: .skip 100
	FileHandle: .skip 4
	FileName: .asciz "inputStrCompare.txt"
	equal: .asciz " = "
	strNotEqual: .asciz " != "
.end
