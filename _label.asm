
#importonce

.segmentdef Code
.segmentdef Map [start=$4000]
.segmentdef Sprites [start=$5000]
.segmentdef CharsetsColors [start=$5600]
.segmentdef Charsets [start=$5800]
.segmentdef Intro
.segmentdef Sounds [start=$c000]

.segment Map
* = $4000 "IntroMapData"
IntroMapData:
  .import binary "./assets/intromap.bin"
* = $4400 "MapData"
MapData:
  .import binary "./assets/mainmap.bin"
* = $4800 "MapDummyArea"
MapDummyArea:
* = $4c00 "DialogLevelCompleted"
DialogLevelCompleted:
  .import binary "./assets/dialog-level-completed.bin"
* = * "DialogGameOver"
DialogGameOver:
  .import binary "./assets/dialog-game-over.bin"

* = * "ScreenMemTableL"
ScreenMemTableL:
.for (var i = 0; i<25; i++) .byte <MapData + (i * $28)

* = * "ScreenMemTableH"
ScreenMemTableH:
.for (var i = 0; i<25; i++) .byte >MapData + (i * $28)

.segment Charsets
Charsets:
  .import binary "./assets/charset.bin"

.segment CharsetsColors
CharsetsColors:
  .import binary "./assets/charcolors.bin"

.segment Intro
.var picture = LoadBinary("./assets/intro.koa", BF_KOALA)
* = $6000 "IntroBitmap";
IntroBitmap:  .fill picture.getBitmapSize(), picture.getBitmap(i)
* = $5c00 "MapForBitmap";
MapForBitmap: .fill picture.getScreenRamSize(), picture.getScreenRam(i)
* = $9400 "IntroColorRam";
IntroColorRam:   .fill picture.getColorRamSize(), picture.getColorRam(i)

