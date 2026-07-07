/**
 * Client module that swaps the favicon based on the current color mode (light/dark).
 * Uses a MutationObserver on <html data-theme="..."> to react to theme changes.
 */

const FAVICON_LIGHT = '/Char2D/img/favicon_light.png';
const FAVICON_DARK = '/Char2D/img/favicon_dark.png';

/**
 * Resolves the current theme by checking multiple sources in priority order:
 * 1. localStorage — the user's persisted choice (survives page navigations)
 * 2. data-theme attribute on <html> — set by Docusaurus at runtime
 * 3. prefers-color-scheme media query — OS-level preference
 * 4. 'dark' — default from docusaurus.config.ts
 */
function getResolvedTheme() {
  // localStorage is the most reliable source during page transitions because
  // Docusaurus may not have set data-theme on <html> yet when scripts run.
  const stored = localStorage.getItem('theme');
  if (stored === 'light' || stored === 'dark') {
    return stored;
  }

  const attr = document.documentElement.getAttribute('data-theme');
  if (attr === 'light' || attr === 'dark') {
    return attr;
  }

  // Fall back to OS preference
  if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
    return 'light';
  }

  return 'dark'; // ultimate default from docusaurus.config.ts
}

function applyFavicon(theme) {
  const faviconHref = theme === 'dark' ? FAVICON_DARK : FAVICON_LIGHT;

  // Find all favicon link elements (Docusaurus may use rel="icon" or rel="shortcut icon")
  const links = document.querySelectorAll(
    'link[rel="icon"], link[rel="shortcut icon"]'
  );

  if (links.length > 0) {
    links.forEach((link) => {
      link.href = faviconHref;
    });
  } else {
    const link = document.createElement('link');
    link.rel = 'icon';
    link.href = faviconHref;
    document.head.appendChild(link);
  }
}

function updateFavicon() {
  applyFavicon(getResolvedTheme());
}

export function onRouteDidUpdate() {
  // Apply immediately for instant feedback
  updateFavicon();

  // Re-apply after a short delay to catch cases where Docusaurus sets
  // data-theme slightly after the route update callback fires
  requestAnimationFrame(() => {
    updateFavicon();
  });
}

// Run immediately when the module loads to catch the theme
// before the first route update (e.g. user had light mode saved)
if (typeof document !== 'undefined') {
  updateFavicon();

  // Observe theme attribute changes on <html> to catch toggle switches
  const observer = new MutationObserver(() => {
    updateFavicon();
  });

  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['data-theme'],
  });
}
