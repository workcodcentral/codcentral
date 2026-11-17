/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        // Brand palette
        navy: {
          DEFAULT: '#0D1B2A',
          50:  '#E8EDF2',
          100: '#C5D0DC',
          200: '#8FA5BB',
          300: '#5A7A9A',
          400: '#2F5479',
          500: '#0D1B2A',
          600: '#0A1520',
          700: '#070F17',
          800: '#04090E',
          900: '#020406',
        },
        red: {
          DEFAULT: '#E8382A',
          50:  '#FDF0EE',
          100: '#F9C9C5',
          200: '#F4908A',
          300: '#EE5750',
          400: '#E8382A',
          500: '#C42A1D',
          600: '#9C2117',
          700: '#741811',
          800: '#4C100B',
          900: '#240805',
        },
        sage: {
          DEFAULT: '#7A9E7E',
          50:  '#F0F5F1',
          100: '#D6E6D8',
          200: '#ADC8B1',
          300: '#7A9E7E',
          400: '#5D8762',
          500: '#446848',
          600: '#354F37',
          700: '#263726',
          800: '#171F17',
          900: '#080A08',
        },
        canvas: '#FAF8F5',
        'canvas-dark': '#F2EFE9',
      },
      fontFamily: {
        display: ['"Bricolage Grotesque"', 'sans-serif'],
        body: ['Manrope', 'sans-serif'],
      },
      fontWeight: {
        '300': '300',
        '400': '400',
        '500': '500',
        '600': '600',
        '700': '700',
        '800': '800',
      },
      fontSize: {
        'display-2xl': ['clamp(3rem,6vw,5.5rem)', { lineHeight: '1.05', letterSpacing: '-0.03em' }],
        'display-xl':  ['clamp(2.5rem,5vw,4rem)',  { lineHeight: '1.08', letterSpacing: '-0.025em' }],
        'display-lg':  ['clamp(2rem,4vw,3rem)',     { lineHeight: '1.1',  letterSpacing: '-0.02em' }],
        'display-md':  ['clamp(1.5rem,3vw,2.25rem)',{ lineHeight: '1.15', letterSpacing: '-0.015em' }],
        'display-sm':  ['clamp(1.25rem,2.5vw,1.75rem)',{ lineHeight: '1.2', letterSpacing: '-0.01em' }],
      },
      animation: {
        'scroll-left': 'scrollLeft 35s linear infinite',
        'fade-up': 'fadeUp 0.6s ease-out forwards',
        'fade-in': 'fadeIn 0.4s ease-out forwards',
      },
      keyframes: {
        scrollLeft: {
          '0%':   { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(-50%)' },
        },
        fadeUp: {
          '0%':   { opacity: '0', transform: 'translateY(24px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        fadeIn: {
          '0%':   { opacity: '0' },
          '100%': { opacity: '1' },
        },
      },
    },
  },
  plugins: [],
};
