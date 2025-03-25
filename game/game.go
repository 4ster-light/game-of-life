package game

import (
	"github.com/4ster-light/game-of-life/grid"
	"github.com/4ster-light/game-of-life/ui"
	"github.com/4ster-light/game-of-life/utils"
	rl "github.com/gen2brain/raylib-go/raylib"
)

type Game struct {
	Grid           *grid.Grid
	Renderer       *ui.Renderer
	State          utils.GameState
	OffsetX        float32
	OffsetY        float32
	LastUpdateTime float32
	UpdateInterval float32
}

func NewGame(rows, cols int) *Game {
	return &Game{
		Grid:           grid.NewGrid(rows, cols),
		Renderer:       ui.NewRenderer(),
		State:          utils.Menu,
		OffsetX:        (float32(utils.ScreenWidth) - float32(cols*utils.CellSize)) / 2,  // Center horizontally
		OffsetY:        (float32(utils.ScreenHeight) - float32(rows*utils.CellSize)) / 2, // Center vertically
		LastUpdateTime: 0,
		UpdateInterval: 0.2,
	}
}

func (g *Game) Update() {
	g.HandleInput()

	if g.State == utils.Playing {
		// Use time-based updates for smoother generations
		currentTime := rl.GetTime()
		if float32(currentTime)-g.LastUpdateTime >= g.UpdateInterval {
			g.Grid.NextGeneration()
			g.LastUpdateTime = float32(currentTime)
		}
	}
}

func (g *Game) Draw() {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	if g.State == utils.Menu {
		newState, stateChanged := g.Renderer.DrawMainMenu()
		if stateChanged {
			g.State = newState
		}

		if g.Renderer.GetGridSizeChanged() {
			rows, cols := g.Renderer.GetNewGridSize()
			g.Grid.Resize(rows, cols)
		}
		return
	}

	g.Renderer.DrawGrid(g.Grid, g.OffsetX, g.OffsetY)
	g.Renderer.DrawGameUI(g.Grid, g.OffsetX, g.OffsetY)

	if g.State == utils.Paused {
		g.Renderer.DrawPauseMenu()
	}
}

func (g *Game) HandleInput() {
	// Toggle play/pause
	if rl.IsKeyPressed(rl.KeySpace) {
		if g.State == utils.Playing {
			g.State = utils.Paused
		} else if g.State == utils.Paused {
			g.State = utils.Playing
		}
	}

	// Toggle menu
	if rl.IsKeyPressed(rl.KeyEscape) {
		if g.State == utils.Menu {
			g.State = utils.Playing
		} else {
			g.State = utils.Menu
		}
	}

	// Randomize grid
	if rl.IsKeyPressed(rl.KeyR) && g.State != utils.Menu {
		g.Grid.Randomize()
	}

	// Clear grid
	if rl.IsKeyPressed(rl.KeyC) && g.State != utils.Menu {
		g.Grid.Clear()
	}

	// Pan control
	panSpeed := float32(10.0)
	if rl.IsKeyDown(rl.KeyUp) {
		g.OffsetY += panSpeed
	}
	if rl.IsKeyDown(rl.KeyDown) {
		g.OffsetY -= panSpeed
	}
	if rl.IsKeyDown(rl.KeyLeft) {
		g.OffsetX += panSpeed
	}
	if rl.IsKeyDown(rl.KeyRight) {
		g.OffsetX -= panSpeed
	}

	// Toggle cells with mouse
	if rl.IsMouseButtonPressed(rl.MouseLeftButton) && g.State != utils.Menu {
		mousePos := rl.GetMousePosition()

		// Define UI element areas to check for clicks
		rightPanelX := int32(utils.ScreenWidth - 180)
		rightPanelY := int32(100)
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

		// Check if we clicked on a UI element
		if !rl.CheckCollisionPointRec(mousePos, zoomInBtn) &&
			!rl.CheckCollisionPointRec(mousePos, zoomOutBtn) {

			// Convert screen coordinates to grid coordinates
			gridX, gridY := g.Renderer.GetGridCoordinates(mousePos.X, mousePos.Y, g.OffsetX, g.OffsetY)

			// Toggle the cell if it's within bounds
			if gridX >= 0 && gridX < g.Grid.Cols && gridY >= 0 && gridY < g.Grid.Rows {
				g.Grid.ToggleCell(gridY, gridX)
			}
		}
	}
}
