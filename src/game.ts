import { defineStore } from "pinia";
import { onMounted, ref } from "vue";

export const useGameStore = defineStore("game", () => {
	const columns = ref(Math.floor(window.innerWidth / 30));
	const rows = ref(Math.floor(window.innerHeight / 30));
	const grid = ref(initializeGrid());
	const isRunning = ref(false);
	const generations = ref(0);
	let intervalId: number | null = null;

	function initializeGrid(): boolean[][] {
		return Array.from({ length: rows.value }, () =>
			Array.from({ length: columns.value }, () => false),
		);
	}

	function toggleCell(row: number, col: number): void {
		if (!isRunning.value) {
			grid.value[row][col] = !grid.value[row][col];
		}
	}

	function randomize(): void {
		stop();
		const newGrid: boolean[][] = initializeGrid();
		for (let i = 0; i < rows.value; i++) {
			for (let j = 0; j < columns.value; j++) {
				newGrid[i][j] = Math.random() > 0.85;
			}
		}
		grid.value = newGrid;
		generations.value = 0;
	}

	function clear(): void {
		stop();
		grid.value = initializeGrid();
		generations.value = 0;
	}

	function start(): void {
		if (!isRunning.value) {
			isRunning.value = true;
			intervalId = setInterval(nextGeneration, 100);
		}
	}

	function stop(): void {
		isRunning.value = false;
		if (intervalId) clearInterval(intervalId);
	}

	function nextGeneration(): void {
		const newGrid: boolean[][] = initializeGrid();
		for (let i = 0; i < rows.value; i++) {
			for (let j = 0; j < columns.value; j++) {
				const neighbors = countNeighbors(i, j);
				newGrid[i][j] =
					neighbors === 3 || (grid.value[i][j] && neighbors === 2);
			}
		}
		grid.value = newGrid;
		generations.value++;
	}

	function countNeighbors(row: number, col: number): number {
		let count = 0;
		for (let i = -1; i <= 1; i++) {
			for (let j = -1; j <= 1; j++) {
				if (i === 0 && j === 0) continue;
				const x = row + i;
				const y = col + j;
				if (x >= 0 && x < rows.value && y >= 0 && y < columns.value) {
					count += grid.value[x][y] ? 1 : 0;
				}
			}
		}
		return count;
	}

	function handleResize(): void {
		const viewportSize = Math.min(window.innerWidth, window.innerHeight);
		const cellSize = 25;
		const gridSize = Math.floor((viewportSize * 0.8) / cellSize);

		columns.value = gridSize;
		rows.value = gridSize;
		grid.value = initializeGrid();
	}

	onMounted(() => {
		handleResize();
		window.addEventListener("resize", handleResize);
	});

	return {
		columns,
		rows,
		grid,
		isRunning,
		generations,
		toggleCell,
		randomize,
		clear,
		start,
		stop,
	};
});
