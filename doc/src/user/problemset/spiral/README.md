# spiral

Your goal is to traverse a spiral from one of the maze corners to its center.
There are no items to collect this time.

## Problem statement
### Maze format
- let `n` be a positive integer
- you are given a `(4n+2)x(4n+1)` grid
  - there are solid walls on all of its 4 borders (so there is a solid left,right,bottom,top wall line)
- the origin `(1,1)` is located at the top left corner of the maze (the intersection of the top and left border)
- the robot starts at the top-right-most empty cell (position `(2,4n)`)
- right underneath the robot, there starts a spiral that whirls towards the center and makes a left turn two blocks before a wall
### Objective
- just get to the end by any means
## Examples
You may find all of the inputs and outputs in the `Examples/spiral` directory.
See the robot's progress while solving these problems by e.g. running
```
./main.lua test -p Examples/spiral/spiral_n1.in Examples/spiral/spiral_n1.out
```
or just
```
./main.lua test -p Examples/spiral/spiral_n2.{in,out}
```
if your shell supports it.
### Example 1
#### Example input (n=1) (Examples/spiral/spiral_n1.in)
```
spiral
6 5
# # # # #
# . . S #
# . # # #
# . # E #
# . . . #
# # # # #
```
#### Example final form
```
# # # # #
# . . S #
# . # # #
# . # n #
# . . . #
# # # # #
```
#### Example output (Examples/spiral/spiral_n1.out)
```
turnleft
movetowall
turnleft
movetowall
turnleft
movetowall
turnleft
movetowall
```
### Example 2
#### Example input (n=4) (Examples/spiral/spiral_n4.in)
```
spiral
18 17
# # # # # # # # # # # # # # # # #
# . . . . . . . . . . . . . . S #
# . # # # # # # # # # # # # # # #
# . # . . . . . . . . . . . . . #
# . # . # # # # # # # # # # # . #
# . # . # . . . . . . . . . # . #
# . # . # . # # # # # # # . # . #
# . # . # . # . . . . . # . # . #
# . # . # . # . # # # . # . # . #
# . # . # . # . # E # . # . # . #
# . # . # . # . . . # . # . # . #
# . # . # . # # # # # . # . # . #
# . # . # . . . . . . . # . # . #
# . # . # # # # # # # # # . # . #
# . # . . . . . . . . . . . # . #
# . # # # # # # # # # # # # # . #
# . . . . . . . . . . . . . . . #
# # # # # # # # # # # # # # # # #
```
#### Example final form
```
# # # # # # # # # # # # # # # # #
# . . . . . . . . . . . . . . S #
# . # # # # # # # # # # # # # # #
# . # . . . . . . . . . . . . . #
# . # . # # # # # # # # # # # . #
# . # . # . . . . . . . . . # . #
# . # . # . # # # # # # # . # . #
# . # . # . # . . . . . # . # . #
# . # . # . # . # # # . # . # . #
# . # . # . # . # nE # . # . # . #
# . # . # . # . . . # . # . # . #
# . # . # . # # # # # . # . # . #
# . # . # . . . . . . . # . # . #
# . # . # # # # # # # # # . # . #
# . # . . . . . . . . . . . # . #
# . # # # # # # # # # # # # # . #
# . . . . . . . . . . . . . . . #
# # # # # # # # # # # # # # # # #
```
