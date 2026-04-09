module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        'pharma-blue': '#1e40af',
        'coldchain-green': '#10b981'
      }
    }
  },
  plugins: []
}
