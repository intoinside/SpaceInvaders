
#importonce

* = * "MoveAliensToLeft"
MoveAliensToLeft: {
    lda #$00
    sta CurrentPosition
    lda #$40
    sta CurrentPosition + 1

  SetupNewLine:
    ldx #1
    ldy #0

    lda CurrentPosition
    sta T1 + 1
    sta T2 + 1
    lda CurrentPosition + 1
    sta T1 + 2
    sta T2 + 2

  Loop:
  T1:
    lda CurrentPosition,x

  T2:
    sta CurrentPosition,y

    inx
    iny
    cpy #30
    bne Loop

// Check if high byte of last row is reached
    lda CurrentPosition + 1
    cmp #$42
    bne CalculateNextRow

// Check if low byte of last row is reached
    lda CurrentPosition
    cmp #$f8
    beq Done

  CalculateNextRow:
    c64lib_add16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    rts

    CurrentPosition: .word $beef
}

* = * "MoveAliensToRight"
MoveAliensToRight: {
    lda #$00
    sta CurrentPosition
    lda #$40
    sta CurrentPosition + 1

  SetupNewLine:
    ldx #30
    ldy #29

    lda CurrentPosition
    sta T1 + 1
    sta T2 + 1
    lda CurrentPosition + 1
    sta T1 + 2
    sta T2 + 2

  Loop:
  T1:
    lda CurrentPosition,y

  T2:
    sta CurrentPosition,x

    dex
    dey
    bne Loop

// Check if high byte of last row is reached
    lda CurrentPosition + 1
    cmp #$42
    bne CalculateNextRow

// Check if low byte of last row is reached
    lda CurrentPosition
    cmp #$f8
    beq Done

  CalculateNextRow:
    c64lib_add16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    rts

    CurrentPosition: .word $beef
}

#import "./common/lib/math-global.asm"
