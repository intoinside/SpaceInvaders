
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

    NewGameSettings()

  !:
// Detect and handle shooter movement
    Shooter_Handle()
    Aliens_Handle()
    
    lda GameOver
    bne !-

    GetRandomNumberInRange(1, 250)
    cmp #238
    bcc WaitForNewMovement

  Shoot:
// Alien have to shoot
    jsr Aliens.Shoot

  WaitForNewMovement:
// Calculate 10th of second, if delta is < 10th seconds
// no move on aliens
    jsr Utils.WaitFor10thSecond
    lda Utils.WaitFor10thSecond.WaitCounter
    bne !-

  MoveAlienBlock:
    InvertValue(MoveTick)
    
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

    jsr SpritesCommon.Init
    jsr Shooter.Init
    jsr Aliens.Init
}

.macro NewGameSettings() {
    lda #27
    sta Hud.ScoreLabel
    sta Hud.ScoreLabel + 1
    sta Hud.ScoreLabel + 2
    sta Hud.ScoreLabel + 3
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
