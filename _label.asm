
#importonce

.segmentdef Code
.segmentdef MapData [start=$4000]
.segmentdef Sprites [start=$5000]
.segmentdef Charsets [start=$5800]
.segmentdef CharsetsColors [start=$c000]

.segment MapData
* = $4000 "MapData"
MapData:
  .import binary "./assets/mainmap.bin"
* = $4400 "MapDummyArea"
MapDummyArea:

.segment Charsets
Charsets:
  .import binary "./assets/charset.bin"

.segment CharsetsColors
CharsetsColors:
  .import binary "./assets/charcolors.bin"

.segment Sprites
Sprites:
  .import binary "./assets/sprites.bin"

MAP: {
  .label PROTECTION_1 = 69

  .label PROTECTION_LAST = PROTECTION_1 + 4
  .label PROTECTION_OVER = PROTECTION_LAST + 1

  .label ALIEN_1 = 37
  .label ALIEN_2 = 41
  .label ALIEN_3 = 45
  .label ALIEN_4 = 49
  .label ALIEN_5 = 53
  .label ALIEN_LAST = ALIEN_1 + 31
  .label ALIEN_OVER = ALIEN_LAST + 1
}

SPRITES: {
  .label SHOOTER = ((Sprites - MapData) / 64)
  .label BULLET = ((Sprites - MapData) / 64) + 5

  .label ALIEN_BULLET = ((Sprites - MapData) / 64) + 6

  .label EXPL_1 = ((Sprites - MapData) / 64) + 7
  .label EXPL_2 = EXPL_1 + 1
  .label EXPL_3 = EXPL_1 + 2
  .label EXPL_4 = EXPL_1 + 3
  .label EXPL_5 = EXPL_1 + 4

  .label FREEALIEN_1A = ((Sprites - MapData) / 64) + 12
  .label FREEALIEN_1B = FREEALIEN_1A + 1
  .label FREEALIEN_2A = ((Sprites - MapData) / 64) + 14
  .label FREEALIEN_2B = FREEALIEN_2A + 1
  .label FREEALIEN_3A = ((Sprites - MapData) / 64) + 16
  .label FREEALIEN_3B = FREEALIEN_3A + 1

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

// 1 means game over
GameOver: .byte 0

ScreenMemTableL: .byte $00, $28, $50, $78, $a0, $c8, $f0, $18, $40, $68
                  .byte $90, $b8, $e0, $08, $30, $58, $80, $a8, $d0, $f8
                  .byte $20, $48, $70, $98, $c0
ScreenMemTableH: .byte $40, $40, $40, $40, $40, $40, $40, $41, $41, $41
                  .byte $41, $41, $41, $42, $42, $42, $42, $42, $42, $42
                  .byte $43, $43, $43, $43, $43
