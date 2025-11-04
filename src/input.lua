local Constants = require("constants")
local UI = require("ui")

local Input = {}

---@param game table
---@param dt number
function Input.handle_keyboard(game, dt)
  if love.keyboard.isDown("space") and not game.space_pressed then
    game.space_pressed = true
    if game.state == Constants.GameState.Playing then
      game.state = Constants.GameState.Paused
    elseif game.state == Constants.GameState.Paused then
      game.state = Constants.GameState.Playing
    end
  elseif not love.keyboard.isDown("space") then
    game.space_pressed = false
  end

  if love.keyboard.isDown("escape") and not game.escape_pressed then
    game.escape_pressed = true
    game.state = game.state == Constants.GameState.Menu and Constants.GameState.Playing or Constants.GameState.Menu
  elseif not love.keyboard.isDown("escape") then
    game.escape_pressed = false
  end

  if love.keyboard.isDown("r") and game.state ~= Constants.GameState.Menu and not game.r_pressed then
    game.r_pressed = true
    game.grid:randomize(game.cell_alpha)
  elseif not love.keyboard.isDown("r") then
    game.r_pressed = false
  end

  if love.keyboard.isDown("c") and game.state ~= Constants.GameState.Menu and not game.c_pressed then
    game.c_pressed = true
    game.grid:clear(game.cell_alpha)
  elseif not love.keyboard.isDown("c") then
    game.c_pressed = false
  end

  local pan_speed = 300 * dt
  if love.keyboard.isDown("up") then game.offset_y = game.offset_y + pan_speed end
  if love.keyboard.isDown("down") then game.offset_y = game.offset_y - pan_speed end
  if love.keyboard.isDown("left") then game.offset_x = game.offset_x + pan_speed end
  if love.keyboard.isDown("right") then game.offset_x = game.offset_x - pan_speed end
end

---@param game table
---@param x number
---@param y number
---@param button number
---@param zoom_out_btn Rect
---@param zoom_in_btn Rect
function Input.handle_mouse_pressed(game, x, y, button, zoom_out_btn, zoom_in_btn)
  if button == 1 and game.state ~= Constants.GameState.Menu then
    if not UI.point_in_rect(zoom_out_btn, x, y) and not UI.point_in_rect(zoom_in_btn, x, y) then
      local grid_x = math.floor((x - game.offset_x) / (Constants.CELL_SIZE * game.zoom)) + 1
      local grid_y = math.floor((y - game.offset_y) / (Constants.CELL_SIZE * game.zoom)) + 1
      game.grid:toggle_cell(game.cell_alpha, grid_y, grid_x)
    end
  end
end

---@param game table
---@param zoom_out_btn Rect
---@param zoom_in_btn Rect
function Input.handle_mouse_ui(game, zoom_out_btn, zoom_in_btn)
  local mx, my = love.mouse.getPosition()
  local zoom_out_hovered = UI.point_in_rect(zoom_out_btn, mx, my)
  local zoom_in_hovered = UI.point_in_rect(zoom_in_btn, mx, my)

  if zoom_in_hovered and love.mouse.isDown(1) and not game.mouse_pressed then
    game.mouse_pressed = true
    game.zoom = math.min(game.zoom + 0.1, 3.0)
    game.offset_x = (Constants.SCREEN_WIDTH - game.cols * Constants.CELL_SIZE * game.zoom) / 2
    game.offset_y = (Constants.SCREEN_HEIGHT - game.rows * Constants.CELL_SIZE * game.zoom) / 2
  elseif zoom_out_hovered and love.mouse.isDown(1) and not game.mouse_pressed then
    game.mouse_pressed = true
    game.zoom = math.max(game.zoom - 0.1, 0.2)
    game.offset_x = (Constants.SCREEN_WIDTH - game.cols * Constants.CELL_SIZE * game.zoom) / 2
    game.offset_y = (Constants.SCREEN_HEIGHT - game.rows * Constants.CELL_SIZE * game.zoom) / 2
  elseif not love.mouse.isDown(1) then
    game.mouse_pressed = false
  end
end

---@param game table
---@param play_btn Rect
---@param small_btn Rect
---@param medium_btn Rect
---@param large_btn Rect
---@param color_btns { btn: Rect, hovered: boolean }[]
function Input.handle_menu_input(game, play_btn, small_btn, medium_btn, large_btn, color_btns)
  local mx, my = love.mouse.getPosition()
  local play_hovered = UI.point_in_rect(play_btn, mx, my)
  local small_hovered = UI.point_in_rect(small_btn, mx, my)
  local medium_hovered = UI.point_in_rect(medium_btn, mx, my)
  local large_hovered = UI.point_in_rect(large_btn, mx, my)

  if play_hovered and love.mouse.isDown(1) and not game.mouse_pressed then
    game.mouse_pressed = true
    game.state = Constants.GameState.Playing
  elseif small_hovered and love.mouse.isDown(1) and not game.mouse_pressed then
    game.mouse_pressed = true
    game.new_rows = 20
    game.new_cols = 20
    game.selected_grid_size = 1
    game.grid_size_changed = true
  elseif medium_hovered and love.mouse.isDown(1) and not game.mouse_pressed then
    game.mouse_pressed = true
    game.new_rows = 40
    game.new_cols = 40
    game.selected_grid_size = 2
    game.grid_size_changed = true
  elseif large_hovered and love.mouse.isDown(1) and not game.mouse_pressed then
    game.mouse_pressed = true
    game.new_rows = 60
    game.new_cols = 60
    game.selected_grid_size = 3
    game.grid_size_changed = true
  elseif not love.mouse.isDown(1) then
    game.mouse_pressed = false
  end

  for i, color_btn in ipairs(color_btns) do
    if color_btn.hovered and love.mouse.isDown(1) and not game.mouse_pressed then
      game.mouse_pressed = true
      game.selected_palette = i
      game.cell_color = game.color_palette[i]
    end
  end
end

return Input
