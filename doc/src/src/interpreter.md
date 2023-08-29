# Interpreter

Let's start with the interpreter module.
It contains a bunch of inter-dependent submodules that are utilized by THE interpreter (`interpreter.intepreter`)

## List of structures/classes
### `Cell`
The module `cell.lua` defines a structure for a single maze cell. Used in a `Maze`.

### `Maze`
A container in `maze.lua` which stores a 2d array of cells while keeping track of its size, start and end cells and current items.
Most notably depends on `data_structures.fenwick-tree`.

### Enums
Various enums related to the interpreter are stored in `enums.lua`.
There's enums defining tokens, cell types, directions and recognized game types.

### Utils
Various helper methods for writing debug information and asserting conditions are stored in `utils.lua`.

### `RobotState`
A simple structure containing robot's current row, column, orientation and inventory status. Used in a `Game`.

### `Game`
Combines a `Maze` with a `RobotState`. Issues in-game warnings if turned on. It's possible to create one from an input file.

### `Interpreter`
Contains a `Game` and a list of `Tokens` to parse.
Takes care of interpreting instructions, maintaining the instruction pointer and letting others know when it's processed all instructions.
Reports parsing-related warnings (if preference set).
