
#importonce

.filenamespace Joystick

// Player sprite direction, $00 - no move, $01 - right, $ff - left
Direction: .byte $00        

// Fire button, 0 not pressed, 1 pressed
FirePressed: .byte $00

* = * "Joystick GetJoystickMove"
GetJoystickMove: {
    lda #0
    sta $dc02

    ldx #$00
    lda $dc00

    lsr
    lsr
    lsr
    bcs !NoLeft+
    ldx #$ff
  !NoLeft:
    lsr
    bcs !NoRight+
    ldx #$01
  !NoRight:
    stx Direction
    ldx #$00
    lsr
    bcs !NoFirePressed+
    ldx #$ff
  !NoFirePressed:
    stx FirePressed
    rts
}
