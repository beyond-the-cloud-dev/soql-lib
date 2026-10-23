// Footer configuration data for Beyond The Cloud websites
// This file can be shared across different sites with context-specific links

export const footerData = {
    company: {
        name: 'BEYOND THE CLOUD SP. Z O.O.',
        nip: 'NIP: 6762675188',
        address: 'Szlak 77/222, 31-153 Krakow, Poland',
        email: 'contact@beyondthecloud.dev',
        tagline: 'We make Salesforce work',
        description: "Helping enterprise teams run Salesforce that's reliable, secure, and predictable."
    },
    services: [
        { label: 'Technical Debt Resolution', href: 'https://beyondthecloud.dev/services#tech-debt' },
        { label: 'Agentforce Implementation', href: 'https://beyondthecloud.dev/services#agentforce' },
        { label: 'Contact Us', href: 'https://beyondthecloud.dev/contact' }
    ],
    openSource: {
        parent: { label: 'Apex Fluently', href: 'https://apexfluently.beyondthecloud.dev', logo: '/img/libs/apex-fluently.png' },
        children: [
            { id: 'soql-lib', label: 'SOQL Lib', href: 'https://soql.beyondthecloud.dev', logo: '/img/libs/soql-lib.png' },
            { id: 'dml-lib', label: 'DML Lib', href: 'https://dml.beyondthecloud.dev', logo: '/img/libs/dml-lib.png' },
            { id: 'async-lib', label: 'Async Lib', href: 'https://async.beyondthecloud.dev', logo: '/img/libs/async-lib.png' },
            { id: 'http-mock', label: 'HTTP Mock', href: 'https://httpmock.beyondthecloud.dev', logo: '/img/libs/http-mock-lib.png' },
            { id: 'apex-consts', label: 'Apex Consts', href: 'https://apexconsts.beyondthecloud.dev', logo: '/img/libs/apex-consts.png' },
            { id: 'cache-manager', label: 'Cache Manager', href: 'https://cachemanager.beyondthecloud.dev', logo: '/img/libs/cache-manager.png' },
            { id: 'test-lib', label: 'Test Lib', href: 'https://testlib.beyondthecloud.dev', logo: '/img/libs/test-lib.png' },
            { id: 'trigger-lib', label: 'Trigger Lib', href: 'https://trigger.beyondthecloud.dev', logo: '/img/libs/trigger-lib.png' },
            { id: 'callout-lib', label: 'Callout Lib', href: 'https://callout.beyondthecloud.dev', logo: '/img/libs/callout-lib.png' }
        ]
    },
    products: [
        { label: 'ISV Analytics', href: 'https://isvanalytics.beyondthecloud.dev' },
        { label: 'Veles', href: 'https://veles.beyondthecloud.dev' },
        { label: 'Release Notifier', href: 'https://releasenotifier.beyondthecloud.dev' }
    ],
    resources: [
        { label: 'Blog', href: 'https://blog.beyondthecloud.dev' },
        { label: 'GitHub', href: 'https://github.com/beyond-the-cloud-dev' }
    ],
    social: [
        { name: 'LinkedIn', href: 'https://www.linkedin.com/company/beyondtheclouddev/', icon: 'linkedin' },
        { name: 'GitHub', href: 'https://github.com/beyond-the-cloud-dev', icon: 'github' },
        { name: 'YouTube', href: 'https://www.youtube.com/@BeyondTheCloudDev', icon: 'youtube' }
    ],
    legal: {
        privacyPolicy: 'https://beyondthecloud.dev/privacy-policy',
        mainSite: 'https://beyondthecloud.dev/'
    }
};

// Context-specific links for different sites
// These appear in the "This site" section when the footer is used on different properties
export const contextLinks = {
    main: [],
    blog: [
        { label: 'Authors', href: '/authors' },
        { label: 'Categories', href: '/categories' }
    ],
    'apex-fluently': [
        { label: 'Get Started', href: '/introduction' },
        { label: 'Installation', href: '/installation' }
    ],
    'soql-lib': [],
    'dml-lib': [
        { label: 'Get Started', href: '/introduction' },
        { label: 'Installation', href: '/installation' }
    ],
    'async-lib': [
        { label: 'Get Started', href: '/getting-started' },
        { label: 'Installation', href: '/introduction/installation' }
    ],
    'http-mock': [
        { label: 'Get Started', href: '/getting-started' },
        { label: 'Installation', href: '/installation' }
    ],
    'apex-consts': [
        { label: 'Get Started', href: '/getting-started' },
        { label: 'Installation', href: '/installation' }
    ],
    'cache-manager': [
        { label: 'Get Started', href: '/getting-started' },
        { label: 'Installation', href: '/installation' }
    ],
    'test-lib': [
        { label: 'Get Started', href: '/introduction' },
        { label: 'Installation', href: '/installation' }
    ],
    'trigger-lib': [
        { label: 'Get Started', href: '/introduction' },
        { label: 'Installation', href: '/installation' }
    ],
    'callout-lib': [
        { label: 'Get Started', href: '/introduction' },
        { label: 'Quick Start', href: '/guide/getting-started' }
    ],
    'isv-analytics': [
        { label: 'Features', href: '/features' },
        { label: 'Pricing', href: '/pricing' }
    ],
    'release-notifier': [{ label: 'Documentation', href: '/docs/intro' }]
};
