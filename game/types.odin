package game

import rl "vendor:raylib"

SCREEN_TITLE :: "Game of Life"
SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720
CELL_SIZE :: 20

GameState :: enum {
	Playing,
	Paused,
	Menu,
}

Cell :: struct {
	alive: bool,
}

DEFAULT_COLORS :: [7]rl.Color{rl.GREEN, rl.BLUE, rl.RED, rl.PURPLE, rl.ORANGE, rl.PINK, rl.YELLOW}

Game :: struct {
    grid:           [dynamic][dynamic]Cell,
    next_grid:      [dynamic][dynamic]Cell,
    rows, cols:     int,
    generations:    int,
    state:          GameState,
    offset_x, offset_y: f32,
    zoom:           f32,
    last_update_time: f32,
    update_interval: f32,
    cell_color:     rl.Color,
    bg_color:       rl.Color,
    grid_color:     rl.Color,
    color_palette:  [7]rl.Color,
    selected_palette: int,
    selected_grid_size: int,
    grid_size_changed: bool,
    new_rows, new_cols: int,
}
