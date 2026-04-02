/** 解析 #RGB / #RRGGBB 为 0–255 分量；失败返回 null */
export function hexToRgb888(hex: string): [number, number, number] | null {
  let h: string = hex.trim();
  if (h.length === 0) {
    return null;
  }
  if (h.startsWith('#')) {
    h = h.substring(1);
  }
  if (h.length === 3) {
    const r: number = parseInt(h.charAt(0) + h.charAt(0), 16);
    const g: number = parseInt(h.charAt(1) + h.charAt(1), 16);
    const b: number = parseInt(h.charAt(2) + h.charAt(2), 16);
    if (Number.isNaN(r) || Number.isNaN(g) || Number.isNaN(b)) {
      return null;
    }
    return [r, g, b];
  }
  if (h.length === 6) {
    const r: number = parseInt(h.substring(0, 2), 16);
    const g: number = parseInt(h.substring(2, 4), 16);
    const b: number = parseInt(h.substring(4, 6), 16);
    if (Number.isNaN(r) || Number.isNaN(g) || Number.isNaN(b)) {
      return null;
    }
    return [r, g, b];
  }
  return null;
}
