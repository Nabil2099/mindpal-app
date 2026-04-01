# Design System Specification: Editorial Organicism

## 1. Overview & Creative North Star
**The Creative North Star: "The Modern Archivist"**

This design system rejects the sterile, high-frequency aesthetic of typical "tech" wellness apps. Instead, it draws inspiration from high-end editorial journals and physical tactile archives. We are building a space that feels like a quiet, sun-drenched library. 

To break the "template" look, we move away from rigid, centered grids in favor of **intentional asymmetry** and **tonal layering**. Elements should feel like they were placed by hand on a sheet of heavy-stock parchment. We use dramatic typography scales—pairing oversized serif displays with tight, functional sans-serif metadata—to create a sense of rhythm and breathing room. The interface doesn't just "show" content; it curates an emotional state.

---

## 2. Colors & Surface Philosophy
The palette is rooted in earth and ink. We prioritize low-contrast transitions to reduce cognitive load and visual noise.

### Surface Hierarchy & Nesting
Forget the traditional "box-on-box" approach. We treat the UI as a series of physical layers.
- **Base Layer:** `surface` (#fbf9f5) – The raw parchment.
- **Sectioning:** Use `surface-container-low` (#f5f3ef) for large structural areas.
- **Interactive Layers:** Use `surface-container-highest` (#e4e2de) for elements that require the most focus.
- **Nesting:** To define importance, an inner card should be `surface-container-lowest` (#ffffff) sitting atop a `surface-container` (#efeeea) section. This "white-on-cream" effect provides a premium, clean lift.

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.** 
Structural boundaries must be defined solely through background color shifts. If a section needs to end, transition the background from `surface` to `surface-container`. The eye should perceive a change in "weight," not a line.

### Signature Textures & Glass
- **The Clay Gradient:** For primary actions, do not use a flat hex. Apply a subtle linear gradient from `primary` (#735638) to `primary_container` (#8e6f4e) at a 145-degree angle. This adds "soul" and a sense of depth.
- **Editorial Glass:** For floating navigation or modals, use `surface` at 80% opacity with a `20px` backdrop blur. This allows the earthy "parchment" tones to bleed through, softening the interface.

---

## 3. Typography
We use a high-contrast pairing to balance emotional warmth with functional clarity.

- **Display & Headlines (Newsreader/Fraunces):** These are our "Editorial Voices." Use `display-lg` for moments of reflection and `headline-md` for page titles. The serif nature conveys authority and timelessness.
- **Body & Titles (Plus Jakarta Sans):** These are our "Functional Voices." Used for journal entries and data. The clean, geometric sans-serif ensures readability even in long-form text.
- **The Typographic Rhythm:** Always pair a `display-sm` serif header with a `label-sm` sans-serif sub-header in all-caps (spaced 0.05em). This creates the "Editorial Header" look.

---

## 4. Elevation & Depth
In this system, shadows are a last resort, not a default.

- **The Layering Principle:** Depth is achieved by "stacking" tones. A `surface-container-lowest` card on a `surface-container-low` background creates a soft, natural lift that feels like a physical page.
- **Ambient Shadows:** When an element must "float" (e.g., a FAB or a Modal), use the custom shadow: `blur 40, spread -32, color rgba(50, 40, 28, 0.28)`. The warmth in the shadow color (derived from our Ink/Clay tones) prevents the UI from looking "muddy" or "gray."
- **The Ghost Border:** If a border is required for accessibility, use `outline-variant` (#d2c4b8) at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons
- **Primary:** Pill-shaped (`rounded-full`). Gradient of `primary` to `primary_container`. Text is `on_primary` (White).
- **Secondary:** Pill-shaped. Background: `surface-container-high`. Text: `primary`. No border.
- **Tertiary:** Text-only using `title-sm`. Use an underline on hover/active states only.

### Cards & Lists
- **The Forbidding of Dividers:** Never use horizontal rules (`<hr>`). Separate list items using `spacing-4` (1.4rem) of vertical white space or by alternating background tones between `surface` and `surface-container-low`.
- **Corner Radius:** All cards must use `rounded-xl` (3rem) or `rounded-lg` (2rem) to maintain the "organic" feel.

### Emotion Chips
- Use the earthy muted palette (e.g., `Joy #e2cab0`, `Calm #b79282`). 
- Chips should be `rounded-full` with `label-md` typography. 
- **Interaction:** When selected, add a `2px` "Ghost Border" of the `primary` color at 40% opacity.

### Input Fields
- **Styling:** Minimalist. No bottom line. Use a `surface-container-highest` background with a `rounded-md` (1.5rem) corner.
- **Focus State:** Background shifts to `surface-container-lowest` with a subtle glow using the `primary` color at 10% opacity.

---

## 6. Do’s and Don’ts

### Do:
- **Embrace Asymmetry:** Offset your headers. If a card is full-width, perhaps the text inside is indented more heavily on the left than the right.
- **Use "Ink" for Hierarchy:** Use `on_surface` (#1b1c1a) for primary text and `on_surface_variant` (#4f453c) for secondary "metadata" to create a soft, readable contrast.
- **Prioritize Negative Space:** If you think a screen is finished, add 20% more white space.

### Don’t:
- **No Pure Grayscale:** Never use `#000000` or `#808080`. Every "neutral" must be tinted with the Sand or Clay foundation.
- **No Sharp Corners:** Even small checkboxes should have a `rounded-sm` (0.5rem) radius. Sharpness causes visual anxiety; we are building for peace.
- **No "Standard" Shadows:** Avoid the default Material or Tailwind shadows. They are too cool-toned and "digital" for this aesthetic.