import type { ReactNode } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={styles.heroBanner}>
      <div className={styles.heroGlow} />
      <div className={styles.heroContent}>
        <div className={styles.logoContainer}>
          <img src="img/logo_texto.png" alt="Char2D Logo" className={styles.heroLogo} />
        </div>
        <p className={styles.heroSubtitle}>{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className={styles.primaryButton}
            to="/docs/intro">
            <span className="material-symbols-outlined icon-inline" style={{ marginRight: '8px', fontSize: '1.25rem' }}>
              menu_book
            </span>
            Read the Docs
          </Link>
          <Link
            className={styles.secondaryButton}
            to="https://github.com/EduLoboM/Char2D">
            <span className="material-symbols-outlined icon-inline" style={{ marginRight: '8px', fontSize: '1.25rem' }}>
              code
            </span>
            GitHub
          </Link>
        </div>
      </div>
    </header>
  );
}


export default function Home(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} Engine`}
      description="A 2D game engine built in Beef Lang for grid-based RPGs, featuring hybrid turn-based combat and active bullet dodging.">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
