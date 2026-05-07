import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import type { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { createWallpaperExportPixelMap } from './WallpaperImageExporter';

const WALLPAPER_LOG_DOMAIN: number = 0xD05B;
const WALLPAPER_LOG_TAG: string = 'DayPaletteWallpaper';
const EXPORT_FILE_READY_RETRY_MS: number = 24;
const EXPORT_FILE_READY_MAX_RETRIES: number = 12;

interface ErrLikeShape {
  code?: number;
  message?: string;
}

function logWallpaperError(step: string, err: Error | object | string): void {
  let detail: string = '';
  if (typeof err === 'string') {
    detail = err;
  } else if (err instanceof Error) {
    detail = `${err.name}: ${err.message}`;
  } else {
    const typed: ErrLikeShape = err as ErrLikeShape;
    detail = typed.message !== undefined ? typed.message : 'unknown error';
  }
  const line: string = `[${step}] ${detail}`;
  hilog.error(WALLPAPER_LOG_DOMAIN, WALLPAPER_LOG_TAG, '%{public}s', line);
  console.error(`[DayPaletteWallpaper] ${line}`);
}

async function packPngPixelMapToPath(pixelMap: image.PixelMap, path: string): Promise<boolean> {
  let opened: fileIo.File | null = null;
  try {
    opened = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
    const packer: image.ImagePacker = image.createImagePacker();
    const opts: image.PackingOption = { format: 'image/png', quality: 100 };
    await packer.packToFile(pixelMap, opened.fd, opts);
    return true;
  } catch (e) {
    logWallpaperError('packPngToFile', e as object);
    return false;
  } finally {
    if (opened !== null) {
      try {
        fileIo.closeSync(opened);
      } catch {
      }
    }
  }
}

function readWholeFileSync(path: string): ArrayBuffer | null {
  try {
    const st: fileIo.Stat = fileIo.statSync(path);
    const size: number = st.size;
    if (size <= 0) {
      return null;
    }
    const buf: ArrayBuffer = new ArrayBuffer(size);
    const rf: fileIo.File = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
    try {
      fileIo.readSync(rf.fd, buf, { length: size });
    } finally {
      fileIo.closeSync(rf);
    }
    return buf;
  } catch (e) {
    logWallpaperError('readWholeFile', e as object);
    return null;
  }
}

function hasReadableFileContent(path: string): boolean {
  try {
    const st: fileIo.Stat = fileIo.statSync(path);
    return st.size > 0;
  } catch {
    return false;
  }
}

async function waitUntilFileReadable(path: string): Promise<boolean> {
  for (let i: number = 0; i < EXPORT_FILE_READY_MAX_RETRIES; i++) {
    if (hasReadableFileContent(path)) {
      return true;
    }
    await new Promise<void>((resolve) => {
      setTimeout((): void => {
        resolve();
      }, EXPORT_FILE_READY_RETRY_MS);
    });
  }
  return hasReadableFileContent(path);
}

function disposePixelMap(pm: image.PixelMap | null): void {
  if (pm === null) {
    return;
  }
  try {
    pm.release();
  } catch {
  }
}

function safeAssetBaseName(title: string): string {
  const oneLine: string = title.replace(/<br\s*\/?>/gi, ' ').trim();
  let sanitized: string = '';
  for (let i: number = 0; i < oneLine.length && sanitized.length < 48; i++) {
    const ch: string = oneLine.charAt(i);
    const code: number = ch.charCodeAt(0);
    const ok: boolean =
      (code >= 48 && code <= 57) ||
      (code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122) ||
      ch === '_' ||
      ch === '-' ||
      (code >= 0x4e00 && code <= 0x9fff);
    if (ok) {
      sanitized = sanitized + ch;
    } else if (ch === ' ' || ch === '.') {
      sanitized = sanitized + '_';
    }
  }
  return sanitized.length > 0 ? sanitized : 'DayPaletteWallpaper';
}

export interface WallpaperSnapshot {
  mainHex: string;
  secHex: string;
  accHex: string;
  styleId: string;
  variantId: string;
  widthPx: number;
  heightPx: number;
  displayTitle: string;
}

export function wallpaperSnapshotFromVm(
  vm: DayPaletteViewModel,
  styleId: string,
  variantId: string,
  widthPx: number,
  heightPx: number
): WallpaperSnapshot {
  const colors: string[] = vm.getHeroColorStrings();
  const compactTitle: string = vm.getHeroTitleCompact().trim();
  const safeWidth: number = widthPx > 0 ? widthPx : 1080;
  const safeHeight: number = heightPx > 0 ? heightPx : 2340;
  return {
    mainHex: colors.length > 0 ? `${colors[0]}`.trim() : '',
    secHex: colors.length > 1 ? `${colors[1]}`.trim() : '',
    accHex: colors.length > 2 ? `${colors[2]}`.trim() : '',
    styleId: styleId,
    variantId: variantId,
    widthPx: safeWidth,
    heightPx: safeHeight,
    displayTitle: compactTitle.length > 0 ? `${compactTitle}_wallpaper` : 'DayPalette_wallpaper'
  };
}

async function buildWallpaperPngFileInCache(
  context: common.UIAbilityContext,
  snap: WallpaperSnapshot
): Promise<string | null> {
  const pm: image.PixelMap | null = createWallpaperExportPixelMap(
    snap.mainHex,
    snap.secHex,
    snap.accHex,
    snap.widthPx,
    snap.heightPx,
    snap.styleId,
    snap.variantId
  );
  if (pm === null) {
    logWallpaperError('export', 'createWallpaperExportPixelMap returned null');
    return null;
  }
  const path: string =
    `${context.cacheDir}/daypalette_wallpaper_${Date.now()}_${Math.floor(Math.random() * 1e9)}.png`;
  const packed: boolean = await packPngPixelMapToPath(pm, path);
  disposePixelMap(pm);
  if (!packed) {
    try {
      fileIo.unlinkSync(path);
    } catch {
    }
    return null;
  }
  if (!(await waitUntilFileReadable(path))) {
    logWallpaperError('export_wait_ready', 'png file not readable after pack');
    try {
      fileIo.unlinkSync(path);
    } catch {
    }
    return null;
  }
  return path;
}

type AssetsDialogOutcome = 'success' | 'cancelled' | 'failed';

async function saveToGalleryViaAssetsCreationDialog(
  context: common.UIAbilityContext,
  pngPath: string,
  suggestedTitle: string
): Promise<AssetsDialogOutcome> {
  try {
    const helper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    const srcUri: string = fileUri.getUriFromPath(pngPath);
    const creationTitle: string = safeAssetBaseName(suggestedTitle);
    const configs: photoAccessHelper.PhotoCreationConfig[] = [{
      title: creationTitle,
      fileNameExtension: 'png',
      photoType: photoAccessHelper.PhotoType.IMAGE
    }];
    const destUris: string[] = await helper.showAssetsCreationDialog([srcUri], configs);
    if (destUris.length === 0) {
      return 'cancelled';
    }
    const diskBuf: ArrayBuffer | null = readWholeFileSync(pngPath);
    if (diskBuf === null) {
      logWallpaperError('gallery_dialog_read', 'read export png failed');
      return 'failed';
    }
    const outFile: fileIo.File = fileIo.openSync(destUris[0], fileIo.OpenMode.READ_WRITE);
    try {
      fileIo.writeSync(outFile.fd, diskBuf);
    } catch (e) {
      logWallpaperError('gallery_dialog_write', e as object);
      return 'failed';
    } finally {
      fileIo.closeSync(outFile);
    }
    return 'success';
  } catch (e) {
    logWallpaperError('gallery_assets_dialog', e as object);
    return 'failed';
  }
}

export interface SaveWallpaperImageSuccess {
  ok: true;
}

export interface SaveWallpaperImageFailure {
  ok: false;
  hint: 'build_image' | 'save_dialog_cancelled' | 'unknown';
}

export type SaveWallpaperImageResult = SaveWallpaperImageSuccess | SaveWallpaperImageFailure;

export async function saveWallpaperToGallery(
  context: common.UIAbilityContext,
  snap: WallpaperSnapshot
): Promise<SaveWallpaperImageResult> {
  const pngPath: string | null = await buildWallpaperPngFileInCache(context, snap);
  if (pngPath === null) {
    return { ok: false, hint: 'build_image' };
  }
  try {
    const viaDialog: AssetsDialogOutcome =
      await saveToGalleryViaAssetsCreationDialog(context, pngPath, snap.displayTitle);
    if (viaDialog === 'success') {
      return { ok: true };
    }
    if (viaDialog === 'cancelled') {
      return { ok: false, hint: 'save_dialog_cancelled' };
    }
    return { ok: false, hint: 'unknown' };
  } finally {
    try {
      fileIo.unlinkSync(pngPath);
    } catch {
    }
  }
}