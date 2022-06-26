
#importonce

FreeAlienExploding: .byte 0

// Handle all screen-refresh-depend actions.
.macro Shooter_Handle() {
    jsr Shooter.Move

    jsr Shooter.StillAlive

    jsr Shooter.HandleShoot

    jsr Shooter.Explosions

    jsr Shooter.HandleFreeAlien

    jsr Shooter.FreeAlienExplosions

  !:
}

// Prepare shooter for new level.
.macro Shooter_Init_Level() {
    lda #0
    sta Shooter.HitAndExploding.IsExploding
    sta Shooter.IsShooting
    sta Shooter.HandleFreeAlien.AlienShowing

    jsr Shooter.Init
}

// Detect if shooter-bullet hit free alien.
.macro Shooter_FreeAlienHit() {
    lda CollisionSprDummy
    cmp #%00001010
    bne !+

    jsr Shooter.ShowFreeAlienExplosion

  !:
}

.filenamespace Shooter

* = * "Shooter Init"
/* Init shooter, used in conjunction with Shooter_Init_Level. */
Init: {
    lda #125
    sta c64lib.SPRITE_0_X
    lda #228
    sta c64lib.SPRITE_0_Y

    rts
}

* = * "Shooter Move"
/* Move shooter based on joystick status, detect if a new shoot should
start. */
Move: {
    jsr Joystick.GetJoystickMove

    lda Joystick.Direction
    beq CheckFire
    cmp #$ff
    bcs Left

  Right:
    lda c64lib.SPRITE_0_X
    cmp #245
    beq CheckFire
    inc c64lib.SPRITE_0_X 
    jmp CheckFire

  Left:
    lda c64lib.SPRITE_0_X
    cmp #28
    beq CheckFire
    dec c64lib.SPRITE_0_X 

  CheckFire:
    lda Joystick.FirePressed
    beq Done

    jsr Shoot

  Done:
    rts
}

* = * "Shooter StillAlive"
/* Check if shooter is still alive by looking at collision with alien. */
StillAlive: {
    lda #%00000001
    bit CollisionBkgDummy
    beq Done

// Shooter exploded
    jsr CheckLifeLeftAndGameOver
    jsr StartHitAndExploding

  Done:
    rts
}

* = * "Shooter HandleShoot"
/* Handle a shoot. */
HandleShoot: {
    lda IsShooting
    bne ShootingInProgress
    jmp Done

  ShootingInProgress:
    lda #%00000010
    bit CollisionBkgDummy     
    bne CollisionHappened
    jmp MoveBullet

// Calculate screen ram row
  CollisionHappened:
    lda c64lib.SPRITE_1_Y
    sec
    sbc #50
    lsr
    lsr
    lsr
    sta CalculatedY

    tay
    lda ScreenMemTableL, y
    sta ScreenPositionCollided
    lda ScreenMemTableH, y
    sta ScreenPositionCollided + 1

// Calculate X
    lda c64lib.SPRITE_1_X
    sec
    sbc #24
    lsr
    lsr
    lsr
    addaccumulatortovar16(ScreenPositionCollided)

// Be sure that collided char is != 0
    lda ScreenPositionCollided
    sta CheckChar + 1
    lda ScreenPositionCollided + 1
    sta CheckChar + 2

  CheckChar:
    lda ScreenPositionCollided
    beq MoveBullet

    jsr AddPointsForAliens

  !:
    lda ScreenPositionCollided
    sta UpdateScreen + 1
    sta ScreenPositionCollidedPrev
    sta ScreenPositionCollidedSucc
    lda ScreenPositionCollided + 1
    sta UpdateScreen + 2
    sta ScreenPositionCollidedPrev + 1
    sta ScreenPositionCollidedSucc + 1

    c64lib_sub16($0001, ScreenPositionCollidedPrev)
    c64lib_add16($0001, ScreenPositionCollidedSucc)

// Empty char on collided position, check where is the other part of alien
    lda #0
  UpdateScreen:
    sta ScreenPositionCollided

// Self mod code
    lda ScreenPositionCollidedPrev
    sta CheckPrevChar + 1
    lda ScreenPositionCollidedPrev + 1
    sta CheckPrevChar + 2

  CheckPrevChar:
// Load previous collided char
    lda ScreenPositionCollidedPrev
// Don't do nothing if it's null char and go to check succ character (that will be the
// other part of the alien)    
    beq CheckSucc

// Prev char is the other part of the alien, prepare self mod code
    lda ScreenPositionCollidedPrev
    sta UpdateScreenOtherPiece + 3
    lda ScreenPositionCollidedPrev + 1
    sta UpdateScreenOtherPiece + 4

    jmp UpdateScreenOtherPiece

  CheckSucc:  
// Succ char is the other part of the alien, prepare self mod code
    lda ScreenPositionCollidedSucc
    sta UpdateScreenOtherPiece + 3
    lda ScreenPositionCollidedSucc + 1
    sta UpdateScreenOtherPiece + 4

// Empty the second part of alien
  UpdateScreenOtherPiece:
    lda #0
    sta ScreenPositionCollided

// Start explosion animation
    jsr ShowExplosion

// Collision with aliens happened, remove bullet
    jmp HideBullet

  MoveBullet:
// No collision detect, move bullet to up
    lda c64lib.SPRITE_1_Y
    sec
    sbc #4
    sta c64lib.SPRITE_1_Y
    cmp #20
    bcs Done

  HideBullet:
    jsr ShootFinished

  Done:
    rts

  CalculatedY: .byte 0

  ScreenPositionCollided: .word $0000
  ScreenPositionCollidedPrev: .word $0000
  ScreenPositionCollidedSucc: .word $0000
  Dummy: .word 0
}

