import { image } from '@kit.ImageKit';
import {
  HERO_ACCENT_CARD_LAYOUT,
  HERO_MAIN_CARD_LAYOUT,
  HERO_PALETTE_BASE_SIZE,
  HERO_SECONDARY_CARD_LAYOUT,
  scaleHeroPaletteLayout,
  scaleHeroPaletteValue
} from '../common/constants/HeroPaletteLayout';
import { DEFAULT_TEMPLATE_ID } from '../model/TodayOutfitState';
import { hexToRgb888 } from './HexColor';

/** 导出正方形边长（短边 ≥1080） */
export const EXPORT_SIZE: number = 1080;
export const TEMPLATE_COLUMNS_ID: string = 'tpl_columns_v2';
export const TEMPLATE_THIRDS_ID: string = 'tpl_thirds_v3';
export const TEMPLATE_BENTO_ID: string = 'tpl_bento_v4';
export const TEMPLATE_STACK_ID: string = 'tpl_stack_v5';

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
  radius: number
): void {
  fillRoundedRect(buf, width, height, x, y + 10, rectWidth, rectHeight, radius, 0, 0, 0, 18);
  fillRoundedRect(buf, width, height, x - 8, y + 14, rectWidth + 16, rectHeight + 12, radius + 8, 0, 0, 0, 10);
  fillRoundedRect(buf, width, height, x - 16, y + 20, rectWidth + 32, rectHeight + 20, radius + 16, 0, 0, 0, 5);
}

function fillBackground(buf: Uint8Array, width: number, height: number, r: number, g: number, b: number): void {
  fillRect(buf, width, height, 0, 0, width, height, r, g, b);
}

function renderHeroComposition(
  buf: Uint8Array,
  width: number,
  height: number,
  main: [number, number, number],
  sec: [number, number, number],
  acc: [number, number, number]
): void {
  fillBackground(buf, width, height, 249, 248, 246);

  const compositionHeight: number = Math.floor(height * 0.66);
  const compositionWidth: number = scaleHeroPaletteValue(HERO_PALETTE_BASE_SIZE, compositionHeight);
  const originX: number = Math.floor((width - compositionWidth) / 2);
  const originY: number = Math.floor((height - compositionHeight) / 2) - Math.floor(height * 0.02);
  const mainCard = scaleHeroPaletteLayout(HERO_MAIN_CARD_LAYOUT, compositionHeight);
  const secondaryCard = scaleHeroPaletteLayout(HERO_SECONDARY_CARD_LAYOUT, compositionHeight);
  const accentCard = scaleHeroPaletteLayout(HERO_ACCENT_CARD_LAYOUT, compositionHeight);
  const radius: number = Math.max(16, scaleHeroPaletteValue(16, compositionHeight));

  drawSoftShadow(buf, width, height, originX + mainCard.left, originY + mainCard.top, mainCard.width, mainCard.height, radius);
  fillRoundedRect(buf, width, height, originX + mainCard.left, originY + mainCard.top, mainCard.width, mainCard.height, radius, main[0], main[1], main[2]);

  drawSoftShadow(
    buf,
    width,
    height,
    originX + secondaryCard.left,
    originY + secondaryCard.top,
    secondaryCard.width,
    secondaryCard.height,
    radius
  );
  fillRoundedRect(
    buf,
    width,
    height,
    originX + secondaryCard.left,
    originY + secondaryCard.top,
    secondaryCard.width,
    secondaryCard.height,
    radius,
    sec[0],
    sec[1],
    sec[2]
  );

  drawSoftShadow(buf, width, height, originX + accentCard.left, originY + accentCard.top, accentCard.width, accentCard.height, radius);
  fillRoundedRect(buf, width, height, originX + accentCard.left, originY + accentCard.top, accentCard.width, accentCard.height, radius, acc[0], acc[1], acc[2]);
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
      // 鸿蒙底层 Skia 默认常使用 BGRA 字节序；当 packer 编码时，若指定 RGBA_8888 可能发生 R/B 通道翻转（表现为蓝黄反相）。
      // 故在此直接按 B, G, R, A 顺序写入，并依然使用 RGBA_8888（或系统默认处理），以抵消翻转。
      buf[i] = b;
      buf[i + 1] = g;
      buf[i + 2] = r;
      buf[i + 3] = 255;
    }
  }
}

