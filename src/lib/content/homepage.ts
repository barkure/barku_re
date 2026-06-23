export type Slide = {
  src: string;
};

export type NetworkItem = {
  icon: string;
  label: string;
  href: string;
};

export const heroIntroBody =
  "a geophysics student at Central South University, and I do a bit of development.";

export const heroSlides: Slide[] = [
  { src: "/images/me/1.webp" },
  { src: "/images/me/2.webp" },
  { src: "/images/me/3.webp" },
  { src: "/images/me/4.webp" },
  { src: "/images/me/5.webp" },
  { src: "/images/me/6.webp" },
];

export const networkItems: NetworkItem[] = [
  {
    icon: "mdi:fountain-pen-tip",
    label: "Blog",
    href: "https://blog.barku.re",
  },
  {
    icon: "mdi:github",
    label: "GitHub",
    href: "https://github.com/barkure",
  },
  {
    icon: "mdi:telegram",
    label: "Telegram",
    href: "https://t.me/barkure",
  },
  {
    icon: "lineicons:x",
    label: "X, formerly Twitter",
    href: "https://x.com/TheBarkure",
  },
  {
    icon: "mdi:email",
    label: "Email",
    href: "mailto:hi@barku.re",
  },
  {
    icon: "bx:link",
    label: "Links",
    href: "/links",
  },
  {
    icon: "mdi:train",
    label: "Travelling",
    href: "https://www.travellings.cn/go.html",
  },
];
