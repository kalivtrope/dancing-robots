# Overview of directory structure

Let's go through the project directory structure from the root up:
```
> tree -L 1
.
├── data_structures -> eralk/BGAnimations/_modules/data_structures
├── doc
├── eralk
├── Examples
├── generators
├── Inputs -> eralk/BGAnimations/_gamedata/Inputs
├── interpreter -> eralk/BGAnimations/_modules/interpreter
├── judges -> eralk/BGAnimations/_modules/judges
├── main.lua
├── Outputs -> eralk/BGAnimations/_gamedata/Outputs
├── README.md
└── solvers
```

## The reason for symlinks
Right off the beginning, you will notice that I've symlinked a bunch of directories.
This is because Project OutFox only runs scripts contained in the theme directory.
Since I need `interpreter` and `judges` (and their dependence `data_structures`) modules to be both functioning
in the CLI and the engine, I chose to move them to the OutFox theme directory and symlink them from there.
Similar thing with `Inputs` and `Outputs`. I'm not symlinking what doesn't need to be linked.
