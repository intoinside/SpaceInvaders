
#importonce

.filenamespace Shooter

* = * "Shooter Init"
Init: {
    lda #SPRITES.SHOOTER
    sta SPRITES.SPRITES_0
    lda #SPRITES.BULLET
    sta SPRITES.SPRITES_1

    lda #GREEN
    sta c64lib.SPRITE_0_COLOR
    lda #GREY
    sta c64lib.SPRITE_1_COLOR

    lda #125
    sta c64lib.SPRITE_0_X
    lda #228
    sta c64lib.SPRITE_0_Y

    rts
}

* = * "Shooter Move"
Move: {
    jsr Joystick.GetJoystickMove

    lda Joystick.Direction
    beq CheckFire
    cmp #$ff
    bcs Left

  Right:
    lda c64lib.SPRITE_0_X
    cmp #249
    beq CheckFire
    inc c64lib.SPRITE_0_X 
    jmp CheckFire

  Left:
    lda c64lib.SPRITE_0_X
    cmp #28
    beq CheckFire
    dec c64lib.SPRITE_0_X 

  CheckFire:
    lda Joystick.FirePressed
    beq Done

    jsr Shoot

  Done:
    rts
}

* = * "Shooter HandleShoot"
HandleShoot: {
    lda IsShooting
    bne ShootingInProgress
    jmp Done

  ShootingInProgress:
    lda c64lib.SPRITE_2B_COLLISION
    and #%00000010
    bne CollisionHappened
    jmp MoveBullet

// Calculate screen ram row
  CollisionHappened:
    lda c64lib.SPRITE_1_Y
    sec
    sbc #50
    lsr
    lsr
    lsr
    tax
    lda ScreenMemTableH, x
    sta ScreenPositionCollided + 1
    lda ScreenMemTableL, x
    sta ScreenPositionCollided

// Calculate screen ram column
    lda c64lib.SPRITE_1_X
    sec
    sbc #23
    lsr
    lsr
    lsr
    clc
    adc ScreenPositionCollided
    sta ScreenPositionCollided
    sta ScreenPositionCollidedPrev
    sta ScreenPositionCollidedSucc
    lda ScreenPositionCollided + 1
    adc #0
    sta ScreenPositionCollided + 1
    sta ScreenPositionCollidedPrev + 1
    sta ScreenPositionCollidedSucc + 1

    c64lib_sub16($0001, ScreenPositionCollidedPrev)
    c64lib_add16($0001, ScreenPositionCollidedSucc)

    lda ScreenPositionCollided
    sta UpdateScreen + 1
    lda ScreenPositionCollided + 1
    sta UpdateScreen + 2

    lda #1
  UpdateScreen:
    sta ScreenPositionCollided

    lda ScreenPositionCollidedPrev
    sta CheckPrevChar + 1
    lda ScreenPositionCollidedPrev + 1
    sta CheckPrevChar + 2

  CheckPrevChar:
    lda ScreenPositionCollidedPrev
    beq CheckSucc

    lda ScreenPositionCollidedPrev
    sta UpdateScreenOtherPiece + 3
    lda ScreenPositionCollidedPrev + 1
    sta UpdateScreenOtherPiece + 4

    jmp UpdateScreenOtherPiece

  CheckSucc:  
    lda ScreenPositionCollidedSucc
    sta UpdateScreenOtherPiece + 3
    lda ScreenPositionCollidedSucc + 1
    sta UpdateScreenOtherPiece + 4

  UpdateScreenOtherPiece:
    lda #1
    sta ScreenPositionCollided

// Collision with aliens happened, remove bullet
    jmp HideBullet

  MoveBullet:
    lda c64lib.SPRITE_1_Y
    sec
    sbc #4
    sta c64lib.SPRITE_1_Y

    cmp #10
    bcs Done

  HideBullet:
    jsr ShootFinished

  Done:
    rts

  ScreenPositionCollided: .word $0000
  ScreenPositionCollidedPrev: .word $0000
  ScreenPositionCollidedSucc: .word $0000
  Dummy: .word 0

  ScreenMemTableL: .byte $00, $28, $50, $78, $a0, $c8, $f0, $18, $40, $68
                   .byte $90, $b8, $e0, $08, $30, $58, $80, $a8, $d0, $f8
                   .byte $20, $48, $70, $98, $c0
  ScreenMemTableH: .byte $40, $40, $40, $40, $40, $40, $40, $41, $41, $41
                   .byte $41, $41, $41, $42, $42, $42, $42, $42, $42, $42
                   .byte $43, $43, $43, $43, $43
}

* = * "Shooter Shoot"
Shoot: {
    lda IsShooting
    bne Done

// New shoot to draw
    inc IsShooting

    lda c64lib.SPRITE_0_X
    clc
    adc #6
    sta c64lib.SPRITE_1_X

    lda c64lib.SPRITE_0_Y
    clc
    adc #12
    sta c64lib.SPRITE_1_Y

    lda #%00000011
    sta c64lib.SPRITE_ENABLE

  Done:
    rts
}

* = * "Shooter ShootFinished"
ShootFinished: {
    lda IsShooting
    beq Done

    lda #%00000001
    sta c64lib.SPRITE_ENABLE

    dec IsShooting

  Done:
    rts
}

IsShooting: .byte 0

#import "./_joystick.asm"
#import "./_label.asm"

#import "./chipset/lib/vic2.asm"
#import "./common/lib/math-global.asm"
