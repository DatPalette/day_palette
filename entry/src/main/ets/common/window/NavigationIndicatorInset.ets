import { window } from '@kit.ArkUI';

/**
 * 底部系统占用高度（px）：取多类避让区的 bottomRect 较大值。
 * 含 TYPE_SYSTEM：多数真机/模拟器上导航栏、手势条会体现在此，仅查 INDICATOR 常为 0。
 */
export function getBottomGestureBarHeightPx(win: window.Window): number {
  let maxPx: number = 0;
  try {
    const system = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    maxPx = Math.max(maxPx, system.bottomRect.height);
  } catch {
  }
  try {
    const nav = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    maxPx = Math.max(maxPx, nav.bottomRect.height);
  } catch {
  }
  try {
    const gesture = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM_GESTURE);
    maxPx = Math.max(maxPx, gesture.bottomRect.height);
  } catch {
  }
  return maxPx;
}
