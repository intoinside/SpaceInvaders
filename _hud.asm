
#importonce

/* Init hud for a new game. */
.macro Hud_Init() {
    lda #MAP.ZeroChar
    sta Hud.ScoreLabel
    sta Hud.ScoreLabel + 1
    sta Hud.ScoreLabel + 2
    sta Hud.ScoreLabel + 3
    sta Hud.ScoreLabel + 4

    lda #(3 + MAP.ZeroChar)
    sta Hud.LifeLeftCounter

    lda #0
    sta Hud.CurrentScore
    sta Hud.CurrentScore + 1
    sta Hud.CurrentScore + 2
    sta Hud.CurrentScore + 3
    sta Hud.CurrentScore + 4
}

/* Add points to current score. */
.macro AddPoints(digit3, digit2, digit1) {
    lda #digit1
    sta Hud.AddScore.Points + 2
    lda #digit2
    sta Hud.AddScore.Points + 1
    lda #digit3
    sta Hud.AddScore.Points

    jsr Hud.AddScore
}

.filenamespace Hud

* = * "Hud AddScore"
/* Add points to current score, used in conjunction with macro
AddPoints. */
AddScore: {
    ldx #3
    clc
  !:
    lda CurrentScore + 1, x
    adc Points - 1, x
    cmp #10
    bcc SaveDigit
    sbc #10
    sec

  SaveDigit:
    sta CurrentScore + 1, x
    dex
    bne !-

  Done:
    jmp DrawScore   // jsr + rts

  Points: .byte $00, $00, $00
}

* = * "Hud ResetScore"
/* Reset current score to zero. */
ResetScore: {
    ldx #5
    lda #0
  !:
    sta CurrentScore, x
    dex
    bne !-

    jmp DrawScore   // jsr + rts
}

* = * "Hud DrawScore"
/* Draw current score to screen. */
DrawScore: {
  // Append current score on score label
    ldx #0
    clc
  !:
    lda CurrentScore, x
    adc #MAP.ZeroChar
    sta ScoreLabel, x
    inx
    cpx #$05
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

* = * "Hud CompareAndUpdateHiScore"
/* Compare and update, if necessary, hiscore. */
CompareAndUpdateHiScore: {
    lda ScoreLabel
    cmp HiScoreLabel
    bcc !+
    lda ScoreLabel + 1
    cmp HiScoreLabel + 1
    bcc !+
    lda ScoreLabel + 2
    cmp HiScoreLabel + 2
    bcc !+
    lda ScoreLabel + 3
    cmp HiScoreLabel + 3
    bcc !+
    lda ScoreLabel + 4
    cmp HiScoreLabel + 4
    bcc !+

  UpdateHiScore1:
    lda ScoreLabel
    sta HiScoreLabel
    sta HiScoreLabelOnIntro
  UpdateHiScore2:
    lda ScoreLabel + 1
    sta HiScoreLabel + 1
    sta HiScoreLabelOnIntro + 1
  UpdateHiScore3:
    lda ScoreLabel + 2
    sta HiScoreLabel + 2
    sta HiScoreLabelOnIntro + 2
  UpdateHiScore4:
    lda ScoreLabel + 3
    sta HiScoreLabel + 3
    sta HiScoreLabelOnIntro + 3
  UpdateHiScore5:
    lda ScoreLabel + 4
    sta HiScoreLabel + 4
    sta HiScoreLabelOnIntro + 4

  !:
    rts
}

.label ScoreLabel = MapData + c64lib_getTextOffset(32, 3);
.label HiScoreLabel = MapData + c64lib_getTextOffset(32, 7);

.label HiScoreLabelOnIntro = IntroMapData + c64lib_getTextOffset(27, 14);

.label LifeLeftCounter = MapData + c64lib_getTextOffset(32, 10);

CurrentScore: .byte 0, 0, 0, 0, 0

#import "./_label.asm"
#import "chipset/lib/vic2-global.asm"
