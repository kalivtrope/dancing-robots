local Cell = require("interpreter.cell")

local function shuffle(seq)
  for i=#seq,2,-1 do
    local j = math.random(i)
    seq[i], seq[j] = seq[j], seq[i]
  end
end

local function generate_permutation(n)
  local out = {}
  for i=1,n do
    out[i] = i
  end
  shuffle(out)
  return out
end

local function is_sorted(seq)
  -- assumes ascending numerical ordering
  for i=2,#seq do
    if seq[i] < seq[i-1] then return false end
  end
  return true
end

local function fill_column(grid, column_no, num_objs, column_height)
  for i=1,num_objs do
    grid[2*column_no][column_height - 2*i + 1]:add_item()
  end
end


local function fill_diagonal_from_pos(grid, start_x, start_y, lim_x, lim_y)
  while start_x <= lim_x and start_y <= lim_y do
    grid[start_x][start_y]:add_wall()
    start_x = start_x + 1
    start_y = start_y + 1
  end
end

local function to_string(grid, width, height)
  local res = ""
  for y=1,height do
    local row = ""
    for x=1,width do
      if x > 1 then row = row .. " " end
      row = row .. tostring(grid[x][y])
    end
    res = res .. row .. "\n"
  end
  return res
end

local function generate(n, perm, seed)
  if not n or n < 2 then return nil end
  -- n >= 2: length of the input permutation
    -- the resulting grid will have dimensions (2n+2)x(2n+2)
  local total_n = 2*n+2
  seed = seed or 42
  math.randomseed(seed)
  if not perm then
  repeat
    perm = generate_permutation(n)
  until not is_sorted(perm)
  end
  local grid = {}
  for x=1,total_n do
    grid[x] = {}
    for y=1,total_n do
      grid[x][y] = Cell:new({x=x, y=y})
      if x == 1 or x == total_n or y == 1 or y == total_n then
        grid[x][y]:add_wall()
      end
    end
  end
  for i=1,n do
    fill_column(grid, i, perm[i], total_n)
    if i < n then
      grid[2*i][total_n - 2*i - 2]:add_wall()
    end
    fill_diagonal_from_pos(grid, 2*i+1, total_n-2*i+1, total_n-1, total_n-1)
  end
  ---[[
  local start_x_end_y, start_y_end_x = 2, total_n-1
  grid[start_x_end_y][start_y_end_x]:add_start()
  grid[start_y_end_x][start_x_end_y]:add_end()
  --]]
  return "sortp\n" .. total_n .. " " .. total_n .. "\n" .. to_string(grid, total_n, total_n)
end

--[[ Example usage:
local seed = nil --or os.time()
io.write(generate(8,nil,seed))
--io.write(seed, "\n")
--]]

return generate
