local Constants = require("constants")
local Game = require("game")
local UI = require("ui")
local Input = require("input")

local game = Game.new()
local font_title, font_ui, font_small

function love.load()
  love.window.setTitle("Game of Life")
  love.window.setMode(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
  love.graphics.setBackgroundColor(game.bg_color)

  font_title = love.graphics.newFont(40)
  font_ui = love.graphics.newFont(20)
  font_small = love.graphics.newFont(16)

  Game.initialize_grid(game, Constants.DEFAULT_ROWS, Constants.DEFAULT_COLS)
end

function love.update(dt)
  Game.update(game, dt)
  Input.handle_keyboard(game, dt)
end

function love.mousepressed(x, y, button)
  local zoom_out_btn, zoom_in_btn = UI.draw_game_ui(game, font_ui, font_small)
  Input.handle_mouse_pressed(game, x, y, button, zoom_out_btn, zoom_in_btn)
end

function love.draw()
  UI.draw_background(game)
  if game.state == Constants.GameState.Menu then
    local play_btn, small_btn, medium_btn, large_btn, color_btns = UI.draw_menu(game, font_title, font_ui, font_small)
    Input.handle_menu_input(game, play_btn, small_btn, medium_btn, large_btn, color_btns)
    if game.grid_size_changed then
      Game.initialize_grid(game, game.new_rows, game.new_cols)
    end
  else
    UI.draw_grid(game)
    local zoom_out_btn, zoom_in_btn = UI.draw_game_ui(game, font_ui, font_small)
    Input.handle_mouse_ui(game, zoom_out_btn, zoom_in_btn)
    if game.state == Constants.GameState.Paused then
      UI.draw_pause_menu(font_title, font_ui)
    end
  end
end
