# How to play

Make sure you've got your environment set up before continuing.

## Programming gameplay
There are multiple problems that you may wish to solve in the game.

Each problem involves writing a sequence of commands to be executed by a robot named Eralk[^note_eralk].
Following these commands, Eralk should always traverse from a starting point to an end
point while additionally interacting with the game field (maze) as per the problem statement.

For each problem, you are provided a handful of static *inputs* that you may choose to solve.
You may also design a *solver* to tackle any valid input from the given problem class for extra points (this is to be tested in the "classic KSP" way: with time-constrained inputs).

## Dance gameplay
Once your command sequences (*outputs*) are ready, it's time to dance!

Just fire up an already-configured engine and select the problem instance code from a list before the chosen song start.
The commands from your output file will get mapped uniformly on the song notes.

If you hit *any* note associated with an instruction, the instruction gets executed.
There may be multiple notes associated with a single instructions and vice-versa.
You are guaranteed for each instruction to be associated with at least 3 notes.
If you fail to hit all notes associated with an instruction, a random instruction will be executed instead.

You may choose to play on any difficulty, single-player or multiplayer.

## `main.lua`
This script allows both for generating and testing problems.
If the script mentions *inputs* and *outputs*, by that it means the files located in the `Inputs` and `Output` folders
respectively (relative to the project repository root).

See `main.lua -h` for more information on its usage.

### Example usage
```sh
# generate a problem instance 'spiral_n4' while passing n=4 to the underlying generator
> ./main.lua generate spiral spiral_n4 n 4
# test a problem instance 'comb_n2' while both showing progress and showing warnings
> ./main.lua test comb_n2 -p -w
```

## Inputs
This is the folder used to store problem instance files.
It's also where the `main.lua generate` command stores the generated inputs.
There is currently no naming convention other than that the files must end with an `.in` extension (the `generate` command adds them automatically).

## Outputs
This is the folder used to store user data - outputs (command sequences).
There is currently no naming convention other than that the files must end with an `.out` extension.

**Important note:** a file named `Outputs/problem-instance.out` is expected to be solving a `Inputs/problem-instance.in`.

## Examples
Here you can find example inputs and outputs. You may copy them over to `Inputs/Outputs` in order to test them.

[^note_eralk] descendant of the Great [Hrochobot](https://ksp.mff.cuni.cz/sksp/2006J/hrochobot/)
