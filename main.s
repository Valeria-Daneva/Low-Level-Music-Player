;-------------------------------------------------------------------------------
;           Music Playing Programme
;           Valeria Daneva
;           Version 1.0
;           14th June 2019
;
; This programme has two modes - playing a note specified by the user or playing
; a set tune. The way to switch between either of them is pressing the star key.
; The user cannot switch between modes whilst the operation specified is still
; running.
;
; When in note playing mode, the user should enter three variables, using the
; hash key as a return signifier, in this specific order. The first is the pitch,
; which goes from 1 to 12; then octave, which goes from 1 to 8; and length, which
; has no limit.  The length is specified in tens of seconds. The user will receive
; an error message if they go out of bounds for either of the first two variables.
; After the length has been specified, the note will play out, after which the
; screen will be cleared, allowing the user to specify a new note.
;
; When in tune playing mode, the song will just play out and stop when it's
; finished, allowing the user to switch back to note playing mode.
;
; Last modified: 14/6/2019(VVD)
;
; Known bugs: None
;-------------------------------------------------------------------------------
ORG 0

B main
end_programme B .
B SVC_entry
B   .
B   .
B   .
B ISR_entry
switch_user_mode MOVS PC, LR

;----------------------------OS INITIALISATION----------------------------------
SVC_max EQU 11
ISR_max EQU 256

ISR_entry SUB LR, LR, #4          ;specify correct return address

          STMFD SP!, {R0-R11,LR}  ;push locally used registers onto stack

          MOV R1, #PortA          ;set default port
          LDRB R3, [R1, #&18]     ;load individual interrupts visible value
          LDRB R2, [R1, #&1C]     ;load individual interrupts enable value
          AND R3, R2, R3          ;intersect enabled and visible bits to get actual active bits value
          BIC R2, R2, R3          ;clear all active interrupts
          STRB R2, [R1, #&18]     ;store new value back to visibility port

          MOV R4, #1              ;loop through each bit value to acknowledge active interrupts
loop      CMP R4, #ISR_max        ;loop until it's reached the a non-existent 8th bit
          BEQ end                 ;after which end the programme
          AND R5, R3, R4          ;check to see if that bit is an active interrupt by using AND mask
          CMP R5, #0              ;if the interrupt is not active
          LSLEQ R4, R4, #1        ;go to the next bit
          BEQ loop                ;start over the loop

          ADD R5, PC, R5, LSL #2  ;branching to corresponding table entry
          PUSH {R1-R5}            ;preserve previous bit values
          MOV PC, R5              ;branch to relevant ISR table entry

;The ISR table contains branches to relevant routines for each interrupt enable
;if an interrutp isn't enabled - it just branches back to the loop in order for
;other enables values to be checked whether they are active.
;
;In this case, only the timer compare is enabled.
ISR_table B timer_interrupt
          B loop
          B loop
          B loop
          B loop
          B loop
          B loop
          B loop

return_point  POP {R1-R5}         ;restore previous bit values
              LSL R4, R4, #1      ;check next bit
              B loop              ;start over loop

end       LDMFD SP!, {R0-R11,PC}^ ;pop used registers off stack to preserve
                                  ;original user state
SVC_entry LDR R0, [LR, #-4]
          BIC R0, R0, #&FF000000
                                  ;checking to see if system call number
          CMP R0, #SVC_max        ;specified  fits existing table entry
          BHS switch_user_mode    ;switching to user mode if not
          ADD R0, PC, R0, LSL #2  ;branching to corresponding table entry
          LDR PC, [R0, #0]

SVC_table DEFW end_programme      ;0 - stop programme
          DEFW set_portKeyboard   ;1 - enable keyboard input
          DEFW get_portA          ;2 - port A accessor method
          DEFW get_portB          ;3 - port B accessor method
          DEFW set_portA          ;4 - port A actuator method
          DEFW write_bit          ;5 - turn specified bit high
          DEFW clear_bit          ;6 - turn specified bit low
          DEFW play_note          ;7 - play note
          DEFW stop_note          ;8 - stop note
          DEFW set_timer          ;9 - set timer value

;initialise stacks
EndStackSuper DEFS 500 ;supervisor mode stack
              ALIGN
BegStackSuper

EndStackUser DEFS 500  ;user mode stack
             ALIGN
BegStackUser

EndStackIRQ DEFS 500   ;IRQ mode stack
            ALIGN
BegStackIRQ

;main code
main
          ADR SP, BegStackSuper   ;instatiate supervisor stack

          MRS R0, CPSR            ;load current CPSR value
          BIC R0, R0, #&0F        ;append to System mode
          ORR R0, R0, #&1F
          MSR CPSR_c, R0          ;store new value to CPSR

          ADR SP, BegStackUser    ;instantiate user stack

          MRS R0, CPSR            ;load current CPSR value
          BIC R0, R0, #&0F        ;append to IRQ mode/turn bit 7 active low
          ORR R0, R0, #&12
          MSR CPSR_c, R0          ;store new value to CPSR

          ADR SP, BegStackIRQ     ;instantiate IRQ mode

          MOV R1, #PortA          ;set default port
          LDRB R2, [R1, #&1C]     ;load individual interrupts enable value
          BIC R2, R2, #&FF
          ORR R2, R2, #TimerCompareEnable ;set value to enable timer interrupt
          STRB R2, [R1, #&1C]     ;store new value back to port

          MRS R14, CPSR            ;load current CPSR value
          BIC R14, R14, #&0F       ;append CPSR mode
          BIC R14, R14, #&80
          MSR SPSR, R14            ;store new value to CPSR

          ADR R14, user_code_start ;going to user code
          MOVS PC, R14

user_code_start

SVC 1    ;enabling keyboard input
B  .     ;always branch to self to wait for keyboard input/note playing

;include all routines and variables
INCLUDE variables.s
INCLUDE SVCs.s
INCLUDE ISRs.s
INCLUDE specification.s
INCLUDE print.s
INCLUDE play_tune.s
