# Reverse Engineering Prince of Persia on Apple II

## Game Starts (attract mode)
- Self-running "attract mode" on [MASTER:line:687](https://github.com/magraina/Prince-of-Persia-Apple-II/blob/master/01%20POP%20Source/Source/MASTER.S#L687)
  - Turns music on
  - Sets Display to double hi-res
  - Shows Publisher Credits "Broderbund Software Presents"
  - Shows Publisher Credits "A Game by Jordan Mechner"
  - Shows Title Screen
  - Plays the Prolog
  - Plays Princess Sceene - Princess's room: Vizier starts hourglass
  - Sets Display to double hi-res
  - Prolog Part 2
  - Show Title "Prince of Persia"
  - Jump to Demo sequence