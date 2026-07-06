import type { ReactNode } from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import Link from '@docusaurus/Link';
import { useHistory } from '@docusaurus/router';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './styles.module.css';

type FeatureLink = {
  label: string;
  url: string;
};

type FeatureItem = {
  title: string;
  icon: string;
  link: string;
  linkLabel: string;
  links: FeatureLink[];
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Game Engine Engineering',
    link: '/docs/engine/',
    linkLabel: 'Explore Engine Architecture',
    icon: 'terminal',
    links: [
      { label: 'System Architecture', url: '/docs/engine/#system-architecture-tree' },
      { label: 'Core Loop & Systems', url: '/docs/engine/#system-architecture-tree' },
    ],
  },
  {
    title: 'Combat & Mechanics',
    link: '/docs/game/',
    linkLabel: 'Read Combat Mechanics',
    icon: 'sports_esports',
    links: [
      { label: 'Dungeon Phases', url: '/docs/game/#game-loop' },
      { label: 'Combat & Bullet Dodging', url: '/docs/game/#combat-system' },
      { label: 'Status Synergies', url: '/docs/game/#status-synergies' },
    ],
  },
  {
    title: 'Artifacts & Assets',
    link: '/docs/artifacts/',
    linkLabel: 'View Assets & GDD',
    icon: 'folder_open',
    links: [
      { label: 'Asset Registry', url: '/docs/artifacts/#initial-project-assets' },
      { label: 'Integration Guidelines', url: '/docs/contributing' },
    ],
  },
];

function Feature({ title, icon, link, linkLabel, links }: FeatureItem) {
  const history = useHistory();
  const linkWithBase = useBaseUrl(link);

  const handleCardClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const target = e.target as HTMLElement;
    if (target.closest('a')) {
      return;
    }
    history.push(linkWithBase);
  };

  return (
    <div className={clsx('col col--4', styles.featureCol)}>
      <div className="glass-card" onClick={handleCardClick}>
        <div className={styles.featureInfo}>
          <Heading as="h3" className={styles.featureTitle}>
            <span className={clsx('material-symbols-outlined', styles.featureIcon)}>
              {icon}
            </span>
            {title}
          </Heading>
          <ul className={styles.linkList}>
            {links.map((item, idx) => (
              <li key={idx}>
                <Link className={styles.subLink} to={item.url}>
                  <span className={clsx('material-symbols-outlined', styles.subLinkIcon)}>
                    chevron_right
                  </span>
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}

