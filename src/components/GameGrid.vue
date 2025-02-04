<script setup>
import { storeToRefs } from "pinia";
import { useGameStore } from "../game";

const store = useGameStore();
const { grid, isRunning, columns, rows } = storeToRefs(store);
const { toggleCell } = store;
</script>

<template>
  <div class="grid-wrapper">
    <div class="grid-container" :style="{
      gridTemplateColumns: `repeat(${columns}, 1fr)`,
      gridTemplateRows: `repeat(${rows}, 1fr)`
    }">
      <div v-for="(row, i) in grid" :key="i" class="grid-row">
        <div v-for="(cell, j) in row" :key="j" class="cell" :class="{ 'alive': cell, 'running': isRunning }"
          @click="toggleCell(i, j)" />
      </div>
    </div>
  </div>
</template>

<style scoped>
.grid-wrapper {
  width: 100%;
  padding: 1rem;
  display: flex;
  justify-content: center;
}

.grid-container {
  display: grid;
  gap: 1px;
  background: var(--surface0);
  width: 90vmin;
  height: 90vmin;
  max-width: 800px;
  max-height: 800px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.grid-row {
  display: contents;
}

.cell {
  background-color: var(--mantle);
  transition: all 0.2s ease;
  cursor: pointer;
  min-width: 0;
  min-height: 0;
}

.cell.alive {
  background-color: var(--mauve);
  box-shadow: inset 0 0 12px var(--lavender);
}

.cell:hover:not(.running) {
  filter: brightness(1.2);
}

@media (max-width: 768px) {
  .grid-container {
    width: 95vmin;
    height: 95vmin;
  }
}
</style>