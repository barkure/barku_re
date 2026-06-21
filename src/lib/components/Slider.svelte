<script lang="ts">
	import { onMount } from 'svelte';
	import type { Texture } from 'three';

	type Slide = {
		src: string;
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
		let textures: Array<Texture | undefined> = Array(slides.length);
		let renderer: import('three').WebGLRenderer | undefined;
		let mesh: import('three').Mesh | undefined;
		let material: import('three').ShaderMaterial | undefined;
		let renderScene = () => {};
		let resize = () => {};
		let syncVisibility = () => {};
		let queueTransition = (_wait: number) => {};

		void (async () => {
			const {
				LinearFilter,
				Mesh,
				OrthographicCamera,
				PlaneGeometry,
				Scene,
				ShaderMaterial,
				TextureLoader,
				WebGLRenderer,
			} = await import('three');

			if (cancelled || !stage) return;

			renderer = new WebGLRenderer({
				alpha: true,
				antialias: false,
				powerPreference: 'low-power',
			});
			renderer.setClearColor(0x000000, 0);

			const scene = new Scene();
			const camera = new OrthographicCamera(-1, 1, 1, -1, 0.1, 10);
			camera.position.z = 1;

			material = new ShaderMaterial({
				uniforms: {
					currentImage: { value: null },
					nextImage: { value: null },
					dispFactor: { value: 0 },
					intensity: { value: 0.3 },
				},
				vertexShader,
				fragmentShader,
				transparent: true,
			});

			mesh = new Mesh(new PlaneGeometry(2, 2), material);
			scene.add(mesh);
			stage.appendChild(renderer.domElement);

			renderScene = () => {
				if (!cancelled && renderer) {
					renderer.render(scene, camera);
				}
			};

			const updatePixelRatio = () => {
				const maxPixelRatio = window.innerWidth <= mobileBreakpoint ? 1.25 : 1.75;
				renderer?.setPixelRatio(Math.min(window.devicePixelRatio, maxPixelRatio));
			};

			resize = () => {
				if (!stage || !renderer) return;
				updatePixelRatio();
				const size = Math.min(stage.clientWidth, stage.clientHeight);
				renderer.setSize(size, size, false);
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

			const loadedTextureCount = () => textures.filter(Boolean).length;

			const getNextLoadedIndex = () => {
				for (let offset = 1; offset < textures.length; offset += 1) {
					const index = (currentIndex + offset) % textures.length;
					if (textures[index]) return index;
				}

				return null;
			};

			const loadSlideTexture = async (index: number) => {
				const texture = await loadTexture(slides[index].src);
				if (cancelled) {
					texture.dispose();
					return;
				}

				textures[index] = texture;
				return texture;
			};

			const preloadRemainingTextures = async (startIndex: number) => {
				for (let index = startIndex; index < slides.length; index += 1) {
					if (cancelled) return;

					try {
						await loadSlideTexture(index);
						if (loadedTextureCount() > 1 && !isTransitioning && !transitionTimeout) {
							queueTransition(gap);
						}
					} catch (error) {
						console.error(`Failed to load slider image: ${slides[index].src}`, error);
					}
				}
			};

			queueTransition = (wait: number) => {
				if (transitionTimeout) {
					clearTimeout(transitionTimeout);
				}

				if (cancelled || document.hidden || loadedTextureCount() <= 1) {
					return;
				}

				transitionTimeout = setTimeout(() => {
					transitionTimeout = undefined;
					if (!cancelled && !document.hidden && !isTransitioning) {
						startTransition();
					}
				}, wait);
			};

			const startTransition = () => {
				if (!material) return;

				const currentTexture = textures[currentIndex];
				const nextIndex = getNextLoadedIndex();
				const nextTexture = nextIndex === null ? undefined : textures[nextIndex];

				if (!currentTexture || !nextTexture || nextIndex === null) {
					return;
				}

				isTransitioning = true;
				material.uniforms.currentImage.value = currentTexture;
				material.uniforms.nextImage.value = nextTexture;
				material.uniforms.dispFactor.value = 0;

				const startedAt = performance.now();

				const tick = (now: number) => {
					if (cancelled || !material) return;

					const progress = Math.min((now - startedAt) / (transitionDuration * 1000), 1);
					material.uniforms.dispFactor.value = easeInOutExpo(progress);
					renderScene();

					if (progress < 1) {
						transitionRafId = requestAnimationFrame(tick);
						return;
					}

					isTransitioning = false;
					currentIndex = nextIndex;
					material.uniforms.currentImage.value = nextTexture;
					material.uniforms.dispFactor.value = 0;
					renderScene();
					queueTransition(gap);
				};

				transitionRafId = requestAnimationFrame(tick);
			};

			syncVisibility = () => {
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

			try {
				const firstTexture = await loadSlideTexture(0);
				if (!firstTexture || !material) return;

				material.uniforms.currentImage.value = firstTexture;
				material.uniforms.nextImage.value = firstTexture;
				renderScene();

				if (slides.length > 1) {
					await loadSlideTexture(1);
					if (!cancelled && textures[1]) {
						material.uniforms.nextImage.value = textures[1];
						queueTransition(initialDelay);
					}

					void preloadRemainingTextures(2);
				}
			} catch (error) {
				console.error(`Failed to load slider image: ${slides[0].src}`, error);
			}
		})();

		return () => {
			cancelled = true;
			window.removeEventListener('resize', resize);
			document.removeEventListener('visibilitychange', syncVisibility);
			if (transitionTimeout) clearTimeout(transitionTimeout);
			cancelAnimationFrame(transitionRafId);
			textures.forEach((texture) => texture?.dispose());
			mesh?.geometry.dispose();
			material?.dispose();
			renderer?.dispose();
			if (renderer && stage?.contains(renderer.domElement)) {
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
