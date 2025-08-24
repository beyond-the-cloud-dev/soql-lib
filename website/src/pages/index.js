import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

export default function Home() {
    return (
        <Layout
            title="Home | SOQL Lib"
            description="The SOQL Lib provides functional constructs for SOQL queries in Apex.">
            <div className="relative isolate px-6 pt-14 lg:px-8">
                <div className="text-center">
                    <Heading className="text-5xl mb-6 font-semibold tracking-tight text-balance text-white sm:text-7xl" as="h1">SOQL Lib</Heading>
                    <p className="text-lg mb-10 text-gray-300 max-w-2xl mx-auto">
                        Everything you need to build SOQL queries in Salesforce APEX.
                    </p>
                    
                    <div className="space-x-4">
                        <a href="/docs/getting-started" className="rounded-md bg-sky-600 px-4 py-3 text-sm font-semibold text-white shadow-xs hover:scale-110 transition-transform focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-600">Get Started</a>
                        <a href="/docs/overview" className="rounded-md bg-gray-800 px-4 py-3 text-sm font-semibold text-white shadow-xs ring-1 ring-gray-600 hover:scale-110 transition-transform">Learn More</a>
                        <a href="https://calendar.app.google/VLyYFV8E93QDobPd8" className="rounded-md bg-red-800 px-4 py-3 text-sm font-semibold text-white shadow-xs ring-1 ring-gray-600 hover:scale-110 transition-transform">Help needed?</a>
                    </div>
                </div>
            </div>
            <Features />
        </Layout>
    )
}

export function Features() {
    const features = [
        {
            title: "Dynamic Query Builder",
            description: "Build SOQL queries dynamically with fluent API. No more string concatenation or massive selector classes with hundreds of methods."
        },
        {
            title: "Advanced Caching System", 
            description: "Cache records in Apex transactions, Session Cache, or Org Cache for dramatic performance improvements."
        },
        {
            title: "Built-in Security Controls",
            description: "Enforce field-level security and sharing rules with WITH USER_MODE, WITH SYSTEM_MODE, and sharing settings by default."
        },
        {
            title: "Comprehensive Testing Support",
            description: "Mock SOQL results in unit tests without complex test data setup. Perfect for external objects and custom metadata."
        },
        {
            title: "Result Transformation",
            description: "Transform query results easily with built-in methods: toMap(), toIds(), toValuesOf(), and many more powerful utilities."
        },
        {
            title: "Lightweight Selectors",
            description: "Keep selector classes minimal and focused. Define business-specific queries inline where they're needed."
        }
    ];

    return (
        <div className="my-20 px-6 lg:px-8">
            <div className="mx-auto max-w-7xl">
                <div className="text-center mb-16">
                    <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl mb-4">
                        What's in SOQL Lib?
                    </h2>
                    <p className="text-lg text-gray-300 max-w-2xl mx-auto">
                        The SOQL Lib provides functional constructs for SOQL queries in Apex.
                    </p>
                </div>
                
                <div className="grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
                    {features.map((feature, index) => (
                        <div key={index} className="relative rounded-2xl border border-gray-700 p-8 shadow-lg hover:shadow-xl transition-shadow bg-gray-800/50 backdrop-blur-sm">
                            <h3 className="text-lg font-semibold text-white mb-4">{feature.title}</h3>
                            <p className="text-gray-300 leading-relaxed">{feature.description}</p>
                        </div>
                    ))}
                </div>

            </div>
        </div>
    )
}