.segment Sounds
Sounds:
.byte $bd,$bf,$c2,$99,$68,$c2,$bd,$c2,$c2,$99,$6b,$c2,$bd,$cb,$c2,$99
.byte $74,$c2,$bd,$ce,$c2,$99,$77,$c2,$bd,$c5,$c2,$99,$6e,$c2,$bd,$c8
.byte $c2,$99,$71,$c2,$60,$bd,$d1,$c2,$99,$68,$c2,$bd,$d4,$c2,$99,$6b
.byte $c2,$bd,$dd,$c2,$99,$74,$c2,$bd,$e0,$c2,$99,$77,$c2,$bd,$d7,$c2
.byte $99,$6e,$c2,$bd,$da,$c2,$99,$71,$c2,$60,$99,$5c,$c2,$aa,$98,$48
.byte $b9,$59,$c2,$85,$fe,$a9,$d4,$85,$ff,$bd,$b9,$c2,$99,$62,$c2,$bd
.byte $bc,$c2,$99,$65,$c2,$bd,$9e,$c2,$99,$86,$c2,$bd,$a1,$c2,$99,$89
.byte $c2,$bd,$a4,$c2,$99,$8c,$c2,$bd,$9b,$c2,$c9,$41,$d0,$18,$bd,$ad
.byte $c2,$99,$8f,$c2,$bd,$b0,$c2,$99,$92,$c2,$bd,$b3,$c2,$99,$95,$c2
.byte $bd,$b6,$c2,$99,$98,$c2,$a9,$00,$99,$7a,$c2,$99,$7d,$c2,$99,$80
.byte $c2,$99,$83,$c2,$20,$00,$c0,$bd,$9b,$c2,$c9,$41,$d0,$0d,$a0,$02
.byte $bd,$ad,$c2,$91,$fe,$c8,$bd,$b0,$c2,$91,$fe,$bd,$a7,$c2,$a0,$05
.byte $91,$fe,$bd,$aa,$c2,$c8,$91,$fe,$bd,$9b,$c2,$a0,$04,$91,$fe,$68
.byte $a8,$a9,$00,$99,$5f,$c2,$60,$b9,$5c,$c2,$c9,$ff,$f0,$f8,$aa,$b9
.byte $59,$c2,$85,$fe,$a9,$d4,$85,$ff,$b9,$5f,$c2,$c9,$02,$f0,$18,$4c
.byte $16,$c1,$a9,$ff,$99,$5c,$c2,$b9,$59,$c2,$85,$fe,$a9,$d4,$85,$ff
.byte $a9,$00,$a0,$04,$91,$fe,$60,$a9,$ff,$99,$5c,$c2,$bd,$9b,$c2,$29
.byte $fe,$a0,$04,$91,$fe,$60,$86,$fc,$84,$fd,$a6,$fd,$bd,$8c,$c2,$f0
.byte $5b,$a0,$00,$18,$bd,$62,$c2,$7d,$7d,$c2,$91,$fe,$c8,$bd,$65,$c2
.byte $7d,$80,$c2,$91,$fe,$bd,$83,$c2,$d0,$24,$18,$bd,$7d,$c2,$7d,$86
.byte $c2,$9d,$7d,$c2,$bd,$80,$c2,$7d,$89,$c2,$9d,$80,$c2,$fe,$7a,$c2
.byte $bd,$7a,$c2,$dd,$8c,$c2,$d0,$31,$fe,$83,$c2,$4c,$89,$c1,$38,$bd
.byte $7d,$c2,$fd,$86,$c2,$9d,$7d,$c2,$bd,$80,$c2,$fd,$89,$c2,$9d,$80
.byte $c2,$de,$7a,$c2,$d0,$13,$de,$83,$c2,$4c,$89,$c1,$a0,$00,$bd,$62
.byte $c2,$91,$fe,$bd,$65,$c2,$c8,$91,$fe,$a4,$fc,$b9,$9b,$c2,$c9,$41
.byte $d0,$3b,$a0,$02,$bd,$8f,$c2,$91,$fe,$c8,$bd,$92,$c2,$91,$fe,$bd
.byte $5f,$c2,$d0,$16,$18,$bd,$8f,$c2,$7d,$95,$c2,$9d,$8f,$c2,$bd,$92
.byte $c2,$7d,$98,$c2,$9d,$92,$c2,$4c,$cd,$c1,$38,$bd,$8f,$c2,$fd,$95
.byte $c2,$9d,$8f,$c2,$bd,$92,$c2,$fd,$98,$c2,$9d,$92,$c2,$18,$bd,$62
.byte $c2,$7d,$68,$c2,$9d,$62,$c2,$bd,$65,$c2,$7d,$6b,$c2,$9d,$65,$c2
.byte $30,$3a,$18,$bd,$68,$c2,$7d,$6e,$c2,$9d,$68,$c2,$bd,$6b,$c2,$7d
.byte $71,$c2,$9d,$6b,$c2,$bd,$6b,$c2,$10,$11,$bd,$65,$c2,$dd,$77,$c2
.byte $d0,$06,$98,$dd,$74,$c2,$f0,$14,$90,$12,$60,$bd,$65,$c2,$dd,$77
.byte $c2,$90,$08,$d0,$07,$98,$dd,$74,$c2,$b0,$01,$60,$fe,$5f,$c2,$bd
.byte $5f,$c2,$c9,$01,$d0,$07,$a6,$fc,$a4,$fd,$20,$25,$c0,$60,$a0,$00
.byte $20,$d7,$c0,$ad,$0d,$dc,$40,$a0,$00,$20,$d7,$c0,$a0,$01,$20,$d7
.byte $c0,$a0,$02,$4c,$d7,$c0,$20,$37,$c2,$4c,$31,$ea,$78,$a9,$46,$8d
.byte $14,$03,$a9,$c2,$8d,$15,$03,$58,$60,$00,$07,$0e,$ff,$ff,$ff,$02
.byte $00,$00,$53,$00,$00,$00,$00,$00,$71,$00,$00,$fd,$a1,$00,$00,$03
.byte $00,$00,$00,$00,$9f,$00,$00,$01,$ff,$00,$00,$3f,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$09
.byte $00,$00,$17,$00,$00,$41,$00,$00,$02,$00,$00,$11,$11,$81,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$54,$54,$4b,$31,$21,$c9,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$d9,$b9,$21,$33,$64,$05,$bf
.byte $cb,$c1,$fc,$fc,$fd,$bf,$bc,$fe,$ff,$ff,$ff,$62,$56,$52,$19,$30
.byte $04,$fa,$bf,$71,$fc,$fc,$fd,$da,$83,$00,$ff,$ff,$00,$71,$93,$9f
.byte $13,$18,$01

