import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import type { PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemShare } from '@kit.ShareKit';
import { createPaletteExportPixelMap } from './PaletteImageExporter';
import { DEFAULT_TEMPLATE_ID } from '../model/TodayOutfitState';
import type { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';

const SAVE_LOG_DOMAIN: number = 0xD05A;
const SAVE_LOG_TAG: string = 'DayPaletteSave';

interface ErrCodeParse {
  code: number;
  message: string;
}

interface ErrLikeShape {
  code?: number;
  message?: string;
}

function parseErrCodeMessage(e: object): ErrCodeParse {
  const err: ErrLikeShape = e as ErrLikeShape;
  const code: number = typeof err.code === 'number' ? err.code : -1;
  const message: string = typeof err.message === 'string' ? err.message : '';
  const out: ErrCodeParse = { code: code, message: message };
  return out;
}

function logSaveError(step: string, err: Error | object | string): void {
  let detail: string = '';
  if (typeof err === 'string') {
    detail = err;
  } else if (err instanceof Error) {
    detail = `${err.name}: ${err.message}`;
  } else {
    const p: ErrCodeParse = parseErrCodeMessage(err);
    if (p.message.length > 0) {
      detail = `code=${p.code} msg=${p.message}`;
    } else {
      try {
        detail = JSON.stringify(err);
      } catch (_e) {
        detail = 'unknown error';
      }
    }
  }
  const line: string = `[${step}] ${detail}`;
  hilog.error(SAVE_LOG_DOMAIN, SAVE_LOG_TAG, '%{public}s', line);
  console.error(`[DayPaletteSave] ${line}`);
}

const WRITE_MEDIA_PERMS: Permissions[] = ['ohos.permission.WRITE_IMAGEVIDEO'] as Permissions[];
const EXPORT_FILE_READY_RETRY_MS: number = 24;
const EXPORT_FILE_READY_MAX_RETRIES: number = 12;

/** 直接编码落盘，避免 packToData 在子线程完成后与主线程缓冲区/释放顺序相关的异常 */
async function packPngPixelMapToPath(pixelMap: image.PixelMap, path: string): Promise<boolean> {
  let opened: fileIo.File | null = null;
  try {
    opened = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
    const packer: image.ImagePacker = image.createImagePacker();
    const opts: image.PackingOption = { format: 'image/png', quality: 100 };
    await packer.packToFile(pixelMap, opened.fd, opts);
    return true;
  } catch (e) {
    logSaveError('packPngToFile', e as object);
    return false;
  } finally {
    if (opened !== null) {
      try {
        fileIo.closeSync(opened);
      } catch (_c) {
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
    logSaveError('readWholeFile', e as object);
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
  } catch (_e) {
  }
}

type PermissionGate = 'granted' | 'denied' | 'error';

async function ensureWriteImagePermission(context: common.UIAbilityContext): Promise<PermissionGate> {
  try {
    const mgr: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const res: PermissionRequestResult =
      await mgr.requestPermissionsFromUser(context, WRITE_MEDIA_PERMS) as PermissionRequestResult;
    if (res.authResults.length === 0) {
      logSaveError('permission', 'authResults empty');
      return 'error';
    }
    if (res.authResults[0] !== 0) {
      logSaveError('permission', `denied authResults[0]=${res.authResults[0]}`);
      return 'denied';
    }
    return 'granted';
  } catch (e) {
    logSaveError('permission', e as object);
    return 'error';
  }
}

export interface PngBufferOk {
  ok: true;
  data: ArrayBuffer;
}

export interface PngBufferFail {
  ok: false;
  step: 'pixel_map' | 'pack_png';
}

export type PngBufferResult = PngBufferOk | PngBufferFail;

/**
 * 在点击保存/分享的同步回调里生成，避免异步调度与界面状态短暂不一致；
 * 同时携带展示标题供分享面板与相册建议文件名。
 */
export interface PaletteExportSnapshot {
  mainHex: string;
  secHex: string;
  accHex: string;
  templateId: string;
  /** 单行：当前套组名（或回退场合标题） */
  displayTitle: string;
}

export function paletteExportSnapshotFromVm(vm: DayPaletteViewModel): PaletteExportSnapshot {
  const cols: string[] = vm.getHeroColorStrings();
  const compact: string = vm.getHeroTitleCompact().trim();
  const m: string = cols.length > 0 ? `${cols[0]}`.trim() : '';
  const s: string = cols.length > 1 ? `${cols[1]}`.trim() : '';
  const a: string = cols.length > 2 ? `${cols[2]}`.trim() : '';
  const tpl: string = `${vm.templateId}`.trim();
  const snap: PaletteExportSnapshot = {
    mainHex: m,
    secHex: s,
    accHex: a,
    templateId: tpl.length > 0 ? tpl : DEFAULT_TEMPLATE_ID,
    displayTitle: compact.length > 0 ? compact : 'DayPalette'
  };
  return snap;
}

/** 相册 / 系统弹窗用的短文件名（保留中英文、数字、_-） */
function safeAssetBaseName(title: string): string {
  const oneLine: string = title.replace(/<br\s*\/?>/gi, ' ').trim();
  let s: string = '';
  for (let i: number = 0; i < oneLine.length && s.length < 48; i++) {
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
      s = s + ch;
    } else if (ch === ' ' || ch === '.') {
      s = s + '_';
    }
  }
  return s.length > 0 ? s : 'DayPalette';
}

/**
 * 在应用 cache 中生成 PNG 文件（packToFile），返回绝对路径；失败返回 null。
 * 与 packToData 相比，编码结果先完整落盘再交给相册/分享，避免异步编码与内存别名问题。
 */
async function buildExportPngFileInCache(
  context: common.UIAbilityContext,
  snap: PaletteExportSnapshot
): Promise<string | null> {
  hilog.info(
    SAVE_LOG_DOMAIN,
    SAVE_LOG_TAG,
    '%{public}s',
    `export snap main=${snap.mainHex} sec=${snap.secHex} acc=${snap.accHex} tpl=${snap.templateId}`
  );
  const pm: image.PixelMap | null =
    createPaletteExportPixelMap(snap.mainHex, snap.secHex, snap.accHex, snap.templateId);
  if (pm === null) {
    logSaveError('export', 'createPaletteExportPixelMap returned null');
    return null;
  }
  const path: string =
    `${context.cacheDir}/daypalette_export_${Date.now()}_${Math.floor(Math.random() * 1e9)}.png`;
  const packed: boolean = await packPngPixelMapToPath(pm, path);
  disposePixelMap(pm);
  if (!packed) {
    try {
      fileIo.unlinkSync(path);
    } catch (_u) {
    }
    return null;
  }

  if (!(await waitUntilFileReadable(path))) {
    logSaveError('export_wait_ready', 'png file not readable after pack');
    try {
      fileIo.unlinkSync(path);
    } catch (_u) {
    }
    return null;
  }

  return path;
}

/** 分享或其它需要内存 buffer 的场景：先落盘再读回（与主流程编码路径一致） */
export async function buildExportPngBuffer(
  context: common.UIAbilityContext,
  vm: DayPaletteViewModel
): Promise<ArrayBuffer | null> {
  const snap: PaletteExportSnapshot = paletteExportSnapshotFromVm(vm);
  const p: string | null = await buildExportPngFileInCache(context, snap);
  if (p === null) {
    return null;
  }
  try {
    return readWholeFileSync(p);
  } finally {
    try {
      fileIo.unlinkSync(p);
    } catch (_u) {
    }
  }
}

/** 系统弹窗授权后写入相册；在「仅修改」等受限权限下通常比直连 createAsset 更可靠。 */
type AssetsDialogOutcome = 'success' | 'cancelled' | 'failed';

/** pngPath 为已写入的 PNG；由调用方在整次保存结束后 unlink */
async function saveToGalleryViaAssetsCreationDialog(
  context: common.UIAbilityContext,
  pngPath: string,
  suggestedTitle: string
): Promise<AssetsDialogOutcome> {
  try {
    const helper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    const srcUri: string = fileUri.getUriFromPath(pngPath);
    const creationTitle: string = safeAssetBaseName(suggestedTitle);
    const configs: photoAccessHelper.PhotoCreationConfig[] = [
      {
        title: creationTitle,
        fileNameExtension: 'png',
        photoType: photoAccessHelper.PhotoType.IMAGE
      }
    ];
    const destUris: string[] = await helper.showAssetsCreationDialog([srcUri], configs);
    if (destUris.length === 0) {
      return 'cancelled';
    }
    const diskBuf: ArrayBuffer | null = readWholeFileSync(pngPath);
    if (diskBuf === null) {
      logSaveError('gallery_dialog_read', 'read export png failed');
      return 'failed';
    }
    const outFile = fileIo.openSync(destUris[0], fileIo.OpenMode.READ_WRITE);
    try {
      fileIo.writeSync(outFile.fd, diskBuf);
    } catch (we) {
      logSaveError('gallery_dialog_write', we as object);
      return 'failed';
    } finally {
      fileIo.closeSync(outFile);
    }
    return 'success';
  } catch (e) {
    logSaveError('gallery_assets_dialog', e as object);
    return 'failed';
  }
}

export type SaveFailureHint =
  | 'album_permission_denied'
  | 'permission_request_failed'
  | 'export_pixel_map'
  | 'export_pack_png'
  | 'gallery_create_open'
  | 'gallery_write'
  | 'save_dialog_cancelled'
  | 'unknown';

export interface SavePaletteImageSuccess {
  ok: true;
}

export interface SavePaletteImageFailure {
  ok: false;
  hint: SaveFailureHint;
  code?: number;
}

export type SavePaletteImageResult = SavePaletteImageSuccess | SavePaletteImageFailure;

export interface SharePaletteSuccess {
  ok: true;
}

export interface SharePaletteFailure {
  ok: false;
  hint: 'build_image' | 'share_panel';
}

export type SharePaletteResult = SharePaletteSuccess | SharePaletteFailure;

interface SharePanelShowOptions {
  selectionMode: systemShare.SelectionMode;
  previewMode: systemShare.SharePreviewMode;
}

export async function saveTodayPaletteToGallery(
  context: common.UIAbilityContext,
  snap: PaletteExportSnapshot
): Promise<SavePaletteImageResult> {
  const pngPath: string | null = await buildExportPngFileInCache(context, snap);
  if (pngPath === null) {
    const out: SavePaletteImageFailure = { ok: false, hint: 'export_pixel_map' };
    return out;
  }
  try {
    const viaDialog: AssetsDialogOutcome =
      await saveToGalleryViaAssetsCreationDialog(context, pngPath, snap.displayTitle);
    if (viaDialog === 'success') {
      const ok: SavePaletteImageSuccess = { ok: true };
      return ok;
    }
    if (viaDialog === 'cancelled') {
      const out: SavePaletteImageFailure = { ok: false, hint: 'save_dialog_cancelled' };
      return out;
    }

    const gate: PermissionGate = await ensureWriteImagePermission(context);
    if (gate === 'denied') {
      const out: SavePaletteImageFailure = { ok: false, hint: 'album_permission_denied' };
      return out;
    }
    if (gate === 'error') {
      const out: SavePaletteImageFailure = { ok: false, hint: 'permission_request_failed' };
      return out;
    }

    const goodBuf: ArrayBuffer | null = readWholeFileSync(pngPath);
    if (goodBuf === null) {
      const out: SavePaletteImageFailure = { ok: false, hint: 'export_pack_png' };
      return out;
    }

    try {
      const helper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      const base: string = safeAssetBaseName(snap.displayTitle);
      const name: string = `${base}_${Date.now()}.png`;
      const uri: string = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, name);
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
      try {
        fileIo.writeSync(file.fd, goodBuf);
      } catch (we) {
        logSaveError('gallery_write', we as object);
        const p: ErrCodeParse = parseErrCodeMessage(we as object);
        try {
          fileIo.closeSync(file);
        } catch (_c) {
        }
        const out: SavePaletteImageFailure = {
          ok: false,
          hint: 'gallery_write',
          code: p.code >= 0 ? p.code : undefined
        };
        return out;
      }
      fileIo.closeSync(file);
      const ok: SavePaletteImageSuccess = { ok: true };
      return ok;
    } catch (e) {
      logSaveError('gallery_create_open', e as object);
      const p: ErrCodeParse = parseErrCodeMessage(e as object);
      const out: SavePaletteImageFailure = {
        ok: false,
        hint: 'gallery_create_open',
        code: p.code >= 0 ? p.code : undefined
      };
      return out;
    }
  } finally {
    try {
      fileIo.unlinkSync(pngPath);
    } catch (_u) {
    }
  }
}

export async function shareTodayPaletteImage(
  context: common.UIAbilityContext,
  snap: PaletteExportSnapshot
): Promise<SharePaletteResult> {
  const path: string | null = await buildExportPngFileInCache(context, snap);
  if (path === null) {
    const out: SharePaletteFailure = { ok: false, hint: 'build_image' };
    return out;
  }
  try {
    const shareUri: string = fileUri.getUriFromPath(path);
    const data: systemShare.SharedData = new systemShare.SharedData({
      utd: uniformTypeDescriptor.UniformDataType.IMAGE,
      uri: shareUri,
      title: snap.displayTitle,
      description: ''
    });
    const controller: systemShare.ShareController = new systemShare.ShareController(data);
    const showOpts: SharePanelShowOptions = {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DEFAULT
    };
    controller.show(context, showOpts);
    const ok: SharePaletteSuccess = { ok: true };
    return ok;
  } catch (e) {
    logSaveError('share', e as object);
    const out: SharePaletteFailure = { ok: false, hint: 'share_panel' };
    return out;
  }
  // 注意：分享面板是异步跨进程的，不能立即 unlinkSync，否则分享目标读不到文件
}
