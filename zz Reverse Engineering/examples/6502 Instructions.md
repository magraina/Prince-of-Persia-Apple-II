
```js
┌─────────────────────────────────────────────────────────────────┐
│                        6502 System Memory                       │
│                             INC DEC                             │
│                         ASL LSR ROL ROR                         │
│                          (STZ TSB TRB)                          │
└─┬───────┬───────────┬───────┬─────────────────────────┬───────┬─┘
  │   ▲   ┊           │   ▲   ┊ CMP ADC SBC  ▲          │   ▲   ┊  
 LDX STX CPX         LDA STA  ┊ AND ORA EOR  ┊(TSB)    LDY STY CPY 
  ▼   │   ▼           ▼   │   ▼ BIT          ┊(TRB)     ▼   │   ▼  
┌─────┴─────┐       ┌─────┴──────────────────┴─┐      ┌─────┴─────┐
│X-Register │       │       Accumulator        │      │Y-Register │
│           ├─TXA──▸│     ASL LSR ROL ROR      ├─TYA─▸│           │
│    LDX    │◂─TAX──┤     LDA CMP ADC SBC      │◂─TAY─┤    LDY    │
│INX DEX CPX│       │     AND ORA EOR BIT      │      │INY DEY CPY│
│           │       │        (INC DEC)         │      │           │
└─┬─────────┘       └─────┬────────────────────┘      └───────────┘
  │      ▲                │              ▲                         
 TXS    TSX              PHA            PLA                        
  ▼      │                ▼              │                         
┌────────┴────────┐ ┌────────────────────┴─────┐      ┌───────────┐
│  Stack Pointer  │ │        6502 Stack        │◂─JSR─┤  Program  │
│ PHA PLA PHP PLP │ │                          ├─RTS─▸│  Counter  │
│ JSR RTS BRK RTI │ │        $100..$1FF        │◂─BRK─┤  NOP JMP  │
│(PHX PLX PHY PLY)│ │                          ├─RTI─▸│  BEQ BNE  │
└─────────────────┘ └─┬───────────────┬────────┘      │  BPL BMI  │
                      │     ▲         │     ▲         │  BCC BCS  │
                     PLP   PHP       RTI   BRK        │  BVC BVS  │
                      ▼     │         ▼     │         │   (BRA)   │
                    ┌───────┴───────────────┴──┐      └───────────┘
                    │          Status          │                   
                    │   CLC SEC CLD SED CLV    │                   
                    │         CLI SEI          │                   
                    └──────────────────────────┘                   
```
- Solid arrows indicate a transfer of data
- Dashed arrows indicate a transfer of information
- Inside brackets indicates 65C02 instructions

### 6502 Microprocessor Instructions
- ADC Add memory to Accumulator with carry  
- AND AND memory with Accumulator  
- ASL Shi4 le4 one bit (memory or Accumulator)  
- BCC Branch on carry clear  
- BCS Branch on carry set  
- BEQ Branch on result = zero  
- BIT Test bits in memory with Accumulator  
- BMI Branch on result = minus
- BNE Branch on result = not zero
- BPL Branch on result = plus
- BRA Branch always [1]
- BRK Force break
- BVC Branch on overSow clear
- BVS Branch on overSow set
- CLC Clear carry Sag
- CLD Clear decimal mode
- CLI Clear interrupt disable bit
- CLV Clear overSow Sag
- CMP Compare memory and Accumulator
- CPX Compare memory and X-Register
- CPY Compare memory and Y-Register
- DEC Decrement memory by one
- DEX Decrement X-Register by one
- DEY Decrement Y-Register by one
- EOR Exclusive OR Accumulator with memory
- INC Increment memory by one
- INX Increment X-Register by one
- INY Increment Y-Register by one
- JMP Jump to new location
- JSR Jump to new location saving return address on Stack
- LDA Load Accumulator with memory
- LDX Load X-Register with memory
- LDY Load Y-Register with memory
- LSR Shi4 right one bit (memory or Accumulator)
- NOP No operation
- ORA OR Accumulator with memory
- PHA Push Accumulator onto stack
- PHP Push processor status onto stack
- PHX Push X-Register onto stack [1]
- PHY Push Y-Register onto stack [1]
- PLA Pull Accumulator from stack
- PLP Pull processor status from stack
- PLX Pull X-Register from stack [1]
- PLY Pull Y-Register from stack [1]
- ROL Rotate le4 one bit (memory or Accumulator)
- ROR Rotate right one bit (memory or Accumulator)
- RTI Return from interrupt
- RTS Return from subroutine
- SBC Subtract memory from Accumulator with borrow
- SEC Set carry Sag
- SED Set decimal mode
- SEI Set interrupt disable status
- STA Store Accumulator in memory
- STX Store X-Register in memory
- STY Store Y-Register in memory
- STZ Store zero in memory [1]
- TAX Transfer Accumulator to X
- TAY Transfer Accumulator to Y
- TRB Test and reset bits [1]
- TSB Test and set bits [1]
- TSX Transfer Stack Pointer to X
- TXA Transfer X to Accumulator
- TXS Transfer X to Stack Pointer
- TYA Transfer Y to Accumulator

[1] Opcodes are for the 65C02.