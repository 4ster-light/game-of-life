const canvas = document.getElementById('gameCanvas') as HTMLCanvasElement;
const ctx = canvas.getContext('2d')!;

type Cell = boolean;

type GameConfig = {
    rows: number;
    cols: number;
    cellSize: number;
    speed: number;
}

class GameOfLife {
    private grid: Cell[][];
    private running: boolean = false;
    private updateIntervalId: number | null = null;

    constructor(private config: GameConfig) {
        this.grid = this.createRandomGrid();
        this.drawGrid();
    }

    // Initialize grid with a random state
    private createRandomGrid(): Cell[][] {
        return Array.from({ length: this.config.rows }, () =>
            Array.from({ length: this.config.cols }, () => Math.random() > 0.7)
        );
    }

    // Initialize an empty grid
    private createEmptyGrid(): Cell[][] {
        return Array.from({ length: this.config.rows }, () =>
            Array(this.config.cols).fill(false)
        );
    }

    // Draw the current state of the grid
    private drawGrid() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        for (let row = 0; row < this.config.rows; row++) {
            for (let col = 0; col < this.config.cols; col++) {
                ctx.fillStyle = this.grid[row][col] ? '#61dafb' : '#282a36';
                ctx.fillRect(
                    col * this.config.cellSize,
                    row * this.config.cellSize,
                    this.config.cellSize,
                    this.config.cellSize
                );
                ctx.strokeStyle = '#44475a';
                ctx.strokeRect(
                    col * this.config.cellSize,
                    row * this.config.cellSize,
                    this.config.cellSize,
                    this.config.cellSize
                );
            }
        }
    }

    // Count live neighbors for a given cell
    private countAliveNeighbors(row: number, col: number): number {
        let count = 0;
        for (let i = -1; i <= 1; i++) {
            for (let j = -1; j <= 1; j++) {
                if (i === 0 && j === 0) continue;
                const r = (row + i + this.config.rows) % this.config.rows;
                const c = (col + j + this.config.cols) % this.config.cols;
                if (this.grid[r][c]) count++;
            }
        }
        return count;
    }

    // Calculate the next state of the grid
    private getNextState(): Cell[][] {
        const nextGrid = this.createEmptyGrid();
        for (let row = 0; row < this.config.rows; row++) {
            for (let col = 0; col < this.config.cols; col++) {
                const aliveNeighbors = this.countAliveNeighbors(row, col);
                nextGrid[row][col] = this.grid[row][col]
                    ? aliveNeighbors === 2 || aliveNeighbors === 3
                    : aliveNeighbors === 3;
            }
        }
        return nextGrid;
    }

    // Update the game state at each interval
    private update() {
        if (!this.running) return;
        this.grid = this.getNextState();
        this.drawGrid();
    }

    // Start or stop the game
    public toggleRunning() {
        this.running = !this.running;
        if (this.running) {
            this.updateIntervalId = window.setInterval(
                () => this.update(),
                this.config.speed
            );
        } else if (this.updateIntervalId !== null) {
            clearInterval(this.updateIntervalId);
            this.updateIntervalId = null;
        }
    }

    // Reset the grid to a new random state
    public reset() {
        this.stop();
        this.grid = this.createRandomGrid();
        this.drawGrid();
    }

    // Stop the game
    public stop() {
        this.running = false;
        if (this.updateIntervalId !== null) {
            clearInterval(this.updateIntervalId);
            this.updateIntervalId = null;
        }
    }

    // Toggle cell state based on user click
    public toggleCell(row: number, col: number) {
        this.grid[row][col] = !this.grid[row][col];
        this.drawGrid();
    }
}

const config: GameConfig = {
    rows: 40,
    cols: 40,
    cellSize: 10,
    speed: 100,
};

// Initialize the game
const game = new GameOfLife(config);

// Handle user interactions
canvas.addEventListener('click', (e: MouseEvent) => {
    const rect = canvas.getBoundingClientRect();
    const col = Math.floor((e.clientX - rect.left) / config.cellSize);
    const row = Math.floor((e.clientY - rect.top) / config.cellSize);
    game.toggleCell(row, col);
});

document.getElementById('start')!.addEventListener('click', () => game.toggleRunning());
document.getElementById('stop')!.addEventListener('click', () => game.stop());
document.getElementById('reset')!.addEventListener('click', () => game.reset());
