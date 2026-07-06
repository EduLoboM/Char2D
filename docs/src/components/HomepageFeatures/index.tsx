import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import Link from '@docusaurus/Link';
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
    title: 'The Game Engine',
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
      { label: 'Dungeon Phases', url: '/docs/game/#2-dungeon-phase' },
      { label: 'Combat & Bullet Dodging', url: '/docs/game/#3-combat-phase' },
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
      { label: 'Integration Guidelines', url: '/docs/artifacts/#asset-integration-guidelines' },
    ],
  },
];

function Feature({title, icon, link, linkLabel, links}: FeatureItem) {
  return (
    <div className={clsx('col col--4', styles.featureCol)}>
      <div className="glass-card">
        <div className={styles.iconWrapper}>
          <span className="material-symbols-outlined" style={{ fontSize: '28px' }}>
            {icon}
          </span>
        </div>
        <div className={styles.featureInfo}>
          <Heading as="h3" className={styles.featureTitle}>{title}</Heading>
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
        <div className={styles.featureFooter}>
          <Link className={styles.featureLink} to={link}>
            {linkLabel} <span className={styles.arrow}>→</span>
          </Link>
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

