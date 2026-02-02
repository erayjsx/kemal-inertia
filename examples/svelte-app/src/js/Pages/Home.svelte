<script>
  export let name;
  let count = 0;
</script>

<div
  style="font-family: system-ui, sans-serif; min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 2rem;"
>
  <div
    style="display: flex; align-items: center; justify-content: center; margin-bottom: 2rem;"
  >
    <img src="/images/kemal.png" alt="Kemal" width="80" height="80" />
    <span
      style="font-size: 2rem; font-weight: bold; margin: 0 1rem; color: #ccc;"
      >+</span
    >
    <img src="/images/inertia.png" alt="Inertia" width="80" height="80" />
    <span
      style="font-size: 2rem; font-weight: bold; margin: 0 1rem; color: #ccc;"
      >+</span
    >
    <img src="/images/svelte.png" alt="Svelte" width="80" height="80" />
  </div>

  <h1 style="margin-bottom: 1rem;">Hello from {name}!</h1>

  <div class="card">
    <p class="counter-text">
      Counter: <span class="count-value">{count}</span>
    </p>
    <button on:click={() => (count += 1)} class="btn-primary">
      Increment
    </button>
  </div>
</div>

<style>
  .card {
    margin-top: 2rem;
    padding: 2rem;
    background: white;
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
    color: #ff3e00;
    font-size: 1.5rem;
  }

  .btn-primary {
    padding: 0.75rem 1.5rem;
    background: #ff3e00;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 1rem;
    transition: all 0.2s;
    box-shadow: 0 2px 4px rgba(255, 62, 0, 0.2);
  }

  .btn-primary:hover {
    background: #e63800;
  }

  .btn-primary:active {
    transform: translateY(0);
  }
</style>
