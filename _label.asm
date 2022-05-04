
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
  .label ALIEN_LAST = ALIEN_1 + 31
  .label ALIEN_OVER = ALIEN_LAST + 1
}

SPRITES: {
  .label SHOOTER = ((Sprites - MapData) / 64)
  .label BULLET = ((Sprites - MapData) / 64) + 1

  .label EXPL_1 = ((Sprites - MapData) / 64) + 2
  .label EXPL_2 = EXPL_1 + 1
  .label EXPL_3 = EXPL_1 + 2
  .label EXPL_4 = EXPL_1 + 3
  .label EXPL_5 = EXPL_1 + 4

  .label FREEALIEN_1A = ((Sprites - MapData) / 64) + 7
  .label FREEALIEN_1B = FREEALIEN_1A + 1
  .label FREEALIEN_2A = ((Sprites - MapData) / 64) + 9
  .label FREEALIEN_2B = FREEALIEN_2A + 1
  .label FREEALIEN_3A = ((Sprites - MapData) / 64) + 11
  .label FREEALIEN_3B = FREEALIEN_3A + 1

  .label SPRITES_0 = MapData + $3f8
  .label SPRITES_1 = MapData + $3f9
  .label SPRITES_2 = MapData + $3fa
  .label SPRITES_3 = MapData + $3fb
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
