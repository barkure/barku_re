<script lang="ts">
	import { onMount } from 'svelte';

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
	const intensity = 0.3;

	const vertexShaderSource = `
		attribute vec2 aPosition;
		varying vec2 vUv;

		void main() {
			vUv = aPosition * 0.5 + 0.5;
			gl_Position = vec4(aPosition, 0.0, 1.0);
		}
	`;

	const fragmentShaderSource = `
		precision mediump float;

		varying vec2 vUv;

		uniform sampler2D uCurrentImage;
		uniform sampler2D uNextImage;
		uniform float uDispFactor;
		uniform float uIntensity;

		float luminance(vec4 color) {
			return dot(color.rgb, vec3(0.299, 0.587, 0.114));
		}

		void main() {
			vec2 uv = vUv;
			vec4 currentSample = texture2D(uCurrentImage, uv);
			vec4 nextSample = texture2D(uNextImage, uv);

			float nextLum = luminance(nextSample);
			float currentLum = luminance(currentSample);

			vec2 currentUv = vec2(uv.x, uv.y + uDispFactor * nextLum * uIntensity);
			vec2 nextUv = vec2(uv.x, uv.y + (1.0 - uDispFactor) * currentLum * uIntensity);

			vec4 currentDistorted = texture2D(uCurrentImage, currentUv);
			vec4 nextDistorted = texture2D(uNextImage, nextUv);

			gl_FragColor = mix(currentDistorted, nextDistorted, uDispFactor);
		}
	`;

	const easeInOutExpo = (t: number) => {
		if (t === 0) return 0;
		if (t === 1) return 1;
		if (t < 0.5) return Math.pow(2, 20 * t - 10) / 2;
		return (2 - Math.pow(2, -20 * t + 10)) / 2;
	};

	let stage: HTMLDivElement | null = null;

	onMount(() => {
		if (!stage || slides.length === 0) {
			return;
		}

		let cancelled = false;
		let transitionRafId = 0;
		let transitionTimeout: ReturnType<typeof setTimeout> | undefined;
		let currentIndex = 0;
		let isTransitioning = false;
		let textures: Array<WebGLTexture | undefined> = Array(slides.length);
		let gl: WebGLRenderingContext | null = null;
		let program: WebGLProgram | null = null;
		let buffer: WebGLBuffer | null = null;
		let canvas: HTMLCanvasElement | null = null;

		let uCurrentImage: WebGLUniformLocation | null = null;
		let uNextImage: WebGLUniformLocation | null = null;
		let uDispFactor: WebGLUniformLocation | null = null;
		let uIntensity: WebGLUniformLocation | null = null;

		let currentTexture: WebGLTexture | null = null;
		let nextTexture: WebGLTexture | null = null;
		let dispFactor = 0;

		let renderScene = () => {};
		let resize = () => {};
		let syncVisibility = () => {};
		let queueTransition = (_wait: number) => {};

		const createShader = (type: number, source: string) => {
			if (!gl) return null;
			const shader = gl.createShader(type);
			if (!shader) return null;
			gl.shaderSource(shader, source);
			gl.compileShader(shader);
			if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
				const info = gl.getShaderInfoLog(shader);
				gl.deleteShader(shader);
				throw new Error(info || 'Shader compile failed');
			}
			return shader;
		};

		const createProgram = (vertSrc: string, fragSrc: string) => {
			if (!gl) return null;
			const vert = createShader(gl.VERTEX_SHADER, vertSrc);
			const frag = createShader(gl.FRAGMENT_SHADER, fragSrc);
			if (!vert || !frag) return null;

			const prog = gl.createProgram();
			if (!prog) return null;
			gl.attachShader(prog, vert);
			gl.attachShader(prog, frag);
			gl.linkProgram(prog);
			gl.deleteShader(vert);
			gl.deleteShader(frag);

			if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
				const info = gl.getProgramInfoLog(prog);
				gl.deleteProgram(prog);
				throw new Error(info || 'Program link failed');
			}
			return prog;
		};

		const bindTextureUnit = (unit: number, texture: WebGLTexture | null, location: WebGLUniformLocation | null) => {
			if (!gl || !location) return;
			gl.activeTexture(gl.TEXTURE0 + unit);
			gl.bindTexture(gl.TEXTURE_2D, texture);
			gl.uniform1i(location, unit);
		};

		renderScene = () => {
			if (cancelled || !gl || !program) return;

			gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
			gl.clearColor(0, 0, 0, 0);
			gl.clear(gl.COLOR_BUFFER_BIT);

			if (!currentTexture || !nextTexture) return;

			gl.useProgram(program);
			bindTextureUnit(0, currentTexture, uCurrentImage);
			bindTextureUnit(1, nextTexture, uNextImage);
			gl.uniform1f(uDispFactor, dispFactor);
			gl.uniform1f(uIntensity, intensity);
			gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		};

		const loadImage = (src: string) =>
			new Promise<HTMLImageElement>((resolve, reject) => {
				const image = new Image();
				image.decoding = 'async';
				image.onload = () => resolve(image);
				image.onerror = () => reject(new Error(`Failed to load ${src}`));
				image.src = src;
			});

		const createTextureFromImage = (image: HTMLImageElement) => {
			if (!gl) throw new Error('Missing GL context');
			const texture = gl.createTexture();
			if (!texture) throw new Error('Failed to create texture');

			gl.bindTexture(gl.TEXTURE_2D, texture);
			gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
			gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 0);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
			gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
			gl.bindTexture(gl.TEXTURE_2D, null);
			return texture;
		};

		const loadedTextureCount = () => textures.filter(Boolean).length;

		const getNextLoadedIndex = () => {
			for (let offset = 1; offset < textures.length; offset += 1) {
				const index = (currentIndex + offset) % textures.length;
				if (textures[index]) return index;
			}
			return null;
		};

		const loadSlideTexture = async (index: number) => {
			const image = await loadImage(slides[index].src);
			if (cancelled || !gl) return;
			const texture = createTextureFromImage(image);
			if (cancelled) {
				gl.deleteTexture(texture);
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
			if (transitionTimeout) clearTimeout(transitionTimeout);

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
			const fromTexture = textures[currentIndex];
			const nextIndex = getNextLoadedIndex();
			const toTexture = nextIndex === null ? undefined : textures[nextIndex];

			if (!fromTexture || !toTexture || nextIndex === null) {
				return;
			}

			isTransitioning = true;
			currentTexture = fromTexture;
			nextTexture = toTexture;
			dispFactor = 0;

			const startedAt = performance.now();

			const tick = (now: number) => {
				if (cancelled) return;

				const progress = Math.min((now - startedAt) / (transitionDuration * 1000), 1);
				dispFactor = easeInOutExpo(progress);
				renderScene();

				if (progress < 1) {
					transitionRafId = requestAnimationFrame(tick);
					return;
				}

				isTransitioning = false;
				currentIndex = nextIndex;
				currentTexture = toTexture;
				nextTexture = toTexture;
				dispFactor = 0;
				renderScene();
				queueTransition(gap);
			};

			transitionRafId = requestAnimationFrame(tick);
		};

		syncVisibility = () => {
			if (document.hidden) {
				if (transitionTimeout) clearTimeout(transitionTimeout);
				cancelAnimationFrame(transitionRafId);
				isTransitioning = false;
				return;
			}

			renderScene();
			queueTransition(gap);
		};

		resize = () => {
			if (!stage || !canvas || !gl) return;

			const maxPixelRatio = window.innerWidth <= mobileBreakpoint ? 1.25 : 1.75;
			const pixelRatio = Math.min(window.devicePixelRatio || 1, maxPixelRatio);
			const size = Math.min(stage.clientWidth, stage.clientHeight);
			const bufferSize = Math.max(1, Math.round(size * pixelRatio));

			if (canvas.width !== bufferSize || canvas.height !== bufferSize) {
				canvas.width = bufferSize;
				canvas.height = bufferSize;
			}

			canvas.style.width = `${size}px`;
			canvas.style.height = `${size}px`;
			renderScene();
		};

		try {
			canvas = document.createElement('canvas');
			canvas.setAttribute('aria-hidden', 'true');
			gl = canvas.getContext('webgl', {
				alpha: true,
				antialias: false,
				depth: false,
				stencil: false,
				premultipliedAlpha: true,
				powerPreference: 'low-power',
			});

			if (!gl) {
				throw new Error('WebGL unavailable');
			}

			program = createProgram(vertexShaderSource, fragmentShaderSource);
			if (!program) throw new Error('Failed to create program');

			gl.useProgram(program);
			uCurrentImage = gl.getUniformLocation(program, 'uCurrentImage');
			uNextImage = gl.getUniformLocation(program, 'uNextImage');
			uDispFactor = gl.getUniformLocation(program, 'uDispFactor');
			uIntensity = gl.getUniformLocation(program, 'uIntensity');

			buffer = gl.createBuffer();
			gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
			gl.bufferData(
				gl.ARRAY_BUFFER,
				new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]),
				gl.STATIC_DRAW,
			);

			const aPosition = gl.getAttribLocation(program, 'aPosition');
			gl.enableVertexAttribArray(aPosition);
			gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, 0, 0);

			gl.disable(gl.DEPTH_TEST);
			gl.enable(gl.BLEND);
			gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

			stage.appendChild(canvas);
			resize();
			window.addEventListener('resize', resize);
			document.addEventListener('visibilitychange', syncVisibility);

			void (async () => {
				try {
					const firstTexture = await loadSlideTexture(0);
					if (!firstTexture || cancelled) return;

					currentTexture = firstTexture;
					nextTexture = firstTexture;
					dispFactor = 0;
					renderScene();

					if (slides.length > 1) {
						await loadSlideTexture(1);
						if (!cancelled && textures[1]) {
							nextTexture = textures[1] ?? firstTexture;
							queueTransition(initialDelay);
						}
						void preloadRemainingTextures(2);
					}
				} catch (error) {
					console.error(`Failed to load slider image: ${slides[0].src}`, error);
				}
			})();
		} catch (error) {
			console.error('Failed to initialize slider', error);
		}

		return () => {
			cancelled = true;
			window.removeEventListener('resize', resize);
			document.removeEventListener('visibilitychange', syncVisibility);
			if (transitionTimeout) clearTimeout(transitionTimeout);
			cancelAnimationFrame(transitionRafId);

			if (gl) {
				for (const texture of textures) {
					if (texture) gl.deleteTexture(texture);
				}
				if (buffer) gl.deleteBuffer(buffer);
				if (program) gl.deleteProgram(program);
				const ext = gl.getExtension('WEBGL_lose_context');
				ext?.loseContext();
			}

			if (canvas && stage?.contains(canvas)) {
				stage.removeChild(canvas);
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
		flex-shrink: 0;
		height: min(96vw, 62rem, calc(100vh - 11rem));
		width: min(96vw, 62rem, calc(100vh - 11rem));
		transform: scale(0.98);
		transform-origin: 50% 100%;
	}

	.slider-stage::after {
		content: "";
		position: absolute;
		inset: 0;
		pointer-events: none;
		--dot-cell: calc(var(--dot-mask-size) / 5);
		background-image: radial-gradient(
			circle,
			var(--color-bg) calc(var(--dot-cell) * 0.36),
			transparent calc(var(--dot-cell) * 0.36 + 0.5px)
		);
		background-size: var(--dot-cell) var(--dot-cell);
		opacity: var(--slider-dot-opacity, 0.5);
	}

	.slider-stage :global(canvas) {
		display: block;
		height: 100%;
		width: 100%;
		filter: brightness(var(--slider-photo-brightness, 1));
	}

	@media (max-width: 767px) {
		.slider-stage {
			height: min(108vw, 36rem);
			width: min(108vw, 36rem);
			transform: scale(1.16);
		}
	}
</style>
