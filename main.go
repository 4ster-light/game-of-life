package main

import (
	"github.com/4ster-light/game-of-life/game"
	"github.com/4ster-light/game-of-life/utils"
	rl "github.com/gen2brain/raylib-go/raylib"
)

const TITLE = "Game of Life - Isometric Edition"

func main() {
	rl.InitWindow(utils.ScreenWidth, utils.ScreenHeight, TITLE)
	rl.SetTargetFPS(60)

	gameInstance := game.NewGame(40, 40)

	for !rl.WindowShouldClose() {
		gameInstance.Update()
		gameInstance.Draw()
	}

	rl.CloseWindow()
}
