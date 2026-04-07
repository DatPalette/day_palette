import type { Palette } from './Palette';

export interface Collection {
  id: string;
  name: string;
  desc: string;
  themeType: string;
  coverPaletteId: string;
  occasionTags: string[];
  palettes: Palette[];
}