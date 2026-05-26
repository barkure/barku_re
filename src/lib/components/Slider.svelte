<script lang="ts">
	import { onMount } from 'svelte';
	import {
		LinearFilter,
		Mesh,
		OrthographicCamera,
		PlaneGeometry,
		Scene,
		ShaderMaterial,
		TextureLoader,
		Vector2,
		WebGLRenderer,
		type Texture,
	} from 'three';

	type Slide = {
		src: string;
		alt: string;
	};

	let {
		slides,
		gap = 800,
		initialDelay = gap,
	} = $props<{
		slides: Slide[];
		gap?: number;
		initialDelay?: number;
	}>();

	const transitionDuration = 2;
	const mobileBreakpoint = 767;
	let stage: HTMLDivElement | null = null;

	const vertexShader = `
		varying vec2 vUv;

		void main() {
			vUv = uv;
			gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
		}
	`;

	const fragmentShader = `
		varying vec2 vUv;

		uniform sampler2D currentImage;
		uniform sampler2D nextImage;
		uniform float dispFactor;
		uniform float intensity;
		uniform vec2 resolution;

		float luminance(vec4 color) {
			return dot(color.rgb, vec3(0.299, 0.587, 0.114));
		}

		void main() {
			vec2 uv = vUv;
			vec4 currentSample = texture2D(currentImage, uv);
			vec4 nextSample = texture2D(nextImage, uv);

			float nextLum = luminance(nextSample);
			float currentLum = luminance(currentSample);

			vec2 currentUv = vec2(uv.x, uv.y + dispFactor * nextLum * intensity);
			vec2 nextUv = vec2(uv.x, uv.y + (1.0 - dispFactor) * currentLum * intensity);

			vec4 currentDistorted = texture2D(currentImage, currentUv);
			vec4 nextDistorted = texture2D(nextImage, nextUv);

			gl_FragColor = mix(currentDistorted, nextDistorted, dispFactor);
		}
	`;

	const easeInOutExpo = (t: number) => {
		if (t === 0) return 0;
		if (t === 1) return 1;
		if (t < 0.5) return Math.pow(2, 20 * t - 10) / 2;
		return (2 - Math.pow(2, -20 * t + 10)) / 2;
	};

	onMount(() => {
		if (!stage || slides.length === 0) {
			return;
		}

		let cancelled = false;
		let transitionRafId = 0;
		let transitionTimeout: ReturnType<typeof setTimeout> | undefined;
		let currentIndex = 0;
		let isTransitioning = false;
		let textures: Texture[] = [];

		const renderer = new WebGLRenderer({
			alpha: true,
			antialias: false,
			powerPreference: 'low-power',
		});
		renderer.setClearColor(0x000000, 0);

		const scene = new Scene();
		const camera = new OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
		camera.position.z = 1;

		const material = new ShaderMaterial({
			uniforms: {
				currentImage: { value: null },
				nextImage: { value: null },
				dispFactor: { value: 0 },
				intensity: { value: 0.3 },
				resolution: { value: new Vector2(1, 1) },
			},
			vertexShader,
			fragmentShader,
			transparent: true,
		});

		const mesh = new Mesh(new PlaneGeometry(2, 2), material);
		scene.add(mesh);
		stage.appendChild(renderer.domElement);

		const renderScene = () => {
			if (!cancelled) {
				renderer.render(scene, camera);
			}
		};

		const updatePixelRatio = () => {
			const maxPixelRatio = window.innerWidth <= mobileBreakpoint ? 1.25 : 1.75;
			renderer.setPixelRatio(Math.min(window.devicePixelRatio, maxPixelRatio));
		};

		const resize = () => {
			if (!stage) return;
			updatePixelRatio();
			const size = Math.min(stage.clientWidth, stage.clientHeight);
			renderer.setSize(size, size, false);
			material.uniforms.resolution.value.set(size, size);
			renderScene();
		};

		const loader = new TextureLoader();
		const loadTexture = (src: string) =>
			new Promise<Texture>((resolve, reject) => {
				loader.load(
					src,
					(texture) => {
						texture.minFilter = LinearFilter;
						texture.magFilter = LinearFilter;
						resolve(texture);
					},
					undefined,
					reject,
				);
			});

		const queueTransition = (wait: number) => {
			if (transitionTimeout) {
				clearTimeout(transitionTimeout);
			}

			if (cancelled || document.hidden || textures.length <= 1) {
				return;
			}

			transitionTimeout = setTimeout(() => {
				if (!cancelled && !document.hidden && !isTransitioning) {
					startTransition();
				}
			}, wait);
		};

		const startTransition = () => {
			if (textures.length <= 1) {
				return;
			}

			isTransitioning = true;
			const nextIndex = (currentIndex + 1) % textures.length;
			material.uniforms.currentImage.value = textures[currentIndex];
			material.uniforms.nextImage.value = textures[nextIndex];
			material.uniforms.dispFactor.value = 0;

			const startedAt = performance.now();

			const tick = (now: number) => {
				if (cancelled) return;

				const progress = Math.min((now - startedAt) / (transitionDuration * 1000), 1);
				material.uniforms.dispFactor.value = easeInOutExpo(progress);
				renderScene();

				if (progress < 1) {
					transitionRafId = requestAnimationFrame(tick);
					return;
				}

				isTransitioning = false;
				currentIndex = nextIndex;
				material.uniforms.currentImage.value = textures[currentIndex];
				material.uniforms.dispFactor.value = 0;
				renderScene();
				queueTransition(gap);
			};

			transitionRafId = requestAnimationFrame(tick);
		};

		const syncVisibility = () => {
			if (document.hidden) {
				if (transitionTimeout) {
					clearTimeout(transitionTimeout);
				}
				cancelAnimationFrame(transitionRafId);
				isTransitioning = false;
				return;
			}

			renderScene();
			queueTransition(gap);
		};

		resize();
		window.addEventListener('resize', resize);
		document.addEventListener('visibilitychange', syncVisibility);

		Promise.all(slides.map((slide: Slide) => loadTexture(slide.src))).then((loadedTextures) => {
			if (cancelled || loadedTextures.length === 0) {
				return;
			}

			textures = loadedTextures;
			material.uniforms.currentImage.value = loadedTextures[0];
			material.uniforms.nextImage.value = loadedTextures[loadedTextures.length > 1 ? 1 : 0];
			renderScene();

			queueTransition(initialDelay);
		});

		return () => {
			cancelled = true;
			window.removeEventListener('resize', resize);
			document.removeEventListener('visibilitychange', syncVisibility);
			if (transitionTimeout) clearTimeout(transitionTimeout);
			cancelAnimationFrame(transitionRafId);
			textures.forEach((texture) => texture.dispose());
			mesh.geometry.dispose();
			material.dispose();
			renderer.dispose();
			if (stage?.contains(renderer.domElement)) {
				stage.removeChild(renderer.domElement);
			}
		};
	});
</script>

<div class="slider-shell" aria-label="Barkure portraits">
	<div class="slider-stage" bind:this={stage}></div>
</div>

<style>
	.slider-shell {
		position: relative;
		display: flex;
		height: 100%;
		width: 100%;
		align-items: end;
		justify-content: center;
		overflow: hidden;
	}

	.slider-stage {
		position: relative;
		height: min(96vw, 62rem, calc(100vh - 11rem));
		width: min(96vw, 62rem, calc(100vh - 11rem));
		transform: scale(0.98);
		transform-origin: 50% 100%;
	}

	.slider-stage :global(canvas) {
		display: block;
		height: 100%;
		width: 100%;
	}

	@media (max-width: 767px) {
		.slider-stage {
			height: min(108vw, 36rem);
			width: min(108vw, 36rem);
			transform: scale(1.16);
		}
	}
</style>
