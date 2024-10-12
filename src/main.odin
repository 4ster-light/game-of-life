package main

import rl "vendor:raylib"
import "logic"
import "render"

ROWS :: 50
COLS :: 80

main :: proc() {
    grid := logic.init_grid(ROWS, COLS)
    defer logic.cleanup_grid(&grid)

    render.init_window(ROWS, COLS)
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        if rl.IsKeyPressed(.SPACE) {
            logic.update_grid(&grid)
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        render.draw_grid(grid)
        rl.EndDrawing()
    }
}
