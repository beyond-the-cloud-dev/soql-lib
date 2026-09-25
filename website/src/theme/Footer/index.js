import React from 'react';
import { footerData, contextLinks } from './footer-data';
import styles from './styles.module.css';

const SITE_CONTEXT = 'soql-lib';

const ICONS = {
  linkedin:
    'M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z',
  github:
    'M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z',
  youtube:
    'M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z'
};

function Socials({ size }) {
  return (
    <div className={styles.socials}>
      {footerData.social.map((s) => (
        <a key={s.name} href={s.href} aria-label={s.name} className={styles.social} target="_blank" rel="noopener noreferrer">
          <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d={ICONS[s.icon]} />
          </svg>
        </a>
      ))}
    </div>
  );
}

function LinkColumn({ title, links, className }) {
  return (
    <div className={`${styles.col} ${className || ''}`}>
      <h4 className={styles.label}>{title}</h4>
      {links.map((l) => (
        <a key={l.label} href={l.href} className={styles.link}>
          {l.label}
        </a>
      ))}
    </div>
  );
}

export default function Footer() {
  const data = footerData;
  const year = new Date().getFullYear();
  const siteLinks = contextLinks[SITE_CONTEXT] || [];

  return (
    <footer className={styles.btcFooter}>
      <div className={styles.strip}>
        <div className={styles.stripInner}>
          <div className={styles.os}>
            <h4 className={styles.label}>Open Source</h4>
            <a href={data.openSource.parent.href} className={styles.parent}>
              <img src={data.openSource.parent.logo} alt="" className={styles.parentLogo} />
              <span>{data.openSource.parent.label}</span>
            </a>
          </div>
          <div className={styles.tiles}>
            {data.openSource.children.map((lib) => {
              const current = lib.id === SITE_CONTEXT;
              return (
                <a
                  key={lib.id}
                  href={lib.href}
                  className={`${styles.tile} ${current ? styles.tileCurrent : ''}`}
                  aria-current={current ? 'page' : undefined}
                >
                  <img src={lib.logo} alt="" className={styles.tileLogo} />
                  <span className={styles.tileName}>{lib.label}</span>
                </a>
              );
            })}
          </div>
        </div>
      </div>

      <div className={`${styles.body} ${siteLinks.length ? styles.bodyWithSite : ''}`}>
        <div className={styles.company}>
          <div className={styles.brand}>
            <img src="/img/btc-logo.png" alt="Beyond The Cloud" className={`${styles.logo} ${styles.logoDark}`} />
            <img src="/img/btc-logo-dark.png" alt="Beyond The Cloud" className={`${styles.logo} ${styles.logoLight}`} />
            <div className={styles.tagline}>{data.company.tagline}</div>
          </div>
          <p className={styles.description}>{data.company.description}</p>
          <div className={`${styles.badgeRow} ${styles.desktopOnly}`}>
            <img src="/img/salesforcePartnerBadgeHorizontal.png" alt="Salesforce Partner" className={styles.badge} />
            <Socials size={17} />
          </div>
        </div>

        {siteLinks.length > 0 && <LinkColumn title="This site" links={siteLinks} className={styles.colSite} />}
        <LinkColumn title="Services" links={data.services} />
        <div className={styles.pair}>
          <LinkColumn title="Products" links={data.products} />
          <LinkColumn title="Resources" links={data.resources} />
        </div>

        <div className={`${styles.badgeRow} ${styles.mobileOnly}`}>
          <img src="/img/salesforcePartnerBadgeHorizontal.png" alt="Salesforce Partner" className={styles.badge} />
          <Socials size={20} />
        </div>
      </div>

      <div className={styles.legal}>
        <div className={styles.legalInner}>
          <div className={styles.legalCompany}>
            <span>{data.company.name}</span>
            <span className={styles.dot}>·</span>
            <span>{data.company.nip}</span>
            <span className={styles.dot}>·</span>
            <span>{data.company.address}</span>
            <span className={styles.dot}>·</span>
            <a href={`mailto:${data.company.email}`} className={`${styles.legalLink} ${styles.email}`}>
              {data.company.email}
            </a>
          </div>
          <div className={styles.legalLinks}>
            <a href={data.legal.privacyPolicy} className={styles.legalLink}>
              Privacy Policy
            </a>
            <span className={styles.dot}>·</span>
            <a href={data.legal.mainSite} className={styles.legalLink}>
              beyondthecloud.dev
            </a>
          </div>
          <div className={styles.copy}>© {year} Beyond The Cloud</div>
        </div>
      </div>
    </footer>
  );
}
