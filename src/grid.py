import random


class Cell:
	def __init__(self, state: bool = False):
		self.state = state

	def is_alive(self) -> bool:
		return self.state

	def set_state(self, state: bool) -> None:
		self.state = state

	def toggle(self) -> None:
		self.state = not self.state


class Grid:
	def __init__(self, width: int, height: int):
		self.width = width
		self.height = height
		self.cells = [[Cell() for _ in range(width)] for _ in range(height)]

	def get_cell(self, x: int, y: int) -> bool:
		if 0 <= x < self.width and 0 <= y < self.height:
			return self.cells[y][x].is_alive()
		return False

	def set_cell(self, x: int, y: int, state: bool) -> None:
		if 0 <= x < self.width and 0 <= y < self.height:
			self.cells[y][x].set_state(state)

	def toggle_cell(self, x: int, y: int) -> None:
		if 0 <= x < self.width and 0 <= y < self.height:
			self.cells[y][x].toggle()

	def count_neighbors(self, x: int, y: int) -> int:
		count = 0
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue
				nx, ny = x + dx, y + dy
				if self.get_cell(nx, ny):
					count += 1
		return count

	def update(self) -> None:
		new_cells = [[Cell() for _ in range(self.width)] for _ in range(self.height)]

		for y in range(self.height):
			for x in range(self.width):
				live_neighbors = self.count_neighbors(x, y)
				current_state = self.get_cell(x, y)

				if current_state:
					new_cells[y][x].set_state(live_neighbors in [2, 3])
				else:
					new_cells[y][x].set_state(live_neighbors == 3)

		self.cells = new_cells

	def randomize(self) -> None:
		for y in range(self.height):
			for x in range(self.width):
				self.cells[y][x].set_state(random.random() < 0.3)

	def clear(self) -> None:
		self.cells = [[Cell() for _ in range(self.width)] for _ in range(self.height)]