* = * "Shooter Shoot"
/* Creates a new shoot. */
Shoot: {
    lda IsShooting
    bne Done

// New shoot to draw
    inc IsShooting

    lda c64lib.SPRITE_0_X
    clc
    adc #10
    sta c64lib.SPRITE_1_X

    lda c64lib.SPRITE_0_Y
    clc
    adc #12
    sta c64lib.SPRITE_1_Y

    lda c64lib.SPRITE_ENABLE
    ora #%00000010
    sta c64lib.SPRITE_ENABLE

    PlaySound(15, 0, 0)
  Done:
    rts
}

* = * "Shooter ShootFinished"
/* Handle a finished shoot. */
ShootFinished: {
    lda IsShooting
    beq Done

    lda c64lib.SPRITE_ENABLE
    and #%11111101
    sta c64lib.SPRITE_ENABLE

    dec IsShooting

  Done:
    rts
}

* = * "Shooter ShowExplosion"
/* Show explosion and play sound. */
ShowExplosion: {
    lda c64lib.SPRITE_1_X
    sec
    sbc #12
    sta c64lib.SPRITE_2_X

    lda c64lib.SPRITE_1_Y
    sec
    sbc #12
    sta c64lib.SPRITE_2_Y
    
    lda #SPRITES.EXPL_1
    sta SPRITES.SPRITES_2

    lda c64lib.SPRITE_ENABLE
    ora #%00000100
    sta c64lib.SPRITE_ENABLE

    PlaySound(10, 2, 2)

    inc ExplosionCounter
    bne Done

  Done:
    rts
}

* = * "Shooter Explosions"
/* Handle explosion evolution. */
Explosions: {
    lda c64lib.SPRITE_ENABLE
    and #%00000100
    beq Done

    lda SPRITES.SPRITES_2
    cmp #SPRITES.EXPL_5
    beq HideSprite

    bcc AdvanceFrame

    jmp Done
    
  AdvanceFrame:
    inc DummyWait
    lda DummyWait
    cmp #10
    bne Done
    inc SPRITES.SPRITES_2

    lda #0
    sta DummyWait

    jmp Done

  HideSprite:
    lda c64lib.SPRITE_ENABLE
    and #%11111011
    sta c64lib.SPRITE_ENABLE

  Done:
    rts

  DummyWait: .byte 0
}

* = * "Shooter HandleFreeAlien"
/* Handle free alien movement. */
HandleFreeAlien: {
    lda AlienShowing
    beq AlienNotAlive

    lda FreeAlienExploding
    bne Done

// Alien already on screen, handle it
    inc c64lib.SPRITE_3_X
    lda c64lib.SPRITE_3_X
    cmp #254
    bcs HideSprite

// Free alien already active, move it
  CheckSwitch:
    inc DummyWaitForSwitch
    lda DummyWaitForSwitch
    cmp #10
    bne Done

    lda #0
    sta DummyWaitForSwitch

    lda SPRITES.SPRITES_3
  SelfModFreeAlien1:
    cmp #SPRITES.FREEALIEN_1A
    bne SwitchBack
    inc SPRITES.SPRITES_3
    jmp Done

  SwitchBack:
    dec SPRITES.SPRITES_3
    jmp Done
    
  AlienNotAlive:
    lda ExplosionCounter
    cmp #ExplosionBeforeAlienAppears
    bcc Done

  StartNewFreeAlien:
    lda #0
    sta c64lib.SPRITE_3_X
    lda #44
    sta c64lib.SPRITE_3_Y

    lda c64lib.SPRITE_ENABLE
    ora #%00001000
    sta c64lib.SPRITE_ENABLE

  SelfModFreeAlien2:
    lda #SPRITES.FREEALIEN_1A
    sta SPRITES.SPRITES_3

    inc AlienShowing

    jmp Done
  
  HideSprite:
    lda #0
    sta ExplosionCounter

    lda c64lib.SPRITE_ENABLE
    and #%11110111
    sta c64lib.SPRITE_ENABLE

    dec AlienShowing

  Done:
    rts

  AlienShowing: .byte 0
  AlienType: .byte 0
  DummyWaitForSwitch: .byte 0
}

