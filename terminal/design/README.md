# Design system

The single source of truth for the terminal's look. `src/rendering/theme.{h,cpp}`
mirrors these values into ImGui/ImPlot styles at runtime.

| File | What it is |
|---|---|
| `tokens.json` | Machine-readable design tokens: colors, type ramp, spacing, radii, heatmap LUTs |
| `tradeos.css` | The full system; the `:root` block is the token layer |
| `IMGUI-NOTES.md` | Practical notes for mapping these tokens onto ImGui / ImPlot |

Dark-only by design: charcoal surfaces (#0E1116 base, #14181D panel), gold
(#C9A227) brand accent, off-white text (#F2EFE6), teal-up / rose-down market data,
amber for replay and events.

Changing a color? Edit `tokens.json` first, then mirror it into `Theme::Tokens`.
Widgets must never hardcode an `ImVec4`. Always go through the theme tokens.
