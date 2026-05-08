import { image } from '@kit.ImageKit';
import { hexToRgb888 } from './HexColor';

export const WALLPAPER_STYLE_BLOCKS_ID: string = 'wallpaper_blocks_v1';
export const WALLPAPER_STYLE_COLLAGE_ID: string = 'wallpaper_collage_v1';
export const WALLPAPER_STYLE_GRADIENT_ID: string = 'wallpaper_gradient_v1';
export const WALLPAPER_STYLE_MIST_ID: string = 'wallpaper_mist_v1';

export const WALLPAPER_VARIANT_A_ID: string = 'variant_a';
export const WALLPAPER_VARIANT_B_ID: string = 'variant_b';
export const WALLPAPER_VARIANT_C_ID: string = 'variant_c';

export const WALLPAPER_STYLE_IDS: string[] = [
  WALLPAPER_STYLE_BLOCKS_ID,
  WALLPAPER_STYLE_COLLAGE_ID,
  WALLPAPER_STYLE_GRADIENT_ID,
  WALLPAPER_STYLE_MIST_ID
];

export const WALLPAPER_VARIANT_IDS: string[] = [
  WALLPAPER_VARIANT_A_ID,
  WALLPAPER_VARIANT_B_ID,
  WALLPAPER_VARIANT_C_ID
];

function blendPixel(buf: Uint8Array, index: number, r: number, g: number, b: number, alpha: number): void {
  if (alpha <= 0) {
    return;
  }
  if (alpha >= 255) {
    buf[index] = b;
    buf[index + 1] = g;
    buf[index + 2] = r;
    buf[index + 3] = 255;
    return;
  }
  const inv: number = 255 - alpha;
  buf[index] = Math.round((b * alpha + buf[index] * inv) / 255);
  buf[index + 1] = Math.round((g * alpha + buf[index + 1] * inv) / 255);
  buf[index + 2] = Math.round((r * alpha + buf[index + 2] * inv) / 255);
  buf[index + 3] = 255;
}

function fillRect(
  buf: Uint8Array,
  width: number,
  height: number,
  x0: number,
  y0: number,
  x1: number,
  y1: number,
  r: number,
  g: number,
  b: number
): void {
  const xStart: number = Math.max(0, Math.floor(x0));
  const yStart: number = Math.max(0, Math.floor(y0));
  const xEnd: number = Math.min(width, Math.ceil(x1));
  const yEnd: number = Math.min(height, Math.ceil(y1));
  for (let y: number = yStart; y < yEnd; y++) {
    for (let x: number = xStart; x < xEnd; x++) {
      const i: number = (y * width + x) * 4;
      buf[i] = b;
      buf[i + 1] = g;
      buf[i + 2] = r;
      buf[i + 3] = 255;
    }
  }
}

function isInsideRoundedRect(x: number, y: number, x0: number, y0: number, x1: number, y1: number, radius: number): boolean {
  if (radius <= 0) {
    return x >= x0 && x < x1 && y >= y0 && y < y1;
  }
  const left: number = x0 + radius;
  const right: number = x1 - radius;
  const top: number = y0 + radius;
  const bottom: number = y1 - radius;
  if (x >= left && x < right) {
    return y >= y0 && y < y1;
  }
  if (y >= top && y < bottom) {
    return x >= x0 && x < x1;
  }
  const cx: number = x < left ? left : right;
  const cy: number = y < top ? top : bottom;
  const dx: number = x - cx;
  const dy: number = y - cy;
  return dx * dx + dy * dy <= radius * radius;
}

function fillRoundedRect(
  buf: Uint8Array,
  width: number,
  height: number,
  x: number,
  y: number,
  rectWidth: number,
  rectHeight: number,
  radius: number,
  r: number,
  g: number,
  b: number,
  alpha: number = 255
): void {
  const x0: number = Math.max(0, Math.floor(x));
  const y0: number = Math.max(0, Math.floor(y));
  const x1: number = Math.min(width, Math.ceil(x + rectWidth));
  const y1: number = Math.min(height, Math.ceil(y + rectHeight));
  const rds: number = Math.max(0, Math.min(radius, Math.floor(Math.min(rectWidth, rectHeight) / 2)));
  for (let py: number = y0; py < y1; py++) {
    for (let px: number = x0; px < x1; px++) {
      if (!isInsideRoundedRect(px + 0.5, py + 0.5, x, y, x + rectWidth, y + rectHeight, rds)) {
        continue;
      }
      const index: number = (py * width + px) * 4;
      blendPixel(buf, index, r, g, b, alpha);
    }
  }
}

