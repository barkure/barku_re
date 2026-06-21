export type Slide = {
  src: string;
};

export type NetworkItem = {
  icon: IconName;
  label: string;
  href: string;
  color: string;
};

export type IconName = "blog" | "github" | "telegram" | "email" | "friends" | "travelling";

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
    icon: "blog",
    label: "Blog",
    href: "https://blog.barku.re",
    color: "rgb(255, 128, 0)",
  },
  {
    icon: "github",
    label: "GitHub",
    href: "https://github.com/barkure",
    color: "rgb(168, 85, 247)",
  },
  {
    icon: "telegram",
    label: "Telegram",
    href: "https://t.me/barkure",
    color: "rgb(0, 255, 255)",
  },
  {
    icon: "email",
    label: "Email",
    href: "mailto:XINYAO_QI@outlook.com",
    color: "rgb(230, 6, 215)",
  },
  {
    icon: "friends",
    label: "Links",
    href: "/links",
    color: "rgb(26, 255, 0)",
  },
  {
    icon: "travelling",
    label: "Travelling",
    href: "https://www.travellings.cn/go.html",
    color: "rgb(255, 242, 0)",
  },
];
