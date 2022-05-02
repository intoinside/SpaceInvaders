
#importonce

.macro Shooter_Handle() {
    jsr Shooter.Move

    jsr Shooter.HandleShoot

    jsr Shooter.Explosions

    jsr Shooter.HandleFreeAlien
}

.filenamespace Shooter

* = * "Shooter Init"
Init: {
    lda #125
    sta c64lib.SPRITE_0_X
    lda #228
    sta c64lib.SPRITE_0_Y

    rts
}

* = * "Shooter Move"
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

* = * "Shooter HandleShoot"
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
    cmp #10
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

  ScreenMemTableL: .byte $00, $28, $50, $78, $a0, $c8, $f0, $18, $40, $68
                   .byte $90, $b8, $e0, $08, $30, $58, $80, $a8, $d0, $f8
                   .byte $20, $48, $70, $98, $c0
  ScreenMemTableH: .byte $40, $40, $40, $40, $40, $40, $40, $41, $41, $41
                   .byte $41, $41, $41, $42, $42, $42, $42, $42, $42, $42
                   .byte $43, $43, $43, $43, $43
}

* = * "Shooter Shoot"
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

  Done:
    rts
}

* = * "Shooter ShootFinished"
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

    inc ExplosionCounter

    rts
}

* = * "Shooter Explosions"
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
HandleFreeAlien: {
    lda AlienShowing
    beq AlienNotAlive

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

// Hold if shoot is in progress
IsShooting: .byte 0

// Explosion counter before free alien appears
ExplosionCounter: .byte 0
.label ExplosionBeforeAlienAppears = 6

#import "./_joystick.asm"
#import "./_label.asm"
#import "./_utils.asm"

#import "./chipset/lib/vic2.asm"
#import "./common/lib/math-global.asm"
