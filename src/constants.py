from pygame import Color

TITLE = "Conway's Game of Life"

# Window dimensions (grid area + sidebar)
WINDOW_WIDTH = 1000
WINDOW_HEIGHT = 800

# Grid dimensions
GRID_WIDTH = 60
GRID_HEIGHT = 60

# Colors
COLOR_BLACK = Color(0, 0, 0)
COLOR_WHITE = Color(255, 255, 255)
COLOR_GRAY = Color(50, 50, 50)
COLOR_GREEN = Color(0, 255, 0)
COLOR_LIGHT_GREEN = Color(100, 255, 100)
COLOR_RED = Color(255, 0, 0)
COLOR_BLUE = Color(0, 100, 255)
COLOR_DEAD_CELL = Color(0, 0, 0)
COLOR_LIVE_CELL = Color(0, 255, 0)
COLOR_GRID_LINE = Color(50, 50, 50)

# UI configuration
SIDEBAR_WIDTH = 300
UI_PADDING = 15
INFO_PANEL_HEIGHT = 120
UI_FPS = 60
SIMULATION_SPEED = 10

# Zoom settings
ZOOM_INITIAL = 1.0
ZOOM_MIN = 0.5
ZOOM_MAX = 5.0

CONTROLS: list[tuple[str, str]] = [
	("SPACE", "Play/Pause"),
	("R", "Randomize"),
	("C", "Clear"),
	("+/-", "Zoom"),
	("Arrow Keys", "Pan"),
	("Click", "Toggle Cell"),
]
