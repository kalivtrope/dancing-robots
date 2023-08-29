# sortp
(as in "`sort` a `p`ermutation")

Oh no, our beautiful identity permutation had just been shuffled!
Can you help us put it back to its original form?

## Problem statement
### Maze format
- let `n` be a positive integer greater than one
- let `p: {1..n} -> {1..n} != id` be a permutation (bijective function with the same domain and range - `{1..n}`)
- the permutation `p` is encoded on the grid as follows:
  - the grid has a square shape of size `(2n+2)x(2n+2)` with walls on its borders (so there is a solid left,right,bottom,top wall line)
  - in the `(2i)`-th column you will find `p(i)` items placed from the bottom wall to top
  - let's denote the bottom wall a row no. 1
  - the first item is placed right above the bottom-most wall block (row 2)
  - each consecutive item is placed two blocks above the previous item (rows `2,4,6,8,...2i`)
  - there is a wall at column `2i`, row `2i+3`
  - there is also a partially filled diagonal of walls starting right to the position of column `2i`, row `2i`
    - this diagonal continues in the bottom-right direction all the way until it hits a border wall
  - the start is placed at position column 2, row 2 (the bottom-left-most non-wall position)
  - the start is placed at position column `2n+1`, row `2n+1` (the top-right-most non-wall position)
### Objective
- Eralk's task is to rearrange the items so that the grid represents a sequence `1,2,...,n`

## Examples

You may find all of the inputs and outputs in the `Examples/sortp` directory.
See the robot's progress while solving these problems by e.g. running
```
./main.lua test -p Examples/sortp/sortp_n4.in Examples/sortp/sortp_n4.out
```
### Example 1
#### Example input (n=4,p=(1,3,4,2)) (Examples/sortp/sortp_n4.in)
```
sortp
10 10
# # # # # # # # # #
# . . . . # . . E #
# . . . . I . . # #
# . . # . . . . . #
# . . I . I # . . #
# # . . . . . # . #
# . . I # I . I # #
# . . . . # . . . #
# IS # I . I # I . #
# # # # # # # # # #
```
#### Example final form
```
# # # # # # # # # #
# . . . . # . . e #
# . . . . . . I # #
# . . # . . . . . #
# . . . . I # I . #
# # . . . . . # . #
# . . I # I . I # #
# . . . . # . . . #
# S # I . I # I . #
# # # # # # # # # #
```
#### Example output
```
movetowall
turnright
movetoitem
turnleft
movetoitem
collect
turnright
movetowall
turnleft
movetoitem
collect
turnright
movetowall
drop
turnright
movetowall
drop
turnleft
turnleft
movetowall
turnright
movetoend
```

### Example 2
#### Example input (n=5,p=(1,3,5,4,2)) (Examples/sortp/sortp_n5.in)
```
sortp
12 12
# # # # # # # # # # # #
# . . . . . . # . . E #
# . . . . I . . . . # #
# . . . . # . . . . . #
# . . . . I . I # . . #
# . . # . . . . . # . #
# . . I . I # I . . # #
# # . . . . . # . . . #
# . . I # I . I # I . #
# . . . . # . . . # . #
# IS # I . I # I . I # #
# # # # # # # # # # # #
```
#### Example final form
```
# # # # # # # # # # # #
# . . . . . . # . . e #
# . . . . . . . . I # #
# . . . . # . . . . . #
# . . . . . . I # I . #
# . . # . . . . . # . #
# . . . . I # I . I # #
# # . . . . . # . . . #
# . . I # I . I # I . #
# . . . . # . . . # . #
# IS # I . I # I . I # #
# # # # # # # # # # # #
```
### Example 3
#### Example input (n=10,p=(8,5,3,1,9,7,10,4,2,6)) (Examples/sortp/sortp_n10.in)
```
sortp
22 22
# # # # # # # # # # # # # # # # # # # # # #
# . . . . . . . . . . . . . . . . # . . E #
# . . . . . . . . . . . . I . . . . . . # #
# . . . . . . . . . . . . . . # . . . . . #
# . . . . . . . . I . . . I . . . . # . . #
# . . . . . . . . . . . . # . . . . . # . #
# I . . . . . . . I . . . I . . # . . . # #
# . . . . . . . . . . # . . . . . # . . . #
# I . . . . . . . I . I . I # . . . # . . #
# . . . . . . . . # . . . . . # . . . # . #
# I . . . . . . . I . I # I . . # . . I # #
# . . . . . . # . . . . . # . . . # . . . #
# I . I . . . . . I # I . I # . . . # I . #
# . . . . # . . . . . # . . . # . . . # . #
# I . I . . . . # I . I # I . I # . . I # #
# . . # . . . . . # . . . # . . . # . . . #
# I . I . I # . . I # I . I # I . . # I . #
# # . . . . . # . . . # . . . # . . . # . #
# I . I # I . . # I . I # I . I # I . I # #
# . . . . # . . . # . . . # . . . # . . . #
# IS # I . I # I . I # I . I # I . I # I . #
# # # # # # # # # # # # # # # # # # # # # #
```
#### Example final form
```
# # # # # # # # # # # # # # # # # # # # # #
# . . . . . . . . . . . . . . . . # . . e #
# . . . . . . . . . . . . . . . . . . I # #
# . . . . . . . . . . . . . . # . . . . . #
# . . . . . . . . . . . . . . . . I # I . #
# . . . . . . . . . . . . # . . . . . # . #
# . . . . . . . . . . . . . . I # I . I # #
# . . . . . . . . . . # . . . . . # . . . #
# . . . . . . . . . . . . I # I . I # I . #
# . . . . . . . . # . . . . . # . . . # . #
# . . . . . . . . . . I # I . I # I . I # #
# . . . . . . # . . . . . # . . . # . . . #
# . . . . . . . . I # I . I # I . I # I . #
# . . . . # . . . . . # . . . # . . . # . #
# . . . . . . I # I . I # I . I # I . I # #
# . . # . . . . . # . . . # . . . # . . . #
# . . . . I # I . I # I . I # I . I # I . #
# # . . . . . # . . . # . . . # . . . # . #
# . . I # I . I # I . I # I . I # I . I # #
# . . . . # . . . # . . . # . . . # . . . #
# IS # I . I # I . I # I . I # I . I # I . #
# # # # # # # # # # # # # # # # # # # # # #
```
