/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
      "./src/**/*.{js,jsx,ts,tsx}",
      "./docs/**/*.{md,mdx}"
    ],
    theme: {
      extend: {},
    },
    plugins: [],
    corePlugins: {
      preflight: false, // Disable Tailwind's base styles
    },
    darkMode: ['class', '[data-theme="dark"]'], // Support Docusaurus dark mode
  }