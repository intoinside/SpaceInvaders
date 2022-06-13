
#importonce

StartNewGame: .byte 1

// Holder for background collision
CollisionBkgDummy: .byte 0

// Holder for sprite collision
CollisionSprDummy: .byte 0

// Used for aliens frame switch
MoveTick: .byte 0

* = * "CheckLifeLeftAndGameOver"
CheckLifeLeftAndGameOver: {
    dec Hud.LifeLeftCounter
    lda Hud.LifeLeftCounter
    cmp #MAP.ZeroChar
    beq NoMoreLife

// At least one life left
    inc LifeEnd
    rts
  
  NoMoreLife:
    inc GameOver
    rts
}

.macro PlaySound(volume, sfxnumber, voice) {
    lda #volume
    sta $d418       // set volume
    lda #sfxnumber  // sfx number
    ldy #voice      // voice number
    jsr $c04a       // play sound
}

.macro GetRandomNumberInRange(minNumber, maxNumber) {
    lda #minNumber
    sta Utils.GetRandom.GeneratorMin
    lda #maxNumber
    sta Utils.GetRandom.GeneratorMax
    jsr Utils.GetRandom
}

.macro addaccumulatortovar16(dest) {
    clc
    adc dest
    sta dest
    lda dest + 1
    adc #0 //adc value + 1
    sta dest + 1
}
/*
.assert "add16($0102, $A000) ", { add16($0102, $A000) }, {
  clc; lda $A000; adc #$02; sta $A000
  lda $A001; adc #$01; sta $A001
}*/

/* Create a screen memory backup from StartAddress to EndAddress but
limited to game area */
.macro CopyGameAreaScreenRam(StartAddress, EndAddress) {
    ldx #31
  !:
    dex
    .for (var i = 0; i < 25 ; i++) {
      lda StartAddress + (i * 40), x
      sta EndAddress + (i * 40), x
    }
    cpx #0
    beq Done
    jmp !-
  Done:
}

.macro CopyDialogScreenRam(StartAddress, EndAddress) {
    ldx #14
  !:
    dex
    .for (var i = 0; i < 7 ; i++) {
      lda StartAddress + (i * 14), x
      sta EndAddress + ((i + 4) * 40) + 8, x
    }
    cpx #0
    beq Done
    jmp !-
  Done:
}

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
    InvertValue(Direction)

  !:
}

// Detect if there is an alien on the first column. Accumulator contains 0 if
// no alien has been found, 1 otherwise
.macro DetectLeftEdgeReached() {
    lda #1
    sta DetectEdgeReached.CurrentPosition

    jsr DetectEdgeReached
}

// Detect if there is an alien on the last column. Accumulator contains 0 if
// no alien has been found, 1 otherwise
.macro DetectRightEdgeReached() {
    lda #29
    sta DetectEdgeReached.CurrentPosition

    jsr DetectEdgeReached
}

