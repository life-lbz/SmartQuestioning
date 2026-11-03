import { defineOverridesPreferences } from '@vben/preferences';
export const overridesPreferences = defineOverridesPreferences({
  app: { name: 'Smart Questioning', defaultHomePath: '/overview', enableCheckUpdates: false },
  transition: { enable: false, loading: false, progress: false },
  theme: { mode: 'light', semiDarkSidebar: false, radius: '0.25' },
  copyright: { enable: false },
  widget: { themeToggle: false, notification: false, lockScreen: false, languageToggle: false, timezone: false },
});
export const preferencesExtension = undefined;
