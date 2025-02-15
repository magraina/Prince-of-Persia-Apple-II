# Reverse Engineering Prince of Persia on Apple II

## Game Starts (attract mode)
- Self-running "attract mode" on [MASTER:line:687](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L687)
  - Turns music on (Stores nummber 1 in a register above $300 - Don't know what that does)
  - Sets Display to double hi-res by setting some Soft switches ([UNPACK:line:627](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/UNPACK.S#L627))
    - And Loads Stage 1A from disk to main RAM probably ([MASTER:line:1168](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L1168))
    - Also loads music from disk ([MASTER:line:1180](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L1180)) into main RAM ([MASTER:line:254](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L254)) and moves it into aux RAM
    - Puts aux RAM into Read mode and again set's some registers with $FF at address above $300
    - Shut the drive of and jumps multiple functions back to the last stack address (crazy!) inside the attract mode.
  - Shows Publisher Credits "Broderbund Software Presents" [MASTER:line:693](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L693)
    - Unpack splash screen into DHires page 1
      - by looping trough several registers and put them on screen
    - Show DHires page 1
    - Sets Display to double hi-res by setting some Soft switches ([UNPACK:line:640](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/UNPACK.S#L640))
    - Copy to DHires page 2
    - Some delay by going troug a loop
    - Then Unpack "Broderbund Presents" onto page 1
    - Finally Plays a Song, but in a interruptible way, which is interessting!
      - It reads the previous loaded flags which hat activated the music/sound ([MASTER:line:1389](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L1389))
      - While music is playing, it checks for a keypresses ([MASTER:line:1389](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L1389))
        - Esc to pause, Ctrl-S to turn sound off (which also toggles the previous flags fro the music)
        - Return A = ASCII value (FF for button)
        - It uses a sound library calles Music System II by Kyle Freeman to play sounds ([MSYS II](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/04%20Support/MakeDisk/S/MSYS.S))
    - - ![image](https://github.com/magraina/Prince-of-Persia-Apple-II/assets/33145691/046ce568-39b3-4715-bf94-9281798c72c7)
  
    - The Screen get's cleared again ([MASTER:line:764](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L764))
  **Note**: If the player presses a key, than we jump out of the attrack mode (which is basically the prolog and a demo scene) into the gameplay
  - Shows Author Credits "A Game by Jordan Mechner"
    - basically the same happens as in the previous step
    - ![image](https://github.com/magraina/Prince-of-Persia-Apple-II/assets/33145691/3dd0f5a8-1ddf-4512-875e-dad6e4e4900f)

  - Shows Title Screen "Prince of Persia"
    - basically the same happens as in the previous step
    - ![image](https://github.com/magraina/Prince-of-Persia-Apple-II/assets/33145691/e67b9c65-a333-4a65-b064-f92e23a04b16)

  - Plays the Prolog 1
    - It does seem to decide to load Hi-Res images based on memory locations ([MASTER:line:100](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L100)), same for music ([MASTER:line:116](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L116))
  - Plays Princess Sceene - Princess's room: Vizier starts hourglass
  - ![image](https://github.com/magraina/Prince-of-Persia-Apple-II/assets/33145691/5a36d484-5d82-4768-af94-2f3cdfab74b4)

  - Sets Display to double hi-res, again
  - Prolog Part 2
    - Works similar as Prolog 1
  - Show Title "Prince of Persia" but without additinal music
    - Similar to previous Titles
  - Jump to Demo sequence
