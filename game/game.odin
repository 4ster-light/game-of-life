package game

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

new_game :: proc(rows, cols: int) -> Game {
	g := Game {
		rows               = rows,
		cols               = cols,
		state              = .Menu,
		offset_x           = (f32(SCREEN_WIDTH) - f32(cols * CELL_SIZE)) / 2,
		offset_y           = (f32(SCREEN_HEIGHT) - f32(rows * CELL_SIZE)) / 2,
		zoom               = 1.0,
		update_interval    = 0.2,
		bg_color           = rl.BLACK,
		grid_color         = rl.DARKGRAY,
		color_palette      = DEFAULT_COLORS,
		selected_palette   = 0,
		selected_grid_size = 1,
		new_rows           = 40,
		new_cols           = 40,
	}
	g.cell_color = g.color_palette[g.selected_palette]
	resize_grid(&g, rows, cols)
	return g
}

free_game :: proc(g: ^Game) {
	for row in g.grid {
		delete(row)
	}
	for row in g.next_grid {
		delete(row)
	}
	delete(g.grid)
	delete(g.next_grid)
}

resize_grid :: proc(g: ^Game, rows, cols: int) {
	free_game(g)

	// Initialize new grid
	g.rows = rows
	g.cols = cols
	g.grid = make([dynamic][dynamic]Cell, rows)
	g.next_grid = make([dynamic][dynamic]Cell, rows)
	for i in 0 ..< rows {
		g.grid[i] = make([dynamic]Cell, cols)
		g.next_grid[i] = make([dynamic]Cell, cols)
	}

	clear_grid(g)
}

clear_grid :: proc(g: ^Game) {
	for i in 0 ..< g.rows {
		for j in 0 ..< g.cols {
			g.grid[i][j].alive = false
		}
	}
	g.generations = 0
}

randomize_grid :: proc(g: ^Game) {
	for i in 0 ..< g.rows {
		for j in 0 ..< g.cols {
			g.grid[i][j].alive = rand.float32() > 0.85
		}
	}
	g.generations = 0
}

toggle_cell :: proc(g: ^Game, row, col: int) {
	if row >= 0 && row < g.rows && col >= 0 && col < g.cols {
		g.grid[row][col].alive = !g.grid[row][col].alive
	}
}

count_neighbors :: proc(g: ^Game, row, col: int) -> int {
	count := 0
	for i in -1 ..= 1 {
		for j in -1 ..= 1 {
			if i == 0 && j == 0 {
				continue
			}
			r := row + i
			c := col + j
			if r >= 0 && r < g.rows && c >= 0 && c < g.cols && g.grid[r][c].alive {
				count += 1
			}
		}
	}
	return count
}

next_generation :: proc(g: ^Game) {
	for i in 0 ..< g.rows {
		for j in 0 ..< g.cols {
			neighbors := count_neighbors(g, i, j)
			g.next_grid[i][j].alive = neighbors == 3 || (g.grid[i][j].alive && neighbors == 2)
		}
	}
	for i in 0 ..< g.rows {
		for j in 0 ..< g.cols {
			g.grid[i][j] = g.next_grid[i][j]
		}
	}
	g.generations += 1
}

update :: proc(g: ^Game) {
	handle_input(g)
	if g.state == .Playing {
		current_time := f32(rl.GetTime())
		if current_time - g.last_update_time >= g.update_interval {
			next_generation(g)
			g.last_update_time = current_time
		}
	}
}

handle_input :: proc(g: ^Game) {
	// Toggle play/pause
	if rl.IsKeyPressed(.SPACE) {
		g.state = g.state == .Playing ? .Paused : g.state == .Paused ? .Playing : g.state
	}

	// Toggle menu
	if rl.IsKeyPressed(.ESCAPE) {
		g.state = g.state == .Menu ? .Playing : .Menu
	}

	// Randomize grid
	if rl.IsKeyPressed(.R) && g.state != .Menu {
		randomize_grid(g)
	}

	// Clear grid
	if rl.IsKeyPressed(.C) && g.state != .Menu {
		clear_grid(g)
	}

	// Pan control
	pan_speed: f32 = 10.0
	if rl.IsKeyDown(.UP) {
		g.offset_y += pan_speed
	}
	if rl.IsKeyDown(.DOWN) {
		g.offset_y -= pan_speed
	}
	if rl.IsKeyDown(.LEFT) {
		g.offset_x += pan_speed
	}
	if rl.IsKeyDown(.RIGHT) {
		g.offset_x -= pan_speed
	}

	// Handle Clicks
	if rl.IsMouseButtonPressed(.LEFT) && g.state != .Menu {
		mouse_pos := rl.GetMousePosition()
		right_panel_x := i32(SCREEN_WIDTH - 180)
		right_panel_y := i32(100)
		button_size: f32 = 30
		button_spacing: f32 = 10

		zoom_out_btn := rl.Rectangle {
			x      = f32(right_panel_x) + 70,
			y      = f32(right_panel_y),
			width  = button_size,
			height = button_size,
		}
		zoom_in_btn := rl.Rectangle {
			x      = zoom_out_btn.x + button_size + button_spacing,
			y      = f32(right_panel_y),
			width  = button_size,
			height = button_size,
		}

		// Toggle cells
		if !rl.CheckCollisionPointRec(mouse_pos, zoom_in_btn) &&
		   !rl.CheckCollisionPointRec(mouse_pos, zoom_out_btn) {
			grid_x := int((mouse_pos.x - g.offset_x) / (f32(CELL_SIZE) * g.zoom))
			grid_y := int((mouse_pos.y - g.offset_y) / (f32(CELL_SIZE) * g.zoom))
			toggle_cell(g, grid_y, grid_x)
		}
	}
}

draw :: proc(g: ^Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	if g.state == .Menu {
		draw_menu(g)
		return
	}

	draw_grid(g)
	draw_ui(g)

	if g.state == .Paused {
		draw_pause_menu(g)
	}
}

draw_grid :: proc(g: ^Game) {
	rl.ClearBackground(g.bg_color)
	cell_size := f32(CELL_SIZE)

	for i in 0 ..< g.rows {
		for j in 0 ..< g.cols {
			size := cell_size * g.zoom
			cell_rect := rl.Rectangle {
				x      = f32(j) * cell_size * g.zoom + g.offset_x,
				y      = f32(i) * cell_size * g.zoom + g.offset_y,
				width  = size,
				height = size,
			}
			if g.grid[i][j].alive {
				rl.DrawRectangleRec(cell_rect, g.cell_color)
				rl.DrawRectangleLinesEx(cell_rect, 1, g.grid_color)
			} else {
				rl.DrawRectangleLinesEx(cell_rect, 1, g.grid_color)
			}
		}
	}
}

draw_ui :: proc(g: ^Game) {
	// Generations
	gen_text := fmt.tprintf("Generations: %d", g.generations)
	rl.DrawText(cstring(raw_data(gen_text)), 20, 20, 20, rl.WHITE)

	// Controls
	controls_text := "Space: Play/Pause | R: Randomize | C: Clear | Arrows: Move | ESC: Menu"
	rl.DrawText(cstring(raw_data(controls_text)), 20, SCREEN_HEIGHT - 30, 16, rl.WHITE)

	// Right panel
	right_panel_x: i32 = SCREEN_WIDTH - 180
	right_panel_y: i32 = 20
	element_spacing: i32 = 40

	// Grid size
	size_text := fmt.tprintf("Grid: %dx%d", g.rows, g.cols)
	rl.DrawText(cstring(raw_data(size_text)), right_panel_x, right_panel_y, 20, rl.WHITE)
	right_panel_y += element_spacing

	// Cell color
	color_label := "Cell Color:"
	rl.DrawText(cstring(raw_data(color_label)), right_panel_x, right_panel_y, 20, rl.WHITE)
	color_indicator_size: i32 = 30
	color_indicator_x := right_panel_x + 120
	rl.DrawRectangle(
		color_indicator_x,
		right_panel_y,
		color_indicator_size,
		color_indicator_size,
		g.cell_color,
	)
	rl.DrawRectangleLines(
		color_indicator_x,
		right_panel_y,
		color_indicator_size,
		color_indicator_size,
		rl.WHITE,
	)
	right_panel_y += element_spacing

	// Zoom controls
	zoom_label := "Zoom:"
	rl.DrawText(cstring(raw_data(zoom_label)), right_panel_x, right_panel_y, 20, rl.WHITE)
	button_size: f32 = 30
	button_spacing: f32 = 10
	zoom_out_btn := rl.Rectangle {
		x      = f32(right_panel_x) + 70,
		y      = f32(right_panel_y),
		width  = button_size,
		height = button_size,
	}
	zoom_in_btn := rl.Rectangle {
		x      = zoom_out_btn.x + button_size + button_spacing,
		y      = f32(right_panel_y),
		width  = button_size,
		height = button_size,
	}
	rl.DrawRectangleRec(zoom_out_btn, g.cell_color)
	rl.DrawRectangleRec(zoom_in_btn, g.cell_color)
	rl.DrawRectangleLinesEx(zoom_out_btn, 2, rl.WHITE)
	rl.DrawRectangleLinesEx(zoom_in_btn, 2, rl.WHITE)
	rl.DrawText("-", i32(zoom_out_btn.x + 12), i32(zoom_out_btn.y + 5), 20, rl.WHITE)
	rl.DrawText("+", i32(zoom_in_btn.x + 10), i32(zoom_in_btn.y + 5), 20, rl.WHITE)

	// Handle zoom clicks
	mouse_pos := rl.GetMousePosition()
	if rl.CheckCollisionPointRec(mouse_pos, zoom_in_btn) {
		rl.DrawRectangleLinesEx(zoom_in_btn, 2, rl.LIGHTGRAY)
		if rl.IsMouseButtonPressed(.LEFT) {
			g.zoom += 0.1
			if g.zoom > 3.0 {
				g.zoom = 3.0
			}
		}
	}
	if rl.CheckCollisionPointRec(mouse_pos, zoom_out_btn) {
		rl.DrawRectangleLinesEx(zoom_out_btn, 2, rl.LIGHTGRAY)
		if rl.IsMouseButtonPressed(.LEFT) {
			g.zoom -= 0.1
			if g.zoom < 0.2 {
				g.zoom = 0.2
			}
		}
	}

	// Zoom level
	zoom_text := fmt.tprintf("%.1fx", g.zoom)
	rl.DrawText(cstring(raw_data(zoom_text)), right_panel_x, right_panel_y + 35, 16, rl.WHITE)
}

draw_pause_menu :: proc(g: ^Game) {
	rl.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl.ColorAlpha(rl.BLACK, 0.7))
	pause_text := "PAUSED"
	pause_text_x := i32(SCREEN_WIDTH / 2 - rl.MeasureText(cstring(raw_data(pause_text)), 40) / 2)
	rl.DrawText(cstring(raw_data(pause_text)), pause_text_x, SCREEN_HEIGHT / 2 - 20, 40, rl.WHITE)
	instructions := "Press SPACE to resume"
	instructions_x := i32(
		SCREEN_WIDTH / 2 - rl.MeasureText(cstring(raw_data(instructions)), 20) / 2,
	)
	rl.DrawText(
		cstring(raw_data(instructions)),
		instructions_x,
		SCREEN_HEIGHT / 2 + 30,
		20,
		rl.WHITE,
	)
}

draw_menu :: proc(g: ^Game) {
	rl.ClearBackground(g.bg_color)
	g.grid_size_changed = false

	// Title
	title := "GAME OF LIFE"
	title_x := i32(SCREEN_WIDTH / 2 - rl.MeasureText(cstring(raw_data(title)), 40) / 2)
	rl.DrawText(cstring(raw_data(title)), title_x, 100, 40, rl.WHITE)

	// Menu layout
	menu_center_x: i32 = SCREEN_WIDTH / 2
	menu_y := 250
	menu_spacing := 60

	// Play button
	play_btn_width: f32 = 300
	play_btn := rl.Rectangle {
		x      = f32(menu_center_x) - play_btn_width / 2,
		y      = f32(menu_y),
		width  = play_btn_width,
		height = 50,
	}
	rl.DrawRectangleRec(play_btn, rl.DARKGREEN)
	play_text := "Play"
	play_text_x := i32(
		play_btn.x +
		play_btn.width / 2 -
		f32(rl.MeasureText(cstring(raw_data(play_text)), 20)) / 2,
	)
	rl.DrawText(cstring(raw_data(play_text)), play_text_x, i32(play_btn.y + 15), 20, rl.WHITE)

	// Grid size
	menu_y += menu_spacing
	grid_size_text := "Grid Size:"
	rl.DrawText(
		cstring(raw_data(grid_size_text)),
		menu_center_x - rl.MeasureText(cstring(raw_data(grid_size_text)), 20) / 2,
		i32(menu_y),
		20,
		rl.WHITE,
	)

	btn_width: f32 = 90
	btn_spacing: f32 = 10
	total_btns_width := 3 * btn_width + 2 * btn_spacing
	small_btn := rl.Rectangle {
		x      = f32(menu_center_x) - total_btns_width / 2,
		y      = f32(menu_y + 30),
		width  = btn_width,
		height = 40,
	}
	medium_btn := rl.Rectangle {
		x      = small_btn.x + small_btn.width + btn_spacing,
		y      = small_btn.y,
		width  = btn_width,
		height = 40,
	}
	large_btn := rl.Rectangle {
		x      = medium_btn.x + medium_btn.width + btn_spacing,
		y      = small_btn.y,
		width  = btn_width,
		height = 40,
	}

	// Draw grid size buttons
	small_color := g.selected_grid_size == 0 ? rl.BLUE : rl.DARKBLUE
	medium_color := g.selected_grid_size == 1 ? rl.BLUE : rl.DARKBLUE
	large_color := g.selected_grid_size == 2 ? rl.BLUE : rl.DARKBLUE
	rl.DrawRectangleRec(small_btn, small_color)
	rl.DrawRectangleRec(medium_btn, medium_color)
	rl.DrawRectangleRec(large_btn, large_color)

	small_text := "20x20"
	medium_text := "40x40"
	large_text := "60x60"
	small_text_x := i32(
		small_btn.x +
		small_btn.width / 2 -
		f32(rl.MeasureText(cstring(raw_data(small_text)), 18)) / 2,
	)
	medium_text_x := i32(
		medium_btn.x +
		medium_btn.width / 2 -
		f32(rl.MeasureText(cstring(raw_data(medium_text)), 18)) / 2,
	)
	large_text_x := i32(
		large_btn.x +
		large_btn.width / 2 -
		f32(rl.MeasureText(cstring(raw_data(large_text)), 18)) / 2,
	)
	rl.DrawText(cstring(raw_data(small_text)), small_text_x, i32(small_btn.y + 12), 18, rl.WHITE)
	rl.DrawText(
		cstring(raw_data(medium_text)),
		medium_text_x,
		i32(medium_btn.y + 12),
		18,
		rl.WHITE,
	)
	rl.DrawText(cstring(raw_data(large_text)), large_text_x, i32(large_btn.y + 12), 18, rl.WHITE)

	// Color options
	menu_y += menu_spacing + 30
	color_text := "Cell Color:"
	rl.DrawText(
		cstring(raw_data(color_text)),
		menu_center_x - rl.MeasureText(cstring(raw_data(color_text)), 20) / 2,
		i32(menu_y),
		20,
		rl.WHITE,
	)

	color_btn_y := menu_y + 30
	color_btn_width: f32 = 40
	color_btn_height: f32 = 40
	color_btn_spacing: f32 = 10
	total_color_btns_width :=
		f32(len(g.color_palette)) * (color_btn_width + color_btn_spacing) - color_btn_spacing

	// Handle menu interactions
	mouse_pos := rl.GetMousePosition()

	// Play button
	if rl.CheckCollisionPointRec(mouse_pos, play_btn) {
		rl.DrawRectangleLinesEx(play_btn, 2, rl.WHITE)
		if rl.IsMouseButtonPressed(.LEFT) {
			g.state = .Playing
		}
	}

	// Grid size buttons
	if rl.CheckCollisionPointRec(mouse_pos, small_btn) {
		rl.DrawRectangleLinesEx(small_btn, 2, rl.WHITE)
		if rl.IsMouseButtonPressed(.LEFT) {
			g.new_rows = 20
			g.new_cols = 20
			g.selected_grid_size = 0
			g.grid_size_changed = true
		}
	}
	if rl.CheckCollisionPointRec(mouse_pos, medium_btn) {
		rl.DrawRectangleLinesEx(medium_btn, 2, rl.WHITE)
		if rl.IsMouseButtonPressed(.LEFT) {
			g.new_rows = 40
			g.new_cols = 40
			g.selected_grid_size = 1
			g.grid_size_changed = true
		}
	}
	if rl.CheckCollisionPointRec(mouse_pos, large_btn) {
		rl.DrawRectangleLinesEx(large_btn, 2, rl.WHITE)
		if rl.IsMouseButtonPressed(.LEFT) {
			g.new_rows = 60
			g.new_cols = 60
			g.selected_grid_size = 2
			g.grid_size_changed = true
		}
	}

	// Apply grid size change
	if g.grid_size_changed {
		resize_grid(g, g.new_rows, g.new_cols)
		g.offset_x = (f32(SCREEN_WIDTH) - f32(g.cols * CELL_SIZE)) / 2
		g.offset_y = (f32(SCREEN_HEIGHT) - f32(g.rows * CELL_SIZE)) / 2
	}

	// Color buttons
	for i in 0 ..< len(g.color_palette) {
		color_btn := rl.Rectangle {
			x      = f32(
				menu_center_x,
			) - total_color_btns_width / 2 + f32(i) * (color_btn_width + color_btn_spacing),
			y      = f32(color_btn_y),
			width  = color_btn_width,
			height = color_btn_height,
		}
		rl.DrawRectangleRec(color_btn, g.color_palette[i])
		if i == g.selected_palette {
			rl.DrawRectangleLinesEx(color_btn, 2, rl.WHITE)
		}
		if rl.CheckCollisionPointRec(mouse_pos, color_btn) {
			rl.DrawRectangleLinesEx(color_btn, 2, rl.WHITE)
			if rl.IsMouseButtonPressed(.LEFT) {
				g.selected_palette = i
				g.cell_color = g.color_palette[i]
			}
		}
	}

	// Controls info
	controls_text := "Controls: Space = Play/Pause | R = Randomize | C = Clear | Arrows = Move"
	rl.DrawText(
		cstring(raw_data(controls_text)),
		menu_center_x - rl.MeasureText(cstring(raw_data(controls_text)), 16) / 2,
		i32(SCREEN_HEIGHT - 40),
		16,
		rl.GRAY,
	)
}
