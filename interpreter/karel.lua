local Game = require("game")

local filename = ... or arg[1]
local file = filename and assert(io.open(filename, "r")) or io.stdin
local game_type_str = file:read("*line")
local game_height, game_width = file:read("*n", "*n")
local game_maze_str = file:read("*all")
curr_game = Game:new({height = game_height, width = game_width, type_str = game_type_str, maze_str = game_maze_str})
