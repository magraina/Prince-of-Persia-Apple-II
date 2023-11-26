# Reverse Engineering Prince of Persia on Apple II

## MASTER.S - The Game Engine
- Jumps to FIRSTBOOT to load/initialize the Code and Data into the RAM

### FIRSTBOOT ([line:186](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L186))

- Loads Hires tables/code into RAM from $E000 to $ED00 from disk via RWTS18 ([MASTER:line:195](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L195))

- Loads permanent code & data from disk via RWTS18 (Load as much of Stage 3 as we can keep):
  - into AUX RAM from $0400 to $2700 which is GRAFIX.S & TOPCTRL.S (and maybe more?) ([MASTER:line:207](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L207))

  - into MAIN RAM from $1A00 to $1F00 & $A800 to $BF00 ([MASTER:line:1095](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L1095))

  - Load aux l.c. stuff (tracks 19-21 & 34) (includes music set 1) into MAIN RAM $2000 to $3D00 and MAIN RAM $5000 to $5F00
    - Then moves $2000.5FFF mainmem to auxiliary language card mem ([MISC:line:152](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MISC.S#L152))

- Then turns the drive off

- It checks if it is a Apple IIgs and sets specific setings for the display (Super hi-res only if IIGS) ([MASTER:line:215](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L215) & [GRAFIX:line:2015](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/GRAFIX.S#L2015))

- Initialize system (in [TOPCTRL:line:120](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/TOPCTRL.S#L120))
 - Centers the Joystic ([GRAFIX:line:1232](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/GRAFIX.S#L1232))
 - Modify FASTLAY routines to expect image tables to be in main/auxmem.  SETFAST need be called only once  (e.g., when switching between game & builder) ([HIRES:line:1977](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/HIRES.S#L1977))
 - Init Game (Initialize vars before starting game) (in [TOPCTRL:line:223](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/TOPCTRL.S#L223))
 - Sound on
 - Start Game (AttractLoop)

## Memory Map

```js
**APPLE //e RAM** - (Memory allocation based on EQ.S and findings in code)
---------------------------------------------------------------------------------------------------------------------
Size/  ADDRESS  / ROM Mem, FW, Flags/    MAIN MEMORY    /       BANK        /  AUXILIARY MEMORY /       BANK        /
----|-----------|-------------------|-------------------|-------------------|-------------------|-------------------|
64k | - $FFFF - |-------------------|-------------------|                   |-------------------| - $FFFF
    |           |                   |      MASTER.S     |                   |                   |      
    | - $F880 - |                   |-------------------|                   |                   | - $F880
    |           |                   |      HIRES.S      |                   |                   |      
    | - $EE00 - |                   |-------------------|                   |                   | - $EE00
    |           |      ROM          |UNPACK.S(Game only)|                   |                   |      
    | - $EA00 - |                   |-------------------|                   |                   | - $EA00
    |           |                   |     HRTABLES.S    |                   |                   |      
56k | - $E000 - |                   |-------------------|-------------------|                   |-------------------| - $E000
    |           |                   |  PEELBUF(BANK 0)  |  RWTS18 (BANK 1)  |                   | BLUECOPY (BANK 1) |
52k | - $D000 - |-------------------|-------------------|-------------------|-------------------|-------------------| - $D000
    |           | Soft Switches                                                                 
48k | - $C000 - |-------------------|-------------------|-------------------|-------------------| - $C000
    |           |                   |                   |                   |                   |      
    |           |                   |                   |                   |                   |      
    |           |                   |                   |                   |                   |      
    |           |                   |                   |                   |                   | - $B700
    | - $B600 - |                   |                   |                   |---(ENDIMSPACE) ---| - $B600
    |           |                   |                   |                   |      IMLIST       |      
    | - $AC00 - |                   |                   |                   |-------------------| - $AC00
    |           |                   |                   |                   | MENUDATA (ED Only)|      
    | - $960F - |                   |                   |                   |-------------------| - $960F
    |           |                   |                   |                   |                   |      
32k | - $8000   |                   |    MAIN MEMORY    |                   |                   |      
    |           |                   |                   |                   |      REDBUFS      |      
    | - $5E00 - |                   |                   |                   |-------------------| - $5E00
    |           |                   |                   |                   |                   |      
    | - $3400 - |                   |                   |                   |                   | - $3400
    |           |                   |                   |                   |                   |      
12k | - $3000 - |                   |                   |                   |                   | - $3000
    | - $2700 - |                   |                   |                   |-------------------| - $2700
    |           |                   |                   |                   |     TOPCTRL.S     |      
 8k | - $2000   |                   |                   |                   |-------------------| - $2000
    |           |                   |                   |                   |     FRAMEADV.S    |      
    | - $1290   |                   |                   |                   |-------------------| - $1290
    |           |                   |                   |                   |      TABLES.S     |      
    | - $0E00 - |                   |                   |                   |-------------------| - $0E00
 4k | - $1000 - |                   |-------------------|                   |                   |      
    | - $0900 - |                   |      BOOT.S       |                   |                   | - $0900
 2k | - $0800 - |                   |-------------------|                   |                   | - $0800
    |           |                   |                   |                   |      GRAFIX.S     |      
 1k | - $0400 - |                   |                   |                   |-------------------| - $0400
 0  | - $0000 - |-------------------|-------------------|                   |-------------------| - $0000
    |------------------------------------------------------------------------------------------------------------
```
---

### [Next Chapter](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/03-ReverseEngineering-GAME-STARTS.md)
