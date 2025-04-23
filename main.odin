package main

import "game"
import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(game.SCREEN_WIDTH, game.SCREEN_HEIGHT, game.SCREEN_TITLE)
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	game_instance := game.new_game(40, 40)
	defer game.free_game(&game_instance)

	for !rl.WindowShouldClose() {
		game.update(&game_instance)
		game.draw(&game_instance)
	}
}

