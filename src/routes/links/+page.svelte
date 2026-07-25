<script lang="ts">
	import { friendLinks } from '$lib/content/friends';

	let linksPage: HTMLElement | null = null;

	const handlePointerMove = (event: PointerEvent) => {
		if (!linksPage || event.pointerType !== 'mouse') return;
		const rect = linksPage.getBoundingClientRect();
		linksPage.style.setProperty('--mx', `${event.clientX - rect.left}px`);
		linksPage.style.setProperty('--my', `${event.clientY - rect.top}px`);
	};
</script>

<svelte:head>
	<title>Links - Barkure</title>
	<meta name="description" content="Links of Barkure" />
	<meta name="theme-color" content="#0c0d12" />
</svelte:head>

<svelte:window onpointermove={handlePointerMove} />

<div class="links-page" bind:this={linksPage}>
	<header class="links-header">
		<a class="back-link" href="/">Back to Barkure</a>
		<h1 class="links-title">Links</h1>
	</header>

	<section class="links-panel" aria-label="Links">
		<ul class="links-list">
			{#each friendLinks as link, i}
				<li style={`--i: ${i}`}>
					<a href={link.href} target="_blank" rel="noreferrer">
						<span class="link-index">{String(i + 1).padStart(2, '0')}</span>
						<span class="link-label">{link.label}</span>
						<span class="link-arrow" aria-hidden="true">↗</span>
					</a>
				</li>
			{/each}
		</ul>
	</section>
</div>

<style>
	.links-page {
		position: relative;
		min-height: 100vh;
		min-height: 100svh;
		background:
			radial-gradient(circle at top left, var(--glow-primary), transparent 34%),
			radial-gradient(circle at top right, var(--glow-secondary), transparent 30%),
			var(--color-bg-darken);
		color: var(--color-text);
		padding: 3.75rem;
	}

	.links-page::before {
		content: "";
		position: absolute;
		inset: 0;
		pointer-events: none;
		background: radial-gradient(
			24rem 24rem at var(--mx, 50%) var(--my, 18%),
			var(--glow-primary),
			transparent 72%
		);
	}

	.links-header,
	.links-panel {
		position: relative;
		z-index: 1;
	}

	.links-header {
		max-width: 72rem;
		margin: 0 auto;
		animation: links-rise 640ms cubic-bezier(0.22, 0.61, 0.36, 1) both;
	}

	.back-link {
		display: inline-block;
		color: var(--color-text-dim);
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
		color: var(--hero-title-color);
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
		border-bottom: 1px solid var(--hairline);
		animation: links-rise 560ms cubic-bezier(0.22, 0.61, 0.36, 1) both;
		animation-delay: calc(120ms + var(--i) * 55ms);
	}

	.links-list a {
		position: relative;
		display: flex;
		align-items: baseline;
		gap: 0.75rem;
		padding: 0.52rem 0.75rem;
		margin: 0 -0.75rem;
		border-radius: 0.5rem;
		color: var(--color-link-text);
		font-size: clamp(1.85rem, 2.85vw, 2.45rem);
		font-weight: 540;
		line-height: 1.45;
		text-decoration: none;
		transition:
			color 140ms ease,
			background-color 140ms ease,
			transform 140ms ease;
	}

	.links-list a:hover {
		color: var(--hero-title-color);
		background: var(--accent-soft);
		transform: translateX(0.18rem);
	}

	.link-index {
		color: var(--color-text-faint);
		font-size: 0.55em;
		font-weight: 700;
		letter-spacing: 0.08em;
		transition: color 140ms ease;
	}

	.links-list a:hover .link-index {
		color: var(--hero-title-color);
	}

	.link-label {
		min-width: 0;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.link-arrow {
		margin-left: auto;
		font-size: 0.7em;
		opacity: 0;
		transform: translate(-0.2rem, 0.2rem);
		transition:
			opacity 140ms ease,
			transform 140ms ease;
	}

	.links-list a:hover .link-arrow {
		opacity: 1;
		transform: translate(0, 0);
	}

	@keyframes links-rise {
		from {
			opacity: 0;
			transform: translateY(1.4rem);
		}

		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	@media (prefers-reduced-motion: reduce) {
		.links-header,
		.links-list li {
			animation: none;
		}
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
			padding: 0.65rem 0.75rem;
			font-size: 1.7rem;
			-webkit-tap-highlight-color: transparent;
		}

		.link-arrow {
			display: none;
		}
	}
</style>
