local Grid = {}
Grid.__index = Grid

function Grid.new(rows, cols, cellSize)
  local self = setmetatable({}, Grid)
  self.rows = rows
  self.cols = cols
  self.cellSize = cellSize
  self.cells = {}

  -- Initialize grid
  for y = 1, rows do
    self.cells[y] = {}
    for x = 1, cols do
      self.cells[y][x] = false
    end
  end

  return self
end

function Grid:isValidPosition(x, y)
  return x >= 1 and x <= self.cols and y >= 1 and y <= self.rows
end

function Grid:toggleCell(x, y)
  if self:isValidPosition(x, y) then
    self.cells[y][x] = not self.cells[y][x]
  end
end

function Grid:countNeighbors(x, y)
  local count = 0
  for dy = -1, 1 do
    for dx = -1, 1 do
      if dx ~= 0 or dy ~= 0 then
        local nx, ny = x + dx, y + dy
        -- Wrap around edges
        nx = (nx - 1) % self.cols + 1
        ny = (ny - 1) % self.rows + 1
        if self.cells[ny][nx] then
          count = count + 1
        end
      end
    end
  end
  return count
end

function Grid:update()
  local newCells = {}

  -- Initialize new grid
  for y = 1, self.rows do
    newCells[y] = {}
    for x = 1, self.cols do
      local neighbors = self:countNeighbors(x, y)
      local currentCell = self.cells[y][x]

      -- Apply Game of Life rules
      if currentCell then
        newCells[y][x] = neighbors == 2 or neighbors == 3
      else
        newCells[y][x] = neighbors == 3
      end
    end
  end

  -- Update cells
  self.cells = newCells
end

function Grid:draw(colors)
  -- Draw grid lines
  love.graphics.setColor(unpack(colors.grid))
  for x = 0, self.cols do
    love.graphics.line(x * self.cellSize, 0, x * self.cellSize, self.rows * self.cellSize)
  end
  for y = 0, self.rows do
    love.graphics.line(0, y * self.cellSize, self.cols * self.cellSize, y * self.cellSize)
  end

  -- Draw cells
  love.graphics.setColor(unpack(colors.cell))
  for y = 1, self.rows do
    for x = 1, self.cols do
      if self.cells[y][x] then
        love.graphics.rectangle(
          'fill',
          (x - 1) * self.cellSize,
          (y - 1) * self.cellSize,
          self.cellSize - 1,
          self.cellSize - 1,
          2 -- rounded corners
        )
      end
    end
  end
end

function Grid:randomize()
  for y = 1, self.rows do
    for x = 1, self.cols do
      self.cells[y][x] = love.math.random() > 0.85
    end
  end
end

function Grid:clear()
  for y = 1, self.rows do
    for x = 1, self.cols do
      self.cells[y][x] = false
    end
  end
end

return Grid
