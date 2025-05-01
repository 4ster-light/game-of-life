---@diagnostic disable: undefined-field, undefined-doc-name

local Constants = require("constants")

---@alias Color { [1]: number, [2]: number, [3]: number }
---@alias Rect { x: number, y: number, w: number, h: number, id: string }

local UI = {}

---@param game table
function UI.draw_background(game)
  love.graphics.setColor(game.bg_color)
  love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
  love.graphics.setColor(0.1, 0.1, 0.15, 0.5)
  love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
end

---@param game table
function UI.draw_grid(game)
  love.graphics.push()
  love.graphics.translate(game.offset_x, game.offset_y)
  love.graphics.scale(game.zoom)

  local cell_size = Constants.CELL_SIZE
  love.graphics.setLineWidth(math.max(1 / game.zoom, 0.5))

  for i = 1, game.rows do
    for j = 1, game.cols do
      local x = (j - 1) * cell_size
      local y = (i - 1) * cell_size
      if game.grid.grid[i][j].alive then
        love.graphics.setColor(game.cell_color[1], game.cell_color[2], game.cell_color[3], game.cell_alpha[i][j] * 0.3)
        love.graphics.rectangle("fill", x - 2, y - 2, cell_size + 4, cell_size + 4, 4, 4)
        love.graphics.setColor(game.cell_color[1], game.cell_color[2], game.cell_color[3], game.cell_alpha[i][j])
        love.graphics.rectangle("fill", x + 1, y + 1, cell_size - 2, cell_size - 2, 2, 2)
      end
      love.graphics.setColor(game.grid_color)
      love.graphics.rectangle("line", x, y, cell_size, cell_size)
    end
  end

  love.graphics.setLineWidth(1)
  love.graphics.pop()
end

---@param rect Rect
---@param x number
---@param y number
---@return boolean
function UI.point_in_rect(rect, x, y)
  return x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h
end

---@param game table
---@param rect Rect
---@param color Color
---@param text string?
---@param font love.Font?
---@param is_selected boolean
---@param is_hovered boolean
function UI.draw_button(game, rect, color, text, font, is_selected, is_hovered)
  local scale_key = rect.id
  if not game.button_scale[scale_key] then
    game.button_scale[scale_key] = { value = 1, target = 1 }
  end
  local scale = game.button_scale[scale_key].value
  local hover_scale = is_hovered and 1.05 or 1
  game.button_scale[scale_key].target = love.mouse.isDown(1) and is_hovered and 0.95 or hover_scale

  love.graphics.push()
  love.graphics.translate(rect.x + rect.w / 2, rect.y + rect.h / 2)
  love.graphics.scale(scale)

  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.rectangle("fill", -rect.w / 2 + 3, -rect.h / 2 + 3, rect.w, rect.h, 8, 8)

  local r, g, b = color[1], color[2], color[3]
  if is_hovered then
    r, g, b = r * 1.05, g * 1.05, b * 1.05
  elseif love.mouse.isDown(1) and is_hovered then
    r, g, b = r * 0.95, g * 0.95, b * 0.95
  end
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle("fill", -rect.w / 2, -rect.h / 2, rect.w, rect.h, 8, 8)

  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", -rect.w / 2, -rect.h / 2, rect.w, rect.h, 8, 8)

  if is_selected then
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", -rect.w / 2, -rect.h / 2, rect.w, rect.h, 8, 8)
  end

  if text and font then
    love.graphics.setFont(font)
    local text_w = font:getWidth(text)
    local text_h = font:getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(text, -text_w / 2, -text_h / 2)
  end

  love.graphics.pop()
end

---@param game table
---@param font_ui love.Font
---@param font_small love.Font
---@return Rect, Rect
function UI.draw_game_ui(game, font_ui, font_small)
  love.graphics.setFont(font_ui)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Generations: " .. game.generations, 20, 20)

  love.graphics.setFont(font_small)
  love.graphics.print("Space: Play/Pause | R: Randomize | C: Clear | Arrows: Move | ESC: Menu", 20,
    Constants.SCREEN_HEIGHT - 30)

  local right_panel_x = Constants.SCREEN_WIDTH - 180
  local right_panel_y = 20
  local element_spacing = 40

  love.graphics.setFont(font_ui)
  love.graphics.print(string.format("Grid: %dx%d", game.rows, game.cols), right_panel_x, right_panel_y)
  right_panel_y = right_panel_y + element_spacing

  love.graphics.print("Cell Color:", right_panel_x, right_panel_y)
  love.graphics.setColor(game.cell_color)
  love.graphics.rectangle("fill", right_panel_x + 120, right_panel_y, 30, 30, 5, 5)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", right_panel_x + 120, right_panel_y, 30, 30, 5, 5)
  right_panel_y = right_panel_y + element_spacing

  love.graphics.print("Zoom:", right_panel_x, right_panel_y)
  local button_size = 30
  local button_spacing = 10
  local zoom_out_btn = { x = right_panel_x + 70, y = right_panel_y, w = button_size, h = button_size, id = "zoom_out" }
  local zoom_in_btn = {
    x = zoom_out_btn.x + button_size + button_spacing,
    y = right_panel_y,
    w = button_size,
    h =
        button_size,
    id = "zoom_in"
  }

  local mx, my = love.mouse.getPosition()
  local zoom_out_hovered = UI.point_in_rect(zoom_out_btn, mx, my)
  local zoom_in_hovered = UI.point_in_rect(zoom_in_btn, mx, my)
  UI.draw_button(game, zoom_out_btn, game.cell_color, "-", font_ui, false, zoom_out_hovered)
  UI.draw_button(game, zoom_in_btn, game.cell_color, "+", font_ui, false, zoom_in_hovered)

  love.graphics.setFont(font_small)
  love.graphics.print(string.format("%.1fx", game.zoom), right_panel_x, right_panel_y + 35)

  return zoom_out_btn, zoom_in_btn
end

---@param font_title love.Font
---@param font_ui love.Font
function UI.draw_pause_menu(font_title, font_ui)
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
  love.graphics.setFont(font_title)
  love.graphics.setColor(1, 1, 1)
  local pause_text = "PAUSED"
  local pause_text_w = font_title:getWidth(pause_text)
  love.graphics.print(pause_text, Constants.SCREEN_WIDTH / 2 - pause_text_w / 2, Constants.SCREEN_HEIGHT / 2 - 20)
  love.graphics.setFont(font_ui)
  local instructions = "Press SPACE to resume"
  local instructions_w = font_ui:getWidth(instructions)
  love.graphics.print(instructions, Constants.SCREEN_WIDTH / 2 - instructions_w / 2, Constants.SCREEN_HEIGHT / 2 + 30)
end

---@param game table
---@param font_title love.Font
---@param font_ui love.Font
---@param font_small love.Font
function UI.draw_menu(game, font_title, font_ui, font_small)
  game.grid_size_changed = false
  love.graphics.setFont(font_title)
  love.graphics.setColor(1, 1, 1)
  local title = "GAME OF LIFE"
  local title_w = font_title:getWidth(title)
  love.graphics.print(title, Constants.SCREEN_WIDTH / 2 - title_w / 2, 100)

  local menu_center_x = Constants.SCREEN_WIDTH / 2
  local menu_y = 250
  local menu_spacing = 60
  local mx, my = love.mouse.getPosition()

  local play_btn = { x = menu_center_x - 150, y = menu_y, w = 300, h = 50, id = "play" }
  local play_hovered = UI.point_in_rect(play_btn, mx, my)
  UI.draw_button(game, play_btn, { 0.2, 0.5, 0.2 }, "Play", font_ui, false, play_hovered)

  menu_y = menu_y + menu_spacing
  love.graphics.setFont(font_ui)
  local grid_size_text = "Grid Size:"
  local grid_size_text_w = font_ui:getWidth(grid_size_text)
  love.graphics.print(grid_size_text, menu_center_x - grid_size_text_w / 2, menu_y)

  local btn_width = 90
  local btn_spacing = 10
  local total_btns_width = 3 * btn_width + 2 * btn_spacing
  local small_btn = { x = menu_center_x - total_btns_width / 2, y = menu_y + 30, w = btn_width, h = 40, id = "small_grid" }
  local medium_btn = {
    x = small_btn.x + btn_width + btn_spacing,
    y = small_btn.y,
    w = btn_width,
    h = 40,
    id = "medium_grid"
  }
  local large_btn = {
    x = medium_btn.x + btn_width + btn_spacing,
    y = small_btn.y,
    w = btn_width,
    h = 40,
    id = "large_grid"
  }

  local small_hovered = UI.point_in_rect(small_btn, mx, my)
  local medium_hovered = UI.point_in_rect(medium_btn, mx, my)
  local large_hovered = UI.point_in_rect(large_btn, mx, my)
  UI.draw_button(game, small_btn, { 0.2, 0.2, 0.5 }, "20x20", font_small, game.selected_grid_size == 1, small_hovered)
  UI.draw_button(game, medium_btn, { 0.2, 0.2, 0.5 }, "40x40", font_small, game.selected_grid_size == 2, medium_hovered)
  UI.draw_button(game, large_btn, { 0.2, 0.2, 0.5 }, "60x60", font_small, game.selected_grid_size == 3, large_hovered)

  menu_y = menu_y + menu_spacing + 30
  love.graphics.setFont(font_ui)
  local color_text = "Cell Color:"
  local color_text_w = font_ui:getWidth(color_text)
  love.graphics.print(color_text, menu_center_x - color_text_w / 2, menu_y)

  local color_btn_y = menu_y + 30
  local color_btn_width = 40
  local color_btn_height = 40
  local color_btn_spacing = 10
  local total_color_btns_width = #game.color_palette * (color_btn_width + color_btn_spacing) - color_btn_spacing
  local color_btns = {}

  for i, color in ipairs(game.color_palette) do
    local color_btn = {
      x = menu_center_x - total_color_btns_width / 2 + (i - 1) * (color_btn_width + color_btn_spacing),
      y = color_btn_y,
      w = color_btn_width,
      h = color_btn_height,
      id = "color_" .. i
    }
    local color_hovered = UI.point_in_rect(color_btn, mx, my)
    UI.draw_button(game, color_btn, color, nil, nil, i == game.selected_palette, color_hovered)
    color_btns[i] = { btn = color_btn, hovered = color_hovered }
  end

  love.graphics.setFont(font_small)
  local controls_text = "Controls: Space = Play/Pause | R = Randomize | C: Clear | Arrows = Move"
  local controls_text_w = font_small:getWidth(controls_text)
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.print(controls_text, menu_center_x - controls_text_w / 2, Constants.SCREEN_HEIGHT - 40)

  return play_btn, small_btn, medium_btn, large_btn, color_btns
end

return UI
