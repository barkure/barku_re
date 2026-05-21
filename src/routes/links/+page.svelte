<script lang="ts">
  import { friendLinks } from "$lib/content/friends";
</script>

<svelte:head>
  <title>Links - Barkure</title>
  <meta name="description" content="Links of Barkure" />
  <meta name="theme-color" content="#181818" />
</svelte:head>

<div class="links-page">
  <header class="links-header">
    <a class="back-link" href="/">Back to Barkure</a>
    <h1 class="links-title" style="color: var(--hero-title-color);">Links</h1>
  </header>

  <section class="links-panel" aria-label="Links">
    <ul class="links-list">
      {#each friendLinks as link}
        <li>
          <a href={link.href} target="_blank" rel="noreferrer">{link.label}</a>
        </li>
      {/each}
    </ul>
  </section>
</div>

<style>
  .links-page {
    min-height: 100vh;
    min-height: 100svh;
    background:
      radial-gradient(circle at top left, rgba(255, 255, 255, 0.04), transparent 34%),
      radial-gradient(circle at top right, rgba(255, 255, 255, 0.025), transparent 30%),
      var(--color-bg-darken);
    color: var(--color-text);
    padding: 3.75rem;
  }

  .links-header {
    max-width: 72rem;
    margin: 0 auto;
  }

  .back-link {
    display: inline-block;
    color: rgba(255, 255, 255, 0.54);
    font-size: 2.35rem;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    transition: color 140ms ease;
  }

  .back-link:hover {
    color: var(--color-text);
  }

  .links-title {
    margin: 1.4rem 0 0;
    font-size: clamp(2.35rem, 5.2vw, 4.1rem);
    font-weight: 700;
    line-height: 0.96;
  }

  .links-panel {
    max-width: 72rem;
    margin: 2rem auto 0;
  }

  .links-list {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    column-gap: 2rem;
    row-gap: 0.65rem;
  }

  .links-list li {
    min-width: 0;
  }

  .links-list a {
    display: block;
    padding: 0.52rem 0;
    color: rgba(255, 255, 255, 0.72);
    font-size: clamp(1.85rem, 2.85vw, 2.45rem);
    font-weight: 540;
    line-height: 1.45;
    text-decoration: none;
    transition:
      color 120ms ease,
      transform 120ms ease;
  }

  .links-list a:hover {
    color: var(--hero-title-color);
    transform: translateX(0.18rem);
  }

  @media (max-width: 767px) {
    .links-page {
      padding: 1rem;
    }

    .back-link {
      font-size: 2rem;
    }

    .links-title {
      margin-top: 1rem;
      font-size: 2.55rem;
    }

    .links-panel {
      margin-top: 2rem;
    }

    .links-list {
      grid-template-columns: minmax(0, 1fr);
    }

    .links-list a {
      padding: 0.65rem 0;
      font-size: 1.7rem;
      -webkit-tap-highlight-color: transparent;
    }
  }
</style>
