import React from 'react';
import { footerData, contextLinks } from './footer-data';
import styles from './styles.module.css';

const SITE_CONTEXT = 'soql-lib';

const SocialIcons = ({ data }) => (
  <div className={styles.socialIcons}>
    {data.social.map((social) => (
      <a
        key={social.name}
        href={social.href}
        aria-label={social.name}
        className={styles.socialIcon}
        target="_blank"
        rel="noopener noreferrer"
      >
        <img src={`/img/social/${social.icon}.svg`} alt={social.name} className={styles.socialImg} />
      </a>
    ))}
  </div>
);

function Footer() {
  const data = footerData;
  const currentYear = new Date().getFullYear();
  const currentContextLinks = contextLinks[SITE_CONTEXT] || [];

  return (
    <footer className={styles.btcFooter}>
      {/* Background decorative elements */}
      <div className={styles.footerBgEffects}>
        <div className={`${styles.bgBlob} ${styles.bgBlob1}`}></div>
        <div className={`${styles.bgBlob} ${styles.bgBlob2}`}></div>
      </div>

      <div className={styles.footerMain}>
        <div className={styles.footerContainer}>
          {/* Desktop Layout */}
          <div className={`${styles.footerGrid} ${styles.desktopOnly}`}>
            {/* Company Info Column */}
            <div className={styles.companyColumn}>
              <div className={styles.companyHeader}>
                <img src="/img/btc-logo-footer.png" alt="Beyond The Cloud" className={styles.companyLogo} />
                <div className={styles.companyTitle}>
                  <span className={styles.companyTagline}>{data.company.tagline}</span>
                </div>
              </div>
              <p className={styles.companyDescription}>{data.company.description}</p>

              {/* SF Badge + Social icons side by side */}
              <div className={styles.badgeAndSocial}>
                <div className={styles.partnerBadge}>
                  <img src="/img/salesforcePartnerBadge.png" alt="Salesforce Partner" className={styles.sfBadgeImg} />
                </div>
                <SocialIcons data={data} />
              </div>
            </div>

            {/* Links Columns */}
            <div className={styles.linksGrid}>
              {/* Column 1: This Site + Services */}
              <div className={styles.linksColumn}>
                {currentContextLinks.length > 0 && (
                  <div className={styles.linkSection}>
                    <h4 className={styles.sectionTitle}>This Site</h4>
                    <ul className={styles.linkList}>
                      {currentContextLinks.map((link) => (
                        <li key={link.label}>
                          <a href={link.href}>{link.label}</a>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
                <div className={`${styles.linkSection} ${currentContextLinks.length > 0 ? styles.mtSection : ''}`}>
                  <h4 className={styles.sectionTitle}>Services</h4>
                  <ul className={styles.linkList}>
                    {data.services.map((link) => (
                      <li key={link.label}>
                        <a href={link.href}>{link.label}</a>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>

              {/* Column 2: Open Source */}
              <div className={styles.linksColumn}>
                <div className={styles.linkSection}>
                  <h4 className={styles.sectionTitle}>Open Source</h4>
                  <div className={styles.opensourceContent}>
                    <a href={data.openSource.parent.href} className={styles.parentLink}>
                      {data.openSource.parent.label}

                    </a>
                    <ul className={styles.childLinks}>
                      {data.openSource.children.map((child) => (
                        <li key={child.label}>
                          <span className={styles.arrowIcon}>&rarr;</span>
                          <a href={child.href}>{child.label}</a>
                        </li>
                      ))}
                    </ul>
                    <a href={data.openSource.more.href} className={styles.moreLink}>
                      {data.openSource.more.label} &#8599;
                    </a>
                  </div>
                </div>
              </div>

              {/* Column 3: Products + Resources */}
              <div className={styles.linksColumn}>
                <div className={styles.linkSection}>
                  <h4 className={styles.sectionTitle}>Products</h4>
                  <ul className={styles.linkList}>
                    {data.products.map((link) => (
                      <li key={link.label}>
                        <a href={link.href}>{link.label}</a>
                      </li>
                    ))}
                  </ul>
                </div>
                <div className={`${styles.linkSection} ${styles.mtSection}`}>
                  <h4 className={styles.sectionTitle}>Resources</h4>
                  <ul className={styles.linkList}>
                    {data.resources.map((link) => (
                      <li key={link.label}>
                        <a href={link.href}>{link.label}</a>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </div>
          </div>

          {/* Mobile Layout */}
          <div className={`${styles.footerMobile} ${styles.mobileOnly}`}>
            {/* Company Info */}
            <div className={styles.mobileCompany}>
              <div className={styles.companyHeader}>
                <img src="/img/btc-logo-footer.png" alt="Beyond The Cloud" className={styles.companyLogo} />
                <div className={styles.companyTitle}>
                  <span className={styles.companyTagline}>{data.company.tagline}</span>
                </div>
              </div>
              <p className={styles.companyDescription}>{data.company.description}</p>

              {/* SF Badge + Social icons */}
              <div className={styles.badgeAndSocialMobile}>
                <div className={styles.partnerBadge}>
                  <img src="/img/salesforcePartnerBadge.png" alt="Salesforce Partner" className={styles.sfBadgeImg} />
                </div>
                <SocialIcons data={data} />
              </div>
            </div>

            {/* Mobile Links */}
            <div className={styles.mobileLinks}>
              {currentContextLinks.length > 0 && (
                <div className={styles.mobileSection}>
                  <h4 className={styles.sectionTitle}>This Site</h4>
                  <ul className={styles.linkList}>
                    {currentContextLinks.map((link) => (
                      <li key={link.label}>
                        <a href={link.href}>{link.label}</a>
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              <div className={styles.mobileSection}>
                <h4 className={styles.sectionTitle}>Services</h4>
                <ul className={styles.linkList}>
                  {data.services.map((link) => (
                    <li key={link.label}>
                      <a href={link.href}>{link.label}</a>
                    </li>
                  ))}
                </ul>
              </div>

              <div className={styles.mobileSection}>
                <h4 className={styles.sectionTitle}>Open Source</h4>
                <div className={`${styles.opensourceContent} ${styles.mobileOpensource}`}>
                  <a href={data.openSource.parent.href} className={styles.parentLink}>
                    {data.openSource.parent.label}

                  </a>
                  <ul className={styles.childLinks}>
                    {data.openSource.children.map((child) => (
                      <li key={child.label}>
                        <span className={styles.arrowIcon}>&rarr;</span>
                        <a href={child.href}>{child.label}</a>
                      </li>
                    ))}
                  </ul>
                  <a href={data.openSource.more.href} className={styles.moreLink}>
                    {data.openSource.more.label} &#8599;
                  </a>
                </div>
              </div>

              <div className={styles.mobileSection}>
                <h4 className={styles.sectionTitle}>Products</h4>
                <ul className={styles.linkList}>
                  {data.products.map((link) => (
                    <li key={link.label}>
                      <a href={link.href}>{link.label}</a>
                    </li>
                  ))}
                </ul>
              </div>

              <div className={styles.mobileSection}>
                <h4 className={styles.sectionTitle}>Resources</h4>
                <ul className={styles.linkList}>
                  {data.resources.map((link) => (
                    <li key={link.label}>
                      <a href={link.href}>{link.label}</a>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Bar - text only, left aligned */}
      <div className={styles.footerBottom}>
        <div className={`${styles.footerContainer} ${styles.bottomContainer}`}>
          {/* Desktop Bottom */}
          <div className={`${styles.bottomContent} ${styles.desktopOnly}`}>
            <div className={styles.bottomLeft}>
              <span>&copy; {currentYear} Beyond The Cloud</span>
              <span className={styles.separator}>&bull;</span>
              <span>{data.company.nip}</span>
              <span className={styles.separator}>&bull;</span>
              <span>{data.company.address}</span>
              <span className={styles.separator}>&bull;</span>
              <a href={`mailto:${data.company.email}`} className={styles.bottomLink}>{data.company.email}</a>
              <span className={styles.separator}>&bull;</span>
              <a href={data.legal.privacyPolicy} className={styles.bottomLink}>Privacy Policy</a>
            </div>
          </div>

          {/* Mobile Bottom */}
          <div className={`${styles.bottomContentMobile} ${styles.mobileOnly}`}>
            <div className={styles.mobileLegal}>
              <span>&copy; {currentYear} Beyond The Cloud</span>
              <span className={styles.separator}>&bull;</span>
              <a href={`mailto:${data.company.email}`} className={styles.bottomLink}>{data.company.email}</a>
              <span className={styles.separator}>&bull;</span>
              <a href={data.legal.privacyPolicy} className={styles.bottomLink}>Privacy Policy</a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}

export default React.memo(Footer);
