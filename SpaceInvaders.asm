
#import "_label.asm"

.file [name="./SpaceInvaders.prg", segments="Code, Charsets, CharsetsColors, Map, Sprites", modify="BasicUpstart", _start=$0810]
.disk [filename="./SpaceInvaders.d64", name="SPACEINVADERS", id="C2022", showInfo]
{
  [name="----------------", type="rel"],
  [name="--- RAFFAELE ---", type="rel"],
  [name="--- INTORCIA ---", type="rel"],
  [name="-- @GMAIL.COM --", type="rel"],
  [name="----------------", type="rel"],
  [name="SPACEINVADERS", type="prg", segments="Code, Charsets, CharsetsColors, Map, Sprites", modify="BasicUpstart", _start=$0810],
  [name="----------------", type="rel"]
}

.segment Code

* = $0810 "Entry"
Entry: {
  IsReturnPressedAndReleased()

  MainGameSettings()

  CopyGameAreaScreenRam(MapData, MapDummyArea)

  jsr Keyboard.Init

  jsr FirstGameStart

  IntroLoop:
    ShowIntroMap()

  !:
    jsr Joystick.IsFirePressed
    cpx #0
    beq !-

  !:
    jsr Joystick.IsFirePressed
    cpx #0
    bne !-

    RemoveIntroMap()

  GameLoop:
    jsr Utils.WaitRoutine
    lda c64lib.SPRITE_2B_COLLISION
    sta CollisionBkgDummy

    lda c64lib.SPRITE_2S_COLLISION
    sta CollisionSprDummy

    inc CounterForAliensMove

    lda LifeEnd
    beq CheckGameOver

    jsr NewLifeSettings
    jmp GameLoop

  CheckGameOver:
    lda GameOver
    beq IsNotOver

    jsr NewGameSettings
    rts

  IsNotOver:
    Shooter_Handle()
    Aliens_Handle()

    Shooter_FreeAlienHit()

    lda CounterForAliensMove
    cmp #40
    bne Check50th

    InvertValue(MoveTick)

// Detect direction, based on current direction and
// alien position
    DetectDirection(Direction, HasSwitched)
    jmp GameLoop

  Check50th:
    lda CounterForAliensMove
    cmp #50
    beq GotoMoveAliens

    jmp GameLoop

  GotoMoveAliens:
    AliensDescends(HasSwitched)

// Move aliens according to direction
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

    lda #%11001000  // 40 cols, multicolor mode
    sta c64lib.CONTROL_2

    lda #0
    sta c64lib.BG_COL_0
    sta c64lib.BORDER_COL
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
    sta LifeEnd
    sta Direction
    sta HasSwitched
    sta MoveTick

    rts
}

* = * "FirstGameStart"
FirstGameStart: {
    ShowIntroMap()

    CopyGameAreaScreenRam(MapDummyArea, MapData)

    Aliens_Init_Level()
    Shooter_Init_Level()

    lda #0
    sta StartNewGame
    sta GameOver
    sta LifeEnd
    sta Direction
    sta HasSwitched
    sta MoveTick

    jsr SpritesCommon.Init

  Done:
    rts
}

* = * "NewGameSettings"
NewGameSettings: {
    lda DialogShown
    bne AlreadyShown

    CopyDialogScreenRam(DialogGameOver, MapData)
    jsr SetColorToChars
    inc DialogShown
    jmp Done

  AlreadyShown:
    IsReturnPressed()
    bne HideDialog
    jmp Done

  HideDialog:
    jsr Hud.CompareAndUpdateHiScore
    Hud_Init()

    // ShowIntroMap()

    CopyGameAreaScreenRam(MapDummyArea, MapData)

    Aliens_Init_Level()
    Shooter_Init_Level()

    lda #0
    sta StartNewGame
    sta GameOver
    sta LifeEnd
    sta Direction
    sta HasSwitched
    sta MoveTick
    sta DialogShown

    jsr SpritesCommon.Init

  Done:
    rts

  DialogShown: .byte 0
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
#import "_keyboard.asm"
#import "_joystick.asm"
#import "_utils.asm"

#import "chipset/lib/vic2.asm"
