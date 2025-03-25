package main

import (
	"github.com/4ster-light/game-of-life/game"
	"github.com/4ster-light/game-of-life/utils"
	rl "github.com/gen2brain/raylib-go/raylib"
)

func main() {
	rl.InitWindow(utils.ScreenWidth, utils.ScreenHeight, "Game of Life")
	rl.SetTargetFPS(60)

	gameInstance := game.NewGame(40, 40)

	for !rl.WindowShouldClose() {
		gameInstance.Update()
		gameInstance.Draw()
	}

	rl.CloseWindow()
}
