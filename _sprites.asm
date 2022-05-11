/***************************************************
Sprite recap
0: shooter
1: shooter bullet
2: shooter bullet explosion
3: free alien on top
4: alien bullet
5: alien bullet explosion
****************************************************/

#importonce

.filenamespace SpritesCommon

* = * "Sprites Init"
Init: {
    lda #%00000001
    sta c64lib.SPRITE_ENABLE
    lda #%11111111
    sta c64lib.SPRITE_COL_MODE

    lda #0
    sta c64lib.SPRITE_MSB_X
    lda c64lib.SPRITE_EXPAND_X
    lda c64lib.SPRITE_EXPAND_Y

    lda #RED
    sta c64lib.SPRITE_COL_0
    lda #WHITE
    sta c64lib.SPRITE_COL_1
    
    lda #SPRITES.SHOOTER
    sta SPRITES.SPRITES_0
    lda #SPRITES.BULLET
    sta SPRITES.SPRITES_1

    lda #SPRITES.FREEALIEN_1A
    sta SPRITES.SPRITES_3

    lda #LIGHT_RED
    sta c64lib.SPRITE_0_COLOR
    lda #GREY
    sta c64lib.SPRITE_1_COLOR
    lda #YELLOW
    sta c64lib.SPRITE_2_COLOR
    sta c64lib.SPRITE_4_COLOR
    sta c64lib.SPRITE_5_COLOR
    lda #LIGHT_GRAY
    sta c64lib.SPRITE_3_COLOR

    rts
}

#import "./_label.asm"

#import "chipset/lib/vic2.asm"
