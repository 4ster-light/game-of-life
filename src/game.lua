local Constants = require("constants")
local Grid = require("grid")

local Game = {}
Game.__index = Game

function Game.new()
  return setmetatable({
    grid = nil,
    cell_alpha = {},
    rows = Constants.DEFAULT_ROWS,
    cols = Constants.DEFAULT_COLS,
    generations = 0,
    state = Constants.GameState.Menu,
    offset_x = (Constants.SCREEN_WIDTH - Constants.DEFAULT_COLS * Constants.CELL_SIZE) / 2,
    offset_y = (Constants.SCREEN_HEIGHT - Constants.DEFAULT_ROWS * Constants.CELL_SIZE) / 2,
    zoom = 1.0,
    last_update_time = 0,
    update_interval = Constants.UPDATE_INTERVAL,
    cell_color = Constants.DEFAULT_COLORS[1],
    bg_color = { 0.05, 0.05, 0.1 },
    grid_color = { 0.3, 0.3, 0.3 },
    color_palette = Constants.DEFAULT_COLORS,
    selected_palette = 1,
    selected_grid_size = 2,
    grid_size_changed = false,
    new_rows = Constants.DEFAULT_ROWS,
    new_cols = Constants.DEFAULT_COLS,
    button_scale = {},
    space_pressed = false,
    escape_pressed = false,
    r_pressed = false,
    c_pressed = false,
    mouse_pressed = false
  }, Game)
end

---@param rows number
---@param cols number
function Game:initialize_grid(rows, cols)
  self.rows = rows
  self.cols = cols
  self.grid, self.cell_alpha = Grid.new(rows, cols)
  self.generations = 0
  self.offset_x = (Constants.SCREEN_WIDTH - cols * Constants.CELL_SIZE * self.zoom) / 2
  self.offset_y = (Constants.SCREEN_HEIGHT - rows * Constants.CELL_SIZE * self.zoom) / 2
end

---@param dt number
function Game:update(dt)
  for i = 1, self.rows do
    for j = 1, self.cols do
      local target = self.grid.grid[i][j].alive and 1 or 0
      self.cell_alpha[i][j] = self.cell_alpha[i][j] + (target - self.cell_alpha[i][j]) * dt * 5
    end
  end

  for _, scale in pairs(self.button_scale) do
    local target = scale.target or 1
    local delta = target - scale.value
    scale.value = scale.value + delta * dt * 10
    if math.abs(delta) > 0.01 then
      scale.value = scale.value + delta * dt * 3 * (1 - math.abs(delta))
    end
  end

  if self.state == Constants.GameState.Playing then
    self.last_update_time = self.last_update_time + dt
    if self.last_update_time >= self.update_interval then
      self.grid:next_generation(self.cell_alpha)
      self.last_update_time = 0
      self.generations = self.generations + 1
    end
  end
end

return Game
