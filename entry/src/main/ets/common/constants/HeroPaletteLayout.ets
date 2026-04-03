export interface HeroPaletteCardLayout {
  width: number;
  height: number;
  left: number;
  top: number;
  angle: number;
}

export const HERO_PALETTE_BASE_SIZE: number = 320;

export const HERO_MAIN_CARD_LAYOUT: HeroPaletteCardLayout = {
  width: 240,
  height: 260,
  left: 0,
  top: 0,
  angle: 5
};

export const HERO_SECONDARY_CARD_LAYOUT: HeroPaletteCardLayout = {
  width: 176,
  height: 180,
  left: 144,
  top: 120,
  angle: -5
};

export const HERO_ACCENT_CARD_LAYOUT: HeroPaletteCardLayout = {
  width: 112,
  height: 100,
  left: 48,
  top: 220,
  angle: 0
};

export function scaleHeroPaletteValue(value: number, targetHeight: number): number {
  return Math.max(1, Math.round((value * targetHeight) / HERO_PALETTE_BASE_SIZE));
}

export function scaleHeroPaletteLayout(layout: HeroPaletteCardLayout, targetHeight: number): HeroPaletteCardLayout {
  return {
    width: scaleHeroPaletteValue(layout.width, targetHeight),
    height: scaleHeroPaletteValue(layout.height, targetHeight),
    left: scaleHeroPaletteValue(layout.left, targetHeight),
    top: scaleHeroPaletteValue(layout.top, targetHeight),
    angle: layout.angle
  };
}