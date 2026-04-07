module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        // Core Pharma Transport Colors
        'ocean-blue': '#0984C0',
        'sea-serpent': '#60BDD1',
        'silver': '#AAA7B0',
        'davy-grey': '#565759',
        'light-silver': '#C0BEC6',
        
        // Pharma Glassmorphism
        'glass-bg': 'rgba(255, 255, 255, 0.85)',
        'glass-border': 'rgba(148, 163, 184, 0.25)',
        
        // Status Badges
        'status-intransit': '#0984C0',
        'status-delivered': '#10B981',
        'status-pending': '#F59E0B'
      },
      fontFamily: {
        'sans': ['Inter', 'ui-sans-serif', 'system-ui'],
        'heading': ['Inter', '600', '700', '800']
      },
      backdropBlur: {
        xs: '2px',
      },
      boxShadow: {
        'glass': '0 8px 32px rgba(31, 38, 135, 0.15)',
        'card': '0 4px 20px rgba(0, 0, 0, 0.08)',
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'sidebar-slide': 'sidebarSlide 0.3s ease-in-out',
      }
    }
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
