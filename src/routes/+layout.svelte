<script lang="ts">
	import { onMount } from 'svelte';
	import './layout.css';

	let { children } = $props();

	let scrollbarVisible = $state(false);
	let scrollbarActive = $state(false);
	let scrollbarStyle = $state('--scrollbar-thumb-top: 0px; --scrollbar-thumb-height: 72px;');

	const applyTheme = (next: 'dark' | 'light') => {
		document.documentElement.dataset.theme = next;
		document
			.querySelector('meta[name="theme-color"]')
			?.setAttribute('content', next === 'light' ? '#f4f4f4' : '#0b0b0b');
	};

	onMount(() => {
		const media = window.matchMedia('(prefers-color-scheme: dark)');
		const syncTheme = () => applyTheme(media.matches ? 'dark' : 'light');
		syncTheme();
		media.addEventListener('change', syncTheme);

		let frameId = 0;
		let scrollIdleTimeout: ReturnType<typeof setTimeout> | undefined;

		const showScrollbar = () => {
			scrollbarActive = true;
			if (scrollIdleTimeout) clearTimeout(scrollIdleTimeout);
			scrollIdleTimeout = setTimeout(() => {
				scrollbarActive = false;
				scrollIdleTimeout = undefined;
			}, 500);
		};

		const syncScrollbar = () => {
			frameId = 0;

			const viewportHeight = window.innerHeight;
			const scrollHeight = Math.max(
				document.documentElement.scrollHeight,
				document.body.scrollHeight,
			);
			const maxScroll = Math.max(0, scrollHeight - viewportHeight);

			if (maxScroll <= 1) {
				scrollbarVisible = false;
				scrollbarActive = false;
				return;
			}

			const scrollRatio = Math.min(1, Math.max(0, window.scrollY / maxScroll));
			const thumbMinHeight = 80;
			const thumbMaxHeight = 400;
			const thumbPeak = Math.sin(scrollRatio * Math.PI);
			const thumbHeight = Math.round(
				thumbMinHeight + (thumbMaxHeight - thumbMinHeight) * thumbPeak,
			);
			const thumbTop = Math.round(scrollRatio * Math.max(0, viewportHeight - thumbHeight));

			scrollbarStyle = `--scrollbar-thumb-top: ${thumbTop}px; --scrollbar-thumb-height: ${thumbHeight}px;`;
			scrollbarVisible = true;
		};

		const queueScrollbarSync = () => {
			if (frameId) return;
			frameId = window.requestAnimationFrame(syncScrollbar);
		};

		const handleScroll = () => {
			showScrollbar();
			queueScrollbarSync();
		};

		const resizeObserver = new ResizeObserver(queueScrollbarSync);
		resizeObserver.observe(document.documentElement);
		resizeObserver.observe(document.body);

		syncScrollbar();
		window.addEventListener('scroll', handleScroll, { passive: true });
		window.addEventListener('resize', queueScrollbarSync);
		window.addEventListener('load', queueScrollbarSync);

		return () => {
			media.removeEventListener('change', syncTheme);
			if (frameId) window.cancelAnimationFrame(frameId);
			if (scrollIdleTimeout) clearTimeout(scrollIdleTimeout);
			resizeObserver.disconnect();
			window.removeEventListener('scroll', handleScroll);
			window.removeEventListener('resize', queueScrollbarSync);
			window.removeEventListener('load', queueScrollbarSync);
		};
	});
</script>

<svelte:head><link rel="icon" href="/favicon.svg" /></svelte:head>
{@render children()}
<div
	class="pixel-scrollbar"
	class:is-visible={scrollbarVisible && scrollbarActive}
	style={scrollbarStyle}
	aria-hidden="true"
>
	<div class="pixel-scrollbar-thumb"></div>
</div>