function drawSoftShadow(
  buf: Uint8Array,
  width: number,
  height: number,
  x: number,
  y: number,
  rectWidth: number,
  rectHeight: number,
  radius: number,
  alpha: number
): void {
  fillRoundedRect(buf, width, height, x, y + 10, rectWidth, rectHeight, radius, 0, 0, 0, alpha);
  fillRoundedRect(buf, width, height, x - 6, y + 18, rectWidth + 12, rectHeight + 14, radius + 8, 0, 0, 0,
    Math.max(0, Math.floor(alpha * 0.45)));
}

function lerpChannel(start: number, end: number, t: number): number {
  return Math.round(start + (end - start) * t);
}

function mixRgb(
  start: [number, number, number],
  end: [number, number, number],
  t: number
): [number, number, number] {
  return [
    lerpChannel(start[0], end[0], t),
    lerpChannel(start[1], end[1], t),
    lerpChannel(start[2], end[2], t)
  ];
}

function lightenRgb(color: [number, number, number], amount: number): [number, number, number] {
  return mixRgb(color, [255, 255, 255], amount);
}

function darkenRgb(color: [number, number, number], amount: number): [number, number, number] {
  return [
    Math.round(color[0] * (1 - amount)),
    Math.round(color[1] * (1 - amount)),
    Math.round(color[2] * (1 - amount))
  ];
}

function averageRgb(
  a: [number, number, number],
  b: [number, number, number],
  c: [number, number, number]
): [number, number, number] {
  return [
    Math.round((a[0] + b[0] + c[0]) / 3),
    Math.round((a[1] + b[1] + c[1]) / 3),
    Math.round((a[2] + b[2] + c[2]) / 3)
  ];
}

function gradientColorAt(
  t: number,
  main: [number, number, number],
  sec: [number, number, number],
  acc: [number, number, number]
): [number, number, number] {
  if (t <= 0.5) {
    const localT: number = t / 0.5;
    return [
      lerpChannel(main[0], sec[0], localT),
      lerpChannel(main[1], sec[1], localT),
      lerpChannel(main[2], sec[2], localT)
    ];
  }
  const localT: number = (t - 0.5) / 0.5;
  return [
    lerpChannel(sec[0], acc[0], localT),
    lerpChannel(sec[1], acc[1], localT),
    lerpChannel(sec[2], acc[2], localT)
  ];
}

function fillLinearGradient(
  buf: Uint8Array,
  width: number,
  height: number,
  x0: number,
  y0: number,
  x1: number,
  y1: number,
  main: [number, number, number],
  sec: [number, number, number],
  acc: [number, number, number]
): void {
  const dx: number = x1 - x0;
  const dy: number = y1 - y0;
  const len2: number = dx * dx + dy * dy;
  for (let py: number = 0; py < height; py++) {
    for (let px: number = 0; px < width; px++) {
      const tx: number = px - x0;
      const ty: number = py - y0;
      const projection: number = len2 > 0 ? (tx * dx + ty * dy) / len2 : 0;
      const clamped: number = Math.max(0, Math.min(1, projection));
      const color: [number, number, number] = gradientColorAt(clamped, main, sec, acc);
      const index: number = (py * width + px) * 4;
      buf[index] = color[2];
      buf[index + 1] = color[1];
      buf[index + 2] = color[0];
      buf[index + 3] = 255;
    }
  }
}

