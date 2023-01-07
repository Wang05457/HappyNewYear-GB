INCLUDE "hardware.inc"

;--------------------reusing codes from lab---------------
SECTION "Header", ROM0[$100]

	jp EntryPoint
	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Shut down audio circuitry
	xor a
	ld [rNR52], a

	call WaitVBlank

	; Turn the LCD off
	call LCD_Off

	; Copy the tile data of title
	ld de, Tiles_title
	ld hl, $9000
	ld bc, Tiles_titleEnd - Tiles_title
	call Memcpy
		
	; Copy the tilemap of title
	ld de, Tilemap_title
	ld hl, $9800
	ld bc, Tilemap_titleEnd - Tilemap_title
	call Memcpy

	; Copy the tile data of sprite
	ld de, TileSprite
	ld hl, $8000
	ld bc, TileSpriteEnd - TileSprite
	call Memcpy

	;clear the OAM
	xor a 			
	ld b, 160
	call ClearOam

 	;write the object
	ld hl, _OAMRAM
	ld a, 0 + 16 			;Y offset = 16, ini = 0
	ld [hli], a     	
	ld a, 0 + 8 			;X offset = 8, ini = 0
	ld [hli], a
	xor a 				;set ID and attribute to 0
	ld [hli], a
	ld [hl], a

	;Turn the LCD on
	call LCD_On

	;set the pallette to default one
	call DefaultPalette
;-------------------------------------------------------
;----------------title--------------------------
Title:
	ld hl, 1000 			;counter, to wait for a while	
	call Wait

	ld hl, 110 			;counter for the scrolling loop
	ld c, 2 			;slow down factor

;scroll-y
.loop:
	ld a, [rLY]
	cp 144
	jp nz, .loop

	dec c
	jp nz, .loop
	ld c, 2

	ld a, [rSCY]
	inc a
	ld [rSCY], a

	dec hl
	ld a, h
	or l
	jp nz, .loop
;-----------------Stars Theme-------------------
	;change the tile
	call WaitVBlank

	; Turn the LCD off
	call LCD_Off

	; Copy the tile data
	ld de, Tiles_stars
	ld hl, $9000
	ld bc, Tiles_starsEnd - Tiles_stars
	call Memcpy

	; Copy the tilemap
	ld de, Tilemap_stars
	ld hl, $9800
	ld bc, Tilemap_starsEnd - Tilemap_stars
	call Memcpy

	; Turn the LCD on
	call LCD_On
;----------------SubScene1--------------------------	    		
;-----------reusing codes from internet-------------	
	;initialize the wFrameCounter
	xor a
	ld [wFrameCounter], a

	;counter to control the bling loop
	ld hl, 30 	

bling:
	ld a, [rLY]
	cp 144
	jp nc, bling
	
	call WaitVBlank

	ld a, [wFrameCounter]
	inc a
	ld [wFrameCounter], a
	cp a, 15 

	; Every 15 frames (a quarter of a second), run the following code
	jp nz, bling

	; Reset the frame counter back to 0
	xor a
	ld [wFrameCounter], a
;----------------------------------------------------
	dec hl
	ld a, h
	or l
	jp z, Scene2

	xor a 			;b==0 enter s0
	cp b
	jr z, .s1
	inc a 			;b==1 enter s2
	cp b
	jr z, .s2
   
.s0:
	ld a, %11111111
	ld [rBGP], a
	ld b, 0
	jr bling
.s1:
	ld a, %11111110
	ld [rBGP], a
	ld b, 1
	jr bling
.s2:
	ld a, %11111001
	ld [rBGP], a
	ld b, 2
	jr bling
;-------------------SubScnene2------------------
Scene2:
	ld hl, 515 		;counter for the scrolling loop
	ld c, 5 		;slow down factor

	;Turn the LCD on
	call LCD_On_OBJ

	;initialize display registers
	call DefaultPalette

