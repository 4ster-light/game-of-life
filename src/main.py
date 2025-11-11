import sys
import pygame
from game import GameOfLife
from constants import UI_FPS


if __name__ == "__main__":
	pygame.init()
	game = GameOfLife()

	clock = pygame.time.Clock()
	running = True

	while running:
		clock.tick(UI_FPS)

		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				running = False
			elif event.type == pygame.KEYDOWN:
				game.handle_key(event.key)
			elif event.type == pygame.MOUSEBUTTONDOWN:
				if event.button == 1:  # Left click
					game.handle_click(event.pos)
			elif event.type == pygame.MOUSEWHEEL:
				game.handle_zoom(event.y)

		keys = pygame.key.get_pressed()
		game.handle_continuous_input(keys)

		game.update()

		game.draw()
		pygame.display.flip()

	pygame.quit()
	sys.exit()
