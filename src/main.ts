type Cell = boolean;
type Grid = Cell[][];
type GameConfig = {
    rows: number;
    cols: number;
    cellSize: number;
    speed: number;
}

class GameOfLife {
    private grid: Grid;
    private running = false;
    private updateIntervalId: number | null = null;
    private ctx: CanvasRenderingContext2D;

    constructor(
        private canvas: HTMLCanvasElement,
        private config: GameConfig
    ) {
        const context = canvas.getContext('2d');
        if (!context) throw new Error('Could not get canvas context');
        this.ctx = context;

        this.grid = this.createRandomGrid();
        this.drawGrid();
        this.setupClickHandler();
    }

    private createRandomGrid(): Grid {
        return Array.from({ length: this.config.rows }, () =>
            Array.from({ length: this.config.cols }, () => Math.random() > 0.7)
        );
    }

    private setupClickHandler(): void {
        this.canvas.addEventListener('click', (e: MouseEvent) => {
            const rect = this.canvas.getBoundingClientRect();
            const col = Math.floor((e.clientX - rect.left) / this.config.cellSize);
            const row = Math.floor((e.clientY - rect.top) / this.config.cellSize);
            this.toggleCell(row, col);
        });
    }

    private drawGrid(): void {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        for (let row = 0; row < this.config.rows; row++) {
            for (let col = 0; col < this.config.cols; col++) {
                const isAlive = this.grid[row][col];

                // Fill cell
                this.ctx.fillStyle = isAlive ? '#61dafb' : '#282a36';
                this.ctx.fillRect(
                    col * this.config.cellSize,
                    row * this.config.cellSize,
                    this.config.cellSize,
                    this.config.cellSize
                );

                // Draw cell border
                this.ctx.strokeStyle = '#44475a';
                this.ctx.strokeRect(
                    col * this.config.cellSize,
                    row * this.config.cellSize,
                    this.config.cellSize,
                    this.config.cellSize
                );
            }
        }
    }

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

    private update(): void {
        if (!this.running) return;

        const nextGrid = Array.from({ length: this.config.rows }, () =>
            Array(this.config.cols).fill(false)
        );

        for (let row = 0; row < this.config.rows; row++) {
            for (let col = 0; col < this.config.cols; col++) {
                const aliveNeighbors = this.countAliveNeighbors(row, col);
                nextGrid[row][col] = this.grid[row][col]
                    ? aliveNeighbors === 2 || aliveNeighbors === 3
                    : aliveNeighbors === 3;
            }
        }

        this.grid = nextGrid;
        this.drawGrid();
    }

    public toggleCell(row: number, col: number): void {
        if (row >= 0 && row < this.config.rows && col >= 0 && col < this.config.cols) {
            this.grid[row][col] = !this.grid[row][col];
            this.drawGrid();
        }
    }

    public toggleRunning(): void {
        this.running = !this.running;
        if (this.running) {
            this.updateIntervalId = window.setInterval(
                () => this.update(),
                this.config.speed
            );
        } else {
            this.stop();
        }
    }

    public stop(): void {
        this.running = false;
        if (this.updateIntervalId !== null) {
            clearInterval(this.updateIntervalId);
            this.updateIntervalId = null;
        }
    }

    public reset(): void {
        this.stop();
        this.grid = this.createRandomGrid();
        this.drawGrid();
    }
}

// Initialize game when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const canvas = document.getElementById('gameCanvas') as HTMLCanvasElement;
    if (!canvas) throw new Error('Canvas element not found');

    const config: GameConfig = {
        rows: 40,
        cols: 40,
        cellSize: 10,
        speed: 100
    };

    const game = new GameOfLife(canvas, config);

    // Set up button controls
    document.getElementById('start')?.addEventListener('click', () => game.toggleRunning());
    document.getElementById('stop')?.addEventListener('click', () => game.stop());
    document.getElementById('reset')?.addEventListener('click', () => game.reset());
});
