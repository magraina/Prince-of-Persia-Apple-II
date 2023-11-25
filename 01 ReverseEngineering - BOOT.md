# Reverse Engineering Prince of Persia on Apple II

## Start
The Apple II starts to load the fist sectors into the RAM Register $0800
This part is located in the file BOOT.S

---
```
**APPLE II RAM**
----------------------
$FFFF - |
        |
        |
        |
        |
        |
        |
        |
        |
        |
        |
        |
        |------------
        | BOOT.S - 
$0800 - |------------
        |
        |
        |
        |
        |
$0000 - |
```
---

### BOOT.S - Bootloader of the game

- start by outputting $01 to the instruction stream (line:21). This will trigger the Apple firmware to automatically load one sector from track:0 to the RAM at $800 and branch there

```
**APPLE II RAM**
-------------------------------------------------------------------------
$FFFF - |---------------|---------------|               |---------------|
        |               |               |               |               |
        |      ROM      |  MAIN MEMORY  |               |               |
$E000 - |               |---------------|---------------|               |
        |               |     BANK 0    |     BANK 1    |               |
$D000 - |---------------|---------------|---------------|               |
        | Soft Switches |               |               |               |
$C000 - |---------------|               |               |   AUXILIARY   |
        |               |               |               |    MEMORY     |
        |               |               |               |               |
        |               |  MAIN MEMORY  |               |               |
        |               |               |               |               |
        |               |               |               |               |
        |               |               |               |               |
        |               |               |               |               |
        |               |---------------|               |               |
        |               |    BOOT.S     |               |               |
$0800 - |               |---------------|               |               |
        |               |  MAIN MEMORY  |               |               |
$0000 - |---------------|---------------|               |---------------|
```
---

- Setting some soft switches (e.g. clear display, display text mode, setup RWTS16) at line:26

- Loads rest of BOOT.S and RWTS18 into RAM - uses RWTS16 to load a bunch of sectors to RAM using skewing table table (line:79)


```
**APPLE II RAM**
-------------------------------------------------------------------------
$FFFF - |---------------|---------------|               |---------------|
        |               |               |               |               |
        |      ROM      |  MAIN MEMORY  |               |               |
$E000 - |               |---------------|---------------|               |
        |               |     BANK 0    |     BANK 1    |               |
$D000 - |---------------|---------------|---------------|               |
        | Soft Switches |               |               |               |
$C000 - |---------------|               |               |   AUXILIARY   |
        |               |  MAIN MEMORY  |               |    MEMORY     |
        |               |               |               |               |
$3400 - |               |---------------|               |               |
        |               |    RWTS18     |               |               |
$3000 - |               |---------------|               |               |
        |               |               |               |               |
        |               |---------------|               |               |
$0900 - |               |    BOOT.S     |               |               |
$0800 - |               |---------------|               |               |
        |               |  MAIN MEMORY  |               |               |
$0000 - |---------------|---------------|               |---------------|
```
---

- Check (line:113 & line:167) if it is a APPLE //c or //e with 128k RAM otherwise stop with text error message
- Load Disk Read/Write Routine RWTS18 from $3000 into memory at $D000 (line:115)


```
**APPLE II RAM**
-------------------------------------------------------------------------
$FFFF - |---------------|---------------|               |---------------|
        |               |               |               |               |
        |      ROM      |  MAIN MEMORY  |               |               |
$E000 - |               |---------------|---------------|               |
        |               |     BANK 0    |     **RWTS18**    |               |
$D000 - |---------------|---------------|---------------|               |
        | Soft Switches |               |               |               |
$C000 - |---------------|               |               |   AUXILIARY   |
        |               |               |               |    MEMORY     |
        |               |               |               |               |
$3400 - |               |  MAIN MEMORY  |               |               |
        |               |               |               |               |
$3000 - |               |               |               |               |
        |               |               |               |               |
        |               |---------------|               |               |
$0900 - |               |    BOOT.S     |               |               |
$0800 - |               |---------------|               |               |
        |               |  MAIN MEMORY  |               |               |
$0000 - |---------------|---------------|               |---------------|
```
---

- Load then several sectors from disk using RWTS18 Routine and jumps to $EE00 (line:138)
- HIRES.S starts at $EE00

```
**APPLE II RAM**
-------------------------------------------------------------------------
$FFFF - |---------------|---------------|               |---------------|
        |               |               |               |               |
        |               |               |               |               |
        |      ROM      |    HIRES.S    |               |               |
$E000 - |               |---------------|---------------|               |
        |               |     BANK 0    |     RWTS18    |               |
$D000 - |---------------|---------------|---------------|               |
        | Soft Switches |               |               |               |
$C000 - |---------------|               |               |   AUXILIARY   |
        |               |               |               |    MEMORY     |
        |               |               |               |               |
$3400 - |               |  MAIN MEMORY  |               |               |
        |               |               |               |               |
$3000 - |               |               |               |               |
        |               |               |               |               |
        |               |---------------|               |               |
$0900 - |               |    BOOT.S     |               |               |
$0800 - |               |---------------|               |               |
        |               |  MAIN MEMORY  |               |               |
$0000 - |---------------|---------------|               |---------------|
```
---

- HIRES.S directly jumps to to $F880 at begining (line:13)
- MASTER.S starts at $F880

```
**APPLE II RAM**
-------------------------------------------------------------------------
$FFFF - |---------------|---------------|               |---------------|
        |               |    MASTER.S   |               |               |
$F880 - |               |---------------|               |               |
        |      ROM      |    HIRES.S    |               |               |
$E000 - |               |---------------|---------------|               |
        |               |     BANK 0    |     RWTS18    |               |
$D000 - |---------------|---------------|---------------|               |
        | Soft Switches |               |               |               |
$C000 - |---------------|               |               |   AUXILIARY   |
        |               |               |               |    MEMORY     |
        |               |               |               |               |
$3400 - |               |  MAIN MEMORY  |               |               |
        |               |               |               |               |
$3000 - |               |               |               |               |
        |               |               |               |               |
        |               |---------------|               |               |
$0900 - |               |    BOOT.S     |               |               |
$0800 - |               |---------------|               |               |
        |               |  MAIN MEMORY  |               |               |
$0000 - |---------------|---------------|               |---------------|
```
---
