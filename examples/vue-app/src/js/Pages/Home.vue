<template>
  <div class="container">
    <div class="logos">
      <img src="/images/kemal.png" alt="Kemal" width="80" height="80" />
      <span class="plus">+</span>
      <img src="/images/inertia.png" alt="Inertia" width="80" height="80" />
      <span class="plus">+</span>
      <img src="/images/vuejs.png" alt="Inertia" width="80" height="80" />
    </div>

    <h1 class="title">Hello from {{ name }}!</h1>
    
    <div class="card">
      <p class="counter-text">
        Counter: <span class="count-value">{{ count }}</span>
      </p>
      <button 
        @click="count++"
        class="btn-primary"
      >
        Increment
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

defineProps({
  name: String
})

const count = ref(0)
</script>

<style scoped>
.container {
  font-family: system-ui, sans-serif;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.logos {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 2rem;
}

.plus {
  font-size: 2rem;
  font-weight: bold;
  margin: 0 1rem;
  color: #ccc;
}

.vue-logo {
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 3rem;
}

.title {
  margin-bottom: 1rem;
}

.card {
  margin-top: 2rem;
  padding: 2rem;
  background: white;
  border-radius: 12px;
  text-align: center;
  min-width: 240px;
}

.counter-text {
  font-size: 1.25rem;
  color: #374151;
  margin-bottom: 1.5rem;
}

.count-value {
  font-weight: 800;
  color: #42b883;
  font-size: 1.5rem;
}

.btn-primary {
  padding: 0.75rem 1.5rem;
  background: #42b883;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.2s;
}

.btn-primary:hover {
  background: #3aa876;
}

.btn-primary:active {
  transform: translateY(0);
}
</style>
