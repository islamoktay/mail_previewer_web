# Design System Specification: High-End Productivity Editorial

## 1. Overview & Creative North Star: "The Silent Architect"
This design system moves beyond the "generic SaaS" look to create a digital environment that feels like a high-end, bespoke physical workspace. Our Creative North Star is **The Silent Architect**: a philosophy where the UI provides a deliberate, quiet structure that recedes to prioritize the user's focus, using intentional asymmetry and tonal depth rather than rigid lines and boxes.

We reject the "template" aesthetic. Instead of a flat grid, we use **Negative Space as a Component** and **Tonal Layering** to create a sense of premium craftsmanship. The goal is an interface that doesn't just function—it "breathes."

---

## 2. Colors & Surface Philosophy
The palette is rooted in sophisticated slates and navies, designed to feel authoritative yet calm.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to define sections or containers. Structural boundaries must be achieved exclusively through background color shifts.
*   **Example:** A `surface-container-low` sidebar sitting directly against a `surface` main content area.
*   **The "Ghost Border" Fallback:** If accessibility or extreme density requires a container edge, use the `outline-variant` token at **10-20% opacity only**. Never use 100% opaque borders.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the following tiers to define importance:
*   **Level 0 (Foundation):** `surface` (#f7f9fb) – The base canvas.
*   **Level 1 (Sub-sections):** `surface-container-low` (#f0f4f7) – Recessed areas or secondary sidebars.
*   **Level 2 (Interactive Cards):** `surface-container-lowest` (#ffffff) – Used for primary content cards to create a "lifted" feel against the base.
*   **Level 3 (Overlays):** `surface-container-high` (#e1e9ee) – Used for subtle navigation elements or headers.

### The "Glass & Signature" Rule
To elevate the "out-of-the-box" feel:
*   **Glassmorphism:** For floating modals or dropdowns, use `surface-container-lowest` at 80% opacity with a `backdrop-blur` of 12px.
*   **Signature Gradients:** Main CTAs or Hero backgrounds should utilize a subtle linear gradient from `primary` (#565e74) to `primary-dim` (#4a5268) at a 135-degree angle. This adds a "soul" to the color that flat hex codes cannot provide.

---

## 3. Typography: Editorial Authority
We pair the geometric precision of **Manrope** for high-level expression with the functional clarity of **Inter** for data-heavy tasks.

*   **Display & Headlines (Manrope):** Large, bold, and airy. Use `display-lg` (3.5rem) and `headline-md` (1.75rem) to create clear editorial entry points. The increased letter-spacing in Manrope conveys a premium, modern feel.
*   **Body & Labels (Inter):** High-readability sans-serif. `body-md` (0.875rem) is the workhorse for all tool-based interactions.
*   **Tonal Contrast:** Use `on-surface-variant` (#566166) for secondary body text to reduce visual noise, ensuring only the most critical information uses the high-contrast `on-surface` (#2a3439).

---

## 4. Elevation & Depth
Depth is a functional tool, not a decoration. We achieve hierarchy through **Tonal Layering** and **Ambient Light**.

### The Layering Principle
Instead of shadows, stack containers:
1.  **Canvas:** `surface`
2.  **Section:** `surface-container-low`
3.  **Active Element:** `surface-container-lowest` (This creates a soft, natural lift).

### Ambient Shadows
When an element must "float" (e.g., a primary command menu):
*   **Shadow:** `0 20px 40px -12px rgba(42, 52, 57, 0.08)`
*   **Tinting:** Never use pure black shadows. The shadow must be a low-opacity version of `on-surface` (#2a3439) to mimic natural light reflecting off the surface.

---

## 5. Components
All components follow the **DEFAULT roundedness of 8px (0.5rem)** to maintain a soft, professional approachable feel.

### Buttons & CTAs
*   **Primary:** Uses the `primary` to `primary-dim` gradient. No border. Text color: `on-primary`.
*   **Secondary:** `surface-container-high` background. Text color: `on-secondary-container`. This feels integrated into the UI rather than "pasted on."
*   **Tertiary/Ghost:** No background. Uses `primary` color for text. Only reveals a `surface-variant` background on hover.

### Input Fields & Controls
*   **Inputs:** Use `surface-container-lowest` with a "Ghost Border" (10% `outline-variant`). On focus, transition the border to `primary` at 100% opacity.
*   **Checkboxes/Radios:** Rounded corners on checkboxes (sm: 0.25rem). Use `primary` for selected states.
*   **Chips:** Use `surface-container-highest` for unselected filter chips; `primary` for active states.

### Cards & Lists (The Divider-Free Rule)
*   **Lists:** Forbid 1px horizontal dividers. Separate list items using `spacing-2` (0.7rem) of vertical white space or by alternating background tints between `surface` and `surface-container-low`.
*   **Cards:** Use `surface-container-lowest` on a `surface` background. Apply a `DEFAULT` (0.5rem) corner radius.

---

## 6. Do’s and Don'ts

### Do
*   **Use Intentional Asymmetry:** Shift the main content container slightly off-center or use varying column widths (e.g., 25% sidebar / 75% content) to break the "standard bootstrap" feel.
*   **Embrace Negative Space:** If you think a section needs more room, use `spacing-10` (3.5rem) or `spacing-12` (4rem). High-end tools feel spacious.
*   **Nesting Surfaces:** Place `surface-container-highest` elements inside `surface-container-low` areas to create "island" focal points.

### Don't
*   **No High-Contrast Borders:** Never use #000000 or high-opacity grays for borders. It creates "visual cages" that trap the user's eye.
*   **No Pure Black:** Avoid `#000000`. Use `inverse_surface` (#0b0f10) for deep tones to maintain a sophisticated slate-navy profile.
*   **No Crowding:** Do not sacrifice the spacing scale to fit more "features" above the fold. Editorial design requires the luxury of space.