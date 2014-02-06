$NOLIST
;----------------------------------------------------
; helper.asm: 
;
;----------------------------------------------------

Line1 	EQU #80H		; Move to the beginning of the first row
Line2 	EQU #0C0H		; Move to the beginning of the second row
Right1 	EQU #14H		; Move the cursor one space to the right

org 0000H
   ljmp MyProgram
   
DSEG at 30H
roomTemp:	ds	1	; Current room temperature
ovenTemp:	ds	2	; Current oven temperature
R2S_Temp:	ds	2	; Soak Temperature -- condition from ramp-to-soak --> soak
S_Time:		ds	2	; Soak Time -- condition from soak --> Ramp-to-peak
R2P_Temp:	ds	2	; Reflow Temperature -- condition from Ramp-to-peak --> Reflow
R_Time:		ds	2	; Reflow Time -- condition from Reflow --> cooling

BSEG
I:		dbit	1	; Idle state flag
R2S:	dbit	1	; Ramp-2-Soak state flag
S:		dbit	1	; Soak state flag
R2P:	dbit	1	; Ramp-2-Peak state flag	
R:		dbit	1	; Reflow state flag
CL:		dbit	1	; Cooling state flag

CSEG

IDLE_1:
    DB  'IDLE KEY3 TO RUN',0
IDLE_2:
	DB	'C KEY2 TO SET', 0 
SRAMP:
	DB	'SRAMP ',0
SOAK:
	DB	'SOAK ',0
PRAMP:
	DB	'PRAMP ',0
REFLOW:
	DB	'REFLOW ',0
COOL:
	DB	'COOL ',0
GLOBAL:
	DB	'GBL  ',0
TIME:
	DB	'###s',0
	
;---------------------------------------------------
; Clear the LCD Screen
;---------------------------------------------------
clear_LCD:
	push 	acc
	push 	psw
	push 	AR0
	push 	AR1
	push 	AR2
	
	mov 	a, #01H
	lcall 	LCD_command
    mov 	R1, #40
clear_loop:
	lcall 	Wait40us
	djnz 	R1, clear_loop

	pop 	AR2
	pop 	AR1
	pop 	AR0
	pop 	psw
	pop 	acc
	ret
	
;---------------------------------------------------
; PUT a character on the screen 
;        or 
; execute a COMMAND
;---------------------------------------------------
LCD_put:
	push 	acc
	push 	psw
	push 	AR0
	push 	AR1
	push 	AR2
	
	mov		LCD_DATA, A
	setb 	LCD_RS
	sjmp	LCD_put_done
LCD_command:
	push 	acc
	push 	psw
	push 	AR0
	push 	AR1
	push 	AR2
	
	mov		LCD_DATA, A
	clr		LCD_RS
LCD_put_done:
	nop
	nop
	setb 	LCD_EN
	nop
	nop
	nop
	nop
	nop
	nop
	clr		LCD_EN
	lcall 	Wait40us
	
	pop 	AR2
	pop 	AR1
	pop 	AR0
	pop 	psw
	pop 	acc
	ret
	
;---------------------------------------------------
; Clear all the state flags
;---------------------------------------------------
clear_flags:
	clr	I
	clr	R2S
	clr	S
	clr	R2P
	clr	R
	clr	CL
	ret

;---------------------------------------------------
; Put a constant-zero-terminated string on the LCD screen
;---------------------------------------------------
SendString:
    clr 	a
    movc 	a, @a+dptr
    jz 		Send_done
    lcall 	LCD_put
    inc 	dptr
    sjmp 	SendString
Send_done:
	ret

;---------------------------------------------------
; 40us Delay
;---------------------------------------------------	
Wait40us:	
	push 	acc
	push 	psw
	push 	AR0
	push 	AR1
	push 	AR2
	
	mov 	R0, #149
Wait40us_loop: 
	nop
	nop
	nop
	nop
	nop
	nop
	djnz 	R0, Wait40us_loop
	
	pop 	AR2
	pop 	AR1
	pop 	AR0
	pop 	psw
	pop 	acc
    ret
	
$LIST