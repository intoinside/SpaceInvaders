
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
    beq CheckFire
    inc c64lib.SPRITE_0_X 
    jmp CheckFire

  Left:
    lda c64lib.SPRITE_0_X
    cmp #250
    bcs CheckFire
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
    beq Done

    lda c64lib.SPRITE_1_Y
    sec
    sbc #4
    sta c64lib.SPRITE_1_Y

    cmp #10
    bcs Done

    jsr ShootFinished

  Done:
    rts
}

* = * "Shooter Shoot"
Shoot: {
    lda IsShooting
    bne Done

// New shoot to draw
    inc IsShooting

    lda c64lib.SPRITE_0_X
    sta c64lib.SPRITE_1_X

    lda c64lib.SPRITE_0_Y
    sta c64lib.SPRITE_1_Y

    lda #%00000011
    sta c64lib.SPRITE_ENABLE
    jmp Done

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

#import "chipset/lib/vic2.asm"
