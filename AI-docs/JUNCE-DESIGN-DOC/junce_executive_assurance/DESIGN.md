---
name: Junce Executive Assurance
colors:
  surface: '#fff8f3'
  surface-dim: '#e3d8cc'
  surface-bright: '#fff8f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fdf2e5'
  surface-container: '#f7ecdf'
  surface-container-high: '#f1e7d9'
  surface-container-highest: '#ece1d4'
  on-surface: '#201b13'
  on-surface-variant: '#4f4535'
  inverse-surface: '#353027'
  inverse-on-surface: '#faefe2'
  outline: '#817563'
  outline-variant: '#d3c4af'
  surface-tint: '#7b5800'
  primary: '#785600'
  on-primary: '#ffffff'
  primary-container: '#986d00'
  on-primary-container: '#fffbff'
  inverse-primary: '#f7bd48'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfde'
  on-secondary-container: '#636262'
  tertiary: '#085ea2'
  on-tertiary: '#ffffff'
  tertiary-container: '#3477bc'
  on-tertiary-container: '#fdfcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdea6'
  primary-fixed-dim: '#f7bd48'
  on-primary-fixed: '#271900'
  on-primary-fixed-variant: '#5d4200'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#d2e4ff'
  tertiary-fixed-dim: '#a1c9ff'
  on-tertiary-fixed: '#001c37'
  on-tertiary-fixed-variant: '#004880'
  background: '#fff8f3'
  on-background: '#201b13'
  surface-variant: '#ece1d4'
  status-success: '#065F46'
  status-error: '#991B1B'
  status-warning: '#D97706'
  surface-warm-gray: '#F9F8F6'
  surface-ink: '#121212'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.05em
  number-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

This design system is engineered for high-stakes financial and tax intelligence. It communicates authority, precision, and institutional wealth through a "Consultant-in-a-Box" narrative. The brand personality is **Authoritative, Scientific, and Discreet**, designed to provide business owners with a sense of security and clarity amidst complex data.

The visual style is **Corporate Modern with Glassmorphic accents**. It balances the weight of traditional financial services with the agility of AI. The interface uses expansive whitespace, refined typography, and subtle depth to create an "Executive Dashboard" experience. Key characteristics include:
- **Translucent Layering:** Using backdrop blurs to maintain context and create a premium, layered feel.
- **Precision Data Viz:** Clean, ECharts-inspired visualizations that prioritize insight over decoration.
- **Professional Air:** A "No Blue" constraint that pushes the aesthetic toward high-end fintech and private banking.

## Colors

The palette is anchored by **Bronze Gold (#B8860B)**, symbolizing professional wealth management and the "gold standard" of AI diagnosis. This is paired with **Deep Charcoal/Ink (#1A1A1A)** to provide serious, business-grade contrast.

### Palette Logic
- **Primary (Bronze):** Reserved for primary actions, success milestones, and high-level branding.
- **Secondary (Ink):** Used for text, structural headers, and deep-mode backgrounds to command attention.
- **Semantic Accents:** 
    - **Emerald Green:** Represents healthy financial states and "Low Risk."
    - **Deep Red:** Reserved strictly for high-risk alerts and critical tax findings.
- **Neutral Grays:** We use warm-toned neutrals (avoiding cool blues) to maintain a prestigious, "parchment and ink" modernism.

## Typography

The system uses **Plus Jakarta Sans** for headlines to provide a modern, optimistic, and slightly rounded character that softens the "serious" nature of tax audits. **Inter** is used for body copy and data entry for its industry-leading legibility in dense information environments.

### Hierarchy Rules
- **High Contrast:** Large size differentials between display text and body text create a rhythmic, editorial feel.
- **Numeric Emphasis:** Use the `number-xl` style for financial scores and percentages to make them the focal point of the dashboard.
- **Labels:** All caps with increased letter spacing for metadata and chips to distinguish them from prose.

## Layout & Spacing

This design system employs a **12-column fluid grid** for desktop and a **single-column stack** for mobile. The layout is "Airy," utilizing generous vertical margins to separate complex report sections.

### Layout Principles
- **The "One-Minute" Summary:** The top of every page features a full-width "Hero" area for high-level KPIs.
- **Split View:** For interactive tasks like document uploading, use a 60/40 split (Main Content / Status Sidebar).
- **Rhythm:** Spacing follows an 8px base unit. Component-to-component spacing should lean toward `32px` or `48px` to prevent information overload.

## Elevation & Depth

Visual hierarchy is achieved through **Glassmorphic layering** and **Ambient shadows**. Surfaces should feel like high-end physical materials (frosted glass and polished stone).

- **Surface Tiers:**
    - **Level 0 (Background):** Neutral warm gray (#F9F8F6).
    - **Level 1 (Cards):** Pure white with a 1px subtle border (#E5E5E5) and a soft, wide-spread shadow (15% opacity).
    - **Level 2 (Modals/Overlays):** White with 80% opacity and `backdrop-filter: blur(12px)`.
- **Shadow character:** Avoid harsh, black shadows. Use tinted shadows derived from the Ink color (#1A1A1A) with high diffusion (30px-50px blur) to simulate natural, soft lighting.

## Shapes

The shape language is defined by **expansive, generous radii**. This counters the rigid, "scary" perception of tax and financial audits, making the software feel approachable and human-centric.

- **Standard Cards:** 16px to 24px corner radius.
- **Input Fields:** 12px corner radius for a modern feel.
- **Chips/Status Tags:** Fully pill-shaped (rounded-full) to contrast against the geometric grid.
- **Interactive Buttons:** 12px or pill-shaped depending on the hierarchy (Primary buttons = 12px, Secondary/Utility = Pill).

## Components

### Buttons
- **Primary:** Bronze background, white text, 12px radius. Subtle glow on hover.
- **Ghost:** Ink border (1px), transparent background. For secondary navigation and "Cancel" actions.

### Cards & Risk Groups
- **Report Cards:** 24px radius, white background, soft shadow. Should include a "Header" area with a thin 1px bottom divider.
- **Risk Findings:** Grouped in lists with `8px` vertical spacing. Each finding is a Level 1 card with a semantic color stripe on the left edge.

### Inputs & Forms
- **Fields:** Subtle warm gray background (#F3F3F1) with a 1px border that turns Bronze on focus.
- **Progress Bars:** Thin (4px-6px) height. Use the Bronze-to-Gold gradient for completeness states.

### Data Visualizations
- **Radar Charts:** Use a semi-transparent Bronze fill with high-contrast Ink outlines for the "Four Dimensions" (Profit, Risk, Cash Flow, Efficiency).
- **Status Chips:** High-contrast text on low-opacity backgrounds (e.g., Deep Red text on 10% Red background) for maximum legibility without visual noise.

### Feedback States
- **Processing (AI Diagnosis):** Use a glassmorphic overlay with a refined pulse animation rather than a traditional spinner to maintain the "High-End" feel.