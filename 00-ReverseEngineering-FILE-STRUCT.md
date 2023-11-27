# Reverse Engineering Prince of Persia on Apple II

The Game Engine is made of numerous `.S` files.
Back in the day this was one of the ways to structure code, but also you where limited somehow in the file size of such files, as of available RAM.

All these `.S` files contain a `ORG` directive which allows the Assembler to know where will the files be loaded into RAM.

There are some files which hold some references in form of constants.
These are used to reference different parts of the program or the data.

Most of the files include such reference files at the begining:
```asm
 lst
 put EQ
 lst
 put GAMEEQ
 lst
 put SOUNDNAMES
 lst off
```

They also include numerous `jmp` directives at the begining. right after the `ORG` directive.
And this is important for referencing with multiple files.
They are the direct reference to some `label` in the code right after.

A **J**u**MP** instruction needs 3 bytes in memory, which means that the next `jmp` is located right after that in memory.  
Example with ASM code how it look like in memory in comparsion to the ASM code itself (right):
```asm
                1           org $400
0400: 4C 0C 04	2           jmp GR
0403: 4C 0E 04	3           jmp DRAWALL
0406: 4C 10 04	4           jmp CONTRL
0409: 4C 12 04	5           jmp VERSION
040C: EA        6   GR      NOP
040D: EA        7           NOP
040E: EA        8   DRAWALL NOP
040F: EA        9           NOP
0410: EA        10  CONTRL  NOP
0411: EA        11          NOP
0412: EA        12  VERSION	NOP
0413: EA        11          NOP
0414: EA        11          RTS

```
The `ORG` directive instructs the Assembler to start at memory location `$400`.  
In this code there are multiple `labels` like `GR` on line `$040C`.  
The **J**u**MP** directive is `4C` as HEX in memory followed by the line number (2 bytes - Little Endian order) which it is referring to.  
For example the first `jmp` is referring to `GR` on line `$040C`.

The advantage of such jump blocks at the start is, that they alsways keep the same address in code even if there are changes in this file.
So it will be easy to jump from another file to a function that has been programmed in another file, by simply refering to a specific fixed place in memory.

And there comes files like the **EQ.S** into the game. This is some part of it:

```asm
    grafix = $400

    dum grafix          => Instructs the Assembler to start with label values at a given index of $400

    gr ds 3             => Therefore the label `gr` starts at $400 and reservse 3 bytes of memory
    drawall ds 3        => then `drawall` must be at $403 and reservse 3 bytes of memory
    controller ds 3     => $406 + 3 bytes
    ds 3                => $409 + 3 bytes
    saveblue ds 3       => $40C + 3 bytes
```

If you then referring in a different file to `gr` with a Jump to it, the Assembler would know, based on a file like `EQ.S` that the jump must go to memory address $400.
and on $400 is another jump that finally brings us to the function of that specific file.

There are also `jmp`'s that directely point to a specific location whithout the use of labels.

So if you want to know where a Jump is pointing to, you might need check multiple files.
But most likely (today) you also can find the function by using a search function over multiple files in your editor/IDE or by using something like `grep` in your terminal.


### [Next Chapter](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01-ReverseEngineering-BOOT.md)
