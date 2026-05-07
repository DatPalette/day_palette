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
  if (variantId === WALLPAPER_VARIANT_B_ID) {
    const h1: number = Math.floor(height * 0.54);
    const h2: number = Math.floor(height * 0.28);
    fillRect(buf, width, height, 0, 0, width, h1, main[0], main[1], main[2]);
    fillRect(buf, width, height, 0, h1, width, h1 + h2, sec[0], sec[1], sec[2]);
    fillRect(buf, width, height, 0, h1 + h2, width, height, acc[0], acc[1], acc[2]);
    return;
  }
  if (variantId === WALLPAPER_VARIANT_C_ID) {
    const topHeight: number = Math.floor(height * 0.64);
    const bottomHeight: number = height - topHeight;
    const leftWidth: number = Math.floor(width * 0.62);
    fillRect(buf, width, height, 0, 0, width, topHeight, main[0], main[1], main[2]);
    fillRect(buf, width, height, 0, topHeight, leftWidth, height, sec[0], sec[1], sec[2]);
    fillRect(buf, width, height, leftWidth, topHeight, width, height, acc[0], acc[1], acc[2]);
    return;
  }
  const w1: number = Math.floor((width * 3) / 6);
  const w2: number = Math.floor((width * 2) / 6);
  fillRect(buf, width, height, 0, 0, w1, height, main[0], main[1], main[2]);
  fillRect(buf, width, height, w1, 0, w1 + w2, height, sec[0], sec[1], sec[2]);
  fillRect(buf, width, height, w1 + w2, 0, width, height, acc[0], acc[1], acc[2]);
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
  fillRect(buf, width, height, 0, 0, width, height, main[0], main[1], main[2]);
  const radius: number = Math.max(16, Math.floor(Math.min(width, height) * 0.04));
  if (variantId === WALLPAPER_VARIANT_B_ID) {
    const secWidth: number = Math.floor(width * 0.58);
    const secHeight: number = Math.floor(height * 0.3);
    const accWidth: number = Math.floor(width * 0.42);
    const accHeight: number = Math.floor(height * 0.22);
    drawSoftShadow(buf, width, height, Math.floor(width * 0.12), Math.floor(height * 0.18), secWidth, secHeight, radius, 28);
    fillRoundedRect(buf, width, height, Math.floor(width * 0.12), Math.floor(height * 0.18), secWidth, secHeight, radius,
      sec[0], sec[1], sec[2]);
    drawSoftShadow(buf, width, height, Math.floor(width * 0.46), Math.floor(height * 0.56), accWidth, accHeight, radius, 24);
    fillRoundedRect(buf, width, height, Math.floor(width * 0.46), Math.floor(height * 0.56), accWidth, accHeight, radius,
      acc[0], acc[1], acc[2]);
    return;
  }
  if (variantId === WALLPAPER_VARIANT_C_ID) {
    const cardWidth: number = Math.floor(width * 0.72);
    const secHeight: number = Math.floor(height * 0.24);
    const accHeight: number = Math.floor(height * 0.18);
    drawSoftShadow(buf, width, height, Math.floor(width * 0.14), Math.floor(height * 0.12), cardWidth, secHeight, radius, 28);
    fillRoundedRect(buf, width, height, Math.floor(width * 0.14), Math.floor(height * 0.12), cardWidth, secHeight, radius,
      sec[0], sec[1], sec[2]);
    drawSoftShadow(buf, width, height, Math.floor(width * 0.08), Math.floor(height * 0.54), cardWidth, accHeight, radius, 24);
    fillRoundedRect(buf, width, height, Math.floor(width * 0.08), Math.floor(height * 0.54), cardWidth, accHeight, radius,
      acc[0], acc[1], acc[2]);
    return;
  }
  const secWidth: number = Math.floor(width * 0.54);
  const secHeight: number = Math.floor(height * 0.28);
  const accWidth: number = Math.floor(width * 0.38);
  const accHeight: number = Math.floor(height * 0.18);
  drawSoftShadow(buf, width, height, Math.floor(width * 0.32), Math.floor(height * 0.24), secWidth, secHeight, radius, 28);
  fillRoundedRect(buf, width, height, Math.floor(width * 0.32), Math.floor(height * 0.24), secWidth, secHeight, radius,
    sec[0], sec[1], sec[2]);
  drawSoftShadow(buf, width, height, Math.floor(width * 0.16), Math.floor(height * 0.62), accWidth, accHeight, radius, 24);
  fillRoundedRect(buf, width, height, Math.floor(width * 0.16), Math.floor(height * 0.62), accWidth, accHeight, radius,
    acc[0], acc[1], acc[2]);
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
  if (variantId === WALLPAPER_VARIANT_B_ID) {
    fillLinearGradient(buf, width, height, 0, 0, width, height, main, sec, acc);
    return;
  }
  if (variantId === WALLPAPER_VARIANT_C_ID) {
    fillLinearGradient(buf, width, height, 0, Math.floor(height * 0.45), width, Math.floor(height * 0.55), main, sec, acc);
    return;
  }
  fillLinearGradient(buf, width, height, 0, 0, 0, height, main, sec, acc);
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
  fillRect(buf, width, height, 0, 0, width, height, main[0], main[1], main[2]);
  if (variantId === WALLPAPER_VARIANT_B_ID) {
    drawSoftBlob(buf, width, height, width * 0.32, height * 0.28, Math.min(width, height) * 0.44, sec[0], sec[1], sec[2], 150);
    drawSoftBlob(buf, width, height, width * 0.74, height * 0.66, Math.min(width, height) * 0.36, acc[0], acc[1], acc[2], 132);
    drawSoftBlob(buf, width, height, width * 0.18, height * 0.82, Math.min(width, height) * 0.22, sec[0], sec[1], sec[2], 72);
    return;
  }
  if (variantId === WALLPAPER_VARIANT_C_ID) {
    drawSoftBlob(buf, width, height, width * 0.22, height * 0.18, Math.min(width, height) * 0.28, sec[0], sec[1], sec[2], 84);
    drawSoftBlob(buf, width, height, width * 0.54, height * 0.52, Math.min(width, height) * 0.5, sec[0], sec[1], sec[2], 138);
    drawSoftBlob(buf, width, height, width * 0.78, height * 0.32, Math.min(width, height) * 0.34, acc[0], acc[1], acc[2], 116);
    return;
  }
  drawSoftBlob(buf, width, height, width * 0.22, height * 0.2, Math.min(width, height) * 0.26, sec[0], sec[1], sec[2], 82);
  drawSoftBlob(buf, width, height, width * 0.74, height * 0.42, Math.min(width, height) * 0.34, sec[0], sec[1], sec[2], 112);
  drawSoftBlob(buf, width, height, width * 0.46, height * 0.74, Math.min(width, height) * 0.42, acc[0], acc[1], acc[2], 134);
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