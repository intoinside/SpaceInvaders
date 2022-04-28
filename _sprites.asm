
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
    
    rts
}

#import "chipset/lib/vic2.asm"
