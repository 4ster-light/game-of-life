<script setup>
import { storeToRefs } from "pinia";
import { useGameStore } from "../game";

const store = useGameStore();
const { isRunning, generations } = storeToRefs(store);

const toggleSimulation = () => {
  if (isRunning.value) store.stop();
  else store.start();
};

const randomize = () => store.randomize();
const clear = () => store.clear();
</script>

<template>
  <div class="controls">
    <div class="generations">Generations: {{ generations }}</div>
    <div class="buttons">
      <button @click="toggleSimulation" :class="['btn', isRunning ? 'stop' : 'start']">
        {{ isRunning ? 'Stop' : 'Start' }}
      </button>
      <button @click="randomize" class="btn random">Randomize</button>
      <button @click="clear" class="btn clear">Clear</button>
    </div>
  </div>
</template>

<style scoped>
.controls {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin: 2rem 0;
  width: 100%;
  max-width: 800px;
}

.generations {
  font-size: 1.5rem;
  color: var(--lavender);
  font-weight: 600;
  text-align: center;
  padding: 0.5rem 1rem;
  background: var(--surface0);
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  padding: 1rem 2rem;
  border: none;
  border-radius: 8px;
  font-size: 1.1rem;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.btn:active {
  transform: scale(0.98);
}

.start {
  background: var(--green);
  color: var(--crust);
}

.stop {
  background: var(--red);
  color: var(--crust);
}

.random {
  background: var(--peach);
  color: var(--crust);
}

.clear {
  background: var(--blue);
  color: var(--crust);
}

@media (max-width: 768px) {
  .controls {
    margin: 1.5rem 0;
    gap: 1rem;
  }

  .generations {
    font-size: 1.2rem;
  }

  .btn {
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    flex: 1 1 auto;
  }
}
</style>