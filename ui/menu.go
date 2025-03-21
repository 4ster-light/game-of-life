package ui

import (
	"github.com/4ster-light/game-of-life/utils"
	rl "github.com/gen2brain/raylib-go/raylib"
)

type Menu struct {
	UI              *UI
	SelectedSize    int // 0 = small, 1 = medium, 2 = large
	GridSizeChanged bool
	NewRows         int
	NewCols         int
}

func NewMenu(ui *UI) *Menu {
	return &Menu{
		UI:           ui,
		SelectedSize: 1, // Default to medium (40x40)
		NewRows:      40,
		NewCols:      40,
	}
}

func (m *Menu) Draw() (utils.GameState, bool) {
	rl.ClearBackground(rl.Black)
	m.GridSizeChanged = false

	// Draw title - centered
	titleText := "GAME OF LIFE"
	subtitleText := "Isometric Edition"

	titleX := int32(utils.ScreenWidth/2 - rl.MeasureText(titleText, 40)/2)
	subtitleX := int32(utils.ScreenWidth/2 - rl.MeasureText(subtitleText, 25)/2)

	rl.DrawText(titleText, titleX, 100, 40, rl.White)
	rl.DrawText(subtitleText, subtitleX, 150, 25, rl.LightGray)

	// Calculate menu center position
	menuCenterX := int32(utils.ScreenWidth / 2)
	menuY := 250
	menuSpacing := 60

	// Play button
	playBtnWidth := float32(300)
	playBtnRect := rl.Rectangle{
		X:      float32(menuCenterX) - playBtnWidth/2,
		Y:      float32(menuY),
		Width:  playBtnWidth,
		Height: 50,
	}
	rl.DrawRectangleRec(playBtnRect, rl.DarkGreen)

	playText := "Play"
	playTextX := int32(playBtnRect.X + playBtnRect.Width/2 - float32(rl.MeasureText(playText, 20))/2)
	rl.DrawText(playText, playTextX, int32(playBtnRect.Y+15), 20, rl.White)

	// Grid size options
	menuY += menuSpacing
	gridSizeText := "Grid Size:"
	rl.DrawText(gridSizeText, menuCenterX-rl.MeasureText(gridSizeText, 20)/2, int32(menuY), 20, rl.White)

	btnWidth := float32(90)
	btnSpacing := float32(10)
	totalBtnsWidth := 3*btnWidth + 2*btnSpacing

	smallBtnRect := rl.Rectangle{
		X:      float32(menuCenterX) - totalBtnsWidth/2,
		Y:      float32(menuY + 30),
		Width:  btnWidth,
		Height: 40,
	}
	mediumBtnRect := rl.Rectangle{
		X:      smallBtnRect.X + smallBtnRect.Width + btnSpacing,
		Y:      smallBtnRect.Y,
		Width:  btnWidth,
		Height: 40,
	}
	largeBtnRect := rl.Rectangle{
		X:      mediumBtnRect.X + mediumBtnRect.Width + btnSpacing,
		Y:      smallBtnRect.Y,
		Width:  btnWidth,
		Height: 40,
	}

	// Draw buttons with different colors based on selection
	if m.SelectedSize == 0 {
		rl.DrawRectangleRec(smallBtnRect, rl.Blue)
		rl.DrawRectangleRec(mediumBtnRect, rl.DarkBlue)
		rl.DrawRectangleRec(largeBtnRect, rl.DarkBlue)
	} else if m.SelectedSize == 1 {
		rl.DrawRectangleRec(smallBtnRect, rl.DarkBlue)
		rl.DrawRectangleRec(mediumBtnRect, rl.Blue)
		rl.DrawRectangleRec(largeBtnRect, rl.DarkBlue)
	} else {
		rl.DrawRectangleRec(smallBtnRect, rl.DarkBlue)
		rl.DrawRectangleRec(mediumBtnRect, rl.DarkBlue)
		rl.DrawRectangleRec(largeBtnRect, rl.Blue)
	}

	smallText := "20x20"
	mediumText := "40x40"
	largeText := "60x60"

	smallTextX := int32(smallBtnRect.X + smallBtnRect.Width/2 - float32(rl.MeasureText(smallText, 18))/2)
	mediumTextX := int32(mediumBtnRect.X + mediumBtnRect.Width/2 - float32(rl.MeasureText(mediumText, 18))/2)
	largeTextX := int32(largeBtnRect.X + largeBtnRect.Width/2 - float32(rl.MeasureText(largeText, 18))/2)

	rl.DrawText(smallText, smallTextX, int32(smallBtnRect.Y+12), 18, rl.White)
	rl.DrawText(mediumText, mediumTextX, int32(mediumBtnRect.Y+12), 18, rl.White)
	rl.DrawText(largeText, largeTextX, int32(largeBtnRect.Y+12), 18, rl.White)

	// Color options
	menuY += menuSpacing + 30
	colorText := "Cell Color:"
	rl.DrawText(colorText, menuCenterX-rl.MeasureText(colorText, 20)/2, int32(menuY), 20, rl.White)

	colorBtnY := menuY + 30
	colorBtnWidth := float32(40)
	colorBtnHeight := float32(40)
	colorBtnSpacing := float32(10)

	totalColorBtnsWidth := float32(len(m.UI.ColorPalette))*(colorBtnWidth+colorBtnSpacing) - colorBtnSpacing

	for i := range m.UI.ColorPalette {
		colorBtnRect := rl.Rectangle{
			X:      float32(menuCenterX) - totalColorBtnsWidth/2 + float32(i)*(colorBtnWidth+colorBtnSpacing),
			Y:      float32(colorBtnY),
			Width:  colorBtnWidth,
			Height: colorBtnHeight,
		}

		rl.DrawRectangleRec(colorBtnRect, m.UI.ColorPalette[i])

		// Draw selection indicator
		if i == m.UI.SelectedPalette {
			rl.DrawRectangleLinesEx(colorBtnRect, 2, rl.White)
		}
	}

	// Handle menu interactions
	mousePos := rl.GetMousePosition()
	newState := utils.Menu
	stateChanged := false

	// Play button
	if rl.CheckCollisionPointRec(mousePos, playBtnRect) {
		rl.DrawRectangleLinesEx(playBtnRect, 2, rl.White)
		if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
			newState = utils.Playing
			stateChanged = true
		}
	}

	// Grid size buttons
	if rl.CheckCollisionPointRec(mousePos, smallBtnRect) {
		rl.DrawRectangleLinesEx(smallBtnRect, 2, rl.White)
		if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
			m.NewRows = 20
			m.NewCols = 20
			m.SelectedSize = 0
			m.GridSizeChanged = true
		}
	}

	if rl.CheckCollisionPointRec(mousePos, mediumBtnRect) {
		rl.DrawRectangleLinesEx(mediumBtnRect, 2, rl.White)
		if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
			m.NewRows = 40
			m.NewCols = 40
			m.SelectedSize = 1
			m.GridSizeChanged = true
		}
	}

	if rl.CheckCollisionPointRec(mousePos, largeBtnRect) {
		rl.DrawRectangleLinesEx(largeBtnRect, 2, rl.White)
		if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
			m.NewRows = 60
			m.NewCols = 60
			m.SelectedSize = 2
			m.GridSizeChanged = true
		}
	}

	// Color buttons
	for i := range m.UI.ColorPalette {
		colorBtnRect := rl.Rectangle{
			X:      float32(menuCenterX) - totalColorBtnsWidth/2 + float32(i)*(colorBtnWidth+colorBtnSpacing),
			Y:      float32(colorBtnY),
			Width:  colorBtnWidth,
			Height: colorBtnHeight,
		}

		if rl.CheckCollisionPointRec(mousePos, colorBtnRect) {
			rl.DrawRectangleLinesEx(colorBtnRect, 2, rl.White)
			if rl.IsMouseButtonPressed(rl.MouseLeftButton) {
				m.UI.SetCellColor(i)
			}
		}
	}

	// Draw controls info at the bottom
	controlsText := "Controls: Space = Play/Pause | R = Randomize | C = Clear | Arrows = Move"
	rl.DrawText(controlsText, menuCenterX-rl.MeasureText(controlsText, 16)/2, int32(utils.ScreenHeight-40), 16, rl.Gray)

	return newState, stateChanged
}
