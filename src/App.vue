<script setup>
import Controls from "./components/Controls.vue";
import GameGrid from "./components/GameGrid.vue";
</script>

<template>
  <main>
    <h1>Conway's Game of Life</h1>
    <Controls />
    <GameGrid />
  </main>
</template>

<style>
@import "./assets/base.css";

#app {
  min-height: 100dvh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 1rem;
  gap: 1.5rem;
}

main {
  width: 100%;
  max-width: 800px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

h1 {
  color: var(--lavender);
  margin: 0;
  font-size: 2.5rem;
  letter-spacing: -0.5px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  text-align: center;
}

@media (max-width: 768px) {
  h1 {
    font-size: 2rem;
  }

  #app {
    padding: 1rem;
    justify-content: start;
  }
}
</style>