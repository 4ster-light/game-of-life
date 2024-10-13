package main

import rl "vendor:raylib"
import "logic"

UPDATE_INTERVAL :: 0.1

main :: proc() {
    grid := logic.init_grid()

    logic.init_window()
    defer rl.CloseWindow()

    last_update_time := rl.GetTime()
    paused := false

    for !rl.WindowShouldClose() {
        current_time := rl.GetTime()
        
        // Toggle pause state with space key
        if rl.IsKeyPressed(.SPACE) {
            paused = !paused
        }

        // Update grid automatically every UPDATE_INTERVAL seconds
        if !paused && current_time - last_update_time >= UPDATE_INTERVAL {
            logic.update_grid(&grid)
            last_update_time = current_time
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        logic.draw_grid(grid)
        rl.EndDrawing()
    }
}
