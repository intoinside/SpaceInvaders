
#importonce

.filenamespace Aliens

// Alien count, determined at start and updated when and alien is destroyed
Count: .byte 0

// An alien is currently shooting
IsShooting: .byte 0

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

* = * "Aliens Shoot"
/* Check if aliens are not shooting, then shoot. */
Shoot: {
    lda IsShooting
    beq !+

    jmp Done

  !:
    lda #0
    sta Found

// Source line starts from 23
    lda #$43
    sta CurrentPosition + 1
    lda #$98
    sta CurrentPosition

    ldy #24

  SetupNewLine:
    ldx #0

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

  AlienFound:
    inc Found
    //GetRandomNumberInRange(1, 3)
    lda #1
    cmp #2
    bcs CheckRowEnded

// Shoot!
    inc IsShooting

    txa
    asl
    asl
    asl
    clc
    adc #25
    sta c64lib.SPRITE_4_X

    tya
    asl
    asl
    asl
    clc
    adc #56
    sta c64lib.SPRITE_4_Y

    lda #SPRITES.ALIEN_BULLET
    sta SPRITES.SPRITES_4

    lda c64lib.SPRITE_ENABLE
    ora #%00010000
    sta c64lib.SPRITE_ENABLE

    jmp Done

  CheckRowEnded:
    inx
    cpx #30
    bne Loop

    lda Found
    bne Done

// Check if HiByte CurrentPosition holds first row
    lda CurrentPosition + 1
    cmp #$40
    bne CalculateNextRow

// Check if LoByte CurrentPosition holds first row
    lda CurrentPosition
    cmp #$00
    beq Done

  CalculateNextRow:
    dey
    c64lib_sub16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    rts

    CurrentPosition: .word $beef
    Found: .byte 0
}

HandleShoot: {
    lda IsShooting
    beq Done

  ShootingInProgress:
    lda #%00010000
    bit CollisionBkgDummy     
    bne CollisionHappened
    jmp MoveBullet

// Calculate screen ram row
  CollisionHappened:
    lda c64lib.SPRITE_4_Y
    sec
    sbc #50
    lsr
    lsr
    lsr
    sta CalculatedY

    tay
    lda ScreenMemTableL, y
    sta ScreenPositionCollided
    lda ScreenMemTableH, y
    sta ScreenPositionCollided + 1

// Calculate X
    lda c64lib.SPRITE_4_X
    sec
    sbc #24
    lsr
    lsr
    lsr
    addaccumulatortovar16(ScreenPositionCollided)

// Be sure that collided char is != 0
    lda ScreenPositionCollided
    sta CheckChar + 1
    lda ScreenPositionCollided + 1
    sta CheckChar + 2

  CheckChar:
    lda ScreenPositionCollided
    beq MoveBullet

    lda ScreenPositionCollided
    sta UpdateScreen + 1
    lda ScreenPositionCollided + 1
    sta UpdateScreen + 2

// Empty char on collided position, check where is the other part of alien
    lda #0
  UpdateScreen:
    sta ScreenPositionCollided

// Start explosion animation
    jsr ShowExplosion

// Collision with aliens happened, remove bullet
    jmp HideBullet

  MoveBullet:
// No collision detect, move bullet to up
    lda c64lib.SPRITE_4_Y
    clc
    adc #2
    sta c64lib.SPRITE_4_Y
    cmp #245
    bcc Done

  HideBullet:
    jsr ShootFinished

  Done:
    rts

  CalculatedY: .byte 0

  ScreenPositionCollided: .word $0000
}

* = * "Aliens ShootFinished"
ShootFinished: {
    lda IsShooting
    beq Done

    lda c64lib.SPRITE_ENABLE
    and #%11101111
    sta c64lib.SPRITE_ENABLE

    dec IsShooting

  Done:
    rts
}

* = * "Aliens ShowExplosion"
ShowExplosion: {
    lda c64lib.SPRITE_4_X
    sec
    sbc #12
    sta c64lib.SPRITE_2_X

    lda c64lib.SPRITE_4_Y
    sec
    sbc #12
    sta c64lib.SPRITE_2_Y
    
    lda #SPRITES.EXPL_1
    sta SPRITES.SPRITES_4

    lda c64lib.SPRITE_ENABLE
    ora #%00010000
    sta c64lib.SPRITE_ENABLE

    rts
}

#import "./_label.asm"
#import "./_utils.asm"

#import "./common/lib/math-global.asm"
