import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

const FEATURES = [
    {
        title: 'Lightweight Selector Classes',
        description: 'Keep your selector classes minimal, focusing only on essential query configurations (fields, sharing settings) and generic methods (byId, byRecordType).',
        image: '/img/small-selectors.png'
    },
    {
        title: 'Build SOQL Inline with a Query Builder',
        description: 'Most queries are business-specific. Define them exactly where they’re needed using SOQL Lib’s builder, keeping the Selector class for only generic or reusable queries.',
        image: '/img/build-inline.png'
    },
    {
        title: 'Full Control of FLS and Sharing',
        description: 'Easily enforce Field-Level Security and sharing rules using .systemMode(), .withSharing(), or .withoutSharing().',
        image: '/img/fls-and-sharing-settings.png'
    },
    {
        title: 'Mock SOQL for Faster Tests',
        description: 'Boost unit test performance by mocking SOQL results, reducing the need for complex test data setups.',
        image: '/img/mocking.png'
    },
    {
        title: 'Accelerate Performance with Cached Selectors',
        description: 'Store records in Apex transactions, Org Cache, or Session Cache, minimizing redundant queries for faster performance.',
        image: '/img/cached-selector.png'
    },
    {
        title: 'Enhanced SOQL Toolkit',
        description: 'Leverage a suite of predefined methods to simplify query results and reduce code complexity.',
        image: '/img/enhanced-soql.png'
    }
];

export default function Home() {
    return (
        <Layout
            title="Home | SOQL Lib"
            description="The SOQL Lib provides functional constructs for SOQL queries in Apex.">
            <div class="relative isolate px-6 pt-14 lg:px-8">
                <div class="text-center">
                    <Heading class="text-5xl font-semibold tracking-tight text-balance text-gray-900 sm:text-7xl" as="h1">SOQL Lib</Heading>

                    <a href="/installation" class="rounded-md bg-sky-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-xs hover:bg-sky-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-600">Get started</a>
                </div>
            </div>
            <Features />
        </Layout>
    )
}

export function Features() {
    return (
        <div className='my-10 flex flex-col max-w-5xl mx-auto gap-10'>
            {
                FEATURES.map(feature => (
                    <div class="flex gap-10 justify-between">
                        <div>
                            <Heading as="h2">
                                {feature.title}
                            </Heading>
                            <div>{feature.description}</div>
                        </div>

                        <img
                            src={feature.image}
                            alt={feature.title}
                            width="60%"
                            class="shadow-sm"
                        /></div>

                ))
            }
        </div>
    )
}
