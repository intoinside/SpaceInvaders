
#importonce

// Add points to current score
.macro AddPoints(digit4, digit3, digit2, digit1) {
    lda #digit1
    sta Hud.AddScore.Points + 3
    lda #digit2
    sta Hud.AddScore.Points + 2
    lda #digit3
    sta Hud.AddScore.Points + 1
    lda #digit4
    sta Hud.AddScore.Points

    jsr Hud.AddScore
}

.filenamespace Hud

* = * "Hud AddScore"
AddScore: {
    ldx #4
    clc
  !:
    lda CurrentScore - 1, x
    adc Points - 1, x
    cmp #10
    bcc SaveDigit
    sbc #10
    sec

  SaveDigit:
    sta CurrentScore - 1, x
    dex
    bne !-

  Done:
    jmp DrawScore   // jsr + rts

  Points: .byte $00, $00, $00, $00
}

* = * "Hud ResetScore"
ResetScore: {
    ldx #3
    lda #0
  !:
    sta CurrentScore, x
    dex
    bne !-

    jmp DrawScore   // jsr + rts
}

* = * "Hud DrawScore"
DrawScore: {
  // Append current score on score label
    ldx #0
    clc
  !:
    lda CurrentScore, x
    adc #ZeroChar
    sta ScoreLabel, x
    inx
    cpx #$04
    bne !-

  // Draws score label
    ldx #0
  LoopScore:
    lda ScoreLabel, x
  SelfMod:
    sta ScorePtr
    inc SelfMod + 1

    inx
    cpx #$0b
    bne LoopScore

    lda SelfMod + 1
    sbc #$0b
    sta SelfMod + 1

    rts

  .label ScorePtr = $beef
}

CompareAndUpdateHiScore: {
    lda HiScoreLabel
    cmp ScoreLabel
    bcc UpdateHiScore1
    lda HiScoreLabel + 1
    cmp ScoreLabel + 1
    bcc UpdateHiScore2
    lda HiScoreLabel + 2
    cmp ScoreLabel + 2
    bcc UpdateHiScore3
    lda HiScoreLabel + 3
    cmp ScoreLabel + 3
    bcc UpdateHiScore4
    jmp !+

  UpdateHiScore1:
    lda ScoreLabel
    sta HiScoreLabel
  UpdateHiScore2:
    lda ScoreLabel + 1
    sta HiScoreLabel + 1
  UpdateHiScore3:
    lda ScoreLabel + 2
    sta HiScoreLabel + 2
  UpdateHiScore4:
    lda ScoreLabel + 3
    sta HiScoreLabel + 3

  !:
    rts
}

.label ZeroChar = 27;
.label ScoreLabel = MapData + c64lib_getTextOffset(32, 3);
.label HiScoreLabel = MapData + c64lib_getTextOffset(32, 7);

CurrentScore: .byte 0, 0, 0, 0

#import "./_label.asm"
#import "chipset/lib/vic2-global.asm"