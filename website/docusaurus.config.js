// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

import { themes as prismThemes } from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'SOQL Lib',
  tagline: 'Apex SOQL provides functional constructs for SOQL.',
  favicon: 'img/favicon.ico',
  url: 'https://soql.beyondthecloud.dev/',
  baseUrl: '/',
  organizationName: 'Beyond The Cloud', // Usually your GitHub org/user name.
  projectName: 'soql-lib', // Usually your repo name.
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'throw',
  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },
  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          routeBasePath: '/',
        },
        gtag: {
          trackingID: 'G-FVQ8BT1C3H',
          anonymizeIP: false
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],

  ],
  plugins: [
    async function tailwindPlugin(context, options) {
      return {
        name: 'docusaurus-tailwindcss',
        configurePostCss(postcssOptions) {
          postcssOptions.plugins.push(require('tailwindcss'));
          postcssOptions.plugins.push(require('autoprefixer'));
          return postcssOptions;
        },
      };
    },
  ],
  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],
  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/cloud-icon.png',
      metadata: [
        { name: 'description', content: 'SOQL Lib provides functional constructs for SOQL queries in Apex.' },
        { name: 'keywords', content: 'SOQL Lib, Selector Layer Apex, Apex Selector Layer, Query Builder' },
        { name: 'canonical', content: 'https://soql.beyondthecloud.dev' }
      ],
      docs: {
        sidebar: {
          hideable: true,
        },
      },
      navbar: {
        title: 'SOQL Lib',
        logo: {
          alt: 'SOQL Lib logo',
          src: 'img/logo.png',
        },
        items: [
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'docs',
            label: 'Docs',
          },
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'api',
            label: 'API',
          },
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'examples',
            label: 'Showcase',
          },
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'advanced',
            label: 'Advanced',
          },
          {
            href: 'https://github.com/beyond-the-cloud-dev/soql-lib',
            label: 'GitHub',
            position: 'right',
          },
          {
            href: 'https://beyondthecloud.dev/blog',
            label: 'Blog',
            position: 'right',
          },
        ],
      },
      algolia: {
        appId: '9UMSI1LBRW',
        apiKey: '85f2736a0fa16fbd643f48cddcd3111f',
        indexName: 'soql-lib-crawler',
        startUrls: ['https://soql.beyondthecloud.dev'],
        contextualSearch: false
      },
      sitemap: {
        lastmod: 'date',
        changefreq: 'weekly',
        priority: 0.5,
        ignorePatterns: ['/tags/**'],
        filename: 'sitemap.xml',
        createSitemapItems: async params => {
          const { defaultCreateSitemapItems, ...rest } = params;
          const items = await defaultCreateSitemapItems(rest);
          return items.filter(item => !item.url.includes('/page/'));
        }
      },
      footer: {
        style: 'dark',
        links: [
          {
            items: [
              {
                html: `
                  <a href="https://beyondthecloud.dev" target="_blank" aria-label="Beyond The Cloud">
                                    <img src="/img/btc-logo.png" alt="Professional Salesforce Services - Beyond The Cloud" width="167" height="88" />
                                    </a>
                                    <p>
                                    contact@beyondthecloud.dev
                                    <br /><br />
                                We are a Salesforce Partner specializing in AppExchange app development and technical debt emergency resolution
                                </p>
                        `
              }
            ]
          },
          {
            title: 'Documentation',
            items: [
              {
                label: 'Installation',
                to: '/installation'
              },
              {
                label: 'Building Your Selector',
                to: '/building-your-selector'
              }
            ]
          },
          {
            items: [
              {
                label: 'Linkedin',
                href: 'https://www.linkedin.com/company/beyondtheclouddev'
              },
              {
                label: 'Beyond The Cloud',
                href: 'https://beyondthecloud.dev/'
              },
              {
                label: 'Blog',
                href: 'https://blog.beyondthecloud.dev/blog'
              },
              {
                label: 'Learning',
                href: 'https://learning.beyondthecloud.dev/blog'
              },
              {
                label: 'GitHub',
                href: 'https://github.com/beyond-the-cloud-dev'
              }
            ]
          }
        ],
        copyright: `Copyright © ${new Date().getFullYear()} BeyondTheCloud`
      },
      prism: {
        additionalLanguages: ['apex'],
        theme: prismThemes.dracula,
        darkTheme: prismThemes.dracula,
        defaultLanguage: 'apex',
      },
    }),
}

module.exports = config
