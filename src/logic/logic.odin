package logic

import "core:math/rand"

init_grid :: proc() -> Grid {
    grid: Grid
    for row in 0..<ROWS {
        for col in 0..<COLS {
            grid[row][col] = rand.int31() % 2 == 0
        }
    }
    return grid
}

update_grid :: proc(grid: ^Grid) {
    new_grid: Grid
    
    for row in 0..<ROWS {
        for col in 0..<COLS {
            neighbors := count_neighbors(grid^, row, col)
            new_grid[row][col] = grid[row][col] && neighbors == 2 || neighbors == 3
        }
    }
    
    grid^ = new_grid
}

count_neighbors :: proc(grid: Grid, row, col: int) -> int {
    count := 0
    for i in -1..=1 {
        for j in -1..=1 {
            if i == 0 && j == 0 do continue
            new_row := (row + i + ROWS) % ROWS
            new_col := (col + j + COLS) % COLS
            if grid[new_row][new_col] do count += 1
        }
    }
    return count
}
