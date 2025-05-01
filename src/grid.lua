---@alias Cell { alive: boolean }
---@alias CellAlpha { [number]: { [number]: number } }

---@class Grid
---@field grid Cell[][]
---@field next_grid Cell[][]
---@field rows number
---@field cols number
local Grid = {}
Grid.__index = Grid

---@param rows number
---@param cols number
---@return Grid, CellAlpha
function Grid.new(rows, cols)
  local self = setmetatable({
    grid = {},
    next_grid = {},
    rows = rows,
    cols = cols
  }, Grid)

  -- Initialize the grid and next_grid
  local cell_alpha = {}
  for i = 1, rows do
    self.grid[i] = {}
    self.next_grid[i] = {}
    cell_alpha[i] = {}
    for j = 1, cols do
      self.grid[i][j] = { alive = false }
      self.next_grid[i][j] = { alive = false }
      cell_alpha[i][j] = 0
    end
  end

  return self, cell_alpha
end

---@param cell_alpha CellAlpha
function Grid:clear(cell_alpha)
  for i = 1, self.rows do
    for j = 1, self.cols do
      self.grid[i][j].alive = false
      cell_alpha[i][j] = 0
    end
  end
end

---@param cell_alpha CellAlpha
function Grid:randomize(cell_alpha)
  for i = 1, self.rows do
    for j = 1, self.cols do
      self.grid[i][j].alive = math.random() > 0.85
      cell_alpha[i][j] = self.grid[i][j].alive and 1 or 0
    end
  end
end

---@param cell_alpha CellAlpha
---@param row number
---@param col number
function Grid:toggle_cell(cell_alpha, row, col)
  if row >= 1 and row <= self.rows and col >= 1 and col <= self.cols then
    self.grid[row][col].alive = not self.grid[row][col].alive
    cell_alpha[row][col] = self.grid[row][col].alive and 1 or 0
  end
end

---@param row number
---@param col number
---@return number
function Grid:count_cell_neighbors_at(row, col)
  local count = 0
  for i = -1, 1 do
    for j = -1, 1 do
      -- Skip the cell itself
      if i == 0 and j == 0 then goto continue end

      -- Check the bounds of the grid
      local r = row + i
      local c = col + j
      if r >= 1 and r <= self.rows and c >= 1 and c <= self.cols and self.grid[r][c].alive then
        count = count + 1
      end

      ::continue::
    end
  end

  return count
end

---@param cell_alpha CellAlpha
function Grid:next_generation(cell_alpha)
  -- Prepare the next generation grid
  for i = 1, self.rows do
    for j = 1, self.cols do
      local neighbors = self:count_cell_neighbors_at(i, j)
      self.next_grid[i][j].alive = neighbors == 3 or (self.grid[i][j].alive and neighbors == 2)
    end
  end

  -- Update the current grid and cell_alpha
  for i = 1, self.rows do
    for j = 1, self.cols do
      self.grid[i][j].alive = self.next_grid[i][j].alive
      cell_alpha[i][j] = self.grid[i][j].alive and 1 or 0
    end
  end
end

return Grid
