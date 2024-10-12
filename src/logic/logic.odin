package logic

import "core:math/rand"

Grid :: distinct [dynamic][dynamic]bool

init_grid :: proc(rows, cols: int) -> Grid {
    grid := make(Grid, rows)
    for &row in &grid {
        row = make([dynamic]bool, cols)
        for &cell in &row {
            cell = rand.int31() % 2 == 0
        }
    }
    return grid
}

update_grid :: proc(grid: ^Grid) {
    rows := len(grid)
    cols := len(grid[0])
    
    new_grid := make(Grid, rows)
    for i in 0..<rows {
        new_grid[i] = make([dynamic]bool, cols)
    }
    
    for i in 0..<rows {
        for j in 0..<cols {
            neighbors := count_neighbors(grid^, i, j)
            new_grid[i][j] = grid[i][j] && neighbors == 2 || neighbors == 3
        }
    }
    
    for i in 0..<rows {
        delete(grid[i])
        grid[i] = new_grid[i]
    }
}

count_neighbors :: proc(grid: Grid, row, col: int) -> int {
    rows, cols := len(grid), len(grid[0])
    count := 0
    for i in -1..=1 {
        for j in -1..=1 {
            if i == 0 && j == 0 do continue
            new_row := (row + i + rows) % rows
            new_col := (col + j + cols) % cols
            if grid[new_row][new_col] do count += 1
        }
    }
    return count
}

cleanup_grid :: proc(grid: ^Grid) {
    for row in grid {
        delete(row)
    }
}
