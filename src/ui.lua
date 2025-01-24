local UI = {}
UI.__index = UI

function UI.new(game)
  local self = setmetatable({}, UI)
  self.game = game

  -- Calculate UI layout for side panel
  local panelWidth = 200
  local buttonHeight = 40
  local buttonSpacing = 10
  local sideMargin = 20

  -- Store panel dimensions for other calculations
  self.panelWidth = panelWidth

  -- Button definitions
  local buttonX = love.graphics.getWidth() - panelWidth + sideMargin
  local buttonWidth = panelWidth - (sideMargin * 2)
  local startY = 100 -- Start buttons below title

  self.buttons = {
    {
      text = "Play/Pause (Space)",
      x = buttonX,
      y = startY,
      width = buttonWidth,
      height = buttonHeight,
      action = function()
        game.paused = not game.paused
      end
    },
    {
      text = "Random (R)",
      x = buttonX,
      y = startY + (buttonHeight + buttonSpacing),
      width = buttonWidth,
      height = buttonHeight,
      action = function()
        game.grid:randomize()
      end
    },
    {
      text = "Clear (C)",
      x = buttonX,
      y = startY + (buttonHeight + buttonSpacing) * 2,
      width = buttonWidth,
      height = buttonHeight,
      action = function()
        game.grid:clear()
      end
    }
  }

  -- Add speed slider
  self.speedSlider = {
    x = buttonX,
    y = startY + (buttonHeight + buttonSpacing) * 3 + 20,
    width = buttonWidth,
    height = 20,
    min = 0.01,
    max = 0.5,
    value = game.speed
  }

  return self
end

function UI:update() end

function UI:draw()
  self:drawPanelBackground()
  self:drawTitle()
  self:drawButtons()
  self:drawSpeedSlider()
  self:drawStatus()
end

function UI:drawPanelBackground()
  love.graphics.setColor(0.15, 0.15, 0.2, 0.8)
  love.graphics.rectangle("fill",
    love.graphics.getWidth() - self.panelWidth, 0,
    self.panelWidth, love.graphics.getHeight())
end

function UI:drawTitle()
  love.graphics.setColor(unpack(self.game.colors.text))
  local title = "Conway's\nGame of Life"
  local titleFont = love.graphics.newFont(24)
  love.graphics.setFont(titleFont)

  local _, wrappedText = titleFont:getWrap(title, self.panelWidth - 40)

  local startY = 30
  for i, line in ipairs(wrappedText) do
    local lineWidth = titleFont:getWidth(line)
    love.graphics.print(
      line,
      love.graphics.getWidth() - self.panelWidth + (self.panelWidth - lineWidth) / 2,
      startY + (i - 1) * titleFont:getHeight()
    )
  end
end

function UI:drawButtons()
  for _, button in ipairs(self.buttons) do
    self:drawButton(button)
  end
end

function UI:drawButton(button)
  -- Button background
  local isActive = button.text:find("Play") and self.game.paused
  local alpha = isActive and 0.3 or 0.15
  love.graphics.setColor(self.game.colors.button[1], self.game.colors.button[2],
    self.game.colors.button[3], alpha)
  love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 8)

  -- Button border
  love.graphics.setColor(self.game.colors.button[1], self.game.colors.button[2],
    self.game.colors.button[3], 0.5)
  love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 8)

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

function UI:drawSpeedSlider()
  love.graphics.setColor(unpack(self.game.colors.text))
  local font = love.graphics.newFont(14)
  love.graphics.setFont(font)
  love.graphics.print("Speed", self.speedSlider.x, self.speedSlider.y - 20)

  -- Slider background
  love.graphics.setColor(self.game.colors.button[1], self.game.colors.button[2],
    self.game.colors.button[3], 0.15)
  love.graphics.rectangle("fill",
    self.speedSlider.x, self.speedSlider.y,
    self.speedSlider.width, self.speedSlider.height, 4)

  -- Slider handle
  local handlePos = self.speedSlider.x +
      (self.game.speed - self.speedSlider.min) /
      (self.speedSlider.max - self.speedSlider.min) *
      self.speedSlider.width
  love.graphics.setColor(unpack(self.game.colors.button))
  love.graphics.rectangle("fill",
    handlePos - 5, self.speedSlider.y - 5,
    10, self.speedSlider.height + 10, 4)
end

function UI:drawStatus()
  local statusY = self.speedSlider.y + 60
  love.graphics.setColor(unpack(self.game.colors.text))
  local statusText = self.game.paused and "Status: PAUSED" or "Status: RUNNING"
  love.graphics.print(statusText, self.speedSlider.x, statusY)
end

function UI:click(x, y)
  -- Handle button clicks
  for _, button in ipairs(self.buttons) do
    if x >= button.x and x <= button.x + button.width and
        y >= button.y and y <= button.y + button.height then
      button.action()
      return true
    end
  end

  -- Handle slider interaction
  if y >= self.speedSlider.y and y <= self.speedSlider.y + self.speedSlider.height and
      x >= self.speedSlider.x and x <= self.speedSlider.x + self.speedSlider.width then
    local percentage = (x - self.speedSlider.x) / self.speedSlider.width
    self.game.speed = self.speedSlider.min +
        (self.speedSlider.max - self.speedSlider.min) * percentage
    return true
  end

  return false
end

return UI
