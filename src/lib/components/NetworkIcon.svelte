<script lang="ts">
  import type { NetworkIconName } from "$lib/content/homepage";

  let { name } = $props<{
    name: NetworkIconName;
  }>();
</script>

{#if name === "blog"}
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
    <path
      d="M5 19l4.5-1 8.5-8.5-3.5-3.5L6 14.5 5 19Z"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="1.8"
    />
    <path
      d="M13.75 6.25l3.5 3.5"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-width="1.8"
    />
  </svg>
{:else if name === "github"}
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
    <path
      d="M8 17.5c-1.6 0-3-1.2-3-2.8V9.6c0-1.7 1.5-3.1 3.2-3.1h1.1l1.1-1.8h3.2l1.1 1.8h1.1c1.7 0 3.2 1.4 3.2 3.1v5.1c0 1.6-1.4 2.8-3 2.8"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="1.8"
    />
    <circle cx="9.5" cy="11.5" r="1" fill="currentColor" />
    <circle cx="14.5" cy="11.5" r="1" fill="currentColor" />
    <path
      d="M10 15c.6.4 1.3.6 2 .6s1.4-.2 2-.6"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-width="1.8"
    />
  </svg>
{:else if name === "telegram"}
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
    <path
      d="M20 5 4.8 10.8c-.7.3-.7 1.2 0 1.4l3.8 1.3 1.5 4.7c.2.6 1 .7 1.4.2l2.1-2.6 3.9 2.8c.6.4 1.4.1 1.5-.7L21 5.9c.1-.7-.6-1.2-1.2-.9Z"
      fill="none"
      stroke="currentColor"
      stroke-linejoin="round"
      stroke-width="1.8"
    />
    <path
      d="m8.6 13.5 8.8-6.1-6.8 7.3"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="1.8"
    />
  </svg>
{:else if name === "email"}
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
    <rect
      x="4"
      y="6.5"
      width="16"
      height="11"
      rx="1.8"
      fill="none"
      stroke="currentColor"
      stroke-width="1.8"
    />
    <path
      d="m5.5 8 6.5 5 6.5-5"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="1.8"
    />
  </svg>
{:else if name === "friends"}
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
    <circle
      cx="9"
      cy="10"
      r="2.7"
      fill="none"
      stroke="currentColor"
      stroke-width="1.8"
    />
    <circle
      cx="15.5"
      cy="9.3"
      r="2.2"
      fill="none"
      stroke="currentColor"
      stroke-width="1.8"
    />
    <path
      d="M4.8 18c.7-2.5 2.4-4 4.8-4s4.1 1.5 4.8 4"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-width="1.8"
    />
    <path
      d="M13.5 17.4c.5-1.8 1.7-2.9 3.5-2.9 1.1 0 2.1.4 2.9 1.3"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-width="1.8"
    />
  </svg>
{:else}
  <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
    <path
      d="M4 14.5 20 8"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-width="1.8"
    />
    <path
      d="M13 8.7 16.5 6l3.5 1.7-1.7 4.4"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="1.8"
    />
    <path
      d="M5 18h14"
      fill="none"
      stroke="currentColor"
      stroke-linecap="round"
      stroke-width="1.8"
    />
  </svg>
{/if}

<style>
  svg {
    display: block;
    width: 0.9em;
    height: 0.9em;
  }
</style>
