package render

import rl "vendor:raylib"
import "../logic"

CELL_SIZE :: 10
GRID_COLOR :: rl.LIGHTGRAY
LIVE_CELL_COLOR :: rl.BLACK
DEAD_CELL_COLOR :: rl.WHITE

init_window :: proc(rows, cols: int) {
    width := cols * CELL_SIZE
    height := rows * CELL_SIZE
    rl.InitWindow(i32(width), i32(height), "Game of Life")
    rl.SetTargetFPS(10)
}

draw_grid :: proc(grid: logic.Grid) {
    rows := len(grid)
    cols := len(grid[0])
    
    for i in 0..<rows {
        for j in 0..<cols {
            x := j * CELL_SIZE
            y := i * CELL_SIZE
            color := LIVE_CELL_COLOR if grid[i][j] else DEAD_CELL_COLOR
            rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, color)
        }
    }
    
    for i in 0..=rows {
        y := i * CELL_SIZE
        rl.DrawLine(0, i32(y), i32(cols * CELL_SIZE), i32(y), GRID_COLOR)
    }
    
    for j in 0..=cols {
        x := j * CELL_SIZE
        rl.DrawLine(i32(x), 0, i32(x), i32(rows * CELL_SIZE), GRID_COLOR)
    }
}
