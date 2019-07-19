;-----------------------------INTERRUPT FUNCTIONS-------------------------------
timer_interrupt
      LDR R1, PlayingNote
      CMP R1, #TurnOnValue     ;check to see if a note is being played or not
      BEQ track_note_length    ;if it is, track it's length using the timer
      BNE check_if_key_pressed ;if not, check for a newly inputted character

track_note_length

      LDR R1, Length
      MOV R2, #Milliseconds5Iterate   ;iterate in 5 millisecond for better precision
      MOV R4, #CountInTenthOfSecond   ;multiply the specified length by 100 to get
      MUL R1, R1, R4                  ;value in a tenth of a second
      LDR R3, TimePassedSinceNotePlay ;load amount of milliseconds counted so far

      CMP R3, R1                      ;compare counted seconds to specified note length
      MOVGE R3, #TimerResetValue      ;reset timer if counted seconds are >= to length
      BLGE check_song                 ;check to see if a song is being played
      ADDLT R3, R3, R2                ;if not add to counted seconds
      SVCLT 9                         ;set new timer compare value

      STR R3, TimePassedSinceNotePlay ;set new amount of counted seconds

      B return_point                  ;branch back to loop return point

      check_song
            PUSH {LR}
            LDR R1, PlayingSong
            CMP R1, #TurnOnValue      ;check if a song is playing
            SVCNE 8                   ;if not, stop the note
            BLEQ play_tune            ;if yes, play the next note/delay
            POP {PC}


check_if_key_pressed ;interrupt routine utilising timer retrieve keyboard input

      MOV R1, #PortPIO          ;set default PIO port
      LDR R3, TimePassedSinceKeyPress ;load time passed since first key detection
      MOV R5, #ColumnStartValue ;start index of column traversal
      MOV R6, #KeyIndexStart    ;start index of keyboard buttons traversal

      column_check              ;for loop going through each column
            STRB R5, [R1, #2]   ;store/enable current column
            LDRB R4, [R1, #2]   ;retrieve column input
            CMP R4, #LowestInput   ;if input is too low -skip row loop
            BLO row_check_end
            CMP R4, #OverflowInput ;if keyboard input has overflowed - skip row loop
            BHS row_check_end
            MOV R8, #RowStartValue ;start index of row traversal

            row_check           ;nested for loop going through each row
                  CMP R8, #RowEndValue ;if row index is at the end, break row for loop
                  BHS row_check_end
                  TST R4, R8    ;compare retrieved keyboard input to current row/button bit number
                  MOVNE R9, R6  ;set digit to print as current matrix traversal index if equal
                  ADDNE R3, R3, #Milliseconds10Iterate ;add 10 millisecs to total time passed since first valid key press interrupt
                  BNE column_check_end ;break loop when key pressed has been found
                  LSLEQ R8, R8, #1 ;if not equal, go to next row
                  ADDEQ R6, R6, #1 ;and check next button index
                  BEQ row_check    ;then go to next row

            row_check_end       ;end of row for loop
            LSR R5, R5, #1      ;go to next column
            CMP R5, #ColumnEndValue ;check if last column index
            BNE column_check    ;if not, continue loop

      column_check_end          ;end of column for loop

      CMP R6, #KeyIndexEnd      ;check if no key has been pressed
      MOVEQ R3, #TimerResetValue;if yes, restart timer for key press interrupt

      ADR R2, KeyboardValues    ;loading keyboard matrix
      LDR R1, LcdDigitsTaken    ;loading LCD cursor tracker - contains number of digits printed so far

      CMP R1, #EndOfSecondLine  ;check if end of screen
      MOVEQ R10, #ClearDisplay  ;clear display if yes
      MOVEQ R1, #ResetLCD       ;set digits printed value back to zero
      BLEQ print_character          ;clear display routine

      MOV R10, #DisplayDefault  ;set cursor shifter back to default value
      MOV R11, #IsNumber
      LDRB R9, [R2, R9]          ;load digit value corresponding to found matrix index
      ;check if time passed since first interrupt is enough to warrant printing -
      ;this is necessary for key debouncing as the digit would be printed out more times than intended by the user

      CMP R3, #KeyDebounceTimePassed ;any time a new character is inputted
      BLGE check_set                 ;check to see if a variable has been specified or is being set

      CMP R3, #KeyDebounceTimePassed
      MOVGE R3, #TimerResetValue ;if yes - reset the value for the next key press check
      ADDGE R1, R1, #1           ;add to total digits printed
      BLGE print_character           ;then print digit

      CMP R1, #EndOfFirstLine    ;if the cursor is at the end of the first line
      MOVEQ R10, #MoveToSecondLine ;move to the second one
      BLEQ print_character         ;then set the new cursor by printing it

      STR R3, TimePassedSinceKeyPress ;store new/current time passed value
      STR R1, LcdDigitsTaken     ;store new/current total digits/cursor tracker value

      MOV R2, #Milliseconds10Iterate
      SVC 9

      B return_point
