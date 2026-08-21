# DEMO_APP run log

Milestone M1 acceptance: *"let me know when simple_cairo is capable of making
the PIL->PNG-ish GUI that was drawn for simple_narrate"* (Larry, 2026-08-21).

**Answer: 2026-08-21, same day — after S09 (measurement) + Phase B.** The
binding capability was S09's `text_extents.x_advance`; everything else the
reference needs existed by v1.2.0.

## Build

```
/d/prod/ec.sh check -config simple_cairo.ecf -target simple_cairo_demo
→ System Recompiled. (no Error code lines)
/d/prod/ec.sh test  -config simple_cairo.ecf -target simple_cairo_demo
→ ✓ Built: EIFGENs/simple_cairo_demo/F_code/simple_cairo.exe
```

## Runs (verbatim output)

Config 1 — private faces (default):
```
Fonts: 3 private faces loaded (Archivo, Literata, IBM Plex Mono)
Wrote demo_editor_window.png (2960x1720)
```

Config 2 — `--system-fonts` (fallback path exercised):
```
Fonts: system fallbacks by request (--system-fonts)
Wrote demo_editor_window_systemfonts.png (2960x1720)
```

Artifacts (committed beside this log):
```
demo_editor_window.png             173,002 bytes  2960x1720
demo_editor_window_systemfonts.png 166,713 bytes  2960x1720
```

## What the render proves, feature by feature

| Element in the PNG | simple_cairo capability |
|---|---|
| word-wrapped prose, 2 lines | `text_extents.x_advance` accumulation (S09) — the wrap loop, live |
| split-preview tints + caret | per-word measured boxes under text |
| severity stripes on cards | `save` / `clip_rectangle` / `restore` (S09) |
| chips with tracked caps | per-glyph advance placement |
| icons (play/refresh/check/arrows) | path construction incl. `arc` |
| selected-card ring, hairlines, rounded cards | `rounded_rectangle`, `fill_preserve` + `stroke` |
| exact faces | `AddFontResourceExW (FR_PRIVATE)` in the demo + toy `select_font` |
| 2× crispness | `scale (2,2)` on a 2960×1720 surface |
| the file itself | `write_png` (v1.0.0) |

## Known cosmetic deltas vs the browser reference (not blockers)

- Emphasis words inside blocks 09 are not bolded (block 09 body is drawn as a
  single run; only block 08 goes through the tokenizer). Polish item.
- Icon glyphs are hand-drawn paths, near but not identical to the reference's
  font glyphs.
- Minor spacing differences (±2–4 px) where the browser's line-box model and
  the demo's fixed line-height differ.

Re-render: build the `simple_cairo_demo` target, copy `cairo.dll` beside the
exe, run with no args and with `--system-fonts`.
