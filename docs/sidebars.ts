import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    {
      type: 'doc',
      id: 'intro', // This maps to intro.md
      label: 'About Char2D',
    },
    {
      type: 'category',
      label: 'The Game Engine',
      items: ['engine/index'], // Maps to engine/index.md
    },
    {
      type: 'category',
      label: 'The Game',
      items: ['game/index'], // Maps to game/index.md
    },
    {
      type: 'category',
      label: 'The Artifacts and Assets',
      items: ['artifacts/index'], // Maps to artifacts/index.md
    },
  ],
};

export default sidebars;
