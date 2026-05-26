import tailwindcss from "@tailwindcss/vite";
import { sveltekit } from "@sveltejs/kit/vite";

const config = {
  plugins: [...tailwindcss(), sveltekit()],
};

export default config;
