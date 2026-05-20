import { heroTitleColors } from "$lib/content/homepage";

export function load() {
  return {
    heroTitleColor:
      heroTitleColors[Math.floor(Math.random() * heroTitleColors.length)] ?? heroTitleColors[0],
  };
}
