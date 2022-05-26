
#importonce

.segmentdef Code
.segmentdef Map [start=$4000]
.segmentdef Sprites [start=$5000]
.segmentdef Charsets [start=$5800]
.segmentdef CharsetsColors [start=$c000]

.segment Map
* = $4000 "IntroMapData"
IntroMapData:
  .import binary "./assets/intromap.bin"
* = $4400 "MapData"
MapData:
  .import binary "./assets/mainmap.bin"
* = $4800 "MapDummyArea"
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

* = * "ScreenMemTableL"
ScreenMemTableL:
.for (var i = 0; i<25; i++) .byte <MapData + (i * $28)

* = * "ScreenMemTableH"
ScreenMemTableH:
.for (var i = 0; i<25; i++) .byte >MapData + (i * $28)
