import { image } from '@kit.ImageKit';
import { DEFAULT_TEMPLATE_ID } from '../model/TodayOutfitState';
import { hexToRgb888 } from './HexColor';

/** 导出正方形边长（短边 ≥1080） */
export const EXPORT_SIZE: number = 1080;

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

  if (templateId === 'tpl_columns_v2') {
    const w1: number = Math.floor((w * 3) / 6);
    const w2: number = Math.floor((w * 2) / 6);
    const w3: number = w - w1 - w2;
    fillRect(buf, w, h, 0, 0, w1, h, main[0], main[1], main[2]);
    fillRect(buf, w, h, w1, 0, w1 + w2, h, sec[0], sec[1], sec[2]);
    fillRect(buf, w, h, w1 + w2, 0, w, h, acc[0], acc[1], acc[2]);
  } else if (templateId === 'tpl_thirds_v3') {
    const band: number = Math.floor(h / 3);
    fillRect(buf, w, h, 0, 0, w, band, main[0], main[1], main[2]);
    fillRect(buf, w, h, 0, band, w, band * 2, sec[0], sec[1], sec[2]);
    fillRect(buf, w, h, 0, band * 2, w, h, acc[0], acc[1], acc[2]);
  } else if (templateId === 'tpl_bento_v4') {
    const wMain: number = Math.floor((w * 4) / 6);
    const hSec: number = Math.floor((h * 2) / 3);
    fillRect(buf, w, h, 0, 0, wMain, h, main[0], main[1], main[2]);
    fillRect(buf, w, h, wMain, 0, w, hSec, sec[0], sec[1], sec[2]);
    fillRect(buf, w, h, wMain, hSec, w, h, acc[0], acc[1], acc[2]);
  } else if (templateId === 'tpl_stack_v5') {
    // 模拟 Hero 的层叠效果（无旋转，仅通过位置和大小模拟错落感）
    // 背景色使用浅灰白，模拟画布
    fillRect(buf, w, h, 0, 0, w, h, 249, 248, 246);
    
    // 主色：75% 宽，高 65%，靠左上
    const mainW = Math.floor(w * 0.75);
    const mainH = Math.floor(h * 0.65);
    fillRect(buf, w, h, 0, 0, mainW, mainH, main[0], main[1], main[2]);
    
    // 辅色：55% 宽，高 45%，居中偏右
    const secW = Math.floor(w * 0.55);
    const secH = Math.floor(h * 0.45);
    const secX = Math.floor(w * 0.45);
    const secY = Math.floor(h * 0.30);
    fillRect(buf, w, h, secX, secY, secX + secW, secY + secH, sec[0], sec[1], sec[2]);
    
    // 点缀色：35% 宽，高 25%，靠左下
    const accW = Math.floor(w * 0.35);
    const accH = Math.floor(h * 0.25);
    const accX = Math.floor(w * 0.15);
    const accY = Math.floor(h * 0.55);
    fillRect(buf, w, h, accX, accY, accX + accW, accY + accH, acc[0], acc[1], acc[2]);
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

export const TEMPLATE_IDS: string[] = [DEFAULT_TEMPLATE_ID, 'tpl_columns_v2', 'tpl_thirds_v3', 'tpl_bento_v4', 'tpl_stack_v5'];
