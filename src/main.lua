local Grid = require("grid")
local UI = require("ui")

-- Lua compatibility
unpack = table.unpack or unpack

-- Game defaults
local game = {
  grid = nil,
  ui = nil,
  colors = {
    background = { 0.12, 0.12, 0.18, 1 }, -- Dark background
    cell = { 1.0, 0.6, 0.2, 1 },          -- Orange
    grid = { 0.27, 0.28, 0.35, 0.3 },     -- Subtle grid lines
    text = { 0.88, 0.88, 0.88, 1 },       -- Light text
    button = { 1.0, 0.6, 0.2, 1 }         -- Orange buttons
  },
  cellSize = 15,
  paused = true,
  speed = 0.1, -- Default update interval in seconds
  timer = 0
}

function love.load()
  -- Set window title
  love.window.setTitle("Game of Life")

  -- Enable antialiasing
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- Initialize UI first to get panel dimensions
  game.ui = UI.new(game)

  -- Calculate grid dimensions based on window size minus UI panel
  local availableWidth = love.graphics.getWidth() - game.ui.panelWidth
  local availableHeight = love.graphics.getHeight()

  -- Add padding
  local padding = 40
  availableWidth = availableWidth - (padding * 2)
  availableHeight = availableHeight - (padding * 2)

  -- Calculate grid dimensions
  local rows = math.floor(availableHeight / game.cellSize)
  local cols = math.floor(availableWidth / game.cellSize)

  -- Initialize grid
  game.grid = Grid.new(rows, cols, game.cellSize)
end

function love.update(dt)
  game.ui:update(dt)

  if not game.paused then
    game.timer = game.timer + dt
    if game.timer >= game.speed then
      game.timer = game.timer - game.speed
      game.grid:update()
    end
  end
end

function love.draw()
  -- Set background
  love.graphics.setBackgroundColor(unpack(game.colors.background))

  -- Calculate grid offset to center in available space
  local availableWidth = love.graphics.getWidth() - game.ui.panelWidth
  local offsetX = (availableWidth - game.grid.cols * game.cellSize) / 2
  local offsetY = (love.graphics.getHeight() - game.grid.rows * game.cellSize) / 2

  love.graphics.push()
  love.graphics.translate(offsetX, offsetY)

  game.grid:draw(game.colors)

  love.graphics.pop()

  -- Draw UI elements
  game.ui:draw()
end

function love.mousepressed(x, y, button)
  if button == 1 then
    -- Check UI interactions first
    if game.ui:click(x, y) then
      return
    end

    -- Calculate grid offset
    local availableWidth = love.graphics.getWidth() - game.ui.panelWidth
    local offsetX = (availableWidth - game.grid.cols * game.cellSize) / 2
    local offsetY = (love.graphics.getHeight() - game.grid.rows * game.cellSize) / 2

    -- Convert mouse coordinates to grid position
    local gridX = math.floor((x - offsetX) / game.cellSize) + 1
    local gridY = math.floor((y - offsetY) / game.cellSize) + 1

    -- Toggle cell if within grid bounds
    if game.grid:isValidPosition(gridX, gridY) then
      game.grid:toggleCell(gridX, gridY)
    end
  end
end

function love.keypressed(key)
  if key == "space" then
    game.paused = not game.paused
  elseif key == "r" then
    game.grid:randomize()
  elseif key == "c" then
    game.grid:clear()
  end
end
