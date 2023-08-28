local SortpGenerator = require("generators.common"):new()

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
    grid[column_height - 2*i + 1][2*column_no]:add_item()
  end
end


local function fill_diagonal_from_pos(grid, start_x, start_y, lim_x, lim_y)
  while start_x <= lim_x and start_y <= lim_y do
    grid[start_y][start_x]:add_wall()
    start_x = start_x + 1
    start_y = start_y + 1
  end
end


function SortpGenerator.generate(params)
  local n = tonumber(params.n)
  if type(n) ~= "number" or n < 2 then n=10 end
  -- n >= 2: length of the input permutation
    -- the resulting grid will have dimensions (2n+2)x(2n+2)
  local total_n = 2*n+2
  local gen = SortpGenerator:new()
  gen:init("sortp", total_n, total_n)
  gen:add_borders()
  local seed = params.seed or 42
  math.randomseed(seed)
  local perm = params.perm
  if not perm then
  repeat
    perm = generate_permutation(n)
  until not is_sorted(perm)
  end
  for i=1,n do
    fill_column(gen.grid, i, perm[i], total_n)
    if i < n then
      gen.grid[total_n - 2*i - 2][2*i]:add_wall()
    end
    fill_diagonal_from_pos(gen.grid, 2*i+1, total_n-2*i+1, total_n-1, total_n-1)
  end
  ---[[
  local start_col_end_row, start_row_end_col = 2, total_n-1
  gen.grid[start_row_end_col][start_col_end_row]:add_start()
  gen.grid[start_col_end_row][start_row_end_col]:add_end()
  --]]
  return tostring(gen)
end

--[[ Example usage:
local seed = nil --or os.time()
io.write(SortpGenerator.generate({n=10, perm=nil, seed=seed}))
--io.write(seed, "\n")
--]]

return SortpGenerator
