
#importonce

// Handle non-move aliens actions (done on every screen refresh)
.macro Aliens_Handle() {
    jsr Aliens.Shoot

    jsr Aliens.HandleShoot

    jsr Aliens.Explosions

  !:
}

.macro Aliens_Init_Level() {
    lda #0
    sta Aliens.IsShooting
    
    jsr Aliens.Init
}

.filenamespace Aliens

// Alien count, determined at start and updated when and alien is destroyed
CountAlive: .byte 0

// An alien is currently shooting
IsShooting: .byte 0

* = * "Aliens Init"
/* Count how many aliens are on screen. This is determined dinamically
to prevent coupling when editing map. */
Init: {
    // Start scan from line 1
    lda #$28
    sta CurrentPosition
    lda #>MapData
    sta CurrentPosition + 1

    lda #0
    sta CountAlive

  SetupNewLine:
    ldx #30

    lda CurrentPosition
    sta T1 + 1
    lda CurrentPosition + 1
    sta T1 + 2

  Loop:
  T1:
    lda CurrentPosition,x

    cmp #MAP.ALIEN_OVER
    bcs CheckRowEnded
    cmp #MAP.ALIEN_1
    bcc CheckRowEnded

    inc CountAlive

  CheckRowEnded:
    dex
    bne Loop

// Check if HiByte CurrentPosition holds last row
    lda CurrentPosition + 1
    cmp #(>MapData) + 3
    bne CalculateNextRow

// Check if LoByte CurrentPosition holds last row
    lda CurrentPosition
    cmp #$c0
    beq Done

  CalculateNextRow:
    c64lib_add16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    lda CountAlive
    lsr
    sta CountAlive
    rts

    CurrentPosition: .word $beef
}

* = * "Aliens Shoot"
/* Check if aliens are not shooting, then shoot. */
Shoot: {
    lda IsShooting
    beq !+

    jmp Done

  !:
    GetRandomNumberInRange(1, 250)
    cmp #238
    bcc StartShootHandle

    jmp Done

  StartShootHandle:
    lda #0
    sta Found

// Source line starts from 23
    lda #(>MapData) + 3
    sta CurrentPosition + 1
    lda #$98
    sta CurrentPosition

    ldy #24

  SetupNewLine:
    ldx #0

    lda CurrentPosition
    sta T1 + 1
    lda CurrentPosition + 1
    sta T1 + 2

  Loop:
  T1:
    lda CurrentPosition,x
    cmp #MAP.ALIEN_OVER
    bcs CheckRowEnded
    cmp #MAP.ALIEN_1
    bcc CheckRowEnded

  AlienFound:
    inc Found
    GetRandomNumberInRange(1, 5)
    cmp #2
    bcs CheckRowEnded

// Shoot!
    inc IsShooting

    txa
    asl
    asl
    asl
    clc
    adc #25
    sta c64lib.SPRITE_4_X

    tya
    asl
    asl
    asl
    clc
    adc #60
    sta c64lib.SPRITE_4_Y

    lda #SPRITES.ALIEN_BULLET
    sta SPRITES.SPRITES_4

    lda c64lib.SPRITE_ENABLE
    ora #%00010000
    sta c64lib.SPRITE_ENABLE

    jmp Done

  CheckRowEnded:
    inx
    cpx #30
    bne Loop

    lda Found
    bne Done

// Check if HiByte CurrentPosition holds first row
    lda CurrentPosition + 1
    cmp #>MapData
    bne CalculateNextRow

// Check if LoByte CurrentPosition holds first row
    lda CurrentPosition
    cmp #$00
    beq Done

  CalculateNextRow:
    dey
    c64lib_sub16($0028, CurrentPosition)
    jmp SetupNewLine

  Done:
    rts

    CurrentPosition: .word $beef
    Found: .byte 0
}

* = * "Aliens HandleShoot"
/* Handle alien shoot, check collision with background and shooter,
moves alien bullet. */
HandleShoot: {
    lda IsShooting
    bne ShootingInProgress
    jmp Done

  ShootingInProgress:
// Check if alien bullet hit something on background
    lda CollisionBkgDummy
    cmp #%00010000
    beq CollisionHappened

// Check if alien bullet hit shooter
    lda CollisionSprDummy
    cmp #%00010001
    bne MoveBullet

// Shooter exploded
    jsr CheckLifeLeftAndGameOver
    jsr Shooter.StartHitAndExploding

    jmp HideBullet

// Calculate screen ram row
  CollisionHappened:
    lda c64lib.SPRITE_4_Y
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
    lda c64lib.SPRITE_4_X
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
    lda ScreenPositionCollided + 1
    sta UpdateScreen + 2

// Empty char on collided position, check where is the other part of alien
    lda #0
  UpdateScreen:
    sta ScreenPositionCollided

// Start explosion animation
    jsr ShowExplosion

// Collision with aliens happened, remove bullet
    jmp HideBullet

  MoveBullet:
// No collision detect, move bullet to down
    lda c64lib.SPRITE_4_Y
    clc
    adc #2
    sta c64lib.SPRITE_4_Y
    cmp #245
    bcc Done

  HideBullet:
    jsr ShootFinished

  Done:
    rts

  CalculatedY: .byte 0

  ScreenPositionCollided: .word $0000
}

* = * "Aliens ShootFinished"
ShootFinished: {
    lda IsShooting
    beq Done

    lda c64lib.SPRITE_ENABLE
    and #%11101111
    sta c64lib.SPRITE_ENABLE

    dec IsShooting

  Done:
    rts
}

* = * "Aliens ShowExplosion"
ShowExplosion: {
    lda c64lib.SPRITE_4_X
    sec
    sbc #12
    sta c64lib.SPRITE_5_X

    lda c64lib.SPRITE_4_Y
    sec
    sbc #12
    sta c64lib.SPRITE_5_Y
    
    lda #SPRITES.EXPL_1
    sta SPRITES.SPRITES_5

    lda c64lib.SPRITE_ENABLE
    ora #%00100000
    sta c64lib.SPRITE_ENABLE

    rts
}

* = * "Aliens Explosions"
Explosions: {
    lda c64lib.SPRITE_ENABLE
    and #%00100000
    beq Done

    lda SPRITES.SPRITES_5
    cmp #SPRITES.EXPL_5
    beq HideSprite

    bcc AdvanceFrame

    jmp Done
    
  AdvanceFrame:
    inc DummyWait
    lda DummyWait
    cmp #10
    bne Done
    inc SPRITES.SPRITES_5

    lda #0
    sta DummyWait

    jmp Done

  HideSprite:
    lda c64lib.SPRITE_ENABLE
    and #%11011111
    sta c64lib.SPRITE_ENABLE

  Done:
    rts

  DummyWait: .byte 0
}

#import "./_shooter.asm"
#import "./_label.asm"
#import "./_utils.asm"

#import "./common/lib/math-global.asm"