.segment Sprites
Sprites:
  .import binary "./assets/sprites.bin"

MAP: {
  .label PROTECTION_1 = 70

  .label PROTECTION_LAST = PROTECTION_1 + 4
  .label PROTECTION_OVER = PROTECTION_LAST + 1

  .label ALIEN_1 = 38
  .label ALIEN_2 = ALIEN_1 + 4
  .label ALIEN_3 = ALIEN_2 + 4
  .label ALIEN_4 = ALIEN_3 + 4
  .label ALIEN_5 = ALIEN_4 + 4
  .label ALIEN_LAST = ALIEN_1 + 31
  .label ALIEN_OVER = ALIEN_LAST + 1

  .label ZeroChar = 27;
}

SPRITES: {
  .label FIRST_SPRITE_PTR = ((Sprites - IntroMapData) / 64)
  .label SHOOTER = FIRST_SPRITE_PTR
  .label BULLET = FIRST_SPRITE_PTR + 5

  .label ALIEN_BULLET = FIRST_SPRITE_PTR + 6

  .label EXPL_1 = FIRST_SPRITE_PTR + 7
  .label EXPL_2 = EXPL_1 + 1
  .label EXPL_3 = EXPL_1 + 2
  .label EXPL_4 = EXPL_1 + 3
  .label EXPL_5 = EXPL_1 + 4

  .label FREEALIEN_1A = FIRST_SPRITE_PTR + 12
  .label FREEALIEN_1B = FREEALIEN_1A + 1
  .label FREEALIEN_2A = FIRST_SPRITE_PTR + 14
  .label FREEALIEN_2B = FREEALIEN_2A + 1
  .label FREEALIEN_3A = FIRST_SPRITE_PTR + 16
  .label FREEALIEN_3B = FREEALIEN_3A + 1
  .label FREEALIEN_4A = FIRST_SPRITE_PTR + 18
  .label FREEALIEN_4B = FREEALIEN_4A + 1
  .label FREEALIEN_5A = FIRST_SPRITE_PTR + 20
  .label FREEALIEN_5B = FREEALIEN_5A + 1

  .label SPRITES_0 = MapData + $3f8
  .label SPRITES_1 = MapData + $3f9
  .label SPRITES_2 = MapData + $3fa
  .label SPRITES_3 = MapData + $3fb
  .label SPRITES_4 = MapData + $3fc
  .label SPRITES_5 = MapData + $3fd
  .label SPRITES_6 = MapData + $3fe
  .label SPRITES_7 = MapData + $3ff
}

CIA1: {
  .label PORT_A             = $dc00
  .label PORT_B             = $dc01
  .label PORT_A_DIRECTION   = $dc02
  .label PORT_B_DIRECTION   = $dc03
}

CIA2: {
  .label PORT_A = $dd00
}

KEYB: {
  .label CURRENT_PRESSED    = $00cb
  .label BUFFER_LEN         = $0289
  .label REPEAT_SWITCH      = $028a
}

// 1 means game over (all life lost)
GameOver: .byte 0

// 1 means shooter exploded
LifeEnd: .byte 0

// 1 means all aliens exploded
LevelCompleted: .byte 0
