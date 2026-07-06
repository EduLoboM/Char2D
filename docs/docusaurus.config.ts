import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Char2D',
  tagline: 'A 2D game engine built in Beef Lang for grid-based RPGs, featuring hybrid turn-based combat and active bullet dodging.',
  favicon: 'img/favicon.ico',
  url: 'https://edulobom.github.io',
  baseUrl: '/Char2D/',
  organizationName: 'EduLoboM',
  projectName: 'Char2D',

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],

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
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Char2D',
      logo: {
        alt: 'Char2D Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
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
              label: 'GitHub Repository',
              href: 'https://github.com/EduLoboM/Char2D',
            },
            {
              label: 'Report an Issue',
              href: 'https://github.com/EduLoboM/Char2D/issues',
            },
            {
              label: 'Run Locally',
              href: 'https://github.com/EduLoboM/Char2D/blob/main/README.md',
            },
          ],
        },
        {
          title: 'Development',
          items: [
            {
              label: 'Awesome Beef',
              href: 'https://github.com/Jonathan-Racaud/awesome-beef',
            },
            {
              label: 'Releases & Downloads',
              href: 'https://github.com/EduLoboM/Char2D/releases',
            },
            {
              label: 'EPL-2.0 License',
              href: 'https://github.com/EduLoboM/Char2D/blob/main/LICENSE',
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
