* hires
org = $ee00
 tr on
 lst off
*-------------------------------
*
*  PRINCE OF PERSIA
*  Copyright 1989 Jordan Mechner
*
*-------------------------------
 org org

 jmp boot3
 jmp cls
 jmp lay
 jmp fastlay
 jmp layrsave

 jmp lrcls
 jmp fastmask
 jmp fastblack
 jmp peel
 jmp getwidth

 jmp copyscrnMM
 jmp copyscrnAA
 jmp SETFASTAUX
 jmp SETFASTMAIN
 jmp copyscrnMA

 jmp copyscrnAM
 jmp INVERTY

*-------------------------------
 put HRPARAMS

*-------------------------------
boot3 = $f880 ;stage 3 boot

peelbuf1 = $d000
peelbuf2 = $d600

* Local vars

locals = $f0
locals2 = $18

 dum locals

BASE ds 2
IMSAVE ds 2
XSAVE ds 1
YSAVE ds 1
WIDTH ds 1
HEIGHT ds 1
TOPEDGE ds 1
OFFLEFT ds 1
OFFRIGHT ds 1
YREG ds 1
CARRY ds 1

 dum locals2
index
ztemp
AMASK ds 1
BMASK ds 1
VISWIDTH ds 1
RMOST ds 1
carryim ds 1
imbyte ds 1

 dend

* OPACITY codes

and = 0
ora = 1
sta = 2
eor = 3 ;OR/shift/XOR
mask = 4 ;mask/OR

*-------------------------------
*
* Assume hires routines are called from auxmem
* (Exit with RAMRD, RAMWRT, ALTZP on)
*
*-------------------------------

cls jsr mainmem
 jsr CLS
 jmp auxmem

lay jsr mainmem
 jsr LAY
 jmp auxmem

fastlay
 jsr FASTLAY
 jmp auxmem

layrsave jsr mainmem
 jsr LAYRSAVE
 jmp auxmem

lrcls jsr mainmem
 jsr LRCLS
 jmp auxmem

fastmask
  jsr FASTMASK
 jmp auxmem

fastblack jsr mainmem
 jsr FASTBLACK
 jmp auxmem

peel
 jsr PEEL
 jmp auxmem

getwidth jsr mainmem
 jsr GETWIDTH
 jmp auxmem

copyscrnMM
 jsr mainmem ;r/w main
]copyscrn jsr COPYSCRN
 jmp auxmem

copyscrnAA
 jsr auxmem ;r/w aux
 jmp ]copyscrn

copyscrnMA
 sta $c002 ;read main
 sta $c005 ;write aux
 jmp ]copyscrn

copyscrnAM
 sta $c003 ;read aux
 sta $c004 ;write main
 jmp ]copyscrn

*-------------------------------
mainmem sta $c004 ;RAMWRT off
 sta $c002 ;RAMRD off
 rts

auxmem sta $c005 ;RAMWRT on
 sta $c003 ;RAMRD on
 rts

