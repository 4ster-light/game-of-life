import pygame
from grid import Grid
from constants import (
	COLOR_DEAD_CELL,
	COLOR_LIVE_CELL,
	COLOR_GRID_LINE,
	COLOR_WHITE,
	SIDEBAR_WIDTH,
	UI_PADDING,
	SIMULATION_SPEED,
	ZOOM_INITIAL,
	ZOOM_MIN,
	ZOOM_MAX,
	CONSTROLS,
	WINDOW_WIDTH,
	WINDOW_HEIGHT,
	GRID_WIDTH,
	GRID_HEIGHT,
	TITLE,
)


class GameOfLife:
	def __init__(self):
		self.window_width = WINDOW_WIDTH
		self.window_height = WINDOW_HEIGHT
		self.screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
		pygame.display.set_caption(TITLE)

		self.grid = Grid(GRID_WIDTH, GRID_HEIGHT)

		# Game state
		self.paused = True
		self.frame_count = 0
		self.update_interval = 60 // SIMULATION_SPEED  # Convert speed to frame interval

		# View settings
		self.zoom = ZOOM_INITIAL
		self.pan_x = 0
		self.pan_y = 0
		self.is_panning = False  # Track if user is manually panning

		# Calculate initial centered position
		self._update_centered_position()

		# Font for UI
		self.font = pygame.font.Font(None, 24)
		self.title_font = pygame.font.Font(None, 32)

	def handle_key(self, key: int) -> None:
		if key == pygame.K_SPACE:
			self.paused = not self.paused
		elif key == pygame.K_r:
			self.grid.randomize()
		elif key == pygame.K_c:
			self.grid.clear()
		elif key == pygame.K_EQUALS or key == pygame.K_PLUS:
			self.zoom = min(self.zoom + 0.1, ZOOM_MAX)
			self._update_centered_position()
		elif key == pygame.K_MINUS:
			self.zoom = max(self.zoom - 0.1, ZOOM_MIN)
			self._update_centered_position()

	def handle_continuous_input(self, keys: pygame.key.ScancodeWrapper) -> None:
		pan_speed = 10
		panning = False

		if keys[pygame.K_UP] or keys[pygame.K_w]:
			self.pan_y -= pan_speed
			panning = True
		if keys[pygame.K_DOWN] or keys[pygame.K_s]:
			self.pan_y += pan_speed
			panning = True
		if keys[pygame.K_LEFT] or keys[pygame.K_a]:
			self.pan_x -= pan_speed
			panning = True
		if keys[pygame.K_RIGHT] or keys[pygame.K_d]:
			self.pan_x += pan_speed
			panning = True

		self.is_panning = panning

	def handle_click(self, pos: tuple[int, int]) -> None:
		x, y = pos
		grid_area_width = self.window_width - SIDEBAR_WIDTH

		if x >= grid_area_width:
			return

		cell_size = self._cell_size()
		grid_x = (x - self.pan_x) // cell_size
		grid_y = (y - self.pan_y) // cell_size

		if 0 <= grid_x < self.grid.width and 0 <= grid_y < self.grid.height:
			self.grid.toggle_cell(grid_x, grid_y)

	def handle_zoom(self, direction: int) -> None:
		zoom_step = 0.1
		if direction > 0:
			self.zoom = min(self.zoom + zoom_step, ZOOM_MAX)
		else:
			self.zoom = max(self.zoom - zoom_step, ZOOM_MIN)
		self._update_centered_position()

	def _update_centered_position(self) -> None:
		grid_area_width = self.window_width - SIDEBAR_WIDTH
		cell_size = self._cell_size()

		total_grid_width = self.grid.width * cell_size
		total_grid_height = self.grid.height * cell_size

		self.pan_x = (grid_area_width - total_grid_width) // 2
		self.pan_y = (self.window_height - total_grid_height) // 2

	def _cell_size(self) -> int:
		grid_area_width = self.window_width - SIDEBAR_WIDTH
		max_cell_width: float = grid_area_width / self.grid.width
		max_cell_height: float = self.window_height / self.grid.height
		base_size: float = min(max_cell_width, max_cell_height)
		return int(base_size * self.zoom)

	def update(self) -> None:
		if not self.paused:
			self.frame_count += 1
			if self.frame_count >= self.update_interval:
				self.grid.update()
				self.frame_count = 0

	def draw(self) -> None:
		self.screen.fill(pygame.Color(20, 20, 20))

		# Draw grid area
		grid_area_width = self.window_width - SIDEBAR_WIDTH
		pygame.draw.rect(self.screen, COLOR_DEAD_CELL, (0, 0, grid_area_width, self.window_height))

		cell_size = self._cell_size()

		# Draw grid cells
		for y in range(self.grid.height):
			for x in range(self.grid.width):
				rect: pygame.Rect = pygame.Rect(
					x * cell_size + self.pan_x,
					y * cell_size + self.pan_y,
					cell_size,
					cell_size,
				)

				# Only draw if visible on screen and within grid area
				if rect.right < 0 or rect.left > grid_area_width:
					continue
				if rect.bottom < 0 or rect.top > self.window_height:
					continue

				if self.grid.get_cell(x, y):
					pygame.draw.rect(self.screen, COLOR_LIVE_CELL, rect)

				if cell_size > 2:
					pygame.draw.rect(self.screen, COLOR_GRID_LINE, rect, 1)

		# Draw sidebar
		sidebar_x = self.window_width - SIDEBAR_WIDTH
		pygame.draw.rect(self.screen, (40, 40, 40), (sidebar_x, 0, SIDEBAR_WIDTH, self.window_height))
		pygame.draw.line(
			self.screen,
			(100, 100, 100),
			(sidebar_x, 0),
			(sidebar_x, self.window_height),
			2,
		)

		# Title
		title = self.title_font.render("GAME OF LIFE", True, COLOR_WHITE)
		self.screen.blit(title, (sidebar_x + UI_PADDING, UI_PADDING))
		y_offset = UI_PADDING + 40

		# Status
		status = "PAUSED" if self.paused else "RUNNING"
		status_color = (255, 100, 100) if self.paused else (100, 255, 100)
		status_text = self.font.render(f"Status: {status}", True, status_color)
		self.screen.blit(status_text, (sidebar_x + UI_PADDING, y_offset))
		y_offset += 35

		# Stats
		cell_count = sum(1 for y in range(self.grid.height) for x in range(self.grid.width) if self.grid.get_cell(x, y))
		small_font = pygame.font.Font(None, 20)
		stats_lines = [
			f"Live Cells: {cell_count}",
			f"Total Cells: {self.grid.width * self.grid.height}",
			f"Zoom: {self.zoom:.1f}x",
			f"Grid: {self.grid.width}x{self.grid.height}",
		]

		for stat in stats_lines:
			stat_text = small_font.render(stat, True, (200, 200, 200))
			self.screen.blit(stat_text, (sidebar_x + UI_PADDING, y_offset))
			y_offset += 25

		# Separator
		y_offset += 10
		pygame.draw.line(
			self.screen,
			(100, 100, 100),
			(sidebar_x + UI_PADDING, y_offset),
			(sidebar_x + SIDEBAR_WIDTH - UI_PADDING, y_offset),
			1,
		)
		y_offset += 15

		# Controls section
		controls_title = self.font.render("Controls:", True, COLOR_WHITE)
		self.screen.blit(controls_title, (sidebar_x + UI_PADDING, y_offset))
		y_offset += 30

		for key, action in CONSTROLS:
			key_text: pygame.Surface = small_font.render(key, True, (100, 200, 255))
			action_text: pygame.Surface = small_font.render(action, True, (200, 200, 200))
			self.screen.blit(key_text, (sidebar_x + UI_PADDING, y_offset))
			self.screen.blit(action_text, (sidebar_x + 100, y_offset))
			y_offset += 20
