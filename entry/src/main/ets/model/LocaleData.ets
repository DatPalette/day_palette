import { AppLanguage } from './AppLanguage';
import type { LocaleBundle } from './LocaleTypes';
import type { Occasion } from './Occasion';
import type { Palette } from './Palette';

function palette(id: string, name: string, desc: string, main: string, sec: string, acc: string): Palette {
  const colors: string[] = [main, sec, acc];
  return { id, name, desc, colors };
}

const EN_OCCASIONS: Occasion[] = [
  {
    id: 'workday',
    label: 'Workday',
    title: 'Gentle<br>Commute',
    palettes: [
      palette('w1', 'Morning Mist', 'Low saturation, versatile', '#E8D8D3', '#C5B9B6', '#5D637A'),
      palette('w2', 'Coffee Break', 'Warm & grounded', '#D4C5B9', '#A89F91', '#4A3B32'),
      palette('w3', 'City Slate', 'Professional & sharp', '#E2E4E9', '#B0B5C0', '#2C363F'),
      palette('w4', 'Paper Ink', 'Calm contrast', '#F4F1ED', '#C4B8A5', '#1F2933'),
      palette('w5', 'Dawn Line', 'Soft structure', '#EDE7F6', '#B39DDB', '#4527A0')
    ]
  },
  {
    id: 'weekend',
    label: 'Weekend Date',
    title: 'Sweet<br>Escape',
    palettes: [
      palette('we1', 'Peach Weekend', 'Gentle highlights', '#F2E3E0', '#D9A9A0', '#8C6A5D'),
      palette('we2', 'Picnic Day', 'Sunny & bright', '#FFF3E0', '#FFB74D', '#5E6AC4'),
      palette('we3', 'Sea Glass', 'Cool relax', '#E0F7FA', '#4DD0E1', '#006064'),
      palette('we4', 'Rose Lane', 'Warm blush', '#FCE4EC', '#F06292', '#880E4F')
    ]
  },
  {
    id: 'outdoor',
    label: 'Outdoor',
    title: 'Breathe<br>Deeply',
    palettes: [
      palette('o1', 'Breeze Outdoor', 'Fresh & breathable', '#E2EFE9', '#9BBBAA', '#5C6BC0'),
      palette('o2', 'Forest Trail', 'Earthy tones', '#DDE5B6', '#ADC178', '#6C584C'),
      palette('o3', 'Highland', 'Windy moor', '#E8F5E9', '#81C784', '#33691E'),
      palette('o4', 'Clay Path', 'Mineral warm', '#EFEBE9', '#A1887F', '#4E342E')
    ]
  },
  {
    id: 'dinner',
    label: 'Dinner Party',
    title: 'Evening<br>Glow',
    palettes: [
      palette('d1', 'Velvet Night', 'Elegant & moody', '#3D2C2E', '#8B5A5C', '#D4AF37'),
      palette('d2', 'Silver Noir', 'Minimalist chic', '#2B2D42', '#8D99AE', '#EDF2F4'),
      palette('d3', 'Copper Bar', 'Warm metal', '#3E2723', '#BF8F68', '#FFF8E1'),
      palette('d4', 'Ice Riesling', 'Cool glass', '#ECEFF1', '#90A4AE', '#263238')
    ]
  }
];

const ZH_OCCASIONS: Occasion[] = [
  {
    id: 'workday',
    label: '工作日',
    title: '温柔<br>通勤日',
    palettes: [
      palette('w1', '晨雾通勤', '低饱和 · 好搭', '#E8D8D3', '#C5B9B6', '#5D637A'),
      palette('w2', '拿铁时间', '温暖 · 沉稳', '#D4C5B9', '#A89F91', '#4A3B32'),
      palette('w3', '城市灰调', '专业 · 利落', '#E2E4E9', '#B0B5C0', '#2C363F'),
      palette('w4', '纸墨通勤', '安静对比', '#F4F1ED', '#C4B8A5', '#1F2933'),
      palette('w5', '晨光线条', '柔和结构', '#EDE7F6', '#B39DDB', '#4527A0')
    ]
  },
  {
    id: 'weekend',
    label: '周末约会',
    title: '桃汽<br>周末',
    palettes: [
      palette('we1', '桃汽周末', '温柔亮点', '#F2E3E0', '#D9A9A0', '#8C6A5D'),
      palette('we2', '野餐假日', '明媚阳光', '#FFF3E0', '#FFB74D', '#5E6AC4'),
      palette('we3', '海玻璃', '清凉放松', '#E0F7FA', '#4DD0E1', '#006064'),
      palette('we4', '玫瑰小径', '温柔腮红', '#FCE4EC', '#F06292', '#880E4F')
    ]
  },
  {
    id: 'outdoor',
    label: '户外运动',
    title: '清风<br>户外',
    palettes: [
      palette('o1', '清风户外', '清爽透气感', '#E2EFE9', '#9BBBAA', '#5C6BC0'),
      palette('o2', '森林步道', '自然大地色', '#DDE5B6', '#ADC178', '#6C584C'),
      palette('o3', '高地风', '旷野清新', '#E8F5E9', '#81C784', '#33691E'),
      palette('o4', '陶土小径', '矿物暖调', '#EFEBE9', '#A1887F', '#4E342E')
    ]
  },
  {
    id: 'dinner',
    label: '晚宴',
    title: '晚宴<br>流光',
    palettes: [
      palette('d1', '丝绒暗夜', '优雅情绪', '#3D2C2E', '#8B5A5C', '#D4AF37'),
      palette('d2', '极简黑白', '高级克制', '#2B2D42', '#8D99AE', '#EDF2F4'),
      palette('d3', '铜色吧台', '暖金属感', '#3E2723', '#BF8F68', '#FFF8E1'),
      palette('d4', '冰葡白', '清透玻璃', '#ECEFF1', '#90A4AE', '#263238')
    ]
  }
];

const EN_BUNDLE: LocaleBundle = {
  ui: {
    date: 'Apr 01, 2026',
    storyTitle: 'Story of the Day',
    curatedTitle: 'Curated Palettes',
    save: 'Save',
    share: 'Share',
    main: 'Main',
    sec: 'Sec',
    acc: 'Acc',
    settingsTitle: 'Settings',
    langLabel: 'Language',
    langFollowSystem: 'System',
    themeLabel: 'Appearance',
    themeValue: 'System',
    aboutLabel: 'About DayPalette',
    saveSuccess: 'Saved to gallery',
    saveFail: 'Could not save image',
    saveFailAlbumPermission:
      'Allow Photos & videos when prompted, or turn it on in Settings → Apps → DayPalette → Permissions.',
    saveFailPermissionRequest:
      'Could not request storage permission. Try again or enable it in system Settings.',
    saveFailBuildImage:
      'Could not draw the palette image. Try another palette or export layout, then save again.',
    saveFailEncodeImage: 'Could not encode PNG. Try again or restart the app.',
    saveFailGalleryApi:
      'Direct save uses a different path than Share → Save to gallery. Tap Share, then choose Save to gallery. Also check Photos & videos permission.',
    saveFailGalleryWrite:
      'Could not write to gallery. Try Share → Save to gallery; check free space and Photos permission.',
    saveFailUnknown: 'Save failed. Try Share → Save to gallery, or check permissions and storage.',
    saveCancelled: 'Save cancelled.',
    shareFail: 'Could not share',
    shareFailBuildImage: 'Could not prepare image to share. Try another palette or restart the app.',
    shareFailOther: 'Share failed. Check that a share target is available.',
    permissionDenied: 'Photo permission denied',
    randomPalette: 'Random pick',
    randomPaletteHint: 'From this occasion’s curated sets',
    yesterdayOutfit: 'Yesterday',
    fineTune: 'Tune',
    fineTuneTitle: 'Fine-tune colors',
    fineTuneApply: 'Apply',
    fineTuneReset: 'Reset to palette',
    fineTuneInvalid: 'Use valid #RGB or #RRGGBB',
    yesterdayEmpty: 'No yesterday outfit yet',
    exportTemplateLabel: 'Export layout',
    templateEditorial: 'Editorial',
    templateColumns: 'Columns',
    templateThirds: 'Thirds',
    templateBento: 'Mosaic',
    templateStack: 'Stack',
    reduceMotionLabel: 'Reduce motion',
    noiseLabel: 'Subtle grain',
    themeFollowSystem: 'Match system',
    themeLight: 'Light',
    themeDark: 'Dark'
  },
  occasions: EN_OCCASIONS
};

const ZH_BUNDLE: LocaleBundle = {
  ui: {
    date: '2026年4月1日',
    storyTitle: '今天的故事',
    curatedTitle: '精选配色盘',
    save: '保存图片',
    share: '分享',
    main: '主色',
    sec: '辅色',
    acc: '点缀',
    settingsTitle: '设置',
    langLabel: '语言',
    langFollowSystem: '跟随系统',
    themeLabel: '外观',
    themeValue: '跟随系统',
    aboutLabel: '关于今日配色',
    saveSuccess: '已保存到相册',
    saveFail: '保存失败',
    saveFailAlbumPermission:
      '请在弹窗中允许「照片和视频」权限，或到 设置 → 应用 → 今日配色 → 权限 中手动开启。',
    saveFailPermissionRequest: '申请存储权限失败，请稍后重试或到系统设置中手动授权。',
    saveFailBuildImage: '生成配色图失败，可尝试切换套组或导出版式后再保存。',
    saveFailEncodeImage: '图片编码失败，请重试或重启应用后再试。',
    saveFailGalleryApi:
      '「保存图片」直连相册，与分享面板里的「保存至图库」不是同一条通路。可先点「分享」，在分享里选「保存至图库」。并确认已开启「照片和视频」权限。',
    saveFailGalleryWrite:
      '写入相册失败。可先点「分享」→「保存至图库」；并检查剩余空间与相册权限。',
    saveFailUnknown: '保存失败。可先尝试「分享」→「保存至图库」，或检查权限与存储空间。',
    saveCancelled: '已取消保存。',
    shareFail: '分享失败',
    shareFailBuildImage: '无法生成待分享图片，可尝试切换套组或重启应用。',
    shareFailOther: '分享失败，请确认系统有可用的分享目标。',
    permissionDenied: '需要相册写入权限',
    randomPalette: '随机选',
    randomPaletteHint: '从当前场合推荐套组中选一套',
    yesterdayOutfit: '昨日',
    fineTune: '精调',
    fineTuneTitle: '微调三色',
    fineTuneApply: '应用',
    fineTuneReset: '恢复套组色',
    fineTuneInvalid: '请使用 #RGB 或 #RRGGBB',
    yesterdayEmpty: '暂无昨日记录',
    exportTemplateLabel: '导出版式',
    templateEditorial: '横条',
    templateColumns: '竖条',
    templateThirds: '三等分',
    templateBento: '拼图',
    templateStack: '叠放',
    reduceMotionLabel: '减少动效',
    noiseLabel: '轻微颗粒',
    themeFollowSystem: '跟随系统',
    themeLight: '浅色',
    themeDark: '深色'
  },
  occasions: ZH_OCCASIONS
};

export function getLocaleBundle(lang: AppLanguage): LocaleBundle {
  if (lang === AppLanguage.ZH) {
    return ZH_BUNDLE;
  }
  return EN_BUNDLE;
}
