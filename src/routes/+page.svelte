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
	let copyNoticeVisible = $state(false);
	let copyNoticeTimeout: ReturnType<typeof setTimeout> | undefined;

	const isExternalHref = (href: string) => !href.startsWith('/');
	const isEmailHref = (href: string) => href.startsWith('mailto:');
	const getNetworkTarget = (href: string, label: string) => (isEmailHref(href) ? EMAIL_ADDRESS : label);
	const getNetworkAction = (href: string) => (isEmailHref(href) ? 'Email:' : 'Go to:');

	const syncNetworkTarget = (href: string, label: string) => {
		hoveredNetworkAction = getNetworkAction(href);
		hoveredNetworkTarget = getNetworkTarget(href, label);
	};

	const clearNetworkTarget = () => {
		hoveredNetworkAction = '';
		hoveredNetworkTarget = '';
	};

	const copyEmailAddress = async () => {
		await navigator.clipboard.writeText(EMAIL_ADDRESS);
		hoveredNetworkAction = 'Copied!';
		hoveredNetworkTarget = '';
		copyNoticeVisible = true;
		if (copyNoticeTimeout) clearTimeout(copyNoticeTimeout);
		copyNoticeTimeout = setTimeout(() => {
			copyNoticeVisible = false;
			copyNoticeTimeout = undefined;
		}, 2000);
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
			if (copyNoticeTimeout) clearTimeout(copyNoticeTimeout);
		};
	});
</script>

<svelte:head>
	<title>Barkure</title>
	<meta name="description" content="Builder / Open Sourceror / Toolmaker" />
	<meta name="theme-color" content="#0b0b0b" />
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
						{#if isEmailHref(item.href)}
							<button
								class="tag-item"
								type="button"
								aria-label="Copy email address"
								onmouseenter={() => syncNetworkTarget(item.href, item.label)}
								onmouseleave={clearNetworkTarget}
								onfocus={() => syncNetworkTarget(item.href, item.label)}
								onblur={clearNetworkTarget}
								onclick={copyEmailAddress}
							>
								<span class="tag-icon" class:is-x-icon={item.icon === 'lineicons:x'}>
									<Icon icon={item.icon} />
								</span>
								<span class="tag-label">{item.label}</span>
							</button>
						{:else}
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
						{/if}
					</li>
				{/each}
			</ul>
			<p class="tag-target" aria-live="polite">
				{#if hoveredNetworkAction}
					<span class="tag-target-prefix">{hoveredNetworkAction}</span>
					{hoveredNetworkTarget}
				{/if}
			</p>
			{#if copyNoticeVisible}
				<p class="copy-notice" aria-live="polite">Copied to clipboard.</p>
			{/if}
		</section>
	</main>
</div>
