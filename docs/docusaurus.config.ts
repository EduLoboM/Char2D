import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Char2D',
  tagline: 'A 2D game engine built in Beef Lang for grid-based RPGs, featuring hybrid turn-based combat and active bullet dodging.',
  favicon: 'img/favicon_dark.png',
  url: 'https://edulobom.github.io',
  baseUrl: '/Char2D/',
  organizationName: 'EduLoboM',
  projectName: 'Char2D',

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  markdown: {
    mermaid: true,
  },
  themes: [
    '@docusaurus/theme-mermaid',
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        indexBlog: false,
      },
    ],
  ],

  clientModules: [
    './src/theme/theme_favicon.js',
  ],

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
        },
        blog: false, // Disabled blog as requested
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'Char2D',
      logo: {
        alt: 'Char2D Logo',
        src: 'img/favicon_light.png',
        srcDark: 'img/favicon_dark.png',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          type: 'search',
          position: 'right',
        },
        {
          href: 'https://github.com/EduLoboM/Char2D',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {
              label: 'About Char2D',
              href: 'https://edulobom.github.io/Char2D/docs/intro',
            },
            {
              label: 'About Beef',
              href: 'https://www.beeflang.org/',
            },
            {
              label: 'About Docusaurus',
              href: 'https://docusaurus.io/',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'How to Contribute & Run',
              href: 'https://edulobom.github.io/Char2D/docs/contributing',
            },
            {
              label: 'Report an Issue',
              href: 'https://github.com/EduLoboM/Char2D/issues',
            },
            {
              label: 'GitHub Repository',
              href: 'https://github.com/EduLoboM/Char2D',
            },
          ],
        },
        {
          title: 'Development',
          items: [
            {
              label: 'Releases & Downloads',
              href: 'https://github.com/EduLoboM/Char2D/releases',
            },
            {
              label: 'EPL-2.0 License',
              href: 'https://github.com/EduLoboM/Char2D/blob/main/LICENSE',
            },
            {
              label: 'Awesome Beef',
              href: 'https://github.com/Jonathan-Racaud/awesome-beef',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} EduLoboM. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
