
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

SPRITES: {
  .label SHOOTER = ((Sprites - MapData) / 64)
  .label BULLET = ((Sprites - MapData) / 64) + 1

  .label SPRITES_0 = MapData + $3f8
}

CIA2: {
  .label PORT_A = $dd00
}
