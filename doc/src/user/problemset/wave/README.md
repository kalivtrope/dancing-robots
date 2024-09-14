# wave

Eralk is stuck at the epicenter of a wave.
Help him to get out while collecting all items along the way!

## Problem statement
### Maze format
- let `n` be a positive integer
- you are given a `(4n+7)x(4n+7)` grid
  - there are solid walls on all of its 4 borders (so there is a solid left,right,bottom,top wall line)
- the origin `(1,1)` is located at the top left corner of the maze (the intersection of the top and left border)
- there are `n+1` concentric octagon-shaped borders ("waves"), each with a single hole in it
  - we can refer to the octagon's sides by their orientation (north,...,west,norteast,...,southwest)
  - before each hole there is *always* a single item to hold on to
  - `k`-th octagon has each side composed of `2k-1` walls
  - the hole is always in the middle of a (north,east,south,west) side
  - there's a hole on the north side of the first octagon, for each subsequent octagon a hole's position shifts 90 degrees clockwise
    - more formally:
    - for each valid `l`, there's a hole on the north side of the `(4l-3)`rd octagon
    - for each valid `l`, there's a hole on the east side of the `(4l-2)`nd octagon
    - for each valid `l`, there's a hole on the south side of the `(4l-1)`st octagon
    - for each valid `l`, there's a hole on the west side of the `(4l)`th octagon
- start is at the center of the maze (the position `(2n+4,2n+4)`)
- end is located at the hole of the last (`(n+1)`st) octagon
### Objective
- your goal is to collect all items and drop them off at the end
## Examples
You may find all of the inputs and outputs in the `Examples/wave` directory.
See the robot's progress while solving these problems by e.g. running
```
./main.lua test -p Examples/wave/wave_n2.in Examples/wave/wave_n2.out
```
or just
```
./main.lua test -p Examples/wave/wave_n2.{in,out}
```
if your shell supports it.
### Example 1
#### Example input (n=2) (Examples/wave/wave_n2.in)
```
wave
15 15
# # # # # # # # # # # # # # #
# . . . . # # # # # . . . . #
# . . . # . . . . . # . . . #
# . . # . . # # # . . # . . #
# . # . . # . . . # . . # . #
# # . . # . . . . . # . . # #
# # . # . . # I # . . # . # #
# # . # . # . S . # I . . # #
# # . # . . # . # . . # . # #
# # . . # . . # . . # . . # #
# . # . . # . . . # . . # . #
# . . # . . # # # . . # . . #
# . . . # . . I . . # . . . #
# . . . . # # E # # . . . . #
# # # # # # # # # # # # # # #
```
#### Example final form
```
# # # # # # # # # # # # # # #
# . . . . # # # # # . . . . #
# . . . # . . . . . # . . . #
# . . # . . # # # . . # . . #
# . # . . # . . . # . . # . #
# # . . # . . . . . # . . # #
# # . # . . # . # . . # . # #
# # . # . # . S . # . . . # #
# # . # . . # . # . . # . # #
# # . . # . . # . . # . . # #
# . # . . # . . . # . . # . #
# . . # . . # # # . . # . . #
# . . . # . . . . . # . . . #
# . . . . # # sEIII # # . . . . #
# # # # # # # # # # # # # # #
```

