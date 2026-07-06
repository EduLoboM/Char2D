/**
 * Client module that swaps the favicon based on the current color mode (light/dark).
 * Uses a MutationObserver on <html data-theme="..."> to react to theme changes.
 */

const FAVICON_LIGHT = '/Char2D/img/favicon_light.png';
const FAVICON_DARK = '/Char2D/img/favicon_dark.png';

function updateFavicon() {
  // Check data-theme first, then fall back to localStorage (Docusaurus saves it there)
  const theme =
    document.documentElement.getAttribute('data-theme') ||
    localStorage.getItem('theme') ||
    'dark'; // default from docusaurus.config.ts
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

export function onRouteDidUpdate() {
  updateFavicon();
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
