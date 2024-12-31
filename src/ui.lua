-- ui.lua
local UI = {}
UI.__index = UI

function UI.new(game)
  local self = setmetatable({}, UI)
  self.game = game

  -- Calculate UI layout
  local topMargin = 20
  local headerHeight = 40
  local buttonHeight = 40
  local buttonWidth = 150
  local buttonSpacing = 20

  -- Calculate total header area height
  self.headerArea = topMargin + headerHeight + buttonHeight + 20

  -- Button definitions
  local centerX = love.graphics.getWidth() / 2
  self.buttons = {
    {
      text = "Play/Pause (Space)",
      x = centerX - buttonWidth * 1.5 - buttonSpacing,
      y = topMargin + headerHeight + 10,
      width = buttonWidth,
      height = buttonHeight,
      action = function()
        game.paused = not game.paused
      end
    },
    {
      text = "Random (R)",
      x = centerX - buttonWidth / 2,
      y = topMargin + headerHeight + 10,
      width = buttonWidth,
      height = buttonHeight,
      action = function()
        game.grid:randomize()
      end
    },
    {
      text = "Clear (C)",
      x = centerX + buttonWidth / 2 + buttonSpacing,
      y = topMargin + headerHeight + 10,
      width = buttonWidth,
      height = buttonHeight,
      action = function()
        game.grid:clear()
      end
    }
  }

  return self
end

function UI:update(dt)
  -- Add any UI animations or updates here
end

function UI:draw()
  -- Draw title
  love.graphics.setColor(unpack(self.game.colors.text))
  local title = "Conway's Game of Life"
  local titleFont = love.graphics.newFont(32)
  love.graphics.setFont(titleFont)
  local titleWidth = titleFont:getWidth(title)
  love.graphics.print(
    title,
    love.graphics.getWidth() / 2 - titleWidth / 2,
    20
  )

  -- Draw buttons
  for _, button in ipairs(self.buttons) do
    -- Button background
    if self.game.paused and button.text:find("Play") then
      -- Highlight play button when paused
      love.graphics.setColor(self.game.colors.cell[1], self.game.colors.cell[2],
        self.game.colors.cell[3], 0.3)
    else
      love.graphics.setColor(self.game.colors.cell[1], self.game.colors.cell[2],
        self.game.colors.cell[3], 0.2)
    end
    love.graphics.rectangle('fill', button.x, button.y, button.width, button.height, 10)

    -- Button border
    love.graphics.setColor(self.game.colors.cell[1], self.game.colors.cell[2],
      self.game.colors.cell[3], 0.5)
    love.graphics.rectangle('line', button.x, button.y, button.width, button.height, 10)

    -- Button text
    love.graphics.setColor(unpack(self.game.colors.text))
    local font = love.graphics.newFont(14)
    love.graphics.setFont(font)
    local textWidth = font:getWidth(button.text)
    local textHeight = font:getHeight()
    love.graphics.print(
      button.text,
      button.x + button.width / 2 - textWidth / 2,
      button.y + button.height / 2 - textHeight / 2
    )
  end

  -- Draw pause indicator text
  if self.game.paused then
    love.graphics.setColor(unpack(self.game.colors.text))
    local pauseFont = love.graphics.newFont(18)
    love.graphics.setFont(pauseFont)
    local pauseText = "PAUSED"
    love.graphics.print(
      pauseText,
      10,
      love.graphics.getHeight() - 30
    )
  end
end

function UI:click(x, y)
  for _, button in ipairs(self.buttons) do
    if x >= button.x and x <= button.x + button.width and
        y >= button.y and y <= button.y + button.height then
      button.action()
      return true
    end
  end
  return false
end

return UI
