;-----------------------------MEMORY LOCATIONS----------------------------------
;value tracker memory locations
TimePassedSinceKeyPress DEFW 0 ;amount of time passed since first interrupt
TimePassedSinceNotePlay DEFW 0 ;amount of time passed since a note has started playing
LcdDigitsTaken DEFW 0          ;LCD cursor tracker value
TuneNoteOffset DEFW 0          ;which byte of the defined block needs to be loaded next

;values specifying different modes
PlayingNote DEFW 0
PlayingSong DEFW 0

;note variables for note playing mode
Pitch DEFW 0 ;pitch from C to B
PitchSpecified DEFW 0
Octave DEFW 0 ;octave from 0 to 8
OctaveSpecified DEFW 0
Length DEFW 0 ;natural numbers that are multiples of 1/10 a second
LengthSpecified DEFW 0

;--------------------------------CONSTANTS--------------------------------------
;default port values
PortPIO EQU &20000000
PortA EQU &10000000

;matrix traversal indeces
RowStartValue EQU 1
RowEndValue EQU 16
ColumnStartValue EQU &80
ColumnEndValue EQU &10

;values used to specify printing parameters
IsNumber EQU 1       ;whether the character being printed out is a number or not
IsNotNumber EQU 2
WaitTimeError EQU 30 ;time it takes before clearing the screen after printing an error message
EOF EQU '\0'         ;EOF for error message
StarValue EQU &FA    ;keyboard value corresponding to the star key
HashValue EQU &F3    ;keyboard value corresponding to the hash key
LoopStartPoint EQU 0 ;start of error message block print loop

;values used to control the buzzer input
TurnOnBuzzer EQU &F0
TurnOffBuzzer EQU &00
TuneEOF EQU &FF  ;this specifies the end of a tune
DelayValue EQU 0 ;when the pitch is zero, turn off the buzzer for the time specified

;turn memory location 'on' and 'off' to specify which routine to use
TurnOnValue EQU 1
TurnOffValue EQU 0

;number bounds for pitch and octave
PitchOctaveLowerBound EQU 0
PitchUpperBound EQU 13
OctaveUpperBound EQU 9

;matrix cells/buttons indeces
KeyIndexStart EQU 0
KeyIndexEnd EQU 12
OverflowInput EQU &89 ;if input is too big, thus overflowing (biggest is &88)
LowestInput EQU &21

;LCD screen cursor traversal values used as new digits are added on key press
EndOfFirstLine EQU 16
EndOfSecondLine EQU 33
ResetLCD EQU 0

;timer-related values
TimerCompareValue EQU 100
TimerCompareEnable EQU &01
TimerResetValue EQU &0

;key press values checking to see if two keys are pressed at the same time
NoKeyPressed EQU 0
OneKeyPressed EQU 1

;LCD cursor print values
ClearDisplay EQU &01
MoveToSecondLine EQU &C0
DisplayDefault EQU 2

;milliseconds for timer to count to
KeyDebounceTimePassed EQU 100 ;values to iterate the counter to
Milliseconds10Iterate EQU 10
Milliseconds5Iterate EQU 5
CountInTenthOfSecond EQU 100 ;value to multiply user inputted length by

;individual bit checks
Bit0Active EQU &01 ;hexadecimal value to check if bit 0 is high
Bit7Active EQU &80 ;hexadecimal value to check if bit 7 is high

;----------------------------------BLOCKS---------------------------------------
;keyboard button values corresponding to found index in keyboard traversal loop
KeyboardValues DEFB 1, 4, 7, -6 ;hash and star are set to -6  and -13 because
               DEFB 2, 5, 8, 0  ;the print method adds &30 to them, after which
               DEFB 3, 6, 9, -13;they correspond to their ASCII values
ALIGN

;values corresponding to specified pitch - these numbers are notes C0 - B0
;all other notes are derived from multiplying these by a power of 2 (the exponent
;being the octave specified by the user)
NoteValues DEFB 16, 17, 18, 19
           DEFB 21, 22, 23, 25
           DEFB 26, 28, 29, 31
ALIGN

;errors for when the user input for a note is OOB
PitchLowerBoundError DEFB "Error: P>0!\0"
ALIGN
PitchUpperBoundError DEFB "Error: P<=12!\0"
ALIGN
OctaveLowerBoundError DEFB "Error: Oct>0!\0"
ALIGN
OctaveUpperBoundError DEFB "Error: Oct<=8!\0"
ALIGN
