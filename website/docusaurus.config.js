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
  organizationName: 'Beyond The Cloud Sp. z o.o.',
  projectName: 'soql-lib',
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
          // Hide the unreleased "Next" docs (website/docs) from the deployed site;
          // they remain visible locally via `npm run start` for authoring.
          onlyIncludeVersions:
            process.env.NODE_ENV === 'development' ? ['current', '6.12.0'] : ['6.12.0'],
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
  headTags: [
    {
      tagName: 'script',
      attributes: { type: 'application/ld+json' },
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'SoftwareApplication',
        name: 'SOQL Lib',
        description: 'Apex SOQL provides functional constructs for SOQL.',
        url: 'https://soql.beyondthecloud.dev',
        applicationCategory: 'DeveloperApplication',
        operatingSystem: 'Salesforce',
        license: 'https://opensource.org/licenses/MIT',
        codeRepository: 'https://github.com/beyond-the-cloud-dev/soql-lib',
        isPartOf: { '@type': 'SoftwareApplication', name: 'Apex Fluently', url: 'https://apexfluently.beyondthecloud.dev' },
        offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
        author: {
          '@type': 'Organization',
          name: 'Beyond The Cloud',
          url: 'https://beyondthecloud.dev',
          sameAs: ['https://github.com/beyond-the-cloud-dev', 'https://www.linkedin.com/company/beyondtheclouddev'],
        },
      }),
    },
  ],
  plugins: [
    [
      'docusaurus-plugin-llms',
      {
        title: 'SOQL Lib',
        description: 'Apex SOQL provides functional constructs for SOQL.',
        includeOrder: ['docs/*', 'soql/**', 'cache/**', 'evaluator/**'],
        pathTransformation: { ignorePaths: ['docs'] },
      },
    ],
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
      colorMode: {
        defaultMode: 'light',
        disableSwitch: false,
      },
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
            sidebarId: 'soql',
            label: 'SOQL',
          },
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'soqlCache',
            label: 'Cache',
          },
          {
            type: 'docSidebar',
            position: 'left',
            sidebarId: 'soqlEvaluator',
            label: 'Evaluator',
          },
          {
            to: '/playground',
            position: 'left',
            label: '🚀 Playground',
          },
          {
            to: '/critique',
            position: 'left',
            label: 'Critique',
          },
          {
            type: 'docsVersionDropdown',
            position: 'right',
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
      prism: {
        additionalLanguages: ['apex'],
        theme: prismThemes.dracula,
        darkTheme: prismThemes.dracula,
        defaultLanguage: 'apex',
      },
    }),
}

module.exports = config
