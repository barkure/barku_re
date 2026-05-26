<script lang="ts">
	import type { IconName } from '$lib/content/homepage';

	let { name } = $props<{
		name: IconName;
	}>();
</script>

{#if name === 'blog'}
	<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
		<path
			d="M6.94 14.033a30 30 0 0 0-.606 1.783c.96-.697 2.101-1.14 3.418-1.304c2.513-.314 4.746-1.973 5.876-4.058l-1.456-1.455l1.413-1.415l1-1.002c.43-.429.915-1.224 1.428-2.367c-5.593.867-9.018 4.291-11.074 9.818M17 8.997l1 1c-1 3-4 6-8 6.5q-4.003.5-5.002 5.5H3c1-6 3-20 18-20q-1.5 4.496-2.997 5.997z"
			fill="currentColor"
		/>
	</svg>
{:else if name === 'github'}
	<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
		<path
			d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5c.08-1.25-.27-2.48-1-3.5c.28-1.15.28-2.35 0-3.5c0 0-1 0-3 1.5c-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.4 5.4 0 0 0 4 9c0 3.5 3 5.5 6 5.5c-.39.49-.68 1.05-.85 1.65S8.93 17.38 9 18v4"
			fill="none"
			stroke="currentColor"
			stroke-linecap="round"
			stroke-linejoin="round"
			stroke-width="2"
		/>
		<path
			d="M9 18c-4.51 2-5-2-7-2"
			fill="none"
			stroke="currentColor"
			stroke-linecap="round"
			stroke-linejoin="round"
			stroke-width="2"
		/>
	</svg>
{:else if name === 'telegram'}
	<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
		<path
			d="M21 5L2 12.5l7 1M21 5l-2.5 15L9 13.5M21 5L9 13.5m0 0V19l3.249-3.277"
			fill="none"
			stroke="currentColor"
			stroke-linecap="round"
			stroke-linejoin="round"
			stroke-width="1.5"
		/>
	</svg>
{:else if name === 'email'}
	<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
		<path
			d="m22 7l-8.991 5.727a2 2 0 0 1-2.009 0L2 7"
			fill="none"
			stroke="currentColor"
			stroke-linecap="round"
			stroke-linejoin="round"
			stroke-width="2"
		/>
		<rect
			width="20"
			height="16"
			x="2"
			y="4"
			rx="2"
			fill="none"
			stroke="currentColor"
			stroke-linejoin="round"
			stroke-width="2"
		/>
	</svg>
{:else if name === 'friends'}
	<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
		<path
			d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"
			fill="none"
			stroke="currentColor"
			stroke-linecap="round"
			stroke-linejoin="round"
			stroke-width="2"
		/>
		<path
			d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"
			fill="none"
			stroke="currentColor"
			stroke-linecap="round"
			stroke-linejoin="round"
			stroke-width="2"
		/>
	</svg>
{:else}
	<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
		<path
			d="M17.8 19.2L16 11l3.5-3.5C21 6 21.5 4 21 3c-1-.5-3 0-4.5 1.5L13 8L4.8 6.2c-.5-.1-.9.1-1.1.5l-.3.5c-.2.5-.1 1 .3 1.3L9 12l-2 3H4l-1 1l3 2l2 3l1-1v-3l3-2l3.5 5.3c.3.4.8.5 1.3.3l.5-.2c.4-.3.6-.7.5-1.2"
			fill="none"
			stroke="currentColor"
			stroke-linecap="round"
			stroke-linejoin="round"
			stroke-width="2"
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
