# Project of COURSE 104952
By Group 5
## Members
- Jiao HUANG 999009285
- Ziqi WANG 999005457
- Xian ZHANG 999009111

## Descriptions
Containing 3 scenes: TITLE, NIGHT SKY and ENDING.
### Title
-  2023 GO! and Group5's logo
-  scolling Y background

### Night Sky
- subscene1: night sky with shining stars
- subscene2: night sky with scrolling X background and falling star sprite

### Ending
- subscene1: wishing
- subscene2: happy new year and thanks

## Makefile
Containg two basic operations:
- make clean: remove the .gb and .o files
- make build: build the project, obtianing the .gb file

## Codes Reusing
We use the codes from site: https://eldred.fr/gb-asm-tutorial/part2/objects.html
with some modifications.
   
    ld a, 0
    ld [wFrameCounter], a

    Main:
    ld a, [rLY]
    cp 144
    jp nc, Main
    WaitVBlank2:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank2

    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a
    cp a, 15 ; Every 15 frames (a quarter of a second), run the following code
    jp nz, Main

    ; Reset the frame counter back to 0
    ld a, 0
    ld [wFrameCounter], a

    ; Move the paddle one pixel to the right.
    ld a, [_OAMRAM + 1]
    inc a
    ld [_OAMRAM + 1], a
    jp Main

and codes about initialization, such as copytiles are from labs with modifications:
    
    INCLUDE "hardware.inc"
    SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

    EntryPoint:
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
    WaitVBlank:
	ld a, [rLY]
	cp 144
	jp nz, WaitVBlank
	
    ; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; Copy the tile data for background
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
    CopyTiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTiles

	; Copy the tile data for objects
	ld de, ObjTiles
	ld hl, $8000
	ld bc, ObjTilesEnd - ObjTiles
    CopyObjTiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyObjTiles


	; Copy the tilemap
	ld de, Tilemap
	ld hl, $9800
	ld bc, TilemapEnd - Tilemap
    CopyTilemap:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTilemap

    ; set first object entry in OAM
        ld hl,_OAMRAM
        ld [hl], 30  ; Y position
        inc hl
        ld [hl], 30  ; X position
        inc hl
        ld [hl], 0   ; tile index
        inc hl
        ld [hl], 0   ; flags: all set to zero 
        inc hl
    ; clear rest of OAM
        ld b, 39*4
        ld a, 0
    OAM_clear_loop:
        ld [hl], a
        inc hl
        dec b
        jp nz,OAM_clear_loop

    ; prepare OBJ1 palette 
        ld a,%11100100
        ld [rOBP1],a

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a