// Detect if left or right edge contains an alien. Accumulator contains 0 if
// no alien has been found, 1 otherwise. Must be used only with macro.
DetectEdgeReached: {
    lda #>MapData
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
    cmp #(>MapData) + 3
    bcc CalculateNextRow

// Check if low byte of last row is reached
    lda CurrentPosition
    cmp #$c0
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
/* Moving aliens to down when edge is reached. Draw starts from bottom and
 copies line n on n-1 until top is reached. */
MoveAliensToDown: {
// Source line starts from 23, destination line starts from 24
    lda #(>MapData) + 3
    sta CurrentPosition + 1
    sta NewPosition + 1
    lda #$98
    sta CurrentPosition
    lda #$c0
    sta NewPosition

  SetupNewLine:
    ldx #0

    lda CurrentPosition
    sta T1 + 1
    lda CurrentPosition + 1
    sta T1 + 2

    lda NewPosition
    sta T2 + 1
    sta TNext + 1
    lda NewPosition + 1
    sta T2 + 2
    sta TNext + 2

  Loop:
  T1:
    lda CurrentPosition,x
// Check if current char is a protection, should not be copied
    cmp #MAP.PROTECTION_OVER
    bcs NoProtection
    cmp #MAP.PROTECTION_1
    bcc NoProtection

// Current char is a protection, copy a blank char
    lda #0
    jmp IsBlank

  NoProtection:
// Not a protection, check if current char is not an alien
    cmp #MAP.ALIEN_OVER
    bcs CheckBlank
    cmp #MAP.ALIEN_1
    bcc CheckBlank

// Alien, copy
    jmp HandleTick

// Not a protection, not an alien, maybe a blank
  CheckBlank:
    cmp #0
    beq IsBlank

    jmp CheckRowEnded

  IsBlank:
// Current char is blank, should be copied but not on a protection
    pha

  TNext:
    lda NewPosition,x
    cmp #MAP.PROTECTION_OVER
    bcs BeforeJumpToT2
    cmp #MAP.PROTECTION_1
    bcc BeforeJumpToT2

    pla

// Destination char is a protection, skip
    jmp CheckRowEnded

  BeforeJumpToT2:
    pla
    jmp T2

// Handle alien tick to switch frame
  HandleTick:
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

// Store character in new position
  T2:
    sta NewPosition,x

  CheckRowEnded:
    inx
    cpx #30
    bne Loop

// Check if HiByte CurrentPosition holds first row
    lda CurrentPosition + 1
    cmp #>MapData
    bne CalculateNextRow

// Check if LoByte CurrentPosition holds first row
    lda CurrentPosition
    cmp #$28
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
/* Moving aliens one step to left. Draw starts from top to bottom
and left to right. */
MoveAliensToLeft: {
// Draw starts from line 1 (line 0 is used only for free alien)
    lda #$28
    sta CurrentPosition
    lda #>MapData
    sta CurrentPosition + 1

  SetupNewLine:
    ldx #1
    ldy #0

    lda CurrentPosition
    sta T1 + 1
    sta T2 + 1
    sta TNext + 1
    lda CurrentPosition + 1
    sta T1 + 2
    sta T2 + 2
    sta TNext + 2

  Loop:
  T1:
    lda CurrentPosition,x

// Check if current char is a protection, should not be copied
    cmp #MAP.PROTECTION_OVER
    bcs NoProtection
    cmp #MAP.PROTECTION_1
    bcc NoProtection

// Current char is a protection, copy a blank char
    lda #0
    jmp IsBlank

  NoProtection:
// Not a protection, check if current char is not an alien
    cmp #MAP.ALIEN_OVER
    bcs CheckBlank
    cmp #MAP.ALIEN_1
    bcc CheckBlank

// Alien, copy
    jmp HandleTick

// Not a protection, not an alien, maybe a blank
  CheckBlank:
    cmp #0
    beq IsBlank

    jmp CheckRowEnded

  IsBlank:
// Current char is blank, should be copied but not on a protection
    pha

  TNext:
    lda CurrentPosition,y
    cmp #MAP.PROTECTION_OVER
    bcs BeforeJumpToT2
    cmp #MAP.PROTECTION_1
    bcc BeforeJumpToT2

    pla

// Destination char is a protection, skip
    jmp CheckRowEnded

  BeforeJumpToT2:
    pla
    jmp T2

// Handle alien tick to switch frame
  HandleTick:
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

// Store character in new position
  T2:
    sta CurrentPosition,y

  CheckRowEnded:
    inx
    iny
    cpy #30
    bne Loop

// Check if HiByte CurrentPosition holds last row
    lda CurrentPosition + 1
    cmp #(>MapData) + 3
    bne NextLine

// Check if LoByte CurrentPosition holds last row
    lda CurrentPosition
    cmp #$c0
    beq Done

  NextLine:
    c64lib_add16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    rts

    CurrentPosition: .word $beef
}

* = * "MoveAliensToRight"
/* Moving aliens one step to right. Draw starts from top to bottom
and right to left. */
MoveAliensToRight: {
// Draw starts from line 1 (line 0 is used only for free alien)
    lda #$27
    sta CurrentPosition
    lda #>MapData
    sta CurrentPosition + 1

  SetupNewLine:
    lda #0

    ldy #30
    ldx #29

    lda CurrentPosition
    sta T1 + 1
    sta T2 + 1
    sta TNext + 1
    lda CurrentPosition + 1
    sta T1 + 2
    sta T2 + 2
    sta TNext + 2

  Loop:
  T1:
    lda CurrentPosition,x

// Check if current char is a protection, should not be copied
    cmp #MAP.PROTECTION_OVER
    bcs NoProtection
    cmp #MAP.PROTECTION_1
    bcc NoProtection

// Current char is a protection, copy a blank char
    lda #0
    jmp IsBlank

  NoProtection:
// Not a protection, check if current char is not an alien
    cmp #MAP.ALIEN_OVER
    bcs CheckBlank
    cmp #MAP.ALIEN_1
    bcc CheckBlank

// Alien, copy
    jmp HandleTick

// Not a protection, not an alien, maybe a blank
  CheckBlank:
    cmp #0
    beq IsBlank

    jmp CheckRowEnded

  IsBlank:
// Current char is blank, should be copied but not on a protection
    pha

  TNext:
    lda CurrentPosition,y
    cmp #MAP.PROTECTION_OVER
    bcs BeforeJumpToT2
    cmp #MAP.PROTECTION_1
    bcc BeforeJumpToT2

    pla

// Destination char is a protection, skip
    jmp CheckRowEnded

  BeforeJumpToT2:
    pla
    jmp T2

// Handle alien tick to switch frame
  HandleTick:
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

// Store character in new position
  T2:
    sta CurrentPosition,y

  CheckRowEnded:
    dey
    dex
    bne Loop

// Check if HiByte CurrentPosition holds last row
    lda CurrentPosition + 1
    cmp #(>MapData) + 3
    bne NextLine

// Check if LoByte CurrentPosition holds last row
    lda CurrentPosition
    cmp #$bf
    beq Done

  NextLine:
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

* = * "SetColorToCharsForIntromap"
SetColorToCharsForIntromap: {
    lda #$04
    sta CleanLoop
    lda #0
    sta StartLoop + 1
    lda #>IntroMapData
    sta PaintCols + 2
    lda #$d8
    sta ColorMap + 2
  StartLoop:
    ldx #$00
  PaintCols:
    ldy IntroMapData, x
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

.macro InvertValue(value) {
    lda value
    eor #$ff
    sta value
}

.filenamespace Utils

WaitRoutine: {
  VBLANKWAITLOW:
    lda $d011
    bpl VBLANKWAITLOW
  VBLANKWAITHIGH:
    lda $d011
    bmi VBLANKWAITHIGH

    rts
}

* = * "Utils GetRandom"
GetRandom: {
  Loop:
    lda c64lib.RASTER
    eor $dc04
    sbc $dc05
    cmp GeneratorMax
    bcs Loop
    cmp GeneratorMin
    bcc Loop
    rts

    GeneratorMin: .byte $00
    GeneratorMax: .byte $00
}

#import "./_label.asm"
#import "./_hud.asm"

#import "./common/lib/math-global.asm"