.loop:
	ld a, [rLY]
	cp 144
	jp nz, .loop

	dec c
	jp nz, .loop
	ld c, 5

	;scroll X direction
	ld a, [rSCX]
	inc a
	ld [rSCX], a

	; Move the sprite from LU to RD
	ld a, [_OAMRAM + 1]
	inc a
	ld [_OAMRAM + 1], a

	ld a, [_OAMRAM + 1]
	inc a
	ld [_OAMRAM ], a

	dec hl
	ld a, h
	or l
	jp nz, .loop
;---------------------Ending------------------
Ending:	
	call WaitVBlank

	; Turn the LCD off
	call LCD_Off

	; Copy the tile data
	ld de, Tiles_last
	ld hl, $9000
	ld bc, Tiles_lastEnd - Tiles_last
	call Memcpy

	; Copy the tilemap
	ld de, Tilemap_last
	ld hl, $9800
	ld bc, Tilemap_lastEnd - Tilemap_last
	call Memcpy

	; Turn the LCD on
	call LCD_On

	call DefaultPalette

	ld hl, 1000 		;counter, to wait for a while	
	call Wait

	;scroll_y 		
	ld hl, 110 		;counter for scrolling
	ld c, 15 		;slow down factor

.wait:
	ld a, [rLY]
	cp 144
	jp nz, .wait

	dec c
	jp nz, .wait
	ld c, 15

	ld a, [rSCY]
	dec a
	ld [rSCY], a

	dec hl
	ld a, h
	or l
	jp nz, .wait

	call WaitVBlank

	; Turn the LCD off
	call LCD_Off
	
	; Copy the tile data of sprite
	ld de, TileSprite2
	ld hl, $8000
	ld bc, TileSprite2End - TileSprite2
	call Memcpy

	;clear the OAM
	xor a 				
	ld b, 160
	call ClearOam

	;write the object1
	ld hl, _OAMRAM
	ld a, 70 + 16 			
	ld [hli], a     	
	ld a, 20 + 8	
	ld [hli], a
	xor a 			
	ld [hli], a
	ld [hli], a
	
	;write the object2
	ld a, 70 + 16 			
	ld [hli], a     	
	ld a, 132 + 8	
	ld [hli], a
	xor a 			
	ld [hli], a
	ld [hli], a

	;Turn the LCD on with OBJ
	call LCD_On_OBJ

	;initialize display registers
	call DefaultPalette
;-----------reusing codes from internet-----------
	;initialize the wFrameCounter
	xor a
	ld [wFrameCounter], a
.shine:
	ld a, [rLY]
	cp 144
	jp nc, .shine
	
	call WaitVBlank

	ld a, [wFrameCounter]
	inc a
	ld [wFrameCounter], a
	cp a, 30 

	; Every 30 frames, run the following code
	jp nz, .shine

	; Reset the frame counter back to 0
	xor a
	ld [wFrameCounter], a
;--------------------------------------------------
	xor a 			
	cp b
	jr z, .s1
   
.s0:
	ld a, %11111001
	ld [rOBP0], a
	ld b, 0
	jr .shine
.s1:
	ld a, %11100100
	ld [rOBP0], a
	ld b, 1
	jr .shine

Done:
	jp Done


SECTION "Functions", ROM0

WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank
	ret

Memcpy:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, Memcpy
	ret

ClearOam:
	ld hl, _OAMRAM			
.clear:
	ld [hli], a
	dec b
	jp nz, .clear
	ret

DefaultPalette:
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ret

LCD_Off:
    xor a
    ld [rLCDC], a
    ret

LCD_On:
	ld a, LCDCF_ON | LCDCF_BGON
	ld [rLCDC], a
	ret

LCD_On_OBJ:
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a
	ret

;keep still
Wait:
	ld a, [rLY]
	cp 144
	jp nz, Wait

	dec hl
	ld a, h
	or l
	jp nz, Wait
	ret

SECTION "Tile data", ROM0
Tilemap_title:
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
	DB $04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$06,$07,$00,$00,$08
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$12,$13,$14,$15,$16,$17,$18,$19,$00,$1A,$00,$00,$00
	DB $1B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$00,$25,$26,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$27,$28,$29,$2A,$2B,$28,$2C,$2D,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$2E,$2F,$30,$00,$00,$31,$32,$00,$33,$34,$35,$36,$37,$38
	DB $39,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$3A,$3B,$3C,$3D,$3E,$00,$3F,$40,$41,$42,$43,$44
	DB $45,$46,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$41,$50,$51,$52
	DB $53,$54,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$55,$56,$57,$58,$59,$5A,$00,$5B,$5C,$5D,$5E,$5F,$60
	DB $61,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$62,$63,$63,$64,$65,$00,$66,$67,$68,$69,$6A,$6B
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$6C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $6D,$6E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$6F,$00,$00,$00,$00,$00,$00,$00
	DB $70,$71,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Tilemap_titleEnd:

Tiles_title:
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FB,$FF
	DB $FF,$FD,$FA,$FD,$F2,$FD,$E7,$F8,$DF,$E0,$E7,$F8,$F2,$FD,$FA,$FD
	DB $FF,$FF,$FF,$FF,$7F,$FF,$3F,$FF,$DF,$3F,$3F,$FF,$7F,$FF,$FF,$FF
	DB $F5,$FB,$EE,$F1,$F5,$FB,$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FD,$FE,$FE,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$BF,$7F,$DF,$3F,$BF,$7F,$7F,$FF
	DB $FF,$FD,$FD,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FC,$FF,$FC,$FF,$FC,$FE,$FF
	DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$00,$FF,$00,$80,$7F,$7F,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7E,$FF,$3C,$FF,$18,$BF,$48,$FF,$48
	DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$00,$C0,$3F,$FF,$3F,$FF,$1F,$FF,$1F
	DB $FF,$FF,$FF,$FF,$FF,$7E,$FF,$3C,$FF,$18,$7F,$88,$FE,$89,$FD,$8F
	DB $FF,$FF,$FF,$FF,$FF,$01,$FF,$00,$FF,$00,$01,$FE,$FF,$FE,$FF,$FE
	DB $FF,$FF,$FF,$FF,$FF,$FE,$FF,$FC,$FF,$78,$FF,$31,$7F,$93,$FF,$97
	DB $FF,$FF,$FF,$FF,$FF,$01,$FF,$00,$07,$F8,$FD,$FA,$FF,$FB,$FF,$FB
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$3F,$FF,$1F,$FF,$1F
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FC,$FF,$F8,$FE,$F1
	DB $FF,$48,$FF,$48,$FF,$08,$EF,$18,$DF,$38,$BF,$78,$FF,$78,$FF,$78
	DB $7F,$8F,$FF,$8F,$FF,$C7,$FF,$C7,$FF,$E3,$FF,$E3,$FF,$E3,$FF,$F1
	DB $FF,$8F,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$8F
	DB $FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FC,$FF,$F8,$FF,$F0,$FD,$E2
	DB $FF,$9F,$FF,$9F,$FF,$1F,$DF,$3F,$BF,$7F,$7F,$FE,$FF,$FF,$FF,$FF
	DB $FF,$FB,$FF,$FB,$FF,$FA,$FF,$F8,$FF,$F8,$FE,$01,$07,$F8,$FF,$F8
	DB $FF,$1F,$FF,$1F,$DF,$3F,$BF,$7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$7F
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF,$F7,$EB,$F7
	DB $FF,$FF,$FF,$FF,$FF,$FF,$EF,$FF,$D7,$EF,$BB,$C7,$D7,$EF,$EF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FC,$FF,$FC,$FF,$FC
	DB $FD,$E3,$FB,$C7,$F7,$8F,$EF,$1F,$DF,$3F,$BF,$7F,$FF,$00,$FF,$00
	DB $FF,$78,$FF,$78,$FF,$78,$FF,$78,$FF,$78,$FF,$78,$FF,$0C,$FF,$0E
	DB $FF,$F1,$FF,$F8,$FF,$F8,$FF,$FC,$FF,$FC,$FF,$FE,$FF,$7E,$FF,$00
	DB $FF,$8F,$FF,$8F,$FF,$8F,$FF,$0E,$FF,$0C,$FF,$08,$EF,$18,$DF,$38
	DB $FB,$C6,$F7,$8E,$EF,$1E,$DF,$3E,$BF,$7E,$7F,$FE,$FF,$00,$FF,$00
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7,$FF,$F3,$FF,$11,$FF,$18
	DB $FD,$FA,$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FB,$FF,$FA,$FF,$F8,$FF,$00
	DB $FF,$3F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$DF,$3F,$BF,$7F,$7F,$FF
	DB $C9,$F7,$9C,$E3,$7F,$80,$9C,$E3,$C9,$F7,$EB,$F7,$FF,$F7,$F7,$FF
	DB $FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FC,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$0F,$0F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$00,$E0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $BF,$78,$7C,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$1C,$1F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FE,$01,$01,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FE,$FF,$FD,$FE,$FB,$FC,$FD,$FE,$FE,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$BF,$7F,$7F,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$DF,$FF,$CF
	DB $FF,$FD,$FF,$F9,$FF,$F2,$FF,$F6,$FF,$E6,$FF,$CF,$FF,$DF,$FF,$9F
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF,$7F
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$E0,$FF,$C0,$F8,$87,$FB,$87
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$0F,$FF,$07,$3F,$C3,$DF,$E3
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$E0,$FF,$C0,$F0,$8F,$E7,$1F
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$0F,$FF,$07,$3F,$C3,$EF,$D1
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$86,$FF,$96,$FF,$96,$FF,$96
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$18,$FF,$59,$FF,$59,$FF,$59
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F
	DB $FF,$C7,$FF,$D7,$FF,$D3,$FF,$D9,$FF,$DD,$FF,$DC,$FF,$DF,$FF,$DF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$FF,$8F,$FF,$3F,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$00,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$BF,$FF,$3F,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$7F,$FF,$7F,$FF,$BF,$FF,$BF,$FF,$BF,$FF,$9F,$FF,$EF,$FF,$F7
	DB $EF,$17,$FF,$17,$FF,$17,$FF,$17,$FF,$17,$FF,$17,$FF,$17,$FF,$17
	DB $EF,$F1,$EF,$F1,$F1,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F
	DB $FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1
	DB $FF,$96,$FF,$96,$FF,$96,$FF,$96,$FF,$96,$FF,$96,$FF,$96,$FF,$96
	DB $FF,$59,$FF,$59,$FF,$59,$FF,$59,$FF,$59,$FF,$59,$FF,$59,$FF,$59
	DB $FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FE,$7F,$FD,$7E
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FD,$FF,$C0
	DB $FF,$DF,$FF,$DF,$FF,$9F,$FF,$BF,$FF,$3F,$FF,$FF,$FF,$FF,$FF,$3F
	DB $FF,$FF,$FF,$EF,$FF,$EF,$FF,$EF,$FF,$EF,$FF,$EF,$FF,$EF,$FF,$FF
	DB $FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$F9
	DB $FF,$F7,$FF,$F7,$FF,$FB,$FF,$FB,$FF,$FB,$FF,$C0,$FF,$3B,$FF,$FB
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$FF,$FF,$FF
	DB $FF,$17,$FF,$16,$FF,$16,$FF,$16,$FF,$17,$FF,$17,$FF,$17,$FF,$87
	DB $FF,$FF,$FF,$07,$FF,$03,$FF,$01,$FF,$F1,$FF,$F1,$FF,$F1,$FD,$E3
	DB $FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$FF,$D1,$DF,$F1
	DB $FF,$96,$FF,$96,$FF,$96,$FF,$96,$FF,$86,$C7,$FF,$FF,$FF,$FF,$86
	DB $FF,$59,$FF,$59,$FF,$59,$FF,$59,$FF,$18,$1C,$FF,$FF,$FF,$FF,$18
	DB $FB,$7C,$FD,$7E,$FE,$7F,$FF,$7F,$FF,$7F,$7F,$FF,$FF,$FF,$FF,$7F
	DB $BF,$7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FD,$FF,$FD,$FF,$FD,$FF,$FD,$FF,$FD,$FF,$F8,$FF,$FE,$FF,$FF
	DB $FF,$C3,$FF,$FC,$FF,$FF,$FF,$FF,$FF,$E0,$FF,$1F,$FF,$7F,$FF,$3F
	DB $FF,$FF,$FF,$FF,$FF,$3F,$FF,$FF,$FF,$3D,$FF,$FC,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$DF,$FF,$CD,$FF,$B1,$FF,$7F,$FF,$FF,$FF,$FF
	DB $FF,$E7,$FF,$FE,$FF,$F1,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FB,$FF,$00,$FF,$FB,$FF,$F7,$FF,$F7,$FF,$E7,$FF,$EF,$FF,$9F
	DB $FF,$87,$FF,$C0,$FF,$E0,$F8,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$83,$FB,$07,$F7,$0F,$0F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$8F,$FF,$C0,$FF,$E0,$F8,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FD,$C3,$FB,$07,$F7,$0F,$0F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$96,$FF,$96,$FF,$86,$C7,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$59,$FF,$59,$FF,$18,$1C,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$7F,$FF,$7F,$FF,$7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$9F,$FF,$C7,$FF,$F0,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$F8,$FF,$E3,$FF,$0F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$BF,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$C0,$FF,$DE,$FF,$C0,$FF,$DE,$FF,$C0,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FE,$FF,$FE,$FF,$B6,$FF,$B6,$FF,$86,$FF,$F7,$FF,$87
	DB $FF,$FF,$FF,$07,$FF,$FF,$FF,$F4,$FF,$F5,$FF,$05,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$21,$FF,$ED,$FF,$E1,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$68,$FF,$6B,$FF,$08,$FF,$FB,$FF,$FB
	DB $FF,$FF,$FF,$C0,$FF,$DF,$FF,$40,$FF,$7E,$FF,$40,$FF,$FF,$FF,$FF
	DB $DF,$FF,$AF,$DF,$77,$8F,$AF,$DF,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FC,$FF,$FB,$FC
	DB $FF,$FF,$FF,$FF,$BF,$FF,$FF,$BF,$5F,$BF,$4F,$BF,$E7,$1F,$FB,$07
	DB $FF,$FF,$EF,$FF,$D7,$EF,$BB,$C7,$D7,$EF,$EF,$FF,$FF,$FF,$FF,$FF
	DB $FC,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $E7,$1F,$4F,$BF,$5F,$BF,$FF,$BF,$BF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Tiles_titleEnd:

Tilemap_stars:
	DB $00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02
	DB $00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00
	DB $00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$03,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$03,$00
	DB $00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Tilemap_starsEnd:

Tiles_stars:
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$BE,$FF,$FF,$FB,$FF,$FB,$FB,$E0,$FF,$FB,$FF,$FB,$FF,$FF
	DB $FF,$FF,$77,$FF,$FF,$F7,$F7,$E3,$A2,$C1,$F7,$E3,$FF,$F7,$F7,$FF
	DB $FF,$FF,$FF,$FF,$EF,$FF,$D7,$EF,$EF,$FF,$FF,$FF,$FD,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$EF,$FF,$D7,$EF,$EF,$FF,$FF,$FF,$FD,$FF
Tiles_starsEnd:

Tiles_last:
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F3
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$CF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$03
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$3F
	DB $FF,$F3,$FF,$F3,$FF,$F3,$FF,$F0,$FF,$F0,$FF,$F3,$FF,$F3,$FF,$F3
	DB $FF,$CF,$FF,$CF,$FF,$CF,$FF,$0F,$FF,$0F,$FF,$CC,$FF,$CC,$FF,$CC
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$0C,$FF,$0C,$FF,$CC,$FF,$CC,$FF,$0C
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$CF,$FF,$CF,$FF,$CF,$FF,$CF,$FF,$0F
	DB $FF,$03,$FF,$33,$FF,$33,$FF,$33,$FF,$33,$FF,$33,$FF,$33,$FF,$30
	DB $FF,$3F,$FF,$3F,$FF,$3F,$FF,$30,$FF,$30,$FF,$33,$FF,$33,$FF,$30
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$33,$FF,$33,$FF,$33,$FF,$33,$FF,$F0
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$33,$FF,$33,$FF,$33,$FF,$33,$FF,$03
	DB $FF,$CF,$FF,$CF,$FF,$CF,$FF,$C0,$FF,$C0,$FF,$FF,$FF,$FF,$FF,$C0
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$3C,$FF,$3C,$FF,$33,$FF,$33,$FF,$F0
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$30,$FF,$30,$FF,$33,$FF,$33,$FF,$33
	DB $FF,$F3,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$CC,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$0C,$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$0C,$FF,$FF,$FF,$FF,$FF,$FC,$FF,$FC,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$0F,$FF,$CF,$FF,$CF,$FF,$0F,$FF,$0F,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$30,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$F0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$03,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$C0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$33,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0,$FF
	DB $FF,$DF,$FF,$FF,$E7,$FF,$F3,$FF,$FB,$FF,$FB,$1E,$FB,$0C,$7F,$E4
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$03,$FE
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FE,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$00,$FF,$E7
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$67,$FF,$67,$FF,$E7
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$E7,$FF,$E7,$FF,$E7
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FC,$FF,$F9,$FF,$FB,$FF,$FB,$CF,$FB,$C6
	DB $FF,$FF,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$1F,$FF,$1F
	DB $CF,$7F,$FF,$FE,$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FF,$FE,$FF,$FE,$FF
	DB $BF,$F1,$FB,$04,$FF,$10,$FF,$75,$FF,$E5,$3B,$CC,$7B,$CE,$FB,$CE
	DB $7B,$FF,$FF,$3F,$FF,$1F,$FF,$9F,$BF,$FF,$8F,$FF,$E7,$7F,$F7,$7F
	DB $FF,$E7,$FF,$E7,$FF,$E7,$FF,$E7,$FF,$E7,$FF,$E7,$FF,$E7,$FF,$FF
	DB $FF,$E7,$FF,$E0,$FF,$E0,$FF,$E6,$FF,$E6,$FF,$E6,$FF,$E6,$FF,$FF
	DB $FF,$FF,$FF,$78,$FF,$78,$FF,$66,$FF,$66,$FF,$60,$FF,$60,$FF,$FF
	DB $FF,$FF,$FF,$60,$FF,$60,$FF,$66,$FF,$66,$FF,$66,$FF,$66,$FF,$FF
	DB $FF,$E7,$FF,$66,$FF,$66,$FF,$61,$FF,$61,$FF,$66,$FF,$66,$FF,$FF
	DB $FF,$FF,$FF,$78,$FF,$78,$FF,$F9,$FF,$F9,$FF,$61,$FF,$61,$FF,$FF
	DB $FF,$FF,$FF,$7F,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $F8,$EF,$FB,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FC,$FF
	DB $1F,$E4,$DF,$F1,$FB,$84,$FF,$01,$FF,$35,$BF,$F4,$3B,$E6,$FB,$CE
	DB $C1,$FF,$BE,$FF,$FF,$0F,$FF,$07,$FF,$C7,$FF,$E7,$9F,$7F,$CF,$7F
	DB $FF,$FF,$7F,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FC,$FF,$FD,$F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FB,$FF,$FB,$FF,$F3,$FF,$FF,$FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FD,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FB,$CE,$FB,$FF,$FB,$FF,$F9,$FF,$FF,$FF,$FF,$FD,$FF,$FF,$FF,$FF
	DB $EF,$7F,$E7,$FF,$F7,$FD,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$80,$FF,$80,$FF,$9F,$FF,$9F,$FF,$80,$FF,$80
	DB $FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$60,$FF,$60
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$61,$FF,$61
	DB $FF,$FF,$FF,$FF,$FF,$E6,$FF,$E6,$FF,$E6,$FF,$E6,$FF,$E6,$FF,$E6
	DB $FF,$FF,$FF,$FF,$FF,$67,$FF,$67,$FF,$67,$FF,$67,$FF,$67,$FF,$67
	DB $FF,$FF,$FF,$FF,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$86,$FF,$86
	DB $FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$18,$FF,$18
	DB $FF,$FF,$FF,$FF,$FF,$E7,$FF,$E7,$FF,$E7,$FF,$E7,$FF,$60,$FF,$60
	DB $FF,$FF,$FF,$FF,$FF,$E7,$FF,$E7,$FF,$FF,$FF,$FF,$FF,$66,$FF,$66
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$06,$FF,$06
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$07,$FF,$07
	DB $FF,$9F,$FF,$9F,$FF,$9F,$FF,$9F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$E6,$FF,$E6,$FF,$E0,$FF,$E0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$67,$FF,$67,$FF,$67,$FF,$67,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$66,$FF,$66,$FF,$06,$FF,$06,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$79,$FF,$79,$FF,$18,$FF,$18,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$E6,$FF,$E6,$FF,$66,$FF,$66,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$66,$FF,$66,$FF,$66,$FF,$66,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$66,$FF,$66,$FF,$66,$FF,$66,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FE
	DB $FF,$67,$FF,$67,$FF,$07,$FF,$07,$FF,$E7,$FF,$E7,$FF,$07,$FF,$07
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$81
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F0
	DB $FF,$FF,$FF,$E0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$03,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$BF,$FF,$BD,$FF,$BD,$FF,$81,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$08,$FF,$7B,$FF,$78,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$5A,$FF,$5A,$FF,$42,$FF,$FE,$FF,$FE,$FF,$FF,$FF,$FF
	DB $FF,$F7,$FF,$10,$FF,$DF,$FF,$10,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$3F,$FF,$BF,$FF,$3F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$79,$FF,$79,$FF,$79,$FF,$79,$FF,$79
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$E6,$FF,$E6,$FF,$E7,$FF,$E7,$FF,$E6
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF,$FF,$FF,$FF,$FF,$7E
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$06
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$01
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$9F,$FF,$9F,$FF,$FF,$FF,$FF,$FF,$98
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$06
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$01
	DB $FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$79,$FF,$79,$FF,$79,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$E6,$FF,$E6,$FF,$E6,$FF,$06,$FF,$06,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$7E,$FF,$7E,$FF,$7E,$FF,$60,$FF,$60,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$06,$FF,$7E,$FF,$7E,$FF,$7E,$FF,$7E,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$01,$FF,$79,$FF,$79,$FF,$79,$FF,$79,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$98,$FF,$99,$FF,$99,$FF,$99,$FF,$99,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$06,$FF,$E6,$FF,$E6,$FF,$E6,$FF,$E6,$FF,$FF,$FF,$FF,$FF,$FE
	DB $FF,$01,$FF,$79,$FF,$79,$FF,$01,$FF,$01,$FF,$F9,$FF,$F9,$FF,$01
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$CE,$FF,$CE,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$73,$FF,$73,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DB $FF,$01,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Tiles_lastEnd:

Tilemap_last:
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$01,$02,$00,$00,$00,$00,$03,$04,$00,$00,$02,$04,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$05,$06,$07,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0A,$0E
	DB $0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$10,$11,$12,$12,$13,$14,$15,$15,$16,$17,$18,$15,$16
	DB $19,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$1A,$1B,$1C,$1D,$1E,$1F,$00,$00,$20,$00,$00,$00,$21
	DB $22,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$23,$24,$25,$00,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E
	DB $2F,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$31,$32,$33,$00,$00,$00,$00,$00,$00,$00,$00,$34,$35
	DB $36,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,$40,$41
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$42,$43,$44,$43,$45,$45,$46,$47,$48,$49,$4A
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4B,$00,$00
	DB $4C,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4D,$4E,$4F,$50,$51,$52
	DB $53,$54,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$5E,$5F,$60,$61,$62,$63,$64,$65,$66,$67,$68
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$69,$6A,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Tilemap_lastEnd:


SECTION "Sprites", ROM0

TileSprite:
	DB $89,$00,$42,$08,$2c,$34,$b0,$5c
	DB $0d,$3a,$34,$2c,$42,$10,$91,$00
TileSpriteEnd:

TileSprite2:
	DB $00,$00,$24,$00,$66,$00,$18,$00
	DB $18,$00,$66,$00,$24,$00,$00,$00
TileSprite2End:


SECTION "Counter", WRAM0

wFrameCounter: db
wCurKeys: db
wNewKeys: db
