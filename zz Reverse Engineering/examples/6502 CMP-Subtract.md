
*Compare is basicaly the result of a substraction*  

### Substraction with Carry
There are two ways in common use to use the carry flag for subtraction operations.

The 6502 is a particularly well-known example because it does not have a subtract without carry operation, so programmers must ensure that the carry flag is set before every subtract operation where a borrow is not required.

Carry is always set before a substraction.  
If the values are equal, then `carry` and `zero` is set.
```
       Z C
Accu   0 1  1100 -
Memory      1100
            ────
       1 1  0000
```

If the value is greater than, then only `carry` is set.
```
       Z C
Accu   0 1  1100 -
Memory      1000
            ────
       0 1  0100
```

If the value is less than, then `carry` is not set.
```
       Z C
Accu   0 1  1000 -
Memory      1100
            ────
       0 0  1100
```


| To Branch If | Follow compare instruction with For unsigned numbers | Follow compare instruction with For signed numbers |
|-------------------------------------------|---------------------------------|---------------------|
| Register is less than data                | BCC THERE                       | BMI THERE           |
| Register is equal to data                 | BEQ THERE                       | BEQ THERE           |
| Register is greater than data             | BEQ HERE BCS THERE              | BEQ HERE BPL THERE  |
| Register is less than or equal to data    | BCC THERE BEQ THERE             | BMI THERE BEQ THERE |
| Register is greater than or equal to data | BCS THERE                       | BPL THERE           |