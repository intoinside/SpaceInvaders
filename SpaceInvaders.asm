
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

    CopyScreenRam(MapData, MapDummyArea)

    jsr Keyboard.Init
    SetIrqRaster(0)

    jsr NewGameSettings

    jmp *
}

WaitFrame: .byte 0

.macro SetIrqRaster(line) {
    sei
    lda #%01111111
    sta $dc0d
    and $d011
    sta $d011

    lda $dc0d
    lda $dd0d

    lda #0
    sta $d012

    lda #<Irq
    sta $0314
    lda #>Irq
    sta $0315

    lda #%00000001
    sta $d01a

    cli
}

* = * "Irq"
Irq: {
    lda c64lib.SPRITE_2B_COLLISION
    sta CollisionBkgDummy

    lda c64lib.SPRITE_2S_COLLISION
    sta CollisionSprDummy

    jsr ScanLineZero

    lda WaitCounter
    cmp #30
    beq On30Th

    cmp #40
    beq On40Th

    cmp #50
    beq On50Th

    jmp Done

  On30Th:
    jsr Scan30thSecond
    jmp Done

  On40Th:
    jsr Scan40thSecond
    jmp Done

  On50Th:
    jsr Scan50thSecond
    lda #255
    sta WaitCounter

  Done:
    inc WaitCounter
    asl $d019
    jmp $ea31

  WaitCounter: .byte 1
}

* = * "ScanLineZero"
/* Executed everytime scanline starts from 0. It means, every
screen refresh.*/
ScanLineZero: {
    lda GameOver
    beq IsNotOver

    rts

  IsNotOver:
    Shooter_Handle()
    Aliens_Handle()

    Shooter_FreeAlienHit()

    rts
}

* = * "Scan30thSecond"
Scan30thSecond: {
    lda StartNewGame
    beq Done

    jsr NewGameSettings
    
  Done:
    rts
}

* = * "Scan40thSecond"
Scan40thSecond: {
    lda GameOver
    beq !+
    rts

  !:
    InvertValue(MoveTick)

// Detect direction, based on current direction and
// alien position
    DetectDirection(Direction, HasSwitched)

    rts
}

* = * "Scan50thSecond"
Scan50thSecond: {
    lda GameOver
    beq !+
    rts

  !:
// If alien direction has switched, need to go down
    AliensDescends(HasSwitched)

// Move aliens according to direction
    MoveAliens(Direction, HasSwitched)

    rts
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
}

NewGameSettings: {
    Hud_Init()

    CopyScreenRam(MapDummyArea, MapData)
    jsr SetColorToChars

    Aliens_Init_Level()
    Shooter_Init_Level()

    lda #0
    sta StartNewGame
    sta GameOver
    sta Direction
    sta HasSwitched
    sta MoveTick

    jsr SpritesCommon.Init

    lda #1
    sta Irq.WaitCounter

    rts
}

// Current alien direction, 0 means left, 1 means right
Direction: .byte 0

// Direction has switched, aliens must go down
HasSwitched: .byte 0

#import "_aliens.asm"
#import "_sprites.asm"
#import "_shooter.asm"
#import "_keyboard.asm"
#import "_utils.asm"

#import "chipset/lib/vic2.asm"