function drawSoftBlob(
  buf: Uint8Array,
  width: number,
  height: number,
  centerX: number,
  centerY: number,
  radius: number,
  r: number,
  g: number,
  b: number,
  alpha: number
): void {
  const x0: number = Math.max(0, Math.floor(centerX - radius));
  const y0: number = Math.max(0, Math.floor(centerY - radius));
  const x1: number = Math.min(width, Math.ceil(centerX + radius));
  const y1: number = Math.min(height, Math.ceil(centerY + radius));
  for (let py: number = y0; py < y1; py++) {
    for (let px: number = x0; px < x1; px++) {
      const dx: number = px + 0.5 - centerX;
      const dy: number = py + 0.5 - centerY;
      const dist: number = Math.sqrt(dx * dx + dy * dy);
      if (dist >= radius) {
        continue;
      }
      const factor: number = 1 - dist / radius;
      const localAlpha: number = Math.round(alpha * factor * factor);
      const index: number = (py * width + px) * 4;
      blendPixel(buf, index, r, g, b, localAlpha);
    }
  }
}

function rgbOrDefault(hex: string, fallback: [number, number, number]): [number, number, number] {
  const parsed: [number, number, number] | null = hexToRgb888(hex);
  return parsed !== null ? parsed : fallback;
}

function renderBlocks(
  buf: Uint8Array,
  width: number,
  height: number,
  main: [number, number, number],
  sec: [number, number, number],
  acc: [number, number, number],
  variantId: string
): void {
  const minSide: number = Math.min(width, height);
  const base: [number, number, number] = lightenRgb(averageRgb(main, sec, acc), 0.8);
  const glowMain: [number, number, number] = lightenRgb(main, 0.18);
  const glowSec: [number, number, number] = lightenRgb(sec, 0.12);
  const glowAcc: [number, number, number] = lightenRgb(acc, 0.24);
  fillRect(buf, width, height, 0, 0, width, height, base[0], base[1], base[2]);

  if (variantId === WALLPAPER_VARIANT_B_ID) {
    drawSoftBlob(buf, width, height, width * 0.24, height * 0.22, minSide * 0.54, glowMain[0], glowMain[1], glowMain[2], 96);
    drawSoftBlob(buf, width, height, width * 0.78, height * 0.34, minSide * 0.5, glowSec[0], glowSec[1], glowSec[2], 82);
    drawSoftBlob(buf, width, height, width * 0.4, height * 0.84, minSide * 0.72, glowAcc[0], glowAcc[1], glowAcc[2], 78);
  } else if (variantId === WALLPAPER_VARIANT_C_ID) {
    drawSoftBlob(buf, width, height, width * 0.8, height * 0.18, minSide * 0.48, glowMain[0], glowMain[1], glowMain[2], 88);
    drawSoftBlob(buf, width, height, width * 0.22, height * 0.52, minSide * 0.62, glowSec[0], glowSec[1], glowSec[2], 84);
    drawSoftBlob(buf, width, height, width * 0.7, height * 0.82, minSide * 0.64, glowAcc[0], glowAcc[1], glowAcc[2], 74);
  } else {
    drawSoftBlob(buf, width, height, width * 0.28, height * 0.2, minSide * 0.5, glowMain[0], glowMain[1], glowMain[2], 90);
    drawSoftBlob(buf, width, height, width * 0.74, height * 0.5, minSide * 0.58, glowSec[0], glowSec[1], glowSec[2], 82);
    drawSoftBlob(buf, width, height, width * 0.24, height * 0.88, minSide * 0.68, glowAcc[0], glowAcc[1], glowAcc[2], 70);
  }

  drawSoftBlob(buf, width, height, width * 0.58, height * 0.14, minSide * 0.34, 255, 255, 255, 54);
}

