# Defining new problems
- defining a new problem consists of (writing the problem statement), creating a generator and a judge
- in the following text we're going to assume the new problem class you want to create is called `<problem-class>`

## Implementing a generator
- first off, create a new directory `<problem-class>` in `generators/`
- in there, you may create and link as many files as you have, but you need to have a `main.lua` file that ties them all together
- all generators should inherit from the common Generator class which provides a few methods for modifying and printing the maze
### Basic outline for a generator
```lua
-- assuming we're in generators/<problem-class>/main.lua
-- let's instantiate the Generator class first
local ProblemClassGenerator = = require("generators.common"):new()
function ProblemClassGenerator.generate(params)
  -- fetch the arguments from the params table here ...
  local gen = ProblemClassGenerator:new()
  gen:init("<problem-class", height, width)
  gen:add_borders()
  -- more logic to follow here ...
  -- Example usage:
  gen.grid[start_row][start_col]:add_start()
  gen.grid[end_row][end_col]:add_end()
  if i % 5 == 0 then
    gen.grid[5][5]:add_item()
  end
  -- always call this method at the end of the generate function
  -- to get a textual representation of your just-generated maze
  return tostring(gen)
end

return ProblemClassGenerator
```
### Testing a generator
- once ready, you may test your generator via the `./main.lua` program
  - this little router allows for arbitrary string passing to a generator's `params` via the command-line arguments
#### Example
- the following command passes the arguments `"n"="10","m"="50","hello"="world"` to your generator's `params`
- it then stores the generated output to `Inputs/problem-class-instance_n10.in`
```
./main.lua generate <problem-class> problem-class-instance_n10 n 10 m 50 hello world
```

## Creating a judge
- your judge code should reside in the `judges/<problem-class>` directory
- same case as with generators, put your "main" code in `judges/<problem-class>/main.lua`
- all judges should inherit from the common Judge class
### Basic outline for a judge
```lua
local ProblemClassJudge = require("judges.common"):new()
-- you may choose to overload the base class methods make_judgment or judge_next_command
-- this method is for evaluating the grid once all instructions have been executed
-- see judges/common.lua for a list of available methods (mainly the tests)
function ProblemClassJudge:make_judgment()
  self:add_judgment(self:test_if_robot_is_at_end())
  self:add_judgment(self:test_if_everything_collected())
  self.judgment_received = true
end

-- this other method is for continuous tracking of robot behaviour (you may use it to collect stats as well)
function ProblemClassJudge:judge_next_command(randomize)
  collect_stats()
  return Judge.judge_next_command(self, randomize) -- fallback to base class method
end

return ProblemClassJudge
```
## Implementing your own solver (optional but highly recommended)
- a solver is meant to be implemented for just a single problem type
- just write any program that reads a valid input file from stdin and outputs a valid and acceptable output file to stdout
- see the `solvers` directory for more examples
- once finished, add your solvers to the appropriate folder
- a quick-and-dirty script may be enough (think about the maintainability though), no objects necessarily needed
- here's a snippet of parsing the input and storing the maze data in lua:
```lua
local type_str = io.read("*line")
assert(type_str == "<problem-class>", string.format("wrong game type (expected '<problem-class>', got '%s')", type_str))
local h, w = io.read("*n", "*n", "*l") -- eat the newline by requesting to read a line

local row = 1
local maze = {}
for line in (io.read("*all") .. "\n"):gmatch('(.-)\r?\n') do
  maze[row] = maze[row] or {}
  local col = 1
  for cell in line:gmatch("[#ISE%.]+") do
    maze[row][col] = maze[row][col] or {}
    for obj_type in cell:gmatch(".") do
      -- this stores the literal representation of a cell type, you might want to consider processing it in a different way
      maze[row][col][#maze[row][col]+1] = obj_type
    end
    col = col+1
  end
  row = row+1
end
```
### Current usage of solvers
- the players aren't meant to see the `solvers` folder
- for generating example outputs call this command
```
lua solvers/<problem-class>/main.lua < Inputs/<instance>.in > Outputs/<instance>.out
```
