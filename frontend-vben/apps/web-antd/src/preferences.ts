import { defineOverridesPreferences } from '@vben/preferences';
export const overridesPreferences = defineOverridesPreferences({
  app: { name: 'Data Agent', defaultHomePath: '/workbench', enableCheckUpdates: false },
  theme: { mode: 'light', semiDarkSidebar: true, radius: '0.25' },
  copyright: { enable: false },
  widget: { notification: false, lockScreen: false, languageToggle: false, timezone: false, order: ['globalSearch', 'preferences', 'themeToggle', 'fullscreen', 'refresh'] },
});
export const preferencesExtension = undefined;
