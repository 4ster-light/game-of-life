package grid

import (
	"math/rand"
	"time"
)

type Cell struct {
	Alive bool
}

type Grid struct {
	Cells       [][]Cell
	NextCells   [][]Cell
	Rows        int
	Cols        int
	Generations int
}

func NewGrid(rows, cols int) *Grid {
	grid := &Grid{
		Rows: rows,
		Cols: cols,
	}
	grid.Initialize()
	return grid
}

func (g *Grid) Initialize() {
	g.Cells = make([][]Cell, g.Rows)
	g.NextCells = make([][]Cell, g.Rows)

	for i := range g.Rows {
		g.Cells[i] = make([]Cell, g.Cols)
		g.NextCells[i] = make([]Cell, g.Cols)
	}
}

func (g *Grid) Randomize() {
	rand.New(rand.NewSource(time.Now().UnixNano()))

	for i := range g.Rows {
		for j := range g.Cols {
			g.Cells[i][j].Alive = rand.Float32() > 0.85
		}
	}
	g.Generations = 0
}

func (g *Grid) Clear() {
	for i := range g.Rows {
		for j := range g.Cols {
			g.Cells[i][j].Alive = false
		}
	}
	g.Generations = 0
}

func (g *Grid) ToggleCell(row, col int) {
	if row >= 0 && row < g.Rows && col >= 0 && col < g.Cols {
		g.Cells[row][col].Alive = !g.Cells[row][col].Alive
	}
}

func (g *Grid) CountNeighbors(row, col int) int {
	count := 0

	for i := -1; i <= 1; i++ {
		for j := -1; j <= 1; j++ {
			if i == 0 && j == 0 {
				continue
			}

			r := row + i
			c := col + j

			if r >= 0 && r < g.Rows && c >= 0 && c < g.Cols && g.Cells[r][c].Alive {
				count++
			}
		}
	}

	return count
}

func (g *Grid) NextGeneration() {
	// Calculate the next generation
	for i := range g.Rows {
		for j := range g.Cols {
			neighbors := g.CountNeighbors(i, j)
			g.NextCells[i][j].Alive = neighbors == 3 || (g.Cells[i][j].Alive && neighbors == 2)
		}
	}

	// Copy the next generation to the current grid
	for i := range g.Rows {
		for j := range g.Cols {
			g.Cells[i][j] = g.NextCells[i][j]
		}
	}

	g.Generations++
}

func (g *Grid) Resize(rows, cols int) {
	g.Rows = rows
	g.Cols = cols
	g.Initialize()
	g.Clear()
}