function renderCollage(
  buf: Uint8Array,
  width: number,
  height: number,
  main: [number, number, number],
  sec: [number, number, number],
  acc: [number, number, number],
  variantId: string
): void {
  const minSide: number = Math.min(width, height);
  const base: [number, number, number] = lightenRgb(main, 0.82);
  const orbMain: [number, number, number] = lightenRgb(main, 0.06);
  const orbSec: [number, number, number] = lightenRgb(sec, 0.08);
  const orbAcc: [number, number, number] = lightenRgb(acc, 0.18);
  fillRect(buf, width, height, 0, 0, width, height, base[0], base[1], base[2]);
  drawSoftBlob(buf, width, height, width * 0.76, height * 0.16, minSide * 0.42, 255, 255, 255, 52);

  if (variantId === WALLPAPER_VARIANT_B_ID) {
    drawSoftBlob(buf, width, height, width * 0.34, height * 0.26, minSide * 0.34, orbMain[0], orbMain[1], orbMain[2], 164);
    drawSoftBlob(buf, width, height, width * 0.72, height * 0.54, minSide * 0.46, orbSec[0], orbSec[1], orbSec[2], 146);
    drawSoftBlob(buf, width, height, width * 0.28, height * 0.82, minSide * 0.28, orbAcc[0], orbAcc[1], orbAcc[2], 82);
  } else if (variantId === WALLPAPER_VARIANT_C_ID) {
    drawSoftBlob(buf, width, height, width * 0.62, height * 0.26, minSide * 0.38, orbMain[0], orbMain[1], orbMain[2], 152);
    drawSoftBlob(buf, width, height, width * 0.42, height * 0.64, minSide * 0.48, orbSec[0], orbSec[1], orbSec[2], 138);
    drawSoftBlob(buf, width, height, width * 0.82, height * 0.74, minSide * 0.28, orbAcc[0], orbAcc[1], orbAcc[2], 84);
  } else {
    drawSoftBlob(buf, width, height, width * 0.44, height * 0.24, minSide * 0.4, orbMain[0], orbMain[1], orbMain[2], 156);
    drawSoftBlob(buf, width, height, width * 0.56, height * 0.68, minSide * 0.44, orbSec[0], orbSec[1], orbSec[2], 142);
    drawSoftBlob(buf, width, height, width * 0.84, height * 0.52, minSide * 0.2, orbAcc[0], orbAcc[1], orbAcc[2], 76);
  }
}

function renderGradient(
  buf: Uint8Array,
  width: number,
  height: number,
  main: [number, number, number],
  sec: [number, number, number],
  acc: [number, number, number],
  variantId: string
): void {
  const minSide: number = Math.min(width, height);
  const darkMain: [number, number, number] = darkenRgb(main, 0.68);
  const darkSec: [number, number, number] = darkenRgb(sec, 0.58);
  const darkAcc: [number, number, number] = darkenRgb(acc, 0.78);
  const glowMain: [number, number, number] = lightenRgb(main, 0.06);
  const glowSec: [number, number, number] = lightenRgb(sec, 0.04);
  const glowAcc: [number, number, number] = lightenRgb(acc, 0.1);

  if (variantId === WALLPAPER_VARIANT_B_ID) {
    fillLinearGradient(buf, width, height, width, 0, 0, height, darkSec, darkMain, darkAcc);
    drawSoftBlob(buf, width, height, width * 0.22, height * 0.22, minSide * 0.26, glowMain[0], glowMain[1], glowMain[2], 122);
    drawSoftBlob(buf, width, height, width * 0.64, height * 0.5, minSide * 0.42, glowSec[0], glowSec[1], glowSec[2], 142);
    drawSoftBlob(buf, width, height, width * 0.84, height * 0.16, minSide * 0.24, glowAcc[0], glowAcc[1], glowAcc[2], 96);
    return;
  }
  if (variantId === WALLPAPER_VARIANT_C_ID) {
    fillLinearGradient(buf, width, height, 0, height * 0.18, width, height * 0.82, darkAcc, darkSec, darkMain);
    drawSoftBlob(buf, width, height, width * 0.78, height * 0.18, minSide * 0.28, glowAcc[0], glowAcc[1], glowAcc[2], 104);
    drawSoftBlob(buf, width, height, width * 0.34, height * 0.56, minSide * 0.5, glowMain[0], glowMain[1], glowMain[2], 132);
    drawSoftBlob(buf, width, height, width * 0.72, height * 0.78, minSide * 0.3, glowSec[0], glowSec[1], glowSec[2], 92);
    return;
  }
  fillLinearGradient(buf, width, height, width * 0.88, 0, width * 0.12, height, darkAcc, darkSec, darkMain);
  drawSoftBlob(buf, width, height, width * 0.26, height * 0.24, minSide * 0.34, glowMain[0], glowMain[1], glowMain[2], 126);
  drawSoftBlob(buf, width, height, width * 0.54, height * 0.6, minSide * 0.44, glowSec[0], glowSec[1], glowSec[2], 148);
  drawSoftBlob(buf, width, height, width * 0.84, height * 0.18, minSide * 0.22, glowAcc[0], glowAcc[1], glowAcc[2], 94);
}

