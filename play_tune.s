;----------------------ROUTINES FOR TUNE PLAYING MODE---------------------------
play_tune ;method - usedto iterate through tune block values/bytes
      PUSH {R1-R3, LR}

      ADR R1, tune3 ;load tune block
      LDR R2, TuneNoteOffset ;load last iterated through offset

      ;each note consists of three values
      LDRB R3, [R1, R2] ;first byte is pitch or EOF
      CMP R3, #TuneEOF  ;if value is EOF, then stop tune altogether
      BEQ stop_tune
      STR R3, Pitch
      ADD R2, R2, #1

      LDRB R3, [R1, R2] ;next value is octave
      STR R3, Octave
      ADD R2, R2, #1

      LDRB R3, [R1, R2] ;next value is length
      STR R3, Length
      ADD R2, R2, #1

      STR R2, TuneNoteOffset ;set offset to next note

      SVC 7 ;play note routine

      POP {R1-R3, PC}

stop_tune

      MOV R2, #TurnOffValue  ;reset tracker values, turn off song playing mode
      STR R2, TuneNoteOffset
      STR R2, TimePassedSinceNotePlay
      STR R2, PlayingSong

      POP {R1-R3, PC}

INCLUDE tune3.s ;include relevant text file
