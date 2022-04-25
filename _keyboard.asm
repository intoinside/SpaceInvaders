
#importonce

// Set Keyboard.ReturnPressed if return is pressed
.macro IsReturnPressed() {
    lda #%11111110
    sta Keyboard.DetectKeyPressed.MaskOnPortA
    lda #%00000010
    sta Keyboard.DetectKeyPressed.MaskOnPortB
    jsr Keyboard.DetectKeyPressed
    sta Keyboard.ReturnPressed
}

.macro IsReturnPressedAndReleased() {
  !:
    IsReturnPressed()
    beq !-
  !:
    jsr Keyboard.DetectKeyPressed
    bne !-
}

.macro IsBKeyPressed() {
    lda #%11110111
    sta Keyboard.DetectKeyPressed.MaskOnPortA
    lda #%00010000
    sta Keyboard.DetectKeyPressed.MaskOnPortB
    jsr Keyboard.DetectKeyPressed
}

.macro IsTKeyPressed() {
    lda #%11111011
    sta Keyboard.DetectKeyPressed.MaskOnPortA
    lda #%01000000
    sta Keyboard.DetectKeyPressed.MaskOnPortB
    jsr Keyboard.DetectKeyPressed
}

.filenamespace Keyboard

Init: {
    lda #1
    sta KEYB.BUFFER_LEN     // disable keyboard buffer
    lda #127
    sta KEYB.REPEAT_SWITCH  // disable key repeat
}

* = * "Keyboard DetectKeyPressed"
DetectKeyPressed: {
    sei
    lda #%11111111
    sta CIA1.PORT_A_DIRECTION
    lda #%00000000
    sta CIA1.PORT_B_DIRECTION

    lda MaskOnPortA
    sta CIA1.PORT_A
    lda CIA1.PORT_B
    and MaskOnPortB
    beq Pressed
    lda #$00
    jmp !+
  Pressed:
    lda #$01
  !:
    cli
    rts

  MaskOnPortA:    .byte $00
  MaskOnPortB:    .byte $00
}

ReturnPressed:    .byte $00
IKeyPressed:      .byte $00
BackArrowPressed: .byte $00

#import "_label.asm"