*-------------------------------
*
*  Parameters passed to hires routines:
*
*  PAGE        $00 = hires page 1, $20 = hires page 2
*  XCO         Screen X-coord (0=left, 39=right)
*  YCO         Screen Y-coord (0=top, 191=bottom)
*  OFFSET      # of bits to shift image right (0-6)
*  IMAGE       Image # in table (1-127)
*  TABLE       Starting address of image table (2 bytes)
*  BANK        Memory bank of table (2 = main, 3 = aux)
*  OPACITY     Bits 0-6:
*                0    AND
*                1    OR
*                2    STA
*                3    special XOR (OR/shift/XOR)
*                4    mask/OR
*              Bit 7: 0 = normal, 1 = mirror
*  LEFTCUT     Left edge of usable screen area
*                (0 for full screen)
*  RIGHTCUT    Right edge +1 of usable screen area
*                (40 for full screen)
*  TOPCUT      Top edge of usable screen area
*                (0 for full screen)
*  BOTCUT      Bottom edge +1 of usable screen area
*                (192 for full screen)
*
*-------------------------------
*
*  Image table format:
*
*  Byte 0:    width (# of bytes)
*  Byte 1:    height (# of lines)
*  Byte 2-n:  image bytes (read left-right, top-bottom)
*
*-------------------------------
*
*  To preserve the background behind an animated character,
*  call LAYERSAVE before LAYing down each character image.
*  Afterwards, call PEEL to "peel off" the character &
*  restore the original background.
*
*  Peel buffer stores background images sequentially, in
*  normal image table format, & is cleared after every frame.
*
*-------------------------------
*
*  C L S
*
*  Clear hi-res screen to black2
*
*-------------------------------

CLS lda PAGE ;00 = page 1; 20 = page 2
 clc
 adc #$20
 sta :loop+2
 adc #$10
 sta :smod+2

 lda #$80 ;black2

 ldx #$10

 ldy #0

:loop sta $2000,y
:smod sta $3000,y
 iny
 bne :loop

 inc :loop+2
 inc :smod+2

 dex
 bne :loop

 rts

*-------------------------------
*
*  L O - R E S   C L S
*
*  Clear lo-res/text screen (page 1)
*
*  In: A = color
*
*-------------------------------

LRCLS LDY #$F7
:2 STA $400,Y
 STA $500,Y
 STA $600,Y
 STA $700,Y
 DEY
 CPY #$7F
 BNE :3
 LDY #$77
:3 CPY #$FF
 BNE :2
 RTS

*-------------------------------
*
*  S E T   I M A G E
*
*  In: TABLE (2 bytes), IMAGE (image #)
*  Out: IMAGE = image start address (2 bytes)
*
*-------------------------------

setimage lda IMAGE
 asl
 sec
 sbc #1

 tay
 lda (TABLE),y
 sta IMAGE

 iny
 lda (TABLE),y
 sta IMAGE+1

 rts

*-------------------------------
*
*  G E T   W I D T H
*
*  In: BANK, TABLE, IMAGE
*  Out: A = width, X = height
*
*-------------------------------
GETWIDTH
 lda BANK
 sta :RAMRD+1

:RAMRD sta $c003

 jsr setimage

 ldy #1
 lda (IMAGE),y ;height
 tax

 dey
 lda (IMAGE),y ;width
 rts

*-------------------------------
*
*  P R E P R E P
*
*  In: IMAGE, XCO, YCO
*
*-------------------------------

PREPREP

* Save IMAGE, XCO, YCO

 LDA IMAGE
 STA IMSAVE
 LDA XCO
 STA XSAVE
 LDA YCO
 STA YSAVE

* Get image data start address

 lda BANK
 sta :RAMRD+1

:RAMRD sta $c003

 jsr setimage

* Read first two bytes (width, height) of image table

 LDY #0
 LDA (IMAGE),Y
 STA WIDTH

 INY
 LDA (IMAGE),Y
 STA HEIGHT

 LDA IMAGE
 CLC
 ADC #2
 STA IMAGE
 BCC :3
 INC IMAGE+1

:3 sta $c002 ;RAMRD off (read mainmem)

]rts rts

*-------------------------------
*
*  C R O P
*
*  In:  Results of PREPREP (XCO, YCO, HEIGHT, WIDTH)
*       Screen area cutoffs (LEFTCUT, RIGHTCUT, TOPCUT, BOTCUT)
*
*  Out:
*
*  TOPEDGE   Top line -1
*  VISWIDTH  Width, in bytes, of visible (onscreen) portion
*               of image
*  XCO       X-coord of leftmost visible byte of image
*               (must be 0-39)
*  YCO       Y-coord of lowest visible line of image
*               (must be 0-191)
*  OFFLEFT   # of bytes off left edge
*  OFFRIGHT  # of bytes off right edge (including carry byte)
*  RMOST     # of bytes off right edge (excluding carry byte)
*
*  Return - if entire image is offscreen, else +
*
*-------------------------------
CROP

* (1) Crop top & bottom

 lda YCO
 cmp BOTCUT
 bcs :botoff ;Bottom o.s.

* Bottom is onscreen--check top

 sec
 sbc HEIGHT ;top line -1
 cmp #191
 bcc :topok ;Top is onscreen

 lda TOPCUT ;Top is offscreen
 sec
 sbc #1
 sta TOPEDGE
 jmp :done

:topok sta TOPEDGE ;Top line -1 (0-191)

 lda TOPCUT ;top line of image area (forced mask)
 beq :done ;no top cutoff

 sec
 sbc #1
 cmp TOPEDGE
 bcc :done

 sta TOPEDGE
 bcs :done

* Bottom is o.s.--advance IMAGE pointer past o.s. portion

:botoff ;A = YCO
 sec
 sbc HEIGHT
 clc
 adc #1 ;top line
 cmp BOTCUT
 bcs :cancel ;Entire shape is o.s.
 sec
 sbc #1
 sta TOPEDGE ;top line -1

 ldx YCO
:loop
 lda IMAGE
 clc
 adc WIDTH
 sta IMAGE
 bcc :1
 inc IMAGE+1
:1
 dex
 cpx BOTCUT
 bcs :loop

 stx YCO

* (2) Crop sides

:done
 lda XCO
 bmi :leftoff
 cmp LEFTCUT
 bcs :leftok ;XCO >= LEFTCUT

* XCO < LEFTCUT: left edge is offscreen

:leftoff
 lda LEFTCUT
 sec
 sbc XCO
 sta OFFLEFT ;Width of o.s. portion

 lda WIDTH
 sec
 sbc OFFLEFT
 bmi :cancel ;Entire image is o.s. -- skip it
 sta VISWIDTH ;Width of onscreen portion (can be 0)

 lda LEFTCUT
 sta XCO

* Assume image is <=40 bytes wide --> right edge is onscreen

 lda #0
 sta OFFRIGHT
 sta RMOST
 rts

* Left edge is onscreen; what about right edge?

:leftok ;A = XCO
 cmp RIGHTCUT ;normally 40
 bcs :cancel ;Entire image is o.s. - skip it

 clc
 adc WIDTH ;rightmost byte +1
 cmp RIGHTCUT
 bcc :bothok ;Entire image is onscreen

 sec
 sbc RIGHTCUT
 sta RMOST ;Width of o.s. portion

 clc
 adc #1
 sta OFFRIGHT ;+1

 lda RIGHTCUT
 sec
 sbc XCO
 sta VISWIDTH ;Width of onscreen portion

 lda #0
 sta OFFLEFT
 rts

:bothok lda WIDTH
 sta VISWIDTH

 lda #0
 sta OFFLEFT
 sta OFFRIGHT
 sta RMOST
 rts

:cancel lda #-1 ;Entire image is o.s. - skip it
]rts rts

*-------------------------------
*
* Shift offset 1 bit right or left
* (for special XOR)
*
* In/out: X = offset
*
*-------------------------------
shiftoffset
 cpx #6
 bcs :left

 inx
 rts

:left dex
]rts rts

*-------------------------------
*
*  L A Y E R S A V E
*
*  In:  Same as for LAY, plus PEELBUF (2 bytes)
*  Out: PEELBUF (updated), PEELIMG (2 bytes), PEELXCO, PEELYCO
*
*  PEELIMG is 2-byte pointer to beginning of image table.
*  (Hi byte = 0 means no image has been stored.)
*
*  PEELBUF is 2-byte pointer to first available byte in
*  peel buffer.
*
*-------------------------------

LAYRSAVE
 jsr PREPREP

 lda OPACITY
 bpl :normal

 LDA XCO
 SEC
 SBC WIDTH
 STA XCO

:normal
 inc WIDTH ;extra byte to cover shift right

 jsr CROP
 bmi SKIPIT

 lda PEELBUF ;PEELBUF: 2-byte pointer to 1st
 sta PEELIMG ;available byte in peel buffer
 lda PEELBUF+1
 sta PEELIMG+1

 lda XCO
 sta PEELXCO
 sta :smXCO+1

 lda YCO
 sta PEELYCO

 lda PAGE ;spend 7 cycles now --
 sta :smPAGE+1 ;save 1 in loop

 ldy #0

 lda VISWIDTH
 beq SKIPIT
 sta (PEELBUF),y
 sta :smWIDTH+1

 sec
 sbc #1
 sta :smSTART+1

* Continue

:cont iny

 LDA YCO
 SEC
 SBC TOPEDGE
 STA (PEELBUF),y ;Height of onscreen portion ("VISHEIGHT")

 LDA PEELBUF
 CLC
 ADC #2
 STA PEELBUF
 BCC :ok
 INC PEELBUF+1
:ok

* Like FASTLAY in reverse

 ldx YCO

:loop LDA YLO,X
 CLC
:smXCO ADC #0 ;XCO
 STA :smBASE+1

 LDA YHI,X
:smPAGE ADC #0 ;PAGE
 STA :smBASE+2

:smSTART ldy #0 ;VISWIDTH-1

:inloop
:smBASE lda $2000,y
 STA (PEELBUF),Y

 dey
 bpl :inloop

:smWIDTH LDA #0 ;VISWIDTH
 ADC PEELBUF ;assume cc
 STA PEELBUF
 BCC :2
 INC PEELBUF+1
:2
 DEX
 CPX TOPEDGE
 BNE :loop

 JMP DONE

SKIPIT lda #0
 sta PEELIMG+1 ;signal that peelbuf is empty

 JMP DONE

*-------------------------------
*
*  L A Y
*
*  General routine to lay down an image on hi-res screen
*  (Handles edge-clipping, bit-shifting, & mirroring)
*
*  Calls one of the following routines:
*
*    LayGen    General (OR, AND, STA)
*    LayMask   Mask & OR
*    LayXOR    Special XOR
*
*  Transfers control to MLAY if image is to be mirrored
*
*-------------------------------

LAY
 lda OPACITY
 bpl :notmirr

 and #$7f
 sta OPACITY
 jmp MLAY

:notmirr cmp #eor
 bne :1
 jmp LayXOR

:1 cmp #mask
 bcc :2
 jmp LayMask

:2 jmp LayGen

*-------------------------------
*
*   General (AND/OR/STORE)
*
*-------------------------------
LayGen
 jsr PREPREP

 jsr CROP
 bpl :cont
 jmp DONE
:cont
 lda BANK
 sta :RAMRD1+1
 sta :RAMRD2+1

 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 LDA CARRYH,X
 STA :90+2
 STA :92+2

 LDA AMASKS,X
 STA :AMASK+1
 LDA BMASKS,X
 STA :BMASK+1

 LDX OPACITY
 LDA OPCODE,X
 STA :80
 STA :81

* Preparation completed -- Lay down shape

 LDY YCO

:nextline
 LDA YLO,Y
 CLC
 ADC XCO
 STA BASE

 LDA YHI,Y
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

* (a) Left edge of image is offscreen
* Take initial carry byte from image table

 DEY

:RAMRD1 sta $c003 ;aux/main
 lda (IMAGE),y
 sta $c002 ;main

 TAX
:90 LDA $FFFF,X ;CARRYn
 STA CARRY

 LDA IMAGE
 CLC
 ADC OFFLEFT
 STA IMAGE
 BCC :1
 INC IMAGE+1
:1
 LDY #0

 LDA VISWIDTH
 STA WIDTH
 BNE :3
 BEQ :4 ;Zero width

* (b) Left edge of image is onscreen
* Take initial carry byte from screen

:2 LDA (BASE),Y
:AMASK AND #0
 STA CARRY

* Lay line down left-to-right fast as you can

:3
:RAMRD2 sta $c003 ;aux/main
 lda (IMAGE),y
 sta $c002 ;main

 TAX
:91 LDA $FFFF,X ;SHIFTn
 ORA CARRY ;Combine with carryover from previous byte

:80 STA (BASE),Y ;STA/ORA/AND/EOR depending on OPACITY
 STA (BASE),Y

:92 LDA $FFFF,X ;CARRYn
 STA CARRY ;Carry over to next byte

 INY
 CPY VISWIDTH
 BCC :3

*  Extra byte on right (carryover)

 LDA OFFRIGHT
 BNE :5 ;Rightmost byte is offscreen

:4 LDA (BASE),Y

:BMASK AND #0
 ORA CARRY
:81 STA (BASE),Y
 STA (BASE),Y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE
 BNE :nextline

*  Restore parameters

DONE LDA IMSAVE
 STA IMAGE

 LDA XSAVE
 STA XCO
 LDA YSAVE
 STA YCO

 RTS

*-------------------------------
*
*  Mask, then OR
*
*-------------------------------
]done jmp DONE

LayMask
 ldx OPACITY ;4 = mask, 5 = visible mask
 lda OPCODE,x ;4 = and, 5 = sta
 sta :masksm1
 sta :masksm2

 jsr PREPREP

 jsr CROP
 bmi ]done

 lda BANK
 sta :RAMRD1+1
 sta :RAMRD2+1

 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 sta :93+1

 LDA SHIFTH,X
 STA :91+2
 sta :93+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 sta :94+1
 sta :96+1

 LDA CARRYH,X
 STA :90+2
 STA :92+2
 sta :94+2
 sta :96+2

 LDA AMASKS,X
 STA :AMASK+1

 LDA BMASKS,X
 STA :BMASK+1

 LDY YCO

:nextline
 LDA YLO,Y
 CLC
 ADC XCO
 STA BASE

 LDA YHI,Y
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

* (a) Left edge of image is offscreen
* Take initial carry byte from image table

 dey

:RAMRD1 sta $c003
 lda (IMAGE),y
; eor #$ff ;TEMP
; ora #$80 ;TEMP
 sta $c002

 tax
:96 lda $FFFF,x ;CARRYn
 sta carryim

 lda MASKTAB-$80,x
 tax
:90 lda $FFFF,x ;CARRYn
 sta CARRY

 LDA IMAGE
 CLC
 ADC OFFLEFT
 STA IMAGE
 BCC :1
 INC IMAGE+1
:1
 ldy #0

 LDA VISWIDTH
 STA WIDTH
 BNE :inloop
 BEQ :4 ;Zero width

* (b) Left edge of image is onscreen
* Take initial carry byte from screen

:2
:AMASK lda #0 ;AMASK
 sta CARRY

 and (BASE),y
 sta carryim

* Lay line down left-to-right fast as you can

:inloop

:RAMRD2 sta $c003
 lda (IMAGE),y
; eor #$ff ;TEMP
; ora #$80 ;TEMP
 sta $c002

 tax

:93 lda $FFFF,x ;SHIFTn
 ora carryim
 sta imbyte ;shifted image byte

:94 lda $FFFF,x ;CARRYn
 sta carryim

 lda MASKTAB-$80,x
 tax

:91 lda $FFFF,x ;SHIFTn
 ora CARRY
:masksm1 and (BASE),y ;AND with mask byte
 ora imbyte ;OR with original image byte
 sta (BASE),y

:92 lda $FFFF,x ;CARRYn
 sta CARRY ;Carry over to next byte

 iny
 cpy VISWIDTH
 bcc :inloop

*  Extra byte on right (carryover)

 lda OFFRIGHT
 bne :5 ;Rightmost byte is offscreen

:4
:BMASK lda #0 ;BMASK
 ora CARRY
:masksm2 and (BASE),y
 ora carryim
 sta (BASE),y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE
 beq :done

 jmp :nextline

:done jmp DONE

*-------------------------------
*
*  Special XOR
*
*  (OR, then shift 1 bit and XOR)
*
*-------------------------------

LayXOR
 JSR PREPREP

 jsr CROP
 bpl :cont
 jmp DONE
:cont
 lda BANK
 sta :RAMRD1+1
 sta :RAMRD2+1

 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 LDA CARRYH,X
 STA :90+2
 STA :92+2

 jsr shiftoffset ;shift 1 bit right

 lda SHIFTL,x
 sta :s1+1
 lda SHIFTH,x
 sta :s1+2

 lda CARRYL,x
 sta :c1+1
 sta :c2+1
 lda CARRYH,x
 sta :c1+2
 sta :c2+2

 LDA AMASKS,X
 STA :AMASK+1

* Omit opcode setting

 LDY YCO

:0 LDA YLO,Y
 CLC
 ADC XCO
 STA BASE

 LDA YHI,Y
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

*  (a) Left edge offscreen
*  Take CARRY from off left edge

 DEY

:RAMRD1 sta $c003
 lda (IMAGE),y
 sta $c002

 TAX
:c2 lda $FFFF,x ;CARRYn+1
 sta carryim

:90 LDA $FFFF,X ;CARRYn
 STA CARRY

 LDA IMAGE
 CLC
 ADC OFFLEFT
 STA IMAGE
 BCC :1
 INC IMAGE+1

:1 LDY #0

 LDA VISWIDTH
 STA WIDTH
 BNE :inloop
 BEQ :4 ;Zero width

* (b) Left edge onscreen
* Start a new line at left edge

:2 lda (BASE),y
:AMASK and #0 ;AMASK
 sta CARRY

 lda #0 ;0 XOR X == X
 sta carryim

* Lay line down left-to-right fast as you can

:inloop

:RAMRD2 sta $c003
 lda (IMAGE),y
 sta $c002

 tax

:s1 lda $FFFF,x ;SHIFTn+1
 ora carryim
 sta imbyte

:c1 lda $FFFF,x ;CARRYn+1
 sta carryim

:91 lda $FFFF,x ;SHIFTn
 ora CARRY ;Combine with carryover from previous byte

 ora (BASE),y
 eor imbyte

 ora #$80 ;set hibit
 sta (BASE),y

:92 LDA $FFFF,X ;CARRYn
 STA CARRY ;Carry over to next byte

 INY
 CPY VISWIDTH
 BCC :inloop

*  Extra byte on right (carryover)

 LDA OFFRIGHT
 BNE :5 ;Rightmost byte is offscreen

:4 lda CARRY ;0's in unused part of byte

 ora (BASE),y
 eor carryim

 ora #$80
 sta (BASE),y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE
 beq :done

 jmp :0

*  Restore parameters

:done jmp DONE

*-------------------------------
*
*  M I R R O R    L A Y
*
*  Called by LAY
*
*  Specified starting byte (XCO, YCO) is image's bottom
*  right corner, not bottom left; bytes are read off image
*  table R-L, T-B and mirrored before printing.
*
*  In:  A = OPACITY, sans bit 7
*
*-------------------------------

MLAY ;A = OPACITY
 cmp #eor
 bne :1
 jmp MLayXOR

:1 cmp #mask
 bcc :2
 jmp MLayMask

:2 jmp MLayGen

*-------------------------------
*
*  General (AND/OR/STORE)
*
*-------------------------------
MLayGen
 JSR PREPREP

 LDA XCO
 SEC
 SBC WIDTH
 STA XCO

 jsr CROP
 bpl :cont
 jmp DONE
:cont
 lda BANK
 sta :RAMRD1+1
 sta :RAMRD2+1

 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 LDA CARRYH,X
 STA :90+2
 STA :92+2

 LDA AMASKS,X
 STA AMASK
 LDA BMASKS,X
 STA BMASK

 LDX OPACITY
 LDA OPCODE,X
 STA :80
 STA :81

* Lay on

 LDY YCO

:0 LDA YLO,Y
 STA BASE

 LDA YHI,Y
 CLC
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

* Take CARRY from off left edge

 LDY VISWIDTH

:RAMRD1 sta $c003
 lda (IMAGE),y
 sta $c002

 TAX

 LDA MIRROR-$80,X
 TAX

:90 LDA $FFFF,X ;CARRYn
 STA CARRY

:1 DEY
 BPL :3
 BMI :4

* Start a new line at left edge

:2 LDY XCO
 LDA (BASE),Y
 AND AMASK
 STA CARRY

 LDY WIDTH
 DEY

* Lay line down left-to-right fast as you can

:3 STY YREG

:RAMRD2 sta $c003
 lda (IMAGE),y
 sta $c002

 TAX

 LDA MIRROR-$80,X
 TAX

:91 LDA $FFFF,X ;SHIFTn
 ORA CARRY ;Combine with carryover from previous byte

 LDY XCO
:80 STA (BASE),Y ;STA/ORA/AND/EOR depending on OPACITY
 STA (BASE),Y

:92 LDA $FFFF,X ;CARRYn
 STA CARRY ;Carry over to next byte

 INC BASE

 LDY YREG
 CPY RMOST
 BEQ :7

 DEY
 BPL :3

*  Extra byte on right (carryover)

:7 LDA OFFRIGHT
 BNE :5 ;Rightmost byte is offscreen

:4 LDY XCO
 LDA (BASE),Y

 AND BMASK
 ORA CARRY
:81 STA (BASE),Y
 STA (BASE),Y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE

 beq :done
 jmp :0

:done JMP DONE

*-------------------------------
*
*  Mask, then OR
*
*-------------------------------

MLayMask
 ldx OPACITY ;4 = mask, 5 = visible mask
 lda OPCODE,x ;4 = and, 5 = sta
 sta :masksm1
 sta :masksm2

 JSR PREPREP

 LDA XCO
 SEC
 SBC WIDTH
 STA XCO

 jsr CROP
 bpl :cont
 jmp DONE
:cont
 lda BANK
 sta :RAMRD1+1
 sta :RAMRD2+1

 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 sta :93+1

 LDA SHIFTH,X
 STA :91+2
 sta :93+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 sta :94+1
 sta :96+1

 LDA CARRYH,X
 STA :90+2
 STA :92+2
 sta :94+2
 sta :96+2

 LDA AMASKS,X
 STA :AMASK+1
 LDA BMASKS,X
 STA :BMASK+1

* Lay on

 LDY YCO

:0 LDA YLO,Y
 STA BASE

 LDA YHI,Y
 CLC
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

* (a) Left edge offscreen
* Take CARRY from off left edge

 LDY VISWIDTH

:RAMRD1 sta $c003
 lda (IMAGE),y
; eor #$ff ;TEMP
; ora #$80 ;TEMP
 sta $c002

 TAX
 LDA MIRROR-$80,X
 TAX

:96 lda $FFFF,x ;CARRYn
 sta carryim

 lda MASKTAB-$80,x
 tax
:90 LDA $FFFF,X ;CARRYn
 STA CARRY

:1 DEY
 BPL :3
 BMI :4

* (b) Left edge onscreen
* Start a new line at left edge

:2 LDY XCO
:AMASK lda #0 ;AMASK
 sta CARRY

 and (BASE),y
 sta carryim

 LDY WIDTH
 DEY

* Lay line down left-to-right fast as you can

:3 STY YREG

:RAMRD2 sta $c003
 lda (IMAGE),y
; eor #$ff ;TEMP
; ora #$80 ;TEMP
 sta $c002

 TAX
 LDA MIRROR-$80,X
 TAX

:93 lda $FFFF,x ;SHIFTn
 ora carryim
 sta imbyte

:94 lda $FFFF,x ;CARRYn
 sta carryim

 lda MASKTAB-$80,x
 tax

:91 LDA $FFFF,X ;SHIFTn
 ORA CARRY ;Combine with carryover from previous byte

 LDY XCO
:masksm1 and (BASE),y
 ora imbyte
 STA (BASE),Y

:92 LDA $FFFF,X ;CARRYn
 STA CARRY ;Carry over to next byte

 INC BASE

 LDY YREG
 CPY RMOST
 BEQ :7

 DEY
 BPL :3

*  Extra byte on right (carryover)

:7 LDA OFFRIGHT
 BNE :5 ;Rightmost byte is offscreen

:4 LDY XCO
 LDA (BASE),Y

:BMASK AND #0 ;BMASK
 ORA CARRY
:masksm2 and (BASE),y
 ora carryim
 STA (BASE),Y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE
 beq :done

 jmp :0

:done jmp DONE

*-------------------------------
*
*  Special XOR
*
*-------------------------------

MLayXOR
 JSR PREPREP

 LDA XCO
 SEC
 SBC WIDTH
 STA XCO

 jsr CROP
 bpl :cont
 jmp DONE
:cont
 lda BANK
 sta :RAMRD1+1
 sta :RAMRD2+1

 LDX OFFSET

 LDA SHIFTL,X
 STA :91+1
 LDA SHIFTH,X
 STA :91+2

 LDA CARRYL,X
 STA :90+1
 STA :92+1
 LDA CARRYH,X
 STA :90+2
 STA :92+2

 jsr shiftoffset

 lda SHIFTL,x
 sta :s1+1
 lda SHIFTH,x
 sta :s1+2

 lda CARRYL,x
 sta :c1+1
 sta :c2+1
 lda CARRYH,x
 sta :c1+2
 sta :c2+2

 LDA AMASKS,X
 STA :AMASK+1

* Lay on

 LDY YCO

:0 LDA YLO,Y
 STA BASE

 LDA YHI,Y
 CLC
 ADC PAGE
 STA BASE+1

 LDY OFFLEFT
 BEQ :2

* (a) Left edge offscreen
* Take CARRY from off left edge

 LDY VISWIDTH

:RAMRD1 sta $c003
 lda (IMAGE),y
 sta $c002

 TAX
 LDA MIRROR-$80,X
 TAX

:c2 lda $FFFF,x ;CARRYn+1
 sta carryim

:90 LDA $FFFF,X ;CARRYn
 STA CARRY

:1 DEY
 BPL :3
 BMI :4

* (b) Left edge onscreen
* Start a new line at left edge

:2 ldy XCO
:AMASK lda #0 ;AMASK
 and (BASE),y
 sta CARRY

 lda #0
 sta carryim

 LDY WIDTH
 DEY

* Lay line down left-to-right fast as you can

:3 STY YREG

:RAMRD2 sta $c003
 lda (IMAGE),y
 sta $c002

 TAX

 LDA MIRROR-$80,X
 TAX

:s1 lda $FFFF,x ;SHIFTn
 ora carryim
 sta imbyte

:c1 lda $FFFF,x ;CARRYn
 sta carryim

:91 LDA $FFFF,X ;SHIFTn
 ORA CARRY ;Combine with carryover from previous byte

 LDY XCO

 ora (BASE),y
 eor imbyte

 ora #$80
 sta (BASE),Y

:92 LDA $FFFF,X ;CARRYn
 STA CARRY ;Carry over to next byte

 INC BASE

 LDY YREG
 CPY RMOST
 BEQ :7

 DEY
 BPL :3

*  Extra byte on right (carryover)

:7 LDA OFFRIGHT
 BNE :5 ;Rightmost byte is offscreen

:4 LDY XCO

 lda CARRY

 ora (BASE),Y
 eor carryim

 ora #$80
 STA (BASE),Y

*  Next line up

:5 LDA WIDTH
 CLC
 ADC IMAGE
 STA IMAGE
 BCC :6
 INC IMAGE+1

:6 DEC YCO
 LDY YCO
 CPY TOPEDGE
 beq :done

 jmp :0

:done JMP DONE

*-------------------------------
*
* Peel
*
*-------------------------------
PEEL
 sta $c004
]ramrd1 sta $c003

 jmp fastlaySTA

*-------------------------------
*
*  F A S T L A Y
*
*  Streamlined LAY routine
*
*  No offset - no clipping - no mirroring - no masking -
*  no EOR - trashes IMAGE - may crash if overtaxed -
*  but it's fast.
*
*  10/3/88: OK for images to protrude PARTLY off top
*
*-------------------------------
FASTLAY
 sta $c004 ;RAMWRT main
]ramrd2 sta $c003 ;RAMRD aux

 jsr setimage

 ldx OPACITY ;hi bit off!
 cpx #sta
 beq fastlaySTA

 lda OPCODE,x
 sta  :smod

 lda PAGE
 sta :smPAGE+1

 lda XCO
 sta  :smXCO+1

 ldy #0
 lda (IMAGE),y
 sta :smWIDTH+1

 sec
 sbc #1
 sta :smSTART+1

 lda YCO
 tax
 iny
 sbc (IMAGE),y
 bcs :ok
 lda #-1 ;limited Y-clipping
:ok sta  :smTOP+1

 lda IMAGE
 clc
 adc #2
 sta IMAGE
 bcc :1
 inc IMAGE+1
:1

:outloop
 lda YLO,x
 clc
:smXCO adc #0
 sta BASE

 lda YHI,x
:smPAGE adc #$20
 sta BASE+1

:smSTART ldy #3

:inloop
]ramrd3 sta $c003 ;RAMRD aux

 lda (IMAGE),y

 sta $c002 ;RAMRD main

:smod ora (BASE),y
 sta (BASE),y

 dey
 bpl :inloop

:smWIDTH lda #4
 adc IMAGE ;assume cc
 sta IMAGE
 bcc :2
 inc IMAGE+1
:2
 dex
:smTOP cpx #$ff
 bne :outloop

 rts

*-------------------------------
*
*  Still more streamlined version of FASTLAY (STA only)
*
*-------------------------------
fastlaySTA
 lda PAGE
 sta :smPAGE+1

 lda XCO
 sta  :smXCO+1

 ldy #0
 lda (IMAGE),y
 sta :smWIDTH+1

 sec
 sbc #1
 sta :smSTART+1

 lda YCO
 tax
 iny
 sbc (IMAGE),y
 bcs :ok
 lda #-1 ;limited Y-clipping
:ok sta  :smTOP+1

 lda IMAGE
 clc
 adc #2
 sta IMAGE
 bcc :1
 inc IMAGE+1
:1

