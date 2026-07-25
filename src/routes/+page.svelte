<script lang="ts">
	import Icon from '@iconify/svelte';
	import { onMount } from 'svelte';
	import Slider from '$lib/components/Slider.svelte';
	import { heroIntroBody, heroSlides, networkItems } from '$lib/content/homepage';

	const MOBILE_BREAKPOINT = 767;
	const EMAIL_ADDRESS = 'hi@barku.re';

	let contentShell: HTMLElement | null = null;
	let descriptionBlock: HTMLElement | null = null;
	let networkList: HTMLElement | null = null;
	let isContentPinned = $state(false);
	let hoveredNetworkAction = $state('');
	let hoveredNetworkTarget = $state('');

	const isExternalHref = (href: string) => href.startsWith('http');
	const isEmailHref = (href: string) => href.startsWith('mailto:');
	const getNetworkTarget = (href: string, label: string) => (isEmailHref(href) ? EMAIL_ADDRESS : label);
	const getNetworkAction = (href: string) => (isEmailHref(href) ? 'Write to' : 'Visit');

	const syncNetworkTarget = (href: string, label: string) => {
		hoveredNetworkAction = getNetworkAction(href);
		hoveredNetworkTarget = getNetworkTarget(href, label);
	};

	const clearNetworkTarget = () => {
		hoveredNetworkAction = '';
		hoveredNetworkTarget = '';
	};

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

		const revealNodes = [
			descriptionBlock,
			...(networkList ? Array.from(networkList.children) : []),
		].filter((node): node is HTMLElement => !!node);

		let observer: IntersectionObserver | undefined;
		if ('IntersectionObserver' in window && revealNodes.length > 0) {
			observer = new IntersectionObserver(
				(entries) => {
					for (const entry of entries) {
						if (entry.isIntersecting) {
							entry.target.classList.add('is-in');
							observer?.unobserve(entry.target);
						}
					}
				},
				{ threshold: 0.2 },
			);

			revealNodes.forEach((node, index) => {
				node.classList.add('reveal');
				node.style.transitionDelay = `${Math.min(index * 70, 420)}ms`;
				observer?.observe(node);
			});
		}

		return () => {
			window.removeEventListener('scroll', syncPinnedState);
			window.removeEventListener('resize', syncPinnedState);
			observer?.disconnect();
		};
	});
</script>

<svelte:head>
	<title>Barkure</title>
	<meta name="description" content="Builder / Open Sourceror / Toolmaker" />
	<meta name="theme-color" content="#0c0d12" />
	<link rel="preload" as="image" href="/images/me/1.webp" />
</svelte:head>

<div class="site-shell bg-(--color-bg-darken) text-(--color-text)">
	<section class="first-view">
		<header class="hero-copy">
			<h1 class="hero-title">
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
		<section class="description-block" lang="en" bind:this={descriptionBlock}>
			<p>
				Hi, I'm <span class="hero-intro-name" style="color: var(--hero-title-color);">Barkure</span
				>,
				{heroIntroBody}
			</p>
		</section>

		<section class="tag-block">
			<ul bind:this={networkList}>
				{#each networkItems as item}
					<li class="network-item">
						<a
							class="tag-item"
							href={item.href}
							target={isExternalHref(item.href) ? '_blank' : undefined}
							rel={isExternalHref(item.href) ? 'noreferrer' : undefined}
							aria-label={item.label}
							onmouseenter={() => syncNetworkTarget(item.href, item.label)}
							onmouseleave={clearNetworkTarget}
							onfocus={() => syncNetworkTarget(item.href, item.label)}
							onblur={clearNetworkTarget}
						>
							<span class="tag-icon" class:is-x-icon={item.icon === 'lineicons:x'}>
								<Icon icon={item.icon} />
							</span>
							<span class="tag-label">{item.label}</span>
						</a>
					</li>
				{/each}
			</ul>
			<p class="tag-target" aria-live="polite">
				{#if hoveredNetworkAction}
					<span class="tag-target-prefix">{hoveredNetworkAction}</span>
					{hoveredNetworkTarget}
				{/if}
			</p>
		</section>
	</main>
</div>