function renderMist(
  buf: Uint8Array,
  width: number,
  height: number,
  main: [number, number, number],
  sec: [number, number, number],
  acc: [number, number, number],
  variantId: string
): void {
  const maxSide: number = Math.max(width, height);
  const base: [number, number, number] = lightenRgb(mixRgb(main, sec, 0.3), 0.84);
  const tideSec: [number, number, number] = lightenRgb(sec, 0.16);
  const tideAcc: [number, number, number] = lightenRgb(acc, 0.18);
  const tideMain: [number, number, number] = lightenRgb(main, 0.12);
  fillRect(buf, width, height, 0, 0, width, height, base[0], base[1], base[2]);

  if (variantId === WALLPAPER_VARIANT_B_ID) {
    drawSoftBlob(buf, width, height, -width * 0.08, height * 0.18, maxSide * 0.84, tideSec[0], tideSec[1], tideSec[2], 118);
    drawSoftBlob(buf, width, height, width * 0.92, height * 0.76, maxSide * 0.8, tideAcc[0], tideAcc[1], tideAcc[2], 112);
    drawSoftBlob(buf, width, height, width * 0.52, -height * 0.08, maxSide * 0.7, tideMain[0], tideMain[1], tideMain[2], 64);
    return;
  }
  if (variantId === WALLPAPER_VARIANT_C_ID) {
    drawSoftBlob(buf, width, height, width * 0.16, -height * 0.04, maxSide * 0.78, tideMain[0], tideMain[1], tideMain[2], 74);
    drawSoftBlob(buf, width, height, width * 1.04, height * 0.34, maxSide * 0.86, tideSec[0], tideSec[1], tideSec[2], 122);
    drawSoftBlob(buf, width, height, width * 0.28, height * 0.92, maxSide * 0.72, tideAcc[0], tideAcc[1], tideAcc[2], 104);
    return;
  }
  drawSoftBlob(buf, width, height, -width * 0.12, height * 0.36, maxSide * 0.82, tideSec[0], tideSec[1], tideSec[2], 116);
  drawSoftBlob(buf, width, height, width * 0.84, height * 0.02, maxSide * 0.72, tideMain[0], tideMain[1], tideMain[2], 68);
  drawSoftBlob(buf, width, height, width * 0.9, height * 0.86, maxSide * 0.84, tideAcc[0], tideAcc[1], tideAcc[2], 110);
}

export function createWallpaperExportPixelMap(
  mainHex: string,
  secHex: string,
  accHex: string,
  widthPx: number,
  heightPx: number,
  styleId: string,
  variantId: string
): image.PixelMap | null {
  const width: number = widthPx > 0 ? Math.floor(widthPx) : 1080;
  const height: number = heightPx > 0 ? Math.floor(heightPx) : 2340;
  const main: [number, number, number] = rgbOrDefault(mainHex, [232, 216, 211]);
  const sec: [number, number, number] = rgbOrDefault(secHex, [197, 185, 182]);
  const acc: [number, number, number] = rgbOrDefault(accHex, [93, 99, 122]);
  const buffer: ArrayBuffer = new ArrayBuffer(width * height * 4);
  const buf: Uint8Array = new Uint8Array(buffer);

  if (styleId === WALLPAPER_STYLE_COLLAGE_ID) {
    renderCollage(buf, width, height, main, sec, acc, variantId);
  } else if (styleId === WALLPAPER_STYLE_GRADIENT_ID) {
    renderGradient(buf, width, height, main, sec, acc, variantId);
  } else if (styleId === WALLPAPER_STYLE_MIST_ID) {
    renderMist(buf, width, height, main, sec, acc, variantId);
  } else {
    renderBlocks(buf, width, height, main, sec, acc, variantId);
  }

  const opts: image.InitializationOptions = {
    editable: false,
    pixelFormat: image.PixelMapFormat.RGBA_8888,
    size: { width: width, height: height },
    alphaType: image.AlphaType.OPAQUE
  };
  try {
    return image.createPixelMapSync(buffer, opts);
  } catch {
    return null;
  }
}