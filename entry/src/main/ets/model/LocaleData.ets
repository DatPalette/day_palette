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
      palette('w3', 'City Slate', 'Professional & sharp', '#E2E4E9', '#B0B5C0', '#2C363F')
    ]
  },
  {
    id: 'weekend',
    label: 'Weekend Date',
    title: 'Sweet<br>Escape',
    palettes: [
      palette('we1', 'Peach Weekend', 'Gentle highlights', '#F2E3E0', '#D9A9A0', '#8C6A5D'),
      palette('we2', 'Picnic Day', 'Sunny & bright', '#FFF3E0', '#FFB74D', '#5E6AC4')
    ]
  },
  {
    id: 'outdoor',
    label: 'Outdoor',
    title: 'Breathe<br>Deeply',
    palettes: [
      palette('o1', 'Breeze Outdoor', 'Fresh & breathable', '#E2EFE9', '#9BBBAA', '#5C6BC0'),
      palette('o2', 'Forest Trail', 'Earthy tones', '#DDE5B6', '#ADC178', '#6C584C')
    ]
  },
  {
    id: 'dinner',
    label: 'Dinner Party',
    title: 'Evening<br>Glow',
    palettes: [
      palette('d1', 'Velvet Night', 'Elegant & moody', '#3D2C2E', '#8B5A5C', '#D4AF37'),
      palette('d2', 'Silver Noir', 'Minimalist chic', '#2B2D42', '#8D99AE', '#EDF2F4')
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
      palette('w3', '城市灰调', '专业 · 利落', '#E2E4E9', '#B0B5C0', '#2C363F')
    ]
  },
  {
    id: 'weekend',
    label: '周末约会',
    title: '桃汽<br>周末',
    palettes: [
      palette('we1', '桃汽周末', '温柔亮点', '#F2E3E0', '#D9A9A0', '#8C6A5D'),
      palette('we2', '野餐假日', '明媚阳光', '#FFF3E0', '#FFB74D', '#5E6AC4')
    ]
  },
  {
    id: 'outdoor',
    label: '户外运动',
    title: '清风<br>户外',
    palettes: [
      palette('o1', '清风户外', '清爽透气感', '#E2EFE9', '#9BBBAA', '#5C6BC0'),
      palette('o2', '森林步道', '自然大地色', '#DDE5B6', '#ADC178', '#6C584C')
    ]
  },
  {
    id: 'dinner',
    label: '晚宴',
    title: '晚宴<br>流光',
    palettes: [
      palette('d1', '丝绒暗夜', '优雅情绪', '#3D2C2E', '#8B5A5C', '#D4AF37'),
      palette('d2', '极简黑白', '高级克制', '#2B2D42', '#8D99AE', '#EDF2F4')
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
    aboutLabel: 'About DayPalette'
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
    aboutLabel: '关于今日配色'
  },
  occasions: ZH_OCCASIONS
};

export function getLocaleBundle(lang: AppLanguage): LocaleBundle {
  if (lang === AppLanguage.ZH) {
    return ZH_BUNDLE;
  }
  return EN_BUNDLE;
}