* = * "Shooter ShowFreeAlienExplosion"
/* Show a free alien explosion. */
ShowFreeAlienExplosion: {
    inc FreeAlienExploding

    lda #SPRITES.EXPL_1
    sta SPRITES.SPRITES_3
    lda #YELLOW
    sta c64lib.SPRITE_3_COLOR

    PlaySound(10, 2, 2)

    rts
}

* = * "Shooter FreeAlienExplosions"
/* Handle a free aliex explosion. */
FreeAlienExplosions: {
    lda FreeAlienExploding
    beq Done

    lda SPRITES.SPRITES_3
    cmp #SPRITES.EXPL_5
    beq HideSprite

    bcc AdvanceFrame

    jmp Done
    
  AdvanceFrame:
    inc c64lib.BORDER_COL

    inc DummyWait
    lda DummyWait
    cmp #10
    bne Done
    inc SPRITES.SPRITES_3

    lda #0
    sta DummyWait

    jmp Done

  HideSprite:
    lda #0
    sta c64lib.BORDER_COL
    sta FreeAlienExploding

    lda c64lib.SPRITE_ENABLE
    and #%11110111
    sta c64lib.SPRITE_ENABLE

    AddPoints(0, 3, 0)

  Done:
    rts

  DummyWait: .byte 0
}

* = * "Shooter AddPointsForAliens"
/* Add points when free alien explodes. */
AddPointsForAliens: {
    pha
    cmp #MAP.ALIEN_1
    bcc DoneFar
    cmp #MAP.ALIEN_1 + 4
    bcs !+
    AddPoints(0, 2, 5)
    jmp ExplodedAlien

  DoneFar:
    jmp Done
    
  !:
    cmp #MAP.ALIEN_2
    bcc Done
    cmp #MAP.ALIEN_2 + 4
    bcs !+
    AddPoints(0, 2, 0)
    jmp ExplodedAlien

  !:
    cmp #MAP.ALIEN_3
    bcc Done
    cmp #MAP.ALIEN_3 + 4
    bcs !+
    AddPoints(0, 1, 5)
    jmp ExplodedAlien

  !:
    cmp #MAP.ALIEN_4
    bcc Done
    cmp #MAP.ALIEN_4 + 4
    bcs !+
    AddPoints(0, 1, 0)
    jmp ExplodedAlien

  !:
    cmp #MAP.ALIEN_5
    bcc Done
    cmp #MAP.ALIEN_5 + 4
    bcs Done
    AddPoints(0, 0, 5)

  ExplodedAlien:
    dec Aliens.CountAlive
    bne Done
    inc LevelCompleted

  Done:
    pla

    rts
}

* = * "Shooter StartHitAndExploding"
/* Shooter is exploding. */
StartHitAndExploding: {
    lda #1
    sta HitAndExploding.IsExploding

    jmp HitAndExploding // jsr + rts
}

* = * "Shooter HitAndExploding"
/* Handle shooter frame while exploding. */
HitAndExploding: {
    lda IsExploding
    beq Done

    ldx #5
  Loop:
    lda #SPRITES.SHOOTER
    sta SPRITES.SPRITES_0
    jsr Utils.WaitRoutine
    nop
    inc SPRITES.SPRITES_0
    jsr Utils.WaitRoutine
    nop
    inc SPRITES.SPRITES_0
    jsr Utils.WaitRoutine
    nop  
    inc SPRITES.SPRITES_0
    jsr Utils.WaitRoutine
    nop  
    inc SPRITES.SPRITES_0
    jsr Utils.WaitRoutine

    dex
    bne Loop

    dec IsExploding
    inc StartNewGame

    lda #SPRITES.SHOOTER
    sta SPRITES.SPRITES_0

  Done:
    rts

    IsExploding: .byte 0
}

// Hold if shoot is in progress
IsShooting: .byte 0

// Explosion counter before free alien appears
ExplosionCounter: .byte 0
.label ExplosionBeforeAlienAppears = 6

#import "./_aliens.asm"
#import "./_joystick.asm"
#import "./_label.asm"
#import "./_utils.asm"
#import "./_hud.asm"

#import "./chipset/lib/vic2.asm"
#import "./common/lib/math-global.asm"