:outloop
 lda YLO,x
 clc
:smXCO adc #0
 sta :smod+1

 lda YHI,x
:smPAGE adc #$20
 sta :smod+2

:smSTART ldy #3

:inloop
 lda (IMAGE),y
:smod sta $2000,y ;BASE

 dey
 bpl :inloop

:smWIDTH lda #4
 adc IMAGE ;cc
 sta IMAGE
 bcc :2
 inc IMAGE+1
:2
 dex
:smTOP cpx #$ff
 bne :outloop

 rts

*-------------------------------
*
*  F A S T M A S K
*
*-------------------------------
FASTMASK
 sta $c004 ;RAMWRT main
]ramrd4 sta $c003 ;RAMRD aux

 jsr setimage

 lda PAGE
 sta :smPAGE+1

 lda XCO
 sta  :smXCO+1

 ldy #0
 lda (IMAGE),y
 sta :smWIDTH+1

 sec
 sbc #1
 sta :smSTART+1

 lda YCO
 tax
 iny
 sbc (IMAGE),y
 bcs :ok
 lda #-1 ;limited Y-clipping
:ok sta  :smTOP+1

 lda IMAGE
 clc
 adc #2
 sta IMAGE
 bcc :1
 inc IMAGE+1
:1

:outloop
 stx index

 lda YLO,x
 clc
:smXCO adc #0
 sta BASE

 lda YHI,x
:smPAGE adc #$20
 sta BASE+1

:smSTART ldy #3

:inloop
]ramrd5 sta $c003 ;RAMRD aux

 lda (IMAGE),y

 sta $c002 ;RAMRD main

 tax
 lda MASKTAB-$80,X

 and (BASE),Y
 sta (BASE),y

 dey
 bpl :inloop

:smWIDTH lda #4
 adc IMAGE ;cc
 sta IMAGE
 bcc :2
 inc IMAGE+1
:2
 ldx index
 dex
:smTOP cpx #$ff
 bne :outloop

 rts

*-------------------------------
*
*  S E T F A S T   M A I N / A U X
*
*  Modify FASTLAY routines to expect image tables to
*  be in main/auxmem.  SETFAST need be called only once
*  (e.g., when switching between game & builder).
*
*-------------------------------
SETFASTMAIN
 lda #$02 ;RAMRD main
]setfast
 sta ]ramrd1+1
 sta ]ramrd2+1
 sta ]ramrd3+1
 sta ]ramrd4+1
 sta ]ramrd5+1
 rts

SETFASTAUX
 lda #$03 ;RAMRD aux
 bne ]setfast

*-------------------------------
*
*  F A S T B L A C K
*
*  Wipe a rectangular area to black2
*
*  Width/height passed in IMAGE/IMAGE+1
*  (width in bytes, height in pixels)
*
*-------------------------------

FASTBLACK
 lda color
 sta :smCOLOR+1

 lda PAGE
 sta :smPAGE+1

 lda XCO
 sta  :smXCO+1

 lda width
 sec
 sbc #1
 sta :smSTART+1

 lda YCO
 tax
 sbc height ;cs
 sta :smTOP+1

:outloop
 lda YLO,x
 clc
:smXCO adc #0
 sta :smod+1

 lda YHI,x
:smPAGE adc #$20
 sta :smod+2

:smCOLOR lda #$80

:smSTART ldy #3

:inloop
:smod sta $2000,y ;BASE
 dey
 bpl :inloop

 dex
:smTOP cpx #$ff
 bne :outloop

 rts

*-------------------------------
*
*  C O P Y   S C R E E N
*
*  Copy $2000 bytes
*
*  In: IMAGE+1 = dest scrn, IMAGE = org scrn
*      (use hi byte of actual memory address)
*
*-------------------------------
COPYSCRN
 lda IMAGE+1
 sta :dst1+2
 clc
 adc #$10
 sta :dst2+2

 lda IMAGE
 sta :org1+2
 adc #$10
 sta :org2+2

 ldx #$10

 ldy #0
:loop
:org1 lda $2000,y
:dst1 sta $4000,y

:org2 lda $3000,y
:dst2 sta $5000,y

 iny
 bne :loop

 inc :org1+2
 inc :org2+2
 inc :dst1+2
 inc :dst2+2

 dex
 bne :loop

 rts

*-------------------------------
* Invert Y-tables
*-------------------------------
INVERTY
 ldx #191 ;low line
 ldy #0 ;high line

* Switch low & high lines

:loop lda YLO,x
 pha
 lda YLO,y
 sta YLO,x
 pla
 sta YLO,y

 lda YHI,x
 pha
 lda YHI,y
 sta YHI,x
 pla
 sta YHI,y

* Move 1 line closer to ctr

 dex
 iny
 cpy #96
 bcc :loop
]rts rts

*-------------------------------
 lst
 ds 1
 usr $a9,1,$0000,*-org
 lst off
