import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import MDXContent from '@theme/MDXContent';
import SOQLLibBenefits from './soqlLibBenefits.mdx';

export default function Home() {
    return (
        <Layout
            title="Home | SOQL Lib"
            description="The SOQL Lib provides functional constructs for SOQL queries in Apex.">
            <div class="relative isolate px-6 pt-14 lg:px-8">
                <div class="text-center">
                    <Heading class="text-5xl mb-10 font-semibold tracking-tight text-balance text-gray-900 sm:text-7xl" as="h1">SOQL Lib</Heading>
                    <a href="/installation" class="rounded-md bg-sky-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-xs hover:bg-sky-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-600">Get started</a>
                </div>
            </div>
            <Features />
        </Layout>
    )
}

export function Features() {
    return (
        <div className='my-10 flex flex-col max-w-5xl mx-auto'>
            <MDXContent><SOQLLibBenefits /></MDXContent>
        </div>
    )
}
