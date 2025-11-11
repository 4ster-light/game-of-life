# Game of Life

A Python implementation of Conway's Game of Life using Pygame.

![Showcase Image](https://github.com/4ster-light/game-of-life/blob/main/Showcase.png)

## Features

- Smooth zoom in/out functionality
- Pan around the grid with arrow keys
- 60x60 grid with dynamic cell size
- Real-time cell count display and status
- Play/Pause simulation control
- Interactive grid manipulation (click to toggle cells)
- Randomize or clear the entire grid
- Clean sidebar UI with non-overlapping information display
- Responsive controls information

## Quick Start

### Installation

1. Clone this repository:

   ```bash
   git clone --single-branch --branch main --depth 1 https://github.com/4ster-light/game-of-life.git
   cd game-of-life
   ```

2. Install dependencies with UV:

   ```bash
   uv sync
   ```

3. Run the game:

   ```bash
   uv run src/main.py
   ```

## Controls

| Key             | Action              |
| --------------- | ------------------- |
| **Space**       | Toggle Play/Pause   |
| **R**           | Randomize grid      |
| **C**           | Clear all cells     |
| **+/-**         | Zoom in/out         |
| **Arrow Keys**  | Pan around the grid |
| **Mouse Click** | Toggle cell state   |

## Game Rules

Conway's Game of Life follows four simple rules:

1. Any live cell with fewer than two live neighbors dies (underpopulation)
2. Any live cell with two or three live neighbors lives on to the next
   generation
3. Any live cell with more than three live neighbors dies (overpopulation)
4. Any dead cell with exactly three live neighbors becomes a live cell
   (reproduction)

## Project Structure

```plaintext
src/
├── main.py        - Application entry point and game loop
├── game.py        - Main game class (rendering, input handling, state management)
├── grid.py        - Grid class (cell management and Game of Life rules)
└── constants.py   - Configuration (colors, dimensions, simulation speed)
```

## Customization

Edit `src/constants.py`:

### Adjust Grid Size

```python
GRID_WIDTH = 60   # Number of columns
GRID_HEIGHT = 60  # Number of rows
```

### Change Simulation Speed

```python
SIMULATION_SPEED = 10  # Updates per second (1-60 recommended)
```

### Modify Colors

```python
LIVE_CELL_COLOR = Color(0, 255, 0)      # Green for alive cells
DEAD_CELL_COLOR = Color(0, 0, 0)        # Black for dead cells
GRID_COLOR = Color(50, 50, 50)          # Gray for grid lines
```

### Adjust Window Size

```python
WINDOW_WIDTH = 1000    # Total window width (includes sidebar)
WINDOW_HEIGHT = 800    # Window height
SIDEBAR_WIDTH = 300    # Information panel width on the right
```

## Requirements

- Python 3.13+
- UV (package manager)
- Pygame 2.6.1+

## License

Apache License 2.0

## Sponsor

If you like this project, consider supporting me by buying me a coffee.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/B0B41HVJUR)
