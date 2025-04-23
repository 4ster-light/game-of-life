# Game of Life

An implementation of Conway's Game of Life written in Odin using Raylib.

## Features

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

Odin dev-2025-04:d9f990d42 or later

## Usage

1. Install Odin from [odin-lang.org](https://odin-lang.org/)

2. Clone this repository:

   ```bash
   git clone --single-branch --branch main --depth 1 https://github.com/4ster-light/game-of-life.git
   cd game-of-life
   ```

3. Run the game:

   ```bash
   odin run .
   ```

## Game of Life Rules

1. Any live cell with fewer than two live neighbors dies (underpopulation)
2. Any live cell with two or three live neighbors lives on to the next
   generation
3. Any live cell with more than three live neighbors dies (overpopulation)
4. Any dead cell with exactly three live neighbors becomes a live cell
   (reproduction)

## License

Apache License 2.0
