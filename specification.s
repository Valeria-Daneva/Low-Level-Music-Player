;----------------SPECIFICATION FOR NOTES---------------------
check_set ;check or set a note value based on inputted key
    CMP R9, #StarValue ;if it's a star switch to different mode
    BEQ switch_music_mode

    CMP R9, #HashValue
    BEQ check_input    ;if it's a hash, mark input as specified
    BNE set_input      ;if not, set the value of the next unspecifed variable


switch_music_mode
    LDR R1, PlayingSong

    CMP R1, #TurnOnValue ;new value is negation fo previous value
    MOVEQ R2, #TurnOffValue
    MOVNE R2, #TurnOnValue

    STR R2, PlayingSong ;both are turned on or off in order to synchronise
    STR R2, PlayingNote

    MOV PC, LR


check_input
    PUSH {R1-R5, LR}

    LDR R1, PitchSpecified
    LDR R4, OctaveSpecified
    LDR R3, LengthSpecified

    MOV R2, #TurnOnValue

    CMP R1, R2
    STRNE R2, PitchSpecified ;if the pitch is unspecified, check the current value
    BNE check_pitch

    CMP R4, R2
    STRNE R2, OctaveSpecified  ;if the octave is unspecified, check the current value
    BNE check_octave

    CMP R3, R2
    STRNE R2, LengthSpecified  ;if the length is unspecified, mark it as specified as it has no bounds
    SVCNE 7                    ;and play the note

    POP {R1-R5, PC}

check_pitch ;method - check whether the set value of the pitch is within bounds
    LDR R5, Pitch

    CMP R5, #PitchOctaveLowerBound
    ADREQ R3, PitchLowerBoundError
    BLEQ print_error
    CMP R5, #PitchUpperBound
    ADRGE R3, PitchUpperBoundError
    BLGE print_error

    POP {R1-R5, PC} ;pop the values off the stack so as not go to the next unspecified value

check_octave ;method - check whether the set value of the pitch is within bounds
    LDR R5, Octave

    CMP R5, #PitchOctaveLowerBound
    ADREQ R3, OctaveLowerBoundError
    BLEQ print_error
    CMP R5, #OctaveUpperBound
    ADRGE R3, OctaveUpperBoundError
    BLGE print_error

    POP {R1-R5, PC} ;pop the values off the stack so as not go to the next unspecified value



set_input ;set the value of the next unspecified variable
    PUSH {R1-R4, LR}

    LDR R1, PitchSpecified
    LDR R4, OctaveSpecified
    LDR R3, LengthSpecified

    CMP R1, #TurnOnValue
    BNE set_pitch

    CMP R4, #TurnOnValue ;no need for a separate method for octave as it can't be >= 10
    STRNE R9, Octave
    POPNE {R1-R4, PC}

    CMP R3, #TurnOnValue
    BNE set_length

set_pitch ;method for setting the value of the pitch(can be >= 10)
    PUSH {R1, R2, R9}

    MOV R1, #10
    LDR R2, Pitch

    CMP R2, #0
    STREQ R9, Pitch  ;setting single digit value if pitch hasn't been set
    MULNE R2, R2, R1 ;setting double digit value if already set by
    ADDNE R2, R2, R9 ;multiplying previous value by ten and adding new value
    STRNE R2, Pitch

    POP {R1, R2, R9}
    POP {R1-R4, PC} ;pop the values off the stack so as not go to the next unspecified value

set_length ;method for setting the value of the length(can be >= 10)
    PUSH {R1, R2, R9}

    MOV R1, #10
    LDR R4, Length

    CMP R4, #0
    STREQ R9, Length ;setting single digit value if pitch hasn't been set
    MULNE R4, R4, R1 ;setting double digit value if already set by
    ADDNE R4, R4, R9 ;multiplying previous value by ten and adding new value
    STRNE R4, Length

    POP {R1, R2, R9}
    POP {R1-R4, PC} ;pop the values off the stack so as not go to the next unspecified value
