package utils

import rl "github.com/gen2brain/raylib-go/raylib"

const (
	ScreenWidth  = 1280
	ScreenHeight = 720
	CellSize     = 40
)

type GameState int

const (
	Playing GameState = iota
	Paused
	Menu
)

var DefaultColors = []rl.Color{
	rl.Green,
	rl.Blue,
	rl.Red,
	rl.Purple,
	rl.Orange,
	rl.Pink,
	rl.Yellow,
}
