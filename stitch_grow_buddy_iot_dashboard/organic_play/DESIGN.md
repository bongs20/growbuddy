---
name: Organic Play
colors:
  surface: '#fff9e7'
  surface-dim: '#e0dac5'
  surface-bright: '#fff9e7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#faf4de'
  surface-container: '#f4eed8'
  surface-container-high: '#eee8d3'
  surface-container-highest: '#e8e3cd'
  on-surface: '#1e1c0f'
  on-surface-variant: '#42493d'
  inverse-surface: '#333122'
  inverse-on-surface: '#f7f1db'
  outline: '#72796c'
  outline-variant: '#c2c9b9'
  surface-tint: '#376a25'
  primary: '#376a25'
  on-primary: '#ffffff'
  primary-container: '#88c070'
  on-primary-container: '#1c4e0b'
  inverse-primary: '#9cd683'
  secondary: '#2c6956'
  on-secondary: '#ffffff'
  secondary-container: '#aeedd5'
  on-secondary-container: '#316d5b'
  tertiary: '#735c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#d1ae40'
  on-tertiary-container: '#544200'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b8f29d'
  primary-fixed-dim: '#9cd683'
  on-primary-fixed: '#042100'
  on-primary-fixed-variant: '#1f510e'
  secondary-fixed: '#b1efd8'
  secondary-fixed-dim: '#96d3bd'
  on-secondary-fixed: '#002118'
  on-secondary-fixed-variant: '#0d503f'
  tertiary-fixed: '#ffe088'
  tertiary-fixed-dim: '#e7c353'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#574500'
  background: '#fff9e7'
  on-background: '#1e1c0f'
  surface-variant: '#e8e3cd'
typography:
  h1:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  h2:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: '1.5'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: 0.05em
  button:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  container-padding: 20px
  gutter: 16px
---

## Brand & Style

This design system is built on the philosophy of "Nurturing Interaction." It bridges the gap between utilitarian IoT monitoring and the emotional engagement of a casual pet-sim game. The brand personality is encouraging, approachable, and responsive, designed to make plant care feel less like a chore and more like a rewarding hobby.

The visual style is a hybrid of **Minimalism** and **Tactile** design. It utilizes heavy white space and a clean layout to ensure data clarity (IoT), while employing "squishy" UI elements, high-radius corners, and soft, colored shadows to evoke a playful, game-like feel. Every interaction should feel soft and forgiving, mimicking the organic nature of plants.

## Colors

The palette is inspired by a sun-drenched greenhouse. **Soft Green** serves as the primary action color, representing growth and health. **Mint** and **Sky Blue** are used for secondary surfaces and environmental indicators (like humidity and water levels). **Cream** is the primary surface color for cards to provide a warmer, more organic feel than pure white. **Warm Yellow** is reserved for rewards, badges, and "attention-needed" states.

Use subtle gradients between the greens and blues for progress bars to simulate fluid movement. Avoid harsh blacks; use deep desaturated greens or browns for text to maintain the soft aesthetic.

## Typography

The design system uses **Plus Jakarta Sans** for its modern yet friendly geometric curves. The typography should prioritize readability with a casual lean. 

Headlines use a tighter letter spacing and heavier weights to create a "bubbly" and authoritative presence. Body text maintains a comfortable line height for instructional Indonesian microcopy. Use uppercase labels sparingly for category headers to create a distinction between "game" stats and "app" navigation.

## Layout & Spacing

The system uses a **Fluid Grid** model with a base unit of 8px. Layouts should feel spacious and uncrowded to reduce cognitive load for users monitoring their plants.

- **Margins:** Use a consistent 20px or 24px side margin for mobile views.
- **Card Spacing:** Vertical stacking of cards should use the `lg` (24px) spacing unit to let elements "breathe."
- **Nesting:** Internal card padding should never be less than `md` (16px) to maintain the friendly, oversized feel.

## Elevation & Depth

Depth is achieved through **Ambient Shadows** rather than stark borders. Shadows should be highly diffused and tinted with the primary green or secondary blue to avoid a "dirty" gray look.

- **Level 1 (Base Cards):** Y: 4, Blur: 20, Spread: 0, Color: #88C070 (Opacity 8%).
- **Level 2 (Active/Pressed States):** Y: 8, Blur: 24, Spread: 0, Color: #88C070 (Opacity 12%).
- **Interactive Depth:** Buttons should use a slight inner shadow when pressed to create a "squishy" physical response, reinforcing the casual game aesthetic.

## Shapes

The shape language is defined by **Extreme Rounding**. All primary containers (cards) must have a corner radius of at least 24px. Smaller elements like buttons and chips should utilize a pill-shape (fully rounded) to maximize the friendly tactile feel.

Sharp corners are strictly forbidden. Even the ends of health bars and progress indicators should be rounded to maintain consistency with the organic theme.

## Components

### Buttons & 'Siram' Actions
- **Primary Button:** Large, pill-shaped, using Soft Green.
- **Siram (Watering) Button:** Features a distinct "Safety State." A double-tap or slide-to-confirm interaction prevents accidental overwatering. Indonesian microcopy: *"Siram Sekarang"* (Water Now).
- **Disabled State:** Instead of graying out, use a desaturated Mint with a lock icon.

### Health & Mission Cards
- **Health Bars:** Thick, rounded tracks. The fill color transitions from Warm Yellow (low) to Soft Green (healthy).
- **Mission Cards:** Cream background with a Sky Blue border. Includes a checkbox that transforms into a badge icon upon completion. Indonesian microcopy: *"Misi Hari Ini"* (Today's Mission).

### IoT Monitoring Cards
- **Moisture Cards:** Large numeric display of percentage with a "water droplet" background illustration. 
- **Status Indicators:** Use friendly labels like *"Tanamanmu haus!"* (Your plant is thirsty!) or *"Wah, segar sekali!"* (Wow, so fresh!).

### Badges
- Circular or hexagonal shapes with Warm Yellow fills. Use simple flat icons of leaves, suns, or watering cans.