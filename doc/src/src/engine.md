# Engine controller
Main code for the engine controller resides in `eralk/BGAnimations/_modules/engine/`.

## `constants`
A bunch of named magic values that you can tweak to your liking is stored in `constants.lua`.

## `dancefloor`
The main drawing class (also called Actor). Implemented as a polygon (ActorMultiVertex) of Quads with vertices referencing texture coordinates.
Owns a direct reference to the current game state (data stored in the `Game` structure - the `Maze` and `RobotState`) to save bandwidth. Communicates with a `judge-wrapper`.

## `judge-wrapper`
The wrapper around the current judge. Updates the game state (represented by an array of Drawables in this case)
while telling `dancefloor` what part of the maze should be (re)drawn.


## `debug`
A bunch of debugging utilities. Can be turned off via a flag.

## `enums`
Enums relevant to the engine function are defined here. Contains a list of sprites, extended direction and utilities to manipulate them.
### `Drawable`
An enum representing either a [cell type](../user/how_to_program.md#cell-types) or a shadow, sometimes also describing the object's orientation or count (in case of items).
Examples: `Drawable.robot_south, Drawable.item2, Drawable.start, Drawable.wall`.


## `instruction-dispatcher`
This module is in charge of processing hit and missed notes. It then decides whether the next group of instructions should be executed correctly or nah.

## `judgment-emitter`
The sole purpose of this module is to parse hit and missed notes from a Judgment Message and then tell `instruction-dispatcher` how many hits and misses had each player just scored.

## `recognized-types`
Helper module for abstracting work with notes and judgments. Used by `judgment-emitter`.
