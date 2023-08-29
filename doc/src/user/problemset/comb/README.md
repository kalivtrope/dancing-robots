# comb

Your goal here is to traverse a "comb"-shaped maze while collecting every item along the way.

The items are sometimes randomly placed on the tips of the comb, but nowhere else.


## Maze format
- let `n,m` be positive integers
- you are given a `(m+3)x(4n+3)` grid
  - there are solid walls on all of its 4 borders (so there is a solid left,right,bottom,top wall line)
- the origin `(1,1)` is located at the top left corner of the maze (the intersection of the top and left border)
- for each valid integer `k`, the `(4k+3)`rd column is filled with wall except for a single cell at the very bottom of this column (just before the border)
  - this cell may or may not be containing an item
- for each valid integer `k`, the `(4k+1)`st column is filled with wall except for a single cell at the very top of this column (just before the border)
  - this cell may or may not be containing an item
- there are no other walls or items elsewhere other that at the just mentioned positions
- you start off at the top-left-most empty cell (the position `(2,2)`) and end at the bottom-right-most empty cell (the position `(m+2,4n+2)`).
- you must **drop** all items at the ending cell before your program finishes
## Examples
You may find all of the inputs and outputs in the `Examples/comb` directory.
See the robot's progress while solving these problems by e.g. running
```
./main.lua test -p Examples/comb/comb_n2.in Examples/comb/comb_n2.out
```
or just
```
./main.lua test -p Examples/comb/comb_n2.{in,out}
```
if your shell supports it.
### Example 1
#### Example input (n=2, m=10) (Examples/comb/comb_n2.in)
```
comb
13 11
# # # # # # # # # # #
# S # . . . # . I . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . I . # . I . # E #
# # # # # # # # # # #
```
#### Example final form
- note: the robot orientation doesn't matter
- however the robot's inventory MUST be empty after finishing the program
```
# # # # # # # # # # #
# S # . . . # . . . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . . . # . . . # n #
# # # # # # # # # # #
```
#### Example output (Examples/comb/comb_n2.out)
```
turnright
turnright
movetowall
turnleft
movetoitem
collect
movetowall
turnleft
movetowall
turnright
movetowall
turnright
movetowall
turnleft
movetoitem
collect
movetowall
turnleft
movetowall
turnright
movetoitem
collect
movetowall
turnright
movetowall
turnleft
movetowall
turnleft
drop
drop
drop
```
### Example 2
#### Example input (n=10, m=1) (Examples/comb/comb_n10.in)
```
comb
4 43
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# S # . . . # . I . # . . . # . I . # . . . # . . . # . . . # . . . # . I . # . . . #
# . I . # . I . # . I . # . I . # . . . # . . . # . . . # . I . # . I . # . I . # E #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
```
#### Example final form

```
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# S # . . . # . . . # . . . # . . . # . . . # . . . # . . . # . . . # . . . # . . . #
# . . . # . . . # . . . # . . . # . . . # . . . # . . . # . . . # . . . # . . . # n #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
```
