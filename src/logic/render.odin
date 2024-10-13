package logic

import rl "vendor:raylib"

CELL_SIZE :: 10
GRID_COLOR :: rl.DARKGRAY
LIVE_CELL_COLOR :: rl.WHITE
DEAD_CELL_COLOR :: rl.BLACK

init_window :: proc() {
    width := COLS * CELL_SIZE
    height := ROWS * CELL_SIZE
    rl.InitWindow(i32(width), i32(height), "Game of Life")
    rl.SetTargetFPS(60)
}

draw_grid :: proc(grid: Grid) {
    for row in 0..<ROWS {
        for col in 0..<COLS {
            x := col * CELL_SIZE
            y := row * CELL_SIZE
            color := LIVE_CELL_COLOR if grid[row][col] else DEAD_CELL_COLOR
            rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, color)
        }
    }
    
    for i in 0..=ROWS {
        y := i * CELL_SIZE
        rl.DrawLine(0, i32(y), i32(COLS * CELL_SIZE), i32(y), GRID_COLOR)
    }
    
    for j in 0..=COLS {
        x := j * CELL_SIZE
        rl.DrawLine(i32(x), 0, i32(x), i32(ROWS * CELL_SIZE), GRID_COLOR)
    }
}
