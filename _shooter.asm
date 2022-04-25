
#importonce

.filenamespace Shooter

* = * "Shooter Init"
Init: {
    lda #SPRITES.SHOOTER
    sta SPRITES.SPRITES_0

    lda #$01
    sta c64lib.SPRITE_ENABLE
    sta c64lib.SPRITE_COL_MODE

    lda #0
    sta c64lib.SPRITE_MSB_X
    lda c64lib.SPRITE_EXPAND_X
    lda c64lib.SPRITE_EXPAND_Y

    lda #BLUE
    sta c64lib.SPRITE_COL_0
    lda #WHITE
    sta c64lib.SPRITE_COL_1
    
    lda #GREEN
    sta c64lib.SPRITE_0_COLOR

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
    beq Done
    cmp #$ff
    bcs Left

  Right:
    lda c64lib.SPRITE_0_X
    beq Done
    inc c64lib.SPRITE_0_X 
    jmp Done

  Left:
    lda c64lib.SPRITE_0_X
    cmp #250
    bcs Done
    dec c64lib.SPRITE_0_X 

  Done:
    rts
}

#import "./_joystick.asm"
#import "./_label.asm"

#import "chipset/lib/vic2.asm"
