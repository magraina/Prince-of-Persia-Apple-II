# Prince of Persia Apple II - A Code Review

I tried to reverse engineer this peace of code for some of it's parts, which was quiet interesting!  
It was a fascinating experience to dive into the world of 6502 Assembly, that mythical game and the game development back in the 80s.  
Reading the source allowed me to undestand how much work and knowledge went into it and it shows me how grateful we can be for the things we take for granted today.  

I separated my work through the game code into several files:
1. [File Structure](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/zz%20Reverse%20Engineering/00-ReverseEngineering-FILE-STRUCT.md) - About the file structures and how to understand them
2. [Boot](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/zz%20Reverse%20Engineering/01-ReverseEngineering-BOOT.md) - First boot up from disk
3. [Master](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/zz%20Reverse%20Engineering/02-ReverseEngineering-MASTER.md) - Main routine that handles data, code loading and starts the game
4. [Game starts](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/zz%20Reverse%20Engineering/03-ReverseEngineering-GAME-START.md) - The game finaly starts in a somehow demonstration mode intended to attract potential players (attract mode)


## Acknowledgment
I would like thank **Jordan Mechner** for providing that amazing piece of history!  
Many thanks to **Roger Wagner** which helped me with his book [Assembly Lines: The Complete Book](https://archive.org/details/AssemblyLinesCompleteWagner) to understand the 6502  
Also many thanks to **Fabien Sanglard** for providing a really [good review of the PoP code](https://fabiensanglard.net/prince_of_persia/index.php), which helped me a lot to get into the code  

## Related Links for Learning and Understanding Apple II - 6502 Assembly

### Related Software
[AppleWin](https://github.com/AppleWin/AppleWin) - AppleWin is a fully-featured emulator supporting different Apple II models and clones  
[CiderPress](https://a2ciderpress.com/) - Disk Image Utility (To create and Manage Apple II Disk Images)  
[Merlin Pro Assembler v2.43](https://macgui.com/downloads/?file_id=8140) - Assembly Editor with both ProDOS and DOS 3.3  
[Merlin Pro Assembler v2.47](https://macgui.com/downloads/?file_id=8143) - Assembly Editor with both ProDOS and DOS 3.3 (Newer GUI of Editor)  
[VS Code Extension for Merlin 6502 ASM](https://marketplace.visualstudio.com/items?itemName=dfgordon.vscode-language-merlin6502)

### Related Documents
[Merlin 8/16 Manual](https://gswv.apple2.org.za/a2zine/Docs/MerlinManual.txt) - TEXT Manual on how to use Merlin  
[Merlin 8/16 Manual (Newer Version 2.45+)](http://www.apple-iigs.info/doc/fichiers/merlin816.pdf) - Manual on how to use Merlin  
[Assembly Lines: The COmplete Book](https://archive.org/details/AssemblyLinesCompleteWagner) - Programming Guide to 6502 on the Apple II  
[Apple DOS 3.3 - Tipps und Tricks](https://ia904602.us.archive.org/31/items/apple-dos-33-tips-tricks/AppleDOS33_Tips&Tricks.pdf) - Hilfe rund um Befehle in Apple DOS (German)  

### Related Videos
[Quick Introduction Apple II Assembly Programming with Merlin on AppleWin - Getting Started](https://www.youtube.com/watch?v=GG6tfYyzzbM) - Simple Introduction on how to set up AplleWin etc.  


---
---
# Original Repository Text

Some background: This archive contains the source code for the original Prince of Persia game that I wrote on the Apple II, in 6502 assembly language, between 1985-89. The game was first released by Broderbund Software in 1989, and is part of the ongoing Ubisoft game franchise.

For a capsule summary of Prince of Persia's 25-year history, and my involvement with its various incarnations, see [jordanmechner.com](https://jordanmechner.com/).

For those interested in a fuller understanding of the context -- creative, business, personal, and technical -- in which this source code was created, I've published my dev journals from that period. See [jordanmechner.com/books/journals](https://jordanmechner.com/books/journals).

For those who'd like to dig into the source code itself, I've posted an explanatory technical document at [jordanmechner.com/library](https://jordanmechner.com/library) which should help. This is a package I put together in October 1989 for the benefit of the teams that were undertaking the ports of POP to various platforms such as PC, Amiga, Sega, Genesis, etc.

Beyond that, please don't ask me to explain anything about the source code, because I don't remember! I hung up my 6502 programming guns in October 1989, and after two decades working primarily as a writer, game designer, and creative director, to say my coding skills are rusty would be an understatement.

Thanks to [Jason Scott](http://www.textfiles.com) and [Tony Diaz](http://www.apple2.org) for successfully extracting the source code from a 22-year-old 3.5" floppy disk archive, a task that took most of a long day and night, and would have taken much longer if not for Tony's incredible expertise, perseverence, and well-maintained collection of vintage Apple hardware.

We extracted and posted the 6502 code because it was a piece of computer history that could be of interest to others, and because if we hadn't, it might have been lost for all time. We did this for fun, not profit. As the author and copyright holder of this source code, I personally have no problem with anyone studying it, modifying it, attempting to run it, etc. Please understand that this does NOT constitute a grant of rights of any kind in Prince of Persia, which is an ongoing Ubisoft game franchise. Ubisoft alone has the right to make and distribute Prince of Persia games.

That's about all I know. If additional information becomes available, I'll post and/or tweet about it ([@jmechner](https://twitter.com/jmechner)). In the meantime, if you have questions -- technical, legal, or otherwise -- I recommend that you direct them to the community at large, whose collective knowledge and expertise far exceeds mine, and will only increase as more people get their eyes on this code.

As for me, it's time to get back to my day job of making new games and making up stories.

Have fun!

-- Jordan Mechner
