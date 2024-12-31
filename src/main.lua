-- main.lua
local Grid = require('grid')
local UI = require('ui')

-- Game state
local game = {
  grid = nil,
  ui = nil,
  cellSize = 15,
  paused = true,
  speed = 0.1,     -- Update interval in seconds
  timer = 0,
  fadeSpeed = 2,   -- Speed of cell fade animations
}

function love.load()
  -- Enable antialiasing
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- Calculate grid dimensions based on window size with padding
  local padding = 100
  local width = love.graphics.getWidth() - padding
  local height = love.graphics.getHeight() - padding
  local rows = math.floor(height / game.cellSize)
  local cols = math.floor(width / game.cellSize)

  -- Initialize game components
  game.grid = Grid.new(rows, cols, game.cellSize)
  game.ui = UI.new(game)

  -- Set up color palette
  game.colors = {
    background = { 0.12, 0.12, 0.18, 1 },   -- Dark background
    cell = { 0.38, 0.85, 0.98, 1 },         -- Bright cyan
    grid = { 0.27, 0.28, 0.35, 0.3 },       -- Subtle grid lines
    text = { 0.88, 0.88, 0.88, 1 },         -- Light text
    button = { 0.38, 0.85, 0.98, 1 }        -- Matching buttons
  }
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

  -- Update cell fade animations
  game.grid:updateFades(dt * game.fadeSpeed)
end

function love.draw()
  -- Set background
  love.graphics.setBackgroundColor(unpack(game.colors.background))

  -- Draw grid with offset for centering
  local offsetX = (love.graphics.getWidth() - game.grid.cols * game.cellSize) / 2
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
    -- Adjust for grid offset
    local offsetX = (love.graphics.getWidth() - game.grid.cols * game.cellSize) / 2
    local offsetY = (love.graphics.getHeight() - game.grid.rows * game.cellSize) / 2

    -- Convert mouse coordinates to grid position
    local gridX = math.floor((x - offsetX) / game.cellSize) + 1
    local gridY = math.floor((y - offsetY) / game.cellSize) + 1

    -- Toggle cell if within grid bounds
    if game.grid:isValidPosition(gridX, gridY) then
      game.grid:toggleCell(gridX, gridY)
    end

    -- Check UI interactions
    game.ui:click(x, y)
  end
end

function love.keypressed(key)
  if key == 'space' then
    game.paused = not game.paused
  elseif key == 'r' then
    game.grid:randomize()
  elseif key == 'c' then
    game.grid:clear()
  end
end
