
#import "_label.asm"

.file [name="./SpaceInvaders.prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810]
.disk [filename="./SpaceInvaders.d64", name="SPACEINVADERS", id="C2022", showInfo]
{
  [name="----------------", type="rel"],
  [name="--- RAFFAELE ---", type="rel"],
  [name="--- INTORCIA ---", type="rel"],
  [name="-- @GMAIL.COM --", type="rel"],
  [name="----------------", type="rel"],
  [name="SPACEINVADERS", type="prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810],
  [name="----------------", type="rel"]
}

.segment Code

* = $0810 "Entry"
Entry: {
    IsReturnPressedAndReleased()
    MainGameSettings()

  !:
    IsReturnPressedAndReleased()

// Detect direction, based on current direction and
// alien position
    DetectDirection(Direction, HasSwitched)

// If alien direction has switched, need to go down
    AliensDescends(HasSwitched)

// Move aliens according to direction
    MoveAliens(Direction, HasSwitched)

    jmp !-
}

.macro MainGameSettings() {
// Switch out Basic so there is available ram on $a000-$bfff
    lda $01
    ora #%00000010
    and #%11111110  // %xxxxxx10 - Ram $a000-$bfff, Kernal $e000-$ffff
    sta $01

// Set Vic bank 1 ($4000-$7fff)
    lda #%00000010
    sta CIA2.PORT_A

// Set pointer to char memory to $5800-$5fff (xxxx011x)
// and pointer to screen memory to $4000-$43ff (0000xxxx)
    lda #%00000110
    sta c64lib.MEMORY_CONTROL  

    lda #%11001000  // 40 cols, multicolor mode
    sta c64lib.CONTROL_2

    lda #0
    sta c64lib.BG_COL_0
    sta c64lib.BORDER_COL

    jsr SetColorToChars

    SetupSprites()
}

.macro SetupSprites() {
    lda #SPRITES.SHOOTER
    sta SPRITES.SPRITES_0

    lda #$ff
    sta c64lib.SPRITE_ENABLE
    sta c64lib.SPRITE_COL_MODE

    lda #0
    sta c64lib.SPRITE_MSB_X
    lda c64lib.SPRITE_EXPAND_X
    lda c64lib.SPRITE_EXPAND_Y

    lda #BLUE
    sta c64lib.SPRITE_COL_0
    lda #WHITE
    sta c64lib.SPRITE_COL_1
    
    lda #GREEN
    sta c64lib.SPRITE_0_COLOR

    lda #250
    sta c64lib.SPRITE_0_X
    lda #228
    sta c64lib.SPRITE_0_Y
}

// Current alien direction, 0 means left, 1 means right
Direction: .byte 0

// Direction has switched, aliens must go down
HasSwitched: .byte 0

#import "_keyboard.asm"
#import "_utils.asm"

#import "chipset/lib/vic2.asm"