### Example 2
#### Example input (n=6) (Examples/wave/wave_n6.in)
```
wave
31 31
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# . . . . . . . . # # # # # # # # # # # # # . . . . . . . . #
# . . . . . . . # . . . . . . . . . . . . . # . . . . . . . #
# . . . . . . # . . # # # # # # # # # # # . . # . . . . . . #
# . . . . . # . . # . . . . . . . . . . . # . . # . . . . . #
# . . . . # . . # . . # # # # . # # # # . . # . . # . . . . #
# . . . # . . # . . # . . . . I . . . . # . . # . . # . . . #
# . . # . . # . . # . . # # # # # # # . . # . . # . . # . . #
# . # . . # . . # . . # . . . . . . . # . . # . . # . . # . #
# # . . # . . # . . # . . # # # # # . . # . . # . . # . . # #
# # . # . . # . . # . . # . . . . . # . . # . . # . . # . # #
# # . # . # . . # . . # . . # # # . . # . . # . . # . # . # #
# # . # . # . # . . # . . # . . . # . . # . . # . # . # . # #
# # . # . # . # . # . . # . . . . . # . . # . # . # . # . # #
# # . # . # . # . # . # . . # I # . . # . # . # . # . # . # #
# # . # . # . . I # . # . # . S . # I . . # . # . # I . . # #
# # . # . # . # . # . # . . # . # . . # . # . # . # . # . # #
# # . # . # . # . # . . # . . # . . # . . # . # . # . # . # #
# # . # . # . # . . # . . # . . . # . . # . . # . # . # . # #
# # . # . # . . # . . # . . # # # . . # . . # . . # . # . # #
# # . # . . # . . # . . # . . I . . # . . # . . # . . # . # #
# # . . # . . # . . # . . # # . # # . . # . . # . . # . . # #
# . # . . # . . # . . # . . . . . . . # . . # . . # . . # . #
# . . # . . # . . # . . # # # # # # # . . # . . # . . # . . #
# . . . # . . # . . # . . . . . . . . . # . . # . . # . . . #
# . . . . # . . # . . # # # # # # # # # . . # . . # . . . . #
# . . . . . # . . # . . . . . . . . . . . # . . # . . . . . #
# . . . . . . # . . # # # # # # # # # # # . . # . . . . . . #
# . . . . . . . # . . . . . . I . . . . . . # . . . . . . . #
# . . . . . . . . # # # # # # E # # # # # # . . . . . . . . #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
```
#### Example final form
```
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# . . . . . . . . # # # # # # # # # # # # # . . . . . . . . #
# . . . . . . . # . . . . . . . . . . . . . # . . . . . . . #
# . . . . . . # . . # # # # # # # # # # # . . # . . . . . . #
# . . . . . # . . # . . . . . . . . . . . # . . # . . . . . #
# . . . . # . . # . . # # # # . # # # # . . # . . # . . . . #
# . . . # . . # . . # . . . . . . . . . # . . # . . # . . . #
# . . # . . # . . # . . # # # # # # # . . # . . # . . # . . #
# . # . . # . . # . . # . . . . . . . # . . # . . # . . # . #
# # . . # . . # . . # . . # # # # # . . # . . # . . # . . # #
# # . # . . # . . # . . # . . . . . # . . # . . # . . # . # #
# # . # . # . . # . . # . . # # # . . # . . # . . # . # . # #
# # . # . # . # . . # . . # . . . # . . # . . # . # . # . # #
# # . # . # . # . # . . # . . . . . # . . # . # . # . # . # #
# # . # . # . # . # . # . . # . # . . # . # . # . # . # . # #
# # . # . # . . . # . # . # . S . # . . . # . # . # . . . # #
# # . # . # . # . # . # . . # . # . . # . # . # . # . # . # #
# # . # . # . # . # . . # . . # . . # . . # . # . # . # . # #
# # . # . # . # . . # . . # . . . # . . # . . # . # . # . # #
# # . # . # . . # . . # . . # # # . . # . . # . . # . # . # #
# # . # . . # . . # . . # . . . . . # . . # . . # . . # . # #
# # . . # . . # . . # . . # # . # # . . # . . # . . # . . # #
# . # . . # . . # . . # . . . . . . . # . . # . . # . . # . #
# . . # . . # . . # . . # # # # # # # . . # . . # . . # . . #
# . . . # . . # . . # . . . . . . . . . # . . # . . # . . . #
# . . . . # . . # . . # # # # # # # # # . . # . . # . . . . #
# . . . . . # . . # . . . . . . . . . . . # . . # . . . . . #
# . . . . . . # . . # # # # # # # # # # # . . # . . . . . . #
# . . . . . . . # . . . . . . . . . . . . . # . . . . . . . #
# . . . . . . . . # # # # # # sEIIIIIII # # # # # # . . . . . . . . #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
```
