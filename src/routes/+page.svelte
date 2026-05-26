<script lang="ts">
	import { onMount } from 'svelte';
	import Icon from '$lib/components/Icon.svelte';
	import Slider from '$lib/components/Slider.svelte';
	import { heroIntroBody, heroSlides, networkItems } from '$lib/content/homepage';

	const MOBILE_BREAKPOINT = 767;

	let contentShell: HTMLElement | null = null;
	let isContentPinned = $state(false);

	onMount(() => {
		const syncPinnedState = () => {
			isContentPinned =
				!!contentShell &&
				window.innerWidth <= MOBILE_BREAKPOINT &&
				contentShell.getBoundingClientRect().top <= 0;
		};

		syncPinnedState();
		window.addEventListener('scroll', syncPinnedState, { passive: true });
		window.addEventListener('resize', syncPinnedState);

		return () => {
			window.removeEventListener('scroll', syncPinnedState);
			window.removeEventListener('resize', syncPinnedState);
		};
	});
</script>

<svelte:head>
	<title>Barkure</title>
	<meta name="description" content="Builder / Open Sourceror / Toolmaker" />
	<meta name="theme-color" content="#181818" />
</svelte:head>

<div class="site-shell bg-(--color-bg-darken) text-(--color-text)">
	<section class="first-view">
		<header class="hero-copy">
			<h1 class="hero-title" style="color: var(--hero-title-color);">
				<span>Barkure<span class="sp-break"></span></span>
			</h1>
			<p class="hero-subtitle">Builder / Open Sourceror / Toolmaker</p>
			<p class="hero-intro">
				Hi, I'm <span class="hero-intro-name" style="color: var(--hero-title-color);">Barkure</span
				>,
				{heroIntroBody}
			</p>
		</header>

		<div class="hero-media">
			<Slider slides={heroSlides} />
		</div>
	</section>

	<main class="content-shell" class:is-pinned={isContentPinned} bind:this={contentShell}>
		<section class="description-block" lang="en">
			<p>
				Hi, I'm <span class="hero-intro-name" style="color: var(--hero-title-color);">Barkure</span
				>,
				{heroIntroBody}
			</p>
		</section>

		<section class="tag-block">
			<ul>
				{#each networkItems as item}
					<li class="network-item" style={`--icon-color: ${item.color};`}>
						<span class="tag-item">
							<span class="tag-icon">
								<Icon name={item.icon} />
							</span>
							<a href={item.href} target="_blank" rel="noreferrer">{item.label}</a>
						</span>
					</li>
				{/each}
			</ul>
		</section>
	</main>
</div>
