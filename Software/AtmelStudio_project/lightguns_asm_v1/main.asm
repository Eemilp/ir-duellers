;
; lightguns_asm_v1.asm
;
; Created: 13/04/2020 14:04:21
; Author : Eemil Praks
;
.org 0x0000
		rjmp start				;0x0000
		rjmp INT0_ISR			;0x0001


start:
		cli						;disabling interrupts to init everything
		ldi r19,(1 << CLKPCE)	;making sure that correct clockspeed is used
		clr r20
		out CLKPR, r19			;enabling clock prescaler change
		out CLKPR, r20			;changing clock prescaler to none.

		out WDTCR, r20			;disabling the watchdog timer
		ldi r19,(1 << ACD)		;powering down the analog comparator
		out ACSR, r19
		ldi r20,(1 << ISC01)		;setting interrupt 0 to fire at falling edge
		out MCUCR, r20
		ldi r19,(1 << DDB4)|(1 << DDB1)|(1 << DDB0) ;setting pins PB0, 1, 4 as outputs
		out DDRB, r19			;setting the pin settings

		ser r19					;setting timer 1 OC B and C registers to never trigger
		out OCR1C, r19			;these are used for delay function
		out OCR1B, r19

		ldi r25, 50				;setting delay for tones

		ldi r16,255				;ir pin not used on tone
		ldi r18,(1 << CS01)|(1 << CS00);setting prescaler to 64
		ldi r17, 208			;first 300Hz
		ldi r24, 0x0			;pulse counter

	wakeupToneLoop:				;playing wakeup sound
		rcall tone
		rcall delay
		rcall noTone
		subi r17, 25
		inc r24
		cpi r24, 7
		brne wakeupToneLoop

		ldi r19,(1 << INT0)		;enabling interrupt0
		out GIMSK, r19

		ldi r21, (1 << PB4)		;setting led on pin 4 on
		out PORTB, r21
		
		ldi r19,(1 << INTF0)	;clearing the int0 flag before interrupts are turned on
		out GIFR, r19
		sei						;enabling interrupts

		rjmp loop
tone:							;r16: OC0A r17: OC0B r18: Prescaler
		ldi r19,(1 << TSM)|(1 << PSR0);setting timer to synchro mode
		out GTCCR, r19
		ldi r19,(1 << OCF0A)|(1 << OCF0B)|(1 << TOV0);clearing interrupt flags
		out TIFR, r19
		

		out OCR0A,r16			;setting a (ir) compare register to register 16
		out OCR0B,r17			;setting b (piezo) compare match to register 17

		ldi r19,(1 << COM0A0)	;loading bit to r19 for setting 
		cp r16,r17				;checking which register is lower and setting pin ouput
		brlo ifneg				;skipping rightshifts if 16 is lower
		lsr r19
		lsr r19
		out OCR0A, r17
	ifneg:
		ori r19,(1 << WGM01)	;compare match mode on r19
		out TCCR0A, r19			;compare match register
		ldi r19, 0x0
		out TCNT0, r19			;setting counter to 0

		out TCCR0B,r18			;setting prescaler
		out GTCCR, r19			;setting timer out of synchro mode
		ret
noTone:
		clr r19
		out TCCR0B,r19			;stopping timer
		ret
delay:							;delay is stored in r25, a bit is 1.024ms
		out OCR1A,r25			;loading delay to interrupt
		ldi r19,(1 << CS13)|(1 << CS12)|(1 << CS11);see below
		out TCCR1, r19			;setting the prescaler -> timer runs
		
	delayLoop:					;checking if compare match a flag set
		in r19, TIFR
		sbrs r19, OCF1A
		rjmp delayLoop

		clr r19					;stopping delay timer
		out TCCR1, r19
		out TCNT1, r19			;clearing timer

		ldi r19, (1 << OCF1A)|(1 << OCF1B)|(1 << TOV1)
		out TIFR, r19			;clearing all timer 1 interrupt flags

		ret
loop:
		;TODO trigger
		in r19, PINB
		sbrs r19, PINB3			;skipping next jump if trigger set
		rjmp loop
		
		cbi PORTB, PB4			;clearing led
		ldi r16, 111			;sending ir signal
		ldi r17, 255
		ldi r18,(1 << CS00)		;setting prescaler to 8
		ldi r25, 5				;signal for 5ms
		cli						;disabling interrupt for tone duration
		rcall tone
		rcall delay
		rcall noTone
		ldi r19,(1 << INTF0)	;clearing the int0 flag so it wont trigger after the shot
		out GIFR, r19
		sei

		ldi r25, 10				;setting delay for tones

		ser r16					;ir pin not used on tone
		ldi r18,(1 << CS01)|(1 << CS00);setting prescaler to 64
		ldi r17, 15				;first 300Hz
		ser r24					;pulse counter
		ldi r23, 8				;time added

	trigToneLoop:				;playing gun sound
		rcall tone
		rcall delay
		add r17, r23
		inc r24
		cpi r24, 14
		brne trigToneLoop
		rcall noTone

		ldi r25, 250			;delay after shot
		rcall delay
		sbi PORTB, PB4			;clearing led

		rjmp loop				;returning to alive loop
INT0_ISR:
		;cli					;cli run by hardware during interrupt
death:							;recovering peripherals and going to loop
		clr r19					;stopping timers if running to prevent unexpected behaviour
		out TCCR0B, r19
		out TCCR1, r19
		out GIMSK, r19			;stopping int0

		ser r19
		out TIFR, r19			;clearing all timer interrupt flags for delay function

		ldi r19,LOW(RAMEND)		;resetting stack pointer
		out SPL,r19
		ldi r19,HIGH(RAMEND)
		out SPH,r19

		cbi PORTB, PB4			;turning off led

		ldi r25, 45				;setting delay for tones

		ldi r16,255				;ir pin not used on tone
		ldi r18,(1 << CS01)|(1 << CS00);setting prescaler to 64
		ldi r17, 20			;first 300Hz
		clr r24					;pulse counter
		clr	r23					;pulse counter 2
		ldi r22, 25				;tone diff

	deadToneLoop:				;playing decending tone
		rcall tone
		rcall delay
		rcall noTone
		add r17, r22
		inc r24
		cpi r24, 7
		brne deadToneLoop

		inc r23					;playing the decending tone for 3 times
		clr r24
		ldi r17, 20
		cpi r23, 3
		brne deadToneLoop

		ldi r25, 220			;setting delay for dead loop
		clr r19					;used as reference below
dead:	
		sbi PORTB, PB4			;heartbeat blink
		rcall delay
		cbi	PORTB, PB4
		rcall delay
		sbi PORTB, PB4
		rcall delay
		cbi	PORTB, PB4
		rcall delay
		ldi r24, 6
		rcall delay
		rcall delay
		rcall delay

		rjmp dead				;returning to loop