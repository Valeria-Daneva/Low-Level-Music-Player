;------------------------------SVC FUNCTIONS------------------------------------
;enable keyboard input/initialise programme
set_portKeyboard
      PUSH {R1, R2}
      MOV R1, #PortPIO
      LDRB R2, [R1, #3]        ;load enable keyboard port value
      MOV R2, #&1F             ;set bits 5-7 low to turn on keyboard input
      STRB R2, [R1, #3]        ;store new port value

      MOV R1, #EndOfSecondLine ;specify that the cursor is at the end of the LCD
      STR R1, LcdDigitsTaken   ;screen to clear it at the start of the programme

      POP {R1, R2}
      MOVS PC, LR

;port accessor SVC routines
get_portA
      PUSH {R1}
      MOV R1, #PortA
      LDRB R2, [R1]
      POP {R1}
      MOVS PC, LR

get_portB
      PUSH {R1}
      MOV R1, #PortA
      LDRB R2, [R1, #4]
      POP {R1}
      MOVS PC, LR

;port actuator SVC routines
set_portA
      PUSH {R1}
      MOV R1, #PortA
      STRB R9, [R1] ;actuator and accessor calls use different
      POP {R1}      ;registers as outputs to avoid loss of info
      MOVS PC, LR

write_bit ;method - turn a bit signified by R8 high, use R2 as the port to to write to
      PUSH {R10, R9, R2, R1} ;push registers used locally onto stack, others are inputs

      MOV R1, #PortA      ;set default port value
      MOV R10, #1         ;instantiate bit mask value
      LSL R10, R10, R8    ;shift value by number specified in R8
      LDRB R2, [R1, #4]   ;get port B value
      ORR R9, R2, R10     ;use ORR mask to write to bit using hexadecimal value
      STRB R9, [R1, #4]   ;store value to port B

      POP {R10, R9, R2, R1} ;pop registers used locally from stack
      MOVS PC, LR ;end of write_bit

clear_bit ;method - clear a bit signified by R8, use R2 as the port to clear bit from
      PUSH {R10, R9, R2, R1} ;push registers used locally onto stack, others are inputs

      MOV R1, #PortA      ;set default port value
      MOV R10, #1         ;instantiate bit mask value
      LSL R10, R10, R8    ;shift value by number specified in R8
      LDRB R2, [R1, #4]   ;get port B value
      BIC R9, R2, R10     ;use BIC mask to clear bit using hexadecimal value
      STRB R9, [R1, #4]   ;store value to port B

      POP {R10, R9, R2, R1} ;pop registers used locally from stack
      MOVS PC, LR ;end of clear_bit

play_note
      PUSH {R1-R6}

      MOV R1, #PortPIO
      LDR R4, Pitch
      LDR R6, Octave
      CMP R4, #DelayValue      ;if the pitch is 0, it's delay, so turn the buzzer on/off accordingly
      MOVNE R2, #TurnOnBuzzer
      MOVEQ R2, #TurnOffBuzzer

      SUB R4, R4, #1 ;adjust pitch to fit offset
      ADR R5, NoteValues ;load note/pitch values matrix
      LDRB R3, [R5, R4] ;load correct pitch value to calculate frequency by
      CMP R6, #0 ;left shift only if octave value specified, otherwise it is 0
      LSLNE R3, R3, R6 ;multiply by 2^octave
      STRB R3, [R1, #1] ;store in one half of total frequency bits
      LSR R3, R3, #8 ;shift to fit value of second half of frequency bits
      STRB R3, [R1] ;store in other half of total frequency bits
      STRB R2, [R1, #4] ;turn on buzzer when note specified

      MOV R1, #TurnOnValue ;speficy that a note is being played
      STR R1, PlayingNote

      POP {R1-R6}
      MOVS PC, LR

stop_note
      PUSH {R1, R2}

      MOV R1, #PortPIO
      MOV R2, #TurnOffValue

      STRB R2, [R1, #4]        ;turn off buzzer algother first

      MOV R1, #TurnOffValue    ;reset all relevant memory locations
      STR R1, OctaveSpecified
      STR R1, PitchSpecified
      STR R1, LengthSpecified
      STR R1, Octave
      STR R1, Pitch
      STR R1, Length

      LDR R2, PlayingSong
      CMP R2, #TurnOffValue    ;if a song is still playing continue in
      STREQ R1, PlayingNote    ;note playing mode

      MOV R1, #EndOfSecondLine ;specify that the cursor is at the end of the LCD
      STR R1, LcdDigitsTaken   ;screen to clear it at after the note(s) have
                               ;stopped playing to allow the user to specify new input

      POP {R1, R2}
      MOVS PC, LR

set_timer
      PUSH {R1, R3}

      MOV R1, #PortA            ;set default port value
      LDRB R3, [R1, #&C]        ;load current interrupt state
      ADD R3, R3, R2            ;set next interrupt to be in given milliseconds
      STRB R3, [R1, #&C]        ;store new interrupt state

      POP {R1, R3}
      MOVS PC, LR
