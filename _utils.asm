
#importonce

// Detect if direction must be switched.
.macro DetectDirection(Direction, HasSwitched) {
    lda Direction
    beq GoingLeft

  GoingRight:
    DetectRightEdgeReached()
    bne SwitchDirection

    jmp !+

  GoingLeft:
    DetectLeftEdgeReached()
    beq !+

  SwitchDirection:
    inc HasSwitched
    lda Direction
    eor #$ff
    sta Direction

  !:
}

// Detect if there is an alien on the first column. Accumulator contains 0 if
// no alien has been found, 1 otherwise
.macro DetectLeftEdgeReached() {
    lda #$00
    sta DetectEdgeReached.CurrentPosition

    jsr DetectEdgeReached
}

// Detect if there is an alien on the last column. Accumulator contains 0 if
// no alien has been found, 1 otherwise
.macro DetectRightEdgeReached() {
    lda #$1d
    sta DetectEdgeReached.CurrentPosition

    jsr DetectEdgeReached
}

// Detect if left or right edge contains an alien. Accumulator contains 0 if
// no alien has been found, 1 otherwise. Must be used only with macro.
DetectEdgeReached: {
    lda #$40
    sta CurrentPosition + 1

  SetupNewLine:
    lda CurrentPosition
    sta T1 + 1
    lda CurrentPosition + 1
    sta T1 + 2

  Loop:
  T1:
    lda CurrentPosition
    bne Reached

  NextCheck:
// Check if high byte of last row is reached
    lda CurrentPosition + 1
    cmp #$42
    bcc CalculateNextRow
    cmp #$43
    bcs NotReached

// Check if low byte of last row is reached
    lda CurrentPosition
    cmp #$f8
    bcs NotReached

  CalculateNextRow:
    c64lib_add16($0028, CurrentPosition)
    jmp SetupNewLine

  NotReached:
    lda #0
    jmp Done  

  Reached:
    lda #1

  Done:
    rts

    CurrentPosition: .word $beef
}

.macro AliensDescends(HasSwitched) {
    lda HasSwitched
    beq !+

    lda MoveTick
    eor $ff
    sta MoveTick

    jsr MoveAliensToDown

  !:
}

// Move aliens according to direction. In accumulator is expected Direction
.macro MoveAliens(Direction, HasSwitched) {
    lda HasSwitched
    beq Move
    
    dec HasSwitched
    jmp !+

  Move:
    lda MoveTick
    eor $ff
    sta MoveTick

    lda Direction
    beq ToLeft

  ToRight:
    jsr MoveAliensToRight
    jmp !+

  ToLeft:
    jsr MoveAliensToLeft

  !:
    jsr SetColorToChars
}

* = * "MoveAliensToDown"
MoveAliensToDown: {
    lda #$42
    sta CurrentPosition + 1
    sta NewPosition + 1
    lda #$d0
    sta CurrentPosition
    lda #$f8
    sta NewPosition

  SetupNewLine:
    ldx #0

    lda CurrentPosition
    sta T1 + 1
    lda CurrentPosition + 1
    sta T1 + 2

    lda NewPosition
    sta T2 + 1
    lda NewPosition + 1
    sta T2 + 2

  Loop:
  T1:
    lda CurrentPosition,x
    beq T2
    pha
    lda MoveTick
    bne Add
  Sub:
    pla
    sec
    sbc #2
    jmp T2

  Add:
    pla
    clc
    adc #2

  T2:
    sta NewPosition,x

    inx
    cpx #30
    bne Loop

// Check if high byte of last row is reached
    lda CurrentPosition + 1
    cmp #$40
    bne CalculateNextRow

// Check if low byte of last row is reached
    lda CurrentPosition
    cmp #$00
    beq Done

  CalculateNextRow:
    c64lib_sub16($0028, CurrentPosition)
    c64lib_sub16($0028, NewPosition)
    jmp SetupNewLine

  Done:
    rts

    CurrentPosition: .word $beef
    NewPosition: .word $beef
}

* = * "MoveAliensToLeft"
MoveAliensToLeft: {
    lda #$28
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
    beq T2
    pha
    lda MoveTick
    bne Add
  Sub:
    pla
    sec
    sbc #2
    jmp T2

  Add:
    pla
    clc
    adc #2

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
    lda #$27
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
    beq T2
    pha
    lda MoveTick
    bne Add
  Sub:
    pla
    sec
    sbc #2
    jmp T2

  Add:
    pla
    clc
    adc #2
  T2:
    sta CurrentPosition,x

    dey
    dex
    bne Loop

// Check if high byte of last row is reached
    lda CurrentPosition + 1
    cmp #$42
    bne CalculateNextRow

// Check if low byte of last row is reached
    lda CurrentPosition
    cmp #$f0
    bcs Done

  CalculateNextRow:
    c64lib_add16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    rts

    CurrentPosition: .word $beef
}

* = * "SetColorToChars"
SetColorToChars: {
    lda #$04
    sta CleanLoop
    lda #0
    sta StartLoop + 1
    lda #>MapData
    sta PaintCols + 2
    lda #$d8
    sta ColorMap + 2
  StartLoop:
    ldx #$00
  PaintCols:
    ldy MapData, x
    lda CharsetsColors, y
  ColorMap:
    sta $d800, x
    dex
    bne PaintCols

    inc PaintCols + 2
    inc ColorMap + 2
    dec CleanLoop
    lda CleanLoop
    beq Done
    cmp #$01
    beq SetLastRun
    jmp StartLoop

  SetLastRun:
    lda #$e7
    sta StartLoop + 1
    jmp StartLoop

  Done:
    rts

  CleanLoop: .byte $03
}

MoveTick: .byte 0

.filenamespace Utils

WaitFor10thSecond: {
    jsr WaitRoutine

    lda WaitCounter
    cmp #50
    beq ResetCounter
    inc WaitCounter
    jmp Done

  ResetCounter:
    lda #0
    sta WaitCounter

  Done:
    rts
  
  WaitCounter: .byte 0
}

WaitRoutine: {
  VBLANKWAITLOW:
    lda $d011
    bpl VBLANKWAITLOW
  VBLANKWAITHIGH:
    lda $d011
    bmi VBLANKWAITHIGH

    rts
}

#import "./_label.asm"

#import "./common/lib/math-global.asm"
