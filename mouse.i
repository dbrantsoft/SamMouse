
;;--------------------------------------------------
;;Class CMouse

CLASS	CMouse
	.x:	WORD
	.y:	WORD
	.but:	BYTE
ENDCLASS

oMouse:		DEFO	CMouse
;oMouse.x:		EQU	CMouse.x+oMouse
;oMouse.y:		EQU	CMouse.y+oMouse
;oMouse.but:	EQU	CMouse.but+oMouse

METHOD	CMouse.read

		LD	BC,&fffe
		LD	HL,.mouse.data
		LD	DE,&070f
		IN	A,(C)	;strobe mouse
		IN	A,(C)	;read first data byte
		AND	E
		CP	E	;check if it's equal to &0f
		RET	NZ
@rd.loop:
		LD	(HL)+,A
		IN	A,(C)
		AND	E
		DJNZ	D,@rd.loop
		LD	(HL),A

@decodexy:
		LD	HL,.mouse.data+1
		LD	A,(HL)+
		XOR	255
		AND	15
		LD	(oMouse.but),A
		INC	HL
		LD	A,(HL)+	;A=Y16
		LD	E,(HL)+	;E=Y1
		SLA	A	4
		OR	E
		NEG
		LD	E,A
		PUSH	HL
		LD	HL,(oMouse.y)
		BIT	7,E
		JR	NZ,@msysub
@msysadd:
		LD	D,0
		ADD	HL,DE
		JR	C,@hitbottom
		LD	DE,(.maxY)
		INC	DE
		AND	A
		SBC	HL,DE
		JR	C,@yokay
@hitbottom:
		LD	HL,(.maxY)
		JR	@yokay2

;If we're here, we're subtracting our offset from Y coorinate
@msysub:
		LD	D,255
		ADD	HL,DE
		JR	C,@yokay2		;No underflow not sure this is right
		LD	HL,0
		JR	@yokay2
@yokay:
		ADD	HL,DE
@yokay2:
		LD	(oMouse.y),HL
		POP	HL
		INC	HL

		LD	A,(HL)+		;X16
		LD	E,(HL)
		SLA	A	4
		OR	E
		LD	E,A
		LD	HL,(oMouse.x)
		BIT	7,E
		JR	NZ,@msxsub

@msxadd:
		LD	D,0
		ADD	HL,DE
		LD	DE,(.maxX)
		INC	DE
		AND	A
		SBC	HL,DE
		JR	C,@xokay
		EX	DE,HL
		JR	@xokay2
@msxsub:
		LD	D,255
		ADD	HL,DE
		JR	C,@xokay2
		LD	HL,0
		JR	@xokay2
@xokay:
		ADD	HL,DE
@xokay2:
		LD	(oMouse.x),HL
		RET

METHOD	CMouse.init

	;BC=max x DE=max y

		LD	(.maxX),BC
		LD	(.maxY),DE
		LD	HL,oMouse.x
		XOR	A
		LD	(HL)+,A
		LD	(HL)+,A
		LD	(HL)+,A
		LD	(HL)+,A
		RET


METHOD	CMouse.check	;Returns Z if mouse present

		LD	BC,&fffe
		LD	DE,&0b0f
		IN	A,(C)
		IN	A,(C)
		AND	E
		CP	E
		RET	NZ
@loop:
		IN	A,(C)
		DEC	D
		JR	NZ,@loop
		AND	E
		RET

.mouse.data:	DEFS	10
.maxY:		DEFW	192
.maxX:		DEFW	255