function rgbOrDefault(hex: string, fallback: [number, number, number]): [number, number, number] {
  const p: [number, number, number] | null = hexToRgb888(hex);
  return p !== null ? p : fallback;
}

/**
 * 根据模板将三色铺入 1080×1080 RGBA PixelMap（免费基础模板，可多套）。
 */
export function createPaletteExportPixelMap(
  mainHex: string,
  secHex: string,
  accHex: string,
  templateId: string
): image.PixelMap | null {
  const w: number = EXPORT_SIZE;
  const h: number = EXPORT_SIZE;
  const main: [number, number, number] = rgbOrDefault(mainHex, [232, 216, 211]);
  const sec: [number, number, number] = rgbOrDefault(secHex, [197, 185, 182]);
  const acc: [number, number, number] = rgbOrDefault(accHex, [93, 99, 122]);

  const byteLength: number = w * h * 4;
  const buffer: ArrayBuffer = new ArrayBuffer(byteLength);
  const buf: Uint8Array = new Uint8Array(buffer);

  if (templateId === TEMPLATE_COLUMNS_ID) {
    const w1: number = Math.floor((w * 3) / 6);
    const w2: number = Math.floor((w * 2) / 6);
    const w3: number = w - w1 - w2;
    fillRect(buf, w, h, 0, 0, w1, h, main[0], main[1], main[2]);
    fillRect(buf, w, h, w1, 0, w1 + w2, h, sec[0], sec[1], sec[2]);
    fillRect(buf, w, h, w1 + w2, 0, w, h, acc[0], acc[1], acc[2]);
  } else if (templateId === TEMPLATE_THIRDS_ID) {
    const band: number = Math.floor(h / 3);
    fillRect(buf, w, h, 0, 0, w, band, main[0], main[1], main[2]);
    fillRect(buf, w, h, 0, band, w, band * 2, sec[0], sec[1], sec[2]);
    fillRect(buf, w, h, 0, band * 2, w, h, acc[0], acc[1], acc[2]);
  } else if (templateId === TEMPLATE_BENTO_ID) {
    const wMain: number = Math.floor((w * 4) / 6);
    const hSec: number = Math.floor((h * 2) / 3);
    fillRect(buf, w, h, 0, 0, wMain, h, main[0], main[1], main[2]);
    fillRect(buf, w, h, wMain, 0, w, hSec, sec[0], sec[1], sec[2]);
    fillRect(buf, w, h, wMain, hSec, w, h, acc[0], acc[1], acc[2]);
  } else if (templateId === TEMPLATE_STACK_ID || templateId === DEFAULT_TEMPLATE_ID) {
    renderHeroComposition(buf, w, h, main, sec, acc);
  } else {
    const h1: number = Math.floor(h * 0.55);
    const h2: number = Math.floor(h * 0.30);
    fillRect(buf, w, h, 0, 0, w, h1, main[0], main[1], main[2]);
    fillRect(buf, w, h, 0, h1, w, h1 + h2, sec[0], sec[1], sec[2]);
    fillRect(buf, w, h, 0, h1 + h2, w, h, acc[0], acc[1], acc[2]);
  }

  const opts: image.InitializationOptions = {
    editable: false,
    pixelFormat: image.PixelMapFormat.RGBA_8888,
    size: { width: w, height: h },
    alphaType: image.AlphaType.OPAQUE
  };
  try {
    return image.createPixelMapSync(buffer, opts);
  } catch (_e) {
    return null;
  }
}

export const TEMPLATE_IDS: string[] = [
  DEFAULT_TEMPLATE_ID,
  TEMPLATE_COLUMNS_ID,
  TEMPLATE_THIRDS_ID,
  TEMPLATE_BENTO_ID,
  TEMPLATE_STACK_ID
];
