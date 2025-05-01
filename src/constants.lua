return {
  SCREEN_WIDTH = 1280,
  SCREEN_HEIGHT = 720,
  CELL_SIZE = 20,
  DEFAULT_ROWS = 40,
  DEFAULT_COLS = 40,
  UPDATE_INTERVAL = 0.2,

  GameState = {
    Playing = "Playing",
    Paused = "Paused",
    Menu = "Menu"
  },

  ---@type Color[]
  DEFAULT_COLORS = {
    { 0,   1,    0 },   -- Green
    { 0,   0,    1 },   -- Blue
    { 1,   0,    0 },   -- Red
    { 0.5, 0,    0.5 }, -- Purple
    { 1,   0.5,  0 },   -- Orange
    { 1,   0.75, 0.8 }, -- Pink
    { 1,   1,    0 }    -- Yellow
  }
}
