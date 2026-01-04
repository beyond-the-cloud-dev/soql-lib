// Footer configuration data for Beyond The Cloud websites

export const footerData = {
  company: {
    name: "BEYOND THE CLOUD SP. Z O.O.",
    nip: "NIP: 6762675188",
    address: "Szlak 77/222, 31-153 Krakow, Poland",
    email: "contact@beyondthecloud.dev",
    tagline: "We make Salesforce work",
    description: "Helping enterprise teams run Salesforce that's reliable, secure, and predictable."
  },
  services: [
    { label: "Technical Debt Resolution", href: "https://beyondthecloud.dev/services#tech-debt" },
    { label: "Agentforce Implementation", href: "https://beyondthecloud.dev/services#agentforce" },
    { label: "Contact Us", href: "https://beyondthecloud.dev/contact" }
  ],
  openSource: {
    parent: { label: "Apex Fluently", href: "https://apexfluently.beyondthecloud.dev" },
    children: [
      { label: "SOQL Lib", href: "https://soql.beyondthecloud.dev" },
      { label: "DML Lib", href: "https://dml.beyondthecloud.dev" },
      { label: "Async Lib", href: "https://async.beyondthecloud.dev" },
      { label: "HTTP Mock", href: "https://httpmock.beyondthecloud.dev" },
      { label: "Cache Manager", href: "https://cachemanager.beyondthecloud.dev" },
      { label: "Apex Consts", href: "https://apexconsts.beyondthecloud.dev" }
    ],
    more: { label: "More on GitHub", href: "https://github.com/beyond-the-cloud-dev" }
  },
  products: [
    { label: "ISV Analytics", href: "https://isvanalytics.beyondthecloud.dev" },
    { label: "Release Notifier", href: "https://releasenotifier.beyondthecloud.dev" },
    { label: "Wiki", href: "https://wiki.beyondthecloud.dev" }
  ],
  resources: [
    { label: "Blog", href: "https://blog.beyondthecloud.dev" },
    { label: "GitHub", href: "https://github.com/beyond-the-cloud-dev" }
  ],
  social: [
    { name: "LinkedIn", href: "https://www.linkedin.com/company/beyondtheclouddev/", icon: "linkedin" },
    { name: "GitHub", href: "https://github.com/beyond-the-cloud-dev", icon: "github" },
    { name: "YouTube", href: "https://www.youtube.com/@BeyondTheCloudDev", icon: "youtube" }
  ],
  legal: {
    privacyPolicy: "https://beyondthecloud.dev/privacy-policy",
    mainSite: "https://beyondthecloud.dev/"
  }
};

// Context-specific links for different sites
export const contextLinks = {
  'main': [],
  'blog': [
    { label: "Authors", href: "/authors" },
    { label: "Categories", href: "/categories" }
  ],
  'apex-fluently': [
    { label: "Get Started", href: "/introduction" },
    { label: "Installation", href: "/installation" }
  ],
  'soql-lib': [
    { label: "Getting Started", href: "/docs/getting-started" },
    { label: "Overview", href: "/docs/overview" },
    { label: "Installation", href: "/installation" }
  ],
  'dml-lib': [
    { label: "Get Started", href: "/introduction" },
    { label: "Installation", href: "/installation" }
  ],
  'async-lib': [
    { label: "Get Started", href: "/getting-started" },
    { label: "Installation", href: "/introduction/installation" }
  ],
  'http-mock': [
    { label: "Get Started", href: "/getting-started" },
    { label: "Installation", href: "/installation" }
  ],
  'cache-manager': [
    { label: "Get Started", href: "/getting-started" },
    { label: "Installation", href: "/installation" }
  ],
  'apex-consts': [
    { label: "Get Started", href: "/getting-started" },
    { label: "Installation", href: "/installation" }
  ],
  'isv-analytics': [
    { label: "Installation", href: "/docs/installation" },
    { label: "Setup", href: "/docs/setup/app-setup" },
    { label: "FAQ", href: "/docs/faq" }
  ],
  'release-notifier': [
    { label: "Documentation", href: "/docs/intro" }
  ],
  'wiki': [
    { label: "Getting Started", href: "/getting-started" }
  ]
};
