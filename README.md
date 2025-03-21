# Game of Life - Isometric Edition

An implementation of Conway's Game of Life with an isometric perspective, written in Go using Raylib.

## Features

- Isometric perspective view of the Game of Life grid
- Zoom in/out functionality
- Pan around the grid with arrow keys
- Adjustable board size (20x20, 40x40, 60x60)
- Color customization for cells
- Pause menu and main menu
- Randomize grid or clear it completely

## Controls

- **Space**: Play/Pause the simulation
- **R**: Randomize the grid
- **C**: Clear the grid
- **+/-**: Zoom in/out
- **Arrow Keys**: Pan the view
- **Left Mouse Button**: Toggle cells

## Requirements

- Go 1.24.1 or later
- Raylib-go

## Usage

1. Install Go from [golang.org](https://golang.org/)

2. Install the Raylib Go bindings:

   ```bash
   go get -u github.com/gen2brain/raylib-go/raylib
   ```

3. Clone this repository:

   ```bash
   git clone https://github.com/4ster-light/game-of-life.git
   cd game-of-life
   ```

4. Run the game:

   ```bash
   go run .
   ```

## Game of Life Rules

1. Any live cell with fewer than two live neighbors dies (underpopulation)
2. Any live cell with two or three live neighbors lives on to the next generation
3. Any live cell with more than three live neighbors dies (overpopulation)
4. Any dead cell with exactly three live neighbors becomes a live cell (reproduction)

## License

Apache License 2.0
