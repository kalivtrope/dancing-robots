# How to program
This guide covers input and output type format, as well as available commands.
If you wish to solve a problem instance named `Inputs/<problem-instance>.in`, you are expected to put your solution in a file named `Outputs/<problem-instance>.out`.

## Internal coordinate representation
- when seeing certain messages, you will encounter the coordinates in this format unless stated otherwise (e.g. the game reports an error specifying a graph edge)
- the game uses the `(y,x)` (also referred to as `(row,col)`) coordinate system with its origin being at the top-left corner of the grid
  - the x-coordinate increases by going right (east), the y-coordinate increases by going down (south)
  - beware, the top-left corner is actually at `(1,1)` (that's because lua arrays are designed as 1-indexed 😎)
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
## Orientation
- there are 4 directions, one of which the robot will be facing: `North, East, South, West`
- moving `North` decreases the `y` (`row`) coordinate of the robot
- moving `East` increases the `x` (`col`) coordinate of the robot
- moving `South` increases the `y` (`row`) coordinate of the robot
- moving `West` decreases the `x` (`col`) coordinate of the robot
- Eralk's default orientation is to `North`
## Robot commands
- in the following examples, Eralk is marked as one of `nesw` denoting his orientation in the maze
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
### Input file (problem instance) description
- the first line in the file contains a lowercase single-word string determining the game type (=problem class)
- on the next line follow two space-separated positive integers `h w` denoting the height and the width of the grid, respectively, measured in cells
- next follow `h` lines, each containing precisely `w` space-separated cell type descriptions
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
## Cell types
- a cell can be one or more of:
  - empty (denoted by the char `.`)
  - non-empty:
    - item (denoted by the char `I`)
      - items don't have any internal identifiers, they are indistinguishable from one another
    - start (`S`)
    - end (`E`)
    - wall (`#`)
- cell types may be combined (e.g. you may encounter `SEI` meaning there's start, end and a single item on this cell), however you will never encounter a cell that is described nboth as empty and non-empty at the same time (e.g. `.I` is a forbidden cell description)
- there may be multiple items at a single cell (e.g. `EIIIIS`), but there will never be more than one start, end, wall or empty
- there is always precisely one start and one end
- each cell either is a wall or has wall neighbours in all 4 directions
- cell type order is arbitrary

## Output file format
- sequence of commands that the robot shall execute in the order given in this file
- there is no size limit (yet)
- the parser is pretty chill about the user input
- commands are read in a case-insensitive way, you can even put dashes or underscores inside them if you feel like it
  - e.g. all `MOVETOWALL`, `movetowall`, `move-to-wall` or `moveToWall` are recognized as the same command
- other non-letter characters (that is, besides `-` and `_`) are treated as command separators
