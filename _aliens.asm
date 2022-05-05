
#importonce

.filenamespace Aliens

* = * "Aliens Init"
/* Count how many aliens are on screen. This is determined dinamically
to prevent coupling when editing map. */
Init: {
    // Start scan from line 1
    lda #$28
    sta CurrentPosition
    lda #$40
    sta CurrentPosition + 1

    lda #0
    sta Count

  SetupNewLine:
    ldx #30

    lda CurrentPosition
    sta T1 + 1
    lda CurrentPosition + 1
    sta T1 + 2

  Loop:
  T1:
    lda CurrentPosition,x

    cmp #MAP.ALIEN_OVER
    bcs CheckRowEnded
    cmp #MAP.ALIEN_1
    bcc CheckRowEnded

    inc Count

  CheckRowEnded:
    dex
    bne Loop

// Check if HiByte CurrentPosition holds last row
    lda CurrentPosition + 1
    cmp #$43
    bne CalculateNextRow

// Check if LoByte CurrentPosition holds last row
    lda CurrentPosition
    cmp #$c0
    beq Done

  CalculateNextRow:
    c64lib_add16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    lda Count
    lsr
    sta Count
    rts

    CurrentPosition: .word $beef
}

// Alien count, determined at start and updated when and alien is destroyed
Count: .byte 0

#import "./_label.asm"

#import "./common/lib/math-global.asm"
