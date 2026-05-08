export interface SmartMatchLocalizedText {
  zh: string;
  en: string;
}

export interface SmartMatchSceneStrategy {
  tabooFamilies: string[];
  mood: SmartMatchLocalizedText;
}

export interface SmartMatchTemplateSet {
  sceneMatch: SmartMatchLocalizedText;
  layerBalance: SmartMatchLocalizedText;
  safeResult: SmartMatchLocalizedText;
  styleHint: SmartMatchLocalizedText;
}

export interface SmartMatchStrategyFile {
  version: number;
  updatedAt: string;
  templates: SmartMatchTemplateSet;
  fallbackScene: SmartMatchSceneStrategy;
  scenes: Record<string, SmartMatchSceneStrategy>;
}

export interface SmartMatchTemplateReplacement {
  key: string;
  value: string;
}