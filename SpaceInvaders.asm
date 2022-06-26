
#import "_label.asm"

.file [name="./SpaceInvaders.prg", segments="Intro, Code, Charsets, CharsetsColors, Sounds, Map, Sprites", modify="BasicUpstart", _start=$0810]
.disk [filename="./SpaceInvaders.d64", name="SPACEINVADERS", id="C2022", showInfo]
{
  [name="----------------", type="rel"],
  [name="     *    *     ", type="rel"],
  [name="   *  *  *  *   ", type="rel"],
  [name="   * ****** *   ", type="rel"],
  [name="   *** ** ***   ", type="rel"],
  [name="    ********    ", type="rel"],
  [name="     ******     ", type="rel"],
  [name="     *    *     ", type="rel"],
  [name="    *      *    ", type="rel"],
  [name="----------------", type="rel"],
  [name="--- RAFFAELE ---", type="rel"],
  [name="--- INTORCIA ---", type="rel"],
  [name="-- @GMAIL.COM --", type="rel"],
  [name="----------------", type="rel"],
  [name="SPACEINVADERS", type="prg", segments="Intro, Code, Charsets, CharsetsColors, Sounds, Map, Sprites", modify="BasicUpstart", _start=$0810],
  [name="----------------", type="rel"]
}

.segment Code

* = $0810 "Entry"
Entry: {
    MainGameSettings()

    ShowIntroBitmap()

    IsJoystickFirePressedAndReleased()

    AfterIntroSettings()

    CopyGameAreaScreenRam(MapData, MapDummyArea)

    jsr NewGameSettings

// Loop with intro screen
  IntroLoop:
    IsJoystickFirePressedAndReleased()
    RemoveIntroMap()

// Loop for internal game
  GameLoop:
    jsr Utils.WaitRoutine
    lda c64lib.SPRITE_2B_COLLISION
    sta CollisionBkgDummy

    lda c64lib.SPRITE_2S_COLLISION
    sta CollisionSprDummy

    inc CounterForAliensMove

    lda LevelCompleted
    beq !+

// Level completed, show dialog
    CopyDialogScreenRam(DialogLevelCompleted, MapData)
    jsr SetColorToChars
    IsJoystickFirePressedAndReleased()

    jsr NewLevelSettings
    jmp GameLoop

  !:
    lda LifeEnd
    beq CheckGameOver

// Shooter exploded, next life
    jsr NewLifeSettings
    jmp GameLoop

  CheckGameOver:
    lda GameOver
    beq IsNotOver

// GameOver, show dialog or wait for firepress
    CopyDialogScreenRam(DialogGameOver, MapData)
    jsr SetColorToChars
    IsJoystickFirePressedAndReleased()

    jsr Hud.CompareAndUpdateHiScore

    jsr NewGameSettings
    jmp IntroLoop

  IsNotOver:
// Game is in progress, detect shooter and alines move
    Shooter_Handle()
    Aliens_Handle()

    Shooter_FreeAlienHit()

    lda CounterForAliensMove
    cmp #1
    bne CheckMoveAlienIteration

    InvertValue(MoveTick)

// Detect direction, based on current direction and
// alien position
    DetectDirection(Direction, HasSwitched)
    jmp GameLoop

  CheckMoveAlienIteration:
    lda CounterForAliensMove
  SelfModCodeForSpeed:
    cmp #50
    beq GotoMoveAliens

    jmp GameLoop

  GotoMoveAliens:
// Move aliens
    AliensDescends(HasSwitched)

    MoveAliens(Direction, HasSwitched)

    lda #0
    sta CounterForAliensMove

    jmp GameLoop

  CounterForAliensMove: .byte 0
}

WaitFrame: .byte 0

.macro MainGameSettings() {
// Switch out Basic so there is available ram on $a000-$bfff
    lda $01
    ora #%00000010
    and #%11111110  // %xxxxxx10 - Ram $a000-$bfff, Kernal $e000-$ffff
    sta $01

// Set Vic bank 1 ($4000-$7fff)
    lda #%00000010
    sta CIA2.PORT_A
}

.macro ShowIntroBitmap() {
    lda #%01111000  // Bitmap mem $2000, Screen mem $1c00 (+VIC $4000)
    sta c64lib.MEMORY_CONTROL
    lda #%11011000  // 40 cols, multicolor mode
    sta c64lib.CONTROL_2
    lda #%00111011
    sta c64lib.CONTROL_1

    ldx #0
  !Loop:
    .for (var i=0; i<4; i++) {
      lda IntroColorRam + i * $100, x
      sta $d800 + i * $100, x
    }
    inx
    bne !Loop-

    lda #picture.getBackgroundColor()
    sta $d020
    sta $d021
}

.macro AfterIntroSettings() {
    lda #%11001000  // 40 cols, multicolor mode
    sta c64lib.CONTROL_2

    lda #%00011011
    sta c64lib.CONTROL_1

    lda #0
    sta c64lib.BG_COL_0
    sta c64lib.BORDER_COL

    sei
    lda #<RasterIrq
    sta $0314
    lda #>RasterIrq
    sta $0315
    cli
}

RasterIrq: {
    jsr $c237 // play all voices!
    jmp $ea31
}

.macro ShowIntroMap() {
    lda #%00000000
    sta c64lib.SPRITE_ENABLE

// Set pointer to char memory to $5800-$5fff (xxxx011x)
// and pointer to screen memory to $4000-$47ff (0000xxxx)
    lda #%00000110
    sta c64lib.MEMORY_CONTROL

    inc IsIntroMap

    jsr SetColorToCharsForIntromap
}

.macro RemoveIntroMap() {
    lda #%00000001
    sta c64lib.SPRITE_ENABLE

// Set pointer to char memory to $5800-$5fff (xxxx011x)
// and pointer to screen memory to $4400-$47ff (0001xxxx)
    lda #%00010110
    sta c64lib.MEMORY_CONTROL

    lda #0
    sta IsIntroMap

    jsr SetColorToChars
}

* = * "NewLevelSettings"
NewLevelSettings: {
    jsr NewLifeSettings

    lda #0
    sta LevelCompleted

// Change speed (with a maximun)
    lda Entry.SelfModCodeForSpeed + 1
    sec
    sbc #4    
    cmp #20
    bcs DoneSpeed
    lda #20

  DoneSpeed:
    sta Entry.SelfModCodeForSpeed + 1

// Change free alien sprite
    lda Shooter.HandleFreeAlien.SelfModFreeAlien1 + 1
    cmp #SPRITES.FREEALIEN_1A
    beq SetTo2A
    cmp #SPRITES.FREEALIEN_2A
    beq SetTo3A
    cmp #SPRITES.FREEALIEN_3A
    beq SetTo4A
    cmp #SPRITES.FREEALIEN_4A
    beq SetTo5A
    
    ldx #LIGHT_GREY
    lda #SPRITES.FREEALIEN_1A
    jmp SetFreeAlien

  SetTo2A:
    ldx #DARK_GRAY
    lda #SPRITES.FREEALIEN_2A
    jmp SetFreeAlien

  SetTo3A:
    ldx #YELLOW
    lda #SPRITES.FREEALIEN_3A
    jmp SetFreeAlien

  SetTo4A:
    ldx #PURPLE
    lda #SPRITES.FREEALIEN_4A
    jmp SetFreeAlien

  SetTo5A:
    ldx #GREEN
    lda #SPRITES.FREEALIEN_5A

  SetFreeAlien:
    stx c64lib.SPRITE_3_COLOR
    sta Shooter.HandleFreeAlien.SelfModFreeAlien1 + 1
    sta Shooter.HandleFreeAlien.SelfModFreeAlien2 + 1
    
  Done:
    rts
}

* = * "NewLifeSettings"
NewLifeSettings: {
    CopyGameAreaScreenRam(MapDummyArea, MapData)
    jsr SetColorToChars

    lda #%00000001
    sta c64lib.SPRITE_ENABLE

    Aliens_Init_Level()
    Shooter_Init_Level()

    jsr SpritesCommon.Init

    lda #0
    sta StartNewGame
    sta LevelCompleted
    sta LifeEnd
    sta Direction
    sta HasSwitched
    sta MoveTick
    sta Entry.CounterForAliensMove

    rts
}

* = * "NewGameSettings"
NewGameSettings: {
    ShowIntroMap()

    CopyGameAreaScreenRam(MapDummyArea, MapData)

    Aliens_Init_Level()
    Shooter_Init_Level()
    Hud_Init()

    lda #0
    sta StartNewGame
    sta GameOver
    sta LevelCompleted
    sta LifeEnd
    sta Direction
    sta HasSwitched
    sta MoveTick
    sta Entry.CounterForAliensMove

    lda #50
    sta Entry.SelfModCodeForSpeed + 1

    lda #LIGHT_GREY
    sta c64lib.SPRITE_3_COLOR
    lda #SPRITES.FREEALIEN_1A
    sta Shooter.HandleFreeAlien.SelfModFreeAlien1 + 1
    sta Shooter.HandleFreeAlien.SelfModFreeAlien2 + 1

    jsr SpritesCommon.Init

  Done:
    rts
}

// If 1 then intro map is showing (no game action should be taken)
IsIntroMap: .byte 0

// Current alien direction, 0 means left, 1 means right
Direction: .byte 0

// Direction has switched, aliens must go down
HasSwitched: .byte 0

#import "_aliens.asm"
#import "_sprites.asm"
#import "_shooter.asm"
#import "_joystick.asm"
#import "_utils.asm"

#import "chipset/lib/vic2.asm"
