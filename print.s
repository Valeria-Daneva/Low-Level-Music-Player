;------------------------------PRINT FUNCTIONS----------------------------------
print_error ;method - print out relevant error message
      PUSH {R1, R9-R11, LR}

      MOV R1, #LoopStartPoint ;starting character to print out (least significant bit of message block)
      MOV R10, #MoveToSecondLine ;clear previous message/whole display at the beginning
      MOV R11, #IsNotNumber      ;specification to print character routine that the character is not a number

      do_while_not_last_char     ;loop through each character until you reach EOF
                BL print_character ;branch to write character method
                MOV R10, #DisplayDefault ;reset display to enable printing of characters

                LDRB R9, [R3, R1] ;load next bit/character of message block
                ADD R1, R1, #1 ;increment bit signifier
                CMP R9, #EOF ;check to see if it's the end of the message
                BNE do_while_not_last_char ;if not, print out the next character/bit

      MOV R1, #WaitTimeError ;set number of seconds to wait until the screen is cleared
      STR R1, Length
      MOV R1, #TurnOnValue ;set to a note playing in order for the error message to
      STR R1, PlayingNote  ;stay for a while until the user is allowed to set new input again

      POP {R1, R9-R11, PC}

print_character ;method - print out individual digit onto LCD screen
      PUSH {R8, LR} ;push values of locally used registers onto stack

      SVC 3                  ;read from port B
      BL controller_idle     ;check to see if controller is idle - if yes, continue

      MOV R8, #2             ;clear bit 2 of port B
      SVC 6

      CMP R11, #IsNumber
      ADDEQ R9, R9, #'0'     ;adjust output to be ASCII character

      CMP R10, #ClearDisplay ;check if you have to clear the display
      MOVEQ R9, R10          ;set cursor value as character to print
      MOVEQ R8, #1           ;if yes, turn bit 1 of port B high to enable that
      SVCEQ 6

      CMP R10, #ClearDisplay ;comparing again to avoid potential flag-setting issues
      MOVNE R8, #1           ;if no, turn bit 1 of port B high
      SVCNE 5

      CMP R10, #MoveToSecondLine ;check if you have to move to the next line
      MOVEQ R9, R10          ;set cursor value as character to print
      MOVEQ R8, #1           ;if yes, turn bit 1 of port B low to enable that
      SVCEQ 6

      SVC 4                  ;print character/digit

      MOV R8, #0             ;turn bit 0 of port B high
      SVC 5
      MOV R8, #0             ;turn bit 0 of port B low
      SVC 6

      POP {R8, PC} ;end of print_digit

controller_idle ;method - check if controller is idle
      PUSH {R8, LR} ;push registers used locally onto stack, others are inputs

      MOV R8, #2             ;turn bit 2 of port B high
      SVC 5
      MOV R8, #1             ;turn bit 2 of port B low
      SVC 6

      polling_controller ;do while loop running until controller is idle
          MOV R8, #0         ;turn bit 0 of port B high
          SVC 5
          SVC 2              ;load value of port A into R2
          MOV R8, #0         ;turn bit 0 of port B low
          SVC 6
          TST R2, #Bit7Active;check if bit 7 of port A is active
          BNE polling_controller ;if not go back to start of the loop

      POP {R8, PC} ;end of controller_idle
