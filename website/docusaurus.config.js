// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

import { themes as prismThemes } from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'SOQL Lib',
  tagline: 'Apex SOQL provides functional constructs for SOQL.',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://beyondthecloud.dev/',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
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
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
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
      navbar: {
        title: 'SOQL Lib',
        logo: {
          alt: 'SOQL Lib logo',
          src: 'img/cloud-icon.png',
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
      prism: {
        additionalLanguages: ['apex'],
        theme: prismThemes.dracula,
        darkTheme: prismThemes.dracula,
        defaultLanguage: 'apex',
      },
    }),
}

module.exports = config
