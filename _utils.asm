
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
    lda #$43
    sta CurrentPosition + 1

  ResetSelfMod:
    ldx #254
    ldy #255
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

    beq NextPosition

  NextPosition:
    dex
    dey
    beq NextSegment
    jmp Loop

  NextSegment:
    dec CurrentPosition + 1
    lda CurrentPosition + 1
    cmp #$3f
    bne ResetSelfMod
  Done:
    rts

    CurrentPosition: .word $be00
}

#import "./common/lib/math-global.asm"
