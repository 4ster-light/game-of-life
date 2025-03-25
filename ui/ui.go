package ui

import (
	"fmt"

	"github.com/4ster-light/game-of-life/utils"
	rl "github.com/gen2brain/raylib-go/raylib"
)

type UI struct {
	CellColor       rl.Color
	BgColor         rl.Color
	GridColor       rl.Color
	ColorPalette    []rl.Color
	SelectedPalette int
}

func NewUI() *UI {
	ui := &UI{
		BgColor:         rl.Black,
		GridColor:       rl.DarkGray,
		ColorPalette:    utils.DefaultColors,
		SelectedPalette: 0,
	}
	ui.CellColor = ui.ColorPalette[ui.SelectedPalette]
	return ui
}

func (u *UI) DrawGameInfo(generations, rows, cols int) {
	// Draw generations counter
	genText := fmt.Sprintf("Generations: %d", generations)
	rl.DrawText(genText, 20, 20, 20, rl.White)

	// Draw controls help
	controlsText := "Space: Play/Pause | R: Randomize | C: Clear | Arrows: Move | ESC: Exit"
	rl.DrawText(controlsText, 20, utils.ScreenHeight-30, 16, rl.White)

	// Right side UI panel - move closer to right edge
	rightPanelX := int32(utils.ScreenWidth - 180)
	rightPanelY := int32(20)
	elementSpacing := int32(40)

	// Draw grid size
	sizeText := fmt.Sprintf("Grid: %dx%d", rows, cols)
	rl.DrawText(sizeText, rightPanelX, rightPanelY, 20, rl.White)
	rightPanelY += elementSpacing

	// Draw color indicator with label
	colorLabelText := "Cell Color:"
	rl.DrawText(colorLabelText, rightPanelX, rightPanelY, 20, rl.White)

	colorIndicatorSize := int32(30)
	colorIndicatorX := rightPanelX + 120
	rl.DrawRectangle(colorIndicatorX, rightPanelY, colorIndicatorSize, colorIndicatorSize, u.CellColor)
	rl.DrawRectangleLines(colorIndicatorX, rightPanelY, colorIndicatorSize, colorIndicatorSize, rl.White)
}

func (u *UI) DrawZoomControls(rightPanelX, rightPanelY int32) (float32, bool) {
	zoomChange := float32(0.0)
	zoomChanged := false

	// Draw zoom controls with label
	zoomLabelText := "Zoom:"
	rl.DrawText(zoomLabelText, rightPanelX, rightPanelY, 20, rl.White)

	// Zoom buttons
	buttonSize := float32(30)
	buttonSpacing := float32(10)
	zoomOutBtn := rl.Rectangle{
		X:      float32(rightPanelX) + 70,
		Y:      float32(rightPanelY),
		Width:  buttonSize,
		Height: buttonSize,
	}
	zoomInBtn := rl.Rectangle{
		X:      zoomOutBtn.X + buttonSize + buttonSpacing,
		Y:      float32(rightPanelY),
		Width:  buttonSize,
		Height: buttonSize,
	}

	// Draw zoom buttons with same color as cell color
	rl.DrawRectangleRec(zoomOutBtn, u.CellColor)
	rl.DrawRectangleRec(zoomInBtn, u.CellColor)
	rl.DrawRectangleLinesEx(zoomOutBtn, 2, rl.White)
	rl.DrawRectangleLinesEx(zoomInBtn, 2, rl.White)

	// Draw zoom button text
	rl.DrawText("-", int32(zoomOutBtn.X+12), int32(zoomOutBtn.Y+5), 20, rl.White)
	rl.DrawText("+", int32(zoomInBtn.X+10), int32(zoomInBtn.Y+5), 20, rl.White)

	// Handle zoom button clicks
	mousePos := rl.GetMousePosition()
	if rl.CheckCollisionPointRec(mousePos, zoomInBtn) {
		rl.DrawRectangleLinesEx(zoomInBtn, 2, rl.LightGray)
		if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
			zoomChange = 0.1
			zoomChanged = true
		}
	}

	if rl.CheckCollisionPointRec(mousePos, zoomOutBtn) {
		rl.DrawRectangleLinesEx(zoomOutBtn, 2, rl.LightGray)
		if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
			zoomChange = -0.1
			zoomChanged = true
		}
	}

	return zoomChange, zoomChanged
}

func (u *UI) DrawZoomLevel(rightPanelX, rightPanelY int32, zoom float32) {
	zoomText := fmt.Sprintf("%.1fx", zoom)
	rl.DrawText(zoomText, rightPanelX, rightPanelY+35, 16, rl.White)
}

func (u *UI) DrawPauseMenu() {
	// Draw semi-transparent background
	rl.DrawRectangle(0, 0, utils.ScreenWidth, utils.ScreenHeight, rl.ColorAlpha(rl.Black, 0.7))

	// Draw pause text
	pauseText := "PAUSED"
	pauseTextX := int32(utils.ScreenWidth/2 - rl.MeasureText(pauseText, 40)/2)
	rl.DrawText(pauseText, pauseTextX, utils.ScreenHeight/2-20, 40, rl.White)

	// Draw instructions
	instructionsText := "Press SPACE to resume"
	instructionsTextX := int32(utils.ScreenWidth/2 - rl.MeasureText(instructionsText, 20)/2)
	rl.DrawText(instructionsText, instructionsTextX, utils.ScreenHeight/2+30, 20, rl.White)
}

func (u *UI) SetCellColor(paletteIndex int) {
	if paletteIndex >= 0 && paletteIndex < len(u.ColorPalette) {
		u.SelectedPalette = paletteIndex
		u.CellColor = u.ColorPalette[u.SelectedPalette]
	}
}
