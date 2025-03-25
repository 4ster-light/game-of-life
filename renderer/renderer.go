package renderer

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

	cellSize := float32(utils.CellSize)
	for i := range gameGrid.Rows {
		for j := range gameGrid.Cols {
			x := float32(j)*cellSize*r.Zoom + offsetX
			y := float32(i)*cellSize*r.Zoom + offsetY
			width := cellSize * r.Zoom
			height := cellSize * r.Zoom

			cellRect := rl.Rectangle{
				X:      x,
				Y:      y,
				Width:  width,
				Height: height,
			}

			if gameGrid.Cells[i][j].Alive {
				rl.DrawRectangleRec(cellRect, r.UI.CellColor)
				rl.DrawRectangleLinesEx(cellRect, 1, r.UI.GridColor)
			} else {
				rl.DrawRectangleLinesEx(cellRect, 1, r.UI.GridColor)
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

func (r *Renderer) GetGridCoordinates(screenX, screenY, offsetX, offsetY float32) (int, int) {
	gridX := int((screenX - offsetX) / (utils.CellSize * r.Zoom))
	gridY := int((screenY - offsetY) / (utils.CellSize * r.Zoom))
	return gridX, gridY
}

func (r *Renderer) DrawPauseMenu() {
	r.UI.DrawPauseMenu()
}

func (r *Renderer) DrawMainMenu() (utils.GameState, bool) {
	return r.Menu.Draw()
}

func (r *Renderer) GetGridSizeChanged() bool {
	return r.Menu.GridSizeChanged
}

func (r *Renderer) GetNewGridSize() (int, int) {
	return r.Menu.NewRows, r.Menu.NewCols
}
