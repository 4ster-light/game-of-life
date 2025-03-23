package ui

import (
	"github.com/4ster-light/game-of-life/grid"
	"github.com/4ster-light/game-of-life/utils"
	rl "github.com/gen2brain/raylib-go/raylib"
)

type Renderer struct {
	UI   *UI
	Menu *Menu
	Zoom float32
}

func NewRenderer() *Renderer {
	ui := NewUI()
	return &Renderer{
		UI:   ui,
		Menu: NewMenu(ui),
		Zoom: 1.0,
	}
}

func (r *Renderer) DrawGrid(gameGrid *grid.Grid, offsetX, offsetY float32) {
	rl.ClearBackground(r.UI.BgColor)

	for i := range gameGrid.Rows {
		for j := range gameGrid.Cols {
			// Convert grid coordinates to isometric coordinates
			isoX, isoY := utils.CartesianToIsometric(float32(j), float32(i))

			// Apply zoom and offset
			screenX := isoX*r.Zoom + offsetX
			screenY := isoY*r.Zoom + offsetY

			// Calculate the four corners of the isometric tile
			x1 := screenX
			y1 := screenY
			x2 := screenX + utils.IsoWidth*r.Zoom
			y2 := screenY + utils.IsoHeight*r.Zoom
			x3 := screenX
			y3 := screenY + utils.IsoHeight*r.Zoom*2
			x4 := screenX - utils.IsoWidth*r.Zoom
			y4 := screenY + utils.IsoHeight*r.Zoom

			// Draw the cell
			if gameGrid.Cells[i][j].Alive {
				// Draw filled cell with the selected color
				rl.DrawTriangle(
					rl.Vector2{X: x1, Y: y1},
					rl.Vector2{X: x2, Y: y2},
					rl.Vector2{X: x3, Y: y3},
					r.UI.CellColor,
				)
				rl.DrawTriangle(
					rl.Vector2{X: x1, Y: y1},
					rl.Vector2{X: x3, Y: y3},
					rl.Vector2{X: x4, Y: y4},
					r.UI.CellColor,
				)

				// Draw outline using the selected cell color for better visibility
				rl.DrawLineV(rl.Vector2{X: x1, Y: y1}, rl.Vector2{X: x2, Y: y2}, r.UI.CellColor)
				rl.DrawLineV(rl.Vector2{X: x2, Y: y2}, rl.Vector2{X: x3, Y: y3}, r.UI.CellColor)
				rl.DrawLineV(rl.Vector2{X: x3, Y: y3}, rl.Vector2{X: x4, Y: y4}, r.UI.CellColor)
				rl.DrawLineV(rl.Vector2{X: x4, Y: y4}, rl.Vector2{X: x1, Y: y1}, r.UI.CellColor)
			} else {
				// Draw empty cell outline
				rl.DrawLineV(rl.Vector2{X: x1, Y: y1}, rl.Vector2{X: x2, Y: y2}, r.UI.GridColor)
				rl.DrawLineV(rl.Vector2{X: x2, Y: y2}, rl.Vector2{X: x3, Y: y3}, r.UI.GridColor)
				rl.DrawLineV(rl.Vector2{X: x3, Y: y3}, rl.Vector2{X: x4, Y: y4}, r.UI.GridColor)
				rl.DrawLineV(rl.Vector2{X: x4, Y: y4}, rl.Vector2{X: x1, Y: y1}, r.UI.GridColor)
			}
		}
	}
}

func (r *Renderer) DrawGameUI(gameGrid *grid.Grid, offsetX, offsetY float32) {
	r.UI.DrawGameInfo(gameGrid.Generations, gameGrid.Rows, gameGrid.Cols)

	rightPanelX := int32(utils.ScreenWidth - 180)
	rightPanelY := int32(100)

	zoomChange, zoomChanged := r.UI.DrawZoomControls(rightPanelX, rightPanelY)
	if zoomChanged {
		r.Zoom += zoomChange
		if r.Zoom > 3.0 {
			r.Zoom = 3.0
		} else if r.Zoom < 0.2 {
			r.Zoom = 0.2
		}
	}

	r.UI.DrawZoomLevel(rightPanelX, rightPanelY, r.Zoom)
}

func (r *Renderer) DrawPauseMenu() {
	r.UI.DrawPauseMenu()
}

func (r *Renderer) DrawMainMenu() (utils.GameState, bool) {
	return r.Menu.Draw()
}

func (r *Renderer) GetGridCoordinates(screenX, screenY, offsetX, offsetY float32) (int, int) {
	// Convert screen coordinates to isometric grid coordinates
	isoX := (screenX - offsetX) / r.Zoom
	isoY := (screenY - offsetY) / r.Zoom

	cartX, cartY := utils.IsometricToCartesian(isoX, isoY)

	// Round to get grid coordinates
	gridX := int(cartX + 0.5)
	gridY := int(cartY + 0.5)

	return gridX, gridY
}

func (r *Renderer) GetGridSizeChanged() bool {
	return r.Menu.GridSizeChanged
}

func (r *Renderer) GetNewGridSize() (int, int) {
	return r.Menu.NewRows, r.Menu.NewCols
}
