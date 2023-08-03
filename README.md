# Dancing robots (AKA generická KSP úložka na bludiště++)
## Current usage
### How to set this* up for Outfox
- make sure your shell is in the root of the working tree in this repository
```sh
mkdir -p ~/.project-outfox/Themes/
ln -sr eralk ~/.project-outfox/Themes/eralk
```
- * TODO explain what `this` refers to
### So how would users play this?
- TODO: `make userEnv` should prepare a folder `ERALK` with everything that's needed
- we give them a copy of `main.lua` along with (execute-only binaries of) the interpreter and judges to help debug on
- they also receive the `problemset` folder containing problem statements, sample inputs, sample outputs and sample command lists
- they can either just play around with (possibly big) static inputs or they can create a solver for arbitrary inputs (which is worth double the already gained points for static data inputs!)
  - the solver will be tested against randomly generated inputs with validity of 5 minutes (the Odevzdavatko way)
  - the implementation of this is TBD
- static inputs are stored in `Inputs` and in case of corruption can be regenerated anytime from the binary `input_generator` (TODO: this program "just" calls the appropriate generators and seeds them with the same values every time)
  - the theme uses this binary to get appropriate inputs so users wouldn't have a chance to alter them
- each problem input follows a convention `p-m.in`
  - `p` is a problem type (e.g. `sortp`, `matrix`)
  - `m` is an integer denoting input number
- users are expected to provide `p-m.out` for static data inputs
  - they store it in the `Outputs` folder, which is symlinked to a theme directory so they can dance right away
- the solver program is expected to read from STDIN and write all resultant commands to STDOUT

### The `main.lua` file
`lua ./main.lua <path to maze configuration> <path to robot commands>`
- maze configuration files are usually named `*.in`
- robot command files are usually named `*.out`
  - they are meant to be the output files from solvers
- you can find these files in `problemset/<problem codename>/`
- example: `lua main.lua problemset/sortp/example_n5.in problemset/sortp/example_n5.out`
## Problem statement
### Lore
- Eralk is a descendant of the Great [Hrochobot](https://ksp.mff.cuni.cz/sksp/2006J/hrochobot/)
    - (his mother's origins are unknown)
- he does't know how to count (not even to one), but he does have obstacle and item sensors on him which help him move around the environment
  - (so he actually does count (on his sensors))
- Eralk's purpose is to be placed in a maze, move a couple of items around and then head back to the end without destroying himself

### Internal coordinate representation
- when seeing certain errors, you will encounter the coordinates in this format unless stated otherwise (e.g. the game reports an error specifying a graph edge)
- the game uses the `(y,x)` (also referred to as `(row,col)`) coordinate system with its origin being at the top-left corner of the grid
  - the x-coordinate increases by going right (east), the y-coordinate increases by going down (south)
  - beware, the origin is actually at `(1,1)` (that's because lua arrays are designed as 1-indexed 😎)
Example (padded with extra spaces for clarity)
```
row/col 1  2  3 4 5 6   7   8
   1    #  #  # # # #   #   #
   2    #  .  . # . .   E   #
   3    #  .  . I . .   #   #
   4    #  #  . . . .   .   #
   5    #  .  . I # I (5,7) #
   6    #  .  . . . #   .   #
   7    #  IS # I . I   #   #
   8    #  #  # # # #   #   #
```
### Orientation
- there are 4 directions, one of which the robot will be facing: `North, East, South, West`
- moving `North` decreases the `y` (`row`) coordinate of the robot
- moving `East` increases the `x` (`col`) coordinate of the robot
- moving `South` increases the `y` (`row`) coordinate of the robot
- moving `West` decreases the `x` (`col`) coordinate of the robot
- Eralk's default orientation is to `North`
### Robot commands
- in the following examples, Eralk is marked as one of `nesw` denoting his orientation in the grid
- start and end cells are omitted for better alignment and readability
- `TURN_LEFT`
  - formally, this command changes the robot's orientation like this (the format is `Old orientation -> New orientation`): `North -> West, West -> South, South -> East, East -> North`
```
# # # #                # # # #                # # # #                # # # #                # # # #
# n . #                # w . #                # s . #                # e . #                # n . #
# . . # -> TURNLEFT -> # . . # -> TURNLEFT -> # . . # -> TURNLEFT -> # . . # -> TURNLEFT -> # . . #
# . . #                # . . #                # . . #                # . . #                # . . #
# # # #                # # # #                # # # #                # # # #                # # # #
```
- `TURN_RIGHT`
  - inverse operation to the `TURN_LEFT` command
- `COLLECT`
  - this command makes Eralk collect ONE item at the current position and adds it to Eralk's inventory
  - if there's no item to be collected, this command functions as a `NOP` except that you get a warning in stderr (which you can safely ignore if you don't care)
- `DROP`
  - Eralk drops ONE item at the current position from his inventory
  - if Eralk's inventory is empty, this command functions as a `NOP` except that you get a warning in stderr (which you can safely ignore if you don't care)
- `MOVE_TO_ITEM`
 - if there's a wall somewhere between Eralk and the closest item in his direction, this command functions as `MOVE_TO_WALL`
  - otherwise Eralk makes at least one step in the direction of his current orientation and stops at the closest item detected underneath him
```
# #  # # # # #                  # # #  # # # #
# .  I . . . #                  # . I  . . . #
# # Ie I I # # -> MOVETOITEM -> # # I Ie I # #
# .  . . . . #                  # . .  . . . #
# #  # # # # #                  # # #  # # # #
```
```
# # # # #                  # # # # #
# . # . #                  # . # . #
# . . . #                  # . n . #
# . . . # -> MOVETOITEM -> # . . . # (acts as MOVETOWALL)
# . . . #                  # . . . #
# . n . #                  # . . . #
# # # # #                  # # # # #
```

```
# # # # #                  # # # # #
# . I . #                  # . I . #
# . I . #                  # . I . #
# . # . # -> MOVETOITEM -> # . # . # (acts as MOVETOWALL)
# . . . #                  # . n . #
# . n . #                  # . . . #
# # # # #                  # # # # #
```

- `MOVE_TO_WALL`
  - move in the current direction until there's a wall one step away from Eralk
  - in this command Eralk makes ZERO or more steps (that is, he may not need to move at all if standing in front of a wall already)
- `MOVE_TO_START`
  - makes Eralk move in the current direction until he's standing at a cell marked as start `S`
  - if there's no start in the current direction, this command functions as `MOVE_TO_WALL`
  - in this command Eralk makes ZERO or more steps (that is, he may not need to move at all if standing on start already)
- `MOVE_TO_END`
  - makes Eralk move in the current direction until he's standing at a cell marked as end `E`
  - if there's no start in the current direction, this command functions as `MOVE_TO_WALL`
  - in this command Eralk makes ZERO or more steps (that is, he may not need to move at all if standing on end already)
- `NOP`
  - it does absolutely nothing lol
### Input file description
- the first line in the file contains a lowercase single-word string determining the game type
  - currently one of (`sortp`, `matrix`)
- on the next line follow two space-separated positive integers `h w` denoting the height and the width of the grid, respectively
- next follow `h` lines, each containing precisely `w` space separated cell type descriptions
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
### Cell types
- a cell can be one or more of:
  - empty (denoted by the char `.`)
  - non-empty:
    - item (denoted by the char `I`)
      - items don't have any internal identifiers, they are indistinguishable from one another
    - start (`S`)
    - end (`E`)
    - wall (`#`)
- cell types may be combined (e.g. you may encounter `SEI` meaning there's start, end and an item on this cell), however you will never contain a cell that is described nboth as empty and non-empty at the same time (e.g. `.I` is a forbidden cell description)
- there may be multiple items at a single cell (e.g. `EIIIIS`), but there will never be more than one start, end, wall or empty
- there is always precisely one start and one end
- each cell either is a wall or has wall neighbours in all 4 directions
- cell type order is arbitrary

### Output file format
- sequence of commands that the robot shall execute in the order given in this file
- there is no size limit (yet)
- the parser is pretty chill about the user input
- commands are read in a case-insensitive way, you can even put dashes or underscores inside them if you feel like it
  - e.g. all `MOVETOWALL`, `movetowall`, `move-to-wall` or `moveToWall` are recognized as the same command
- other non-letter characters (that is, besides `-` and `_`) are treated as command separators

## What to test for
### All errorneous states are reported and explained via assertions
  - the game tries its best to not crash, but if it encounters a nonsensical situation (e.g. unparsable input), it must throw an error for someone is not playing according to the rules
  - if a program's output throws an error without saying `assertion failed`, please report it to me with the traceback along with any relevant files or commands
### All instructions are executed properly
  - you can try stepping on an empty cell, then `movingtoitem`, picking it up, `movingto another item`, dropping it, ...
  - the reason I want to test this is because the game *tries* to be smart about moving to adjacent items from empty cells (see `intepreter/game.lua` and `data_structures/fenwick-tree.lua` for more details)
### All problems are solvable
  - there's currently 2 types of problems to solve
  - you can test both the generator and the judge, too
  - in all of the problems stated below, it is assumed that the robot is starting at cell marked as `S` facing north
  - the robot must always eventually reach the end (and stay there) in order for the commands to be considered valid
#### Sort a permutation (`sortp`)
- let `n` be a positive integer
- let `p: {1..n} -> {1..n}` be a permutation (bijective function with the same domain and range - `{1..n}`)
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
- Eralk's task is to rearrange the items so that the grid represents a sequnce `1,2,...,n`
- see `problemset/sortp/*.out` to see how these configurations may be achieved
##### Example input (n=4,p=(1,3,4,2)) (problemset/sortp/example_n4.in)
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
##### Example final form
```
# # # # # # # #
# . . # . . e #
# . . . . I # #
# # . . . . . #
# . . I # I . #
# . . . . # . #
# IS # I . I # #
# # # # # # # #
```
##### Example input (n=5,p=(1,3,5,4,2)) (problemset/sortp/example_n5.in)
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
##### Example final form
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
##### Example input (n=10,p=(8,5,3,1,9,7,10,4,2,6))
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
##### Example final form
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
#### Find shortest path in graph given its adjacency matrix (`matrix`)
- let `n >= 3` be a positive integer
- let there be an undirected unweighted graph `G=({1..n},E)`
  - every vertex of the graph contains a self-loop
- the problem is encoded in the grid as follows:
  - the grid has a square shape of `(n+2)x(n+2)` cells
  - there are solid walls on all of its 4 borders (so there is a solid left,right,bottom,top wall line)
  - the top-left-most non-wall cell is at row 1, column 1
  - column number increases by moving east, row number increases by moving south
  - there is an edge `e=(u,v)` in `E` if and only if there is an item at row `u`, column `v`
    - since the graph is undirected, there also exists an edge `e'=(v,u)` opposite to the edge `e`
- both start and end are placed in the same position `(row, column): (r,s)`
- your task is to find the shortest path from node `r` to node `s`
  - the length of the shortest path is guaranteed to be at least 2 edges
  - if there's multiple shortest paths, you may choose to output any (still, you must output only ONE shortest path)
- if the shortest path has length of `k` edges and is consisted of oriented edges with`(v1,v2),(v2,v3),...,(v{k}, v{k+1})`, then the robot shall collect items at positions `(v1,v2),...,(v{k},v{k+1})` and drop them all at position `(r, s)`
- in the end, the only collected or moved items shall be the ones representing the shortest path
##### Example input (n=4)
```
matrix
6 6
# # # # # #
# I I . SE #
# I I I I #
# . I I I #
# . I I I #
# # # # # #
```
##### Example final form
```
# # # # # #
# I . . ESII #
# I I I . #
# . I I I #
# . I I I #
# # # # # #
```

## Implementing your own solver
- a solver is meant to be implemented for just a single problem type
- just write any program that reads a valid input file from stdin and outputs a valid and acceptable output file to stdout
## Generating a new input file
- generators are files matching the pattern `problemset/<problem codename>/generator.lua`
- current way of generating a new input involves doing the following:
  - changing the `--[[ Example usage:` line to `---[[ Example usage:` in the generator
  - setting the arguments to the `generate` call in the generator file accordingly
  - running the generator from the project's root as `lua problemset/<problem codename>/generator.lua`
