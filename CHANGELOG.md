# Changelog

All notable changes to simple_cairo will be documented in this file.

## [Unreleased] - Phase C in progress

### Added (C2/D1 - the get-ahead sprint)
- CAIRO_MATRIX: identity/translate/scale/rotate/multiply/invert +
  point/distance transforms; CAIRO_CONTEXT matrix get/set/transform and
  user_to_device / device_to_user
- CAIRO_SVG_SURFACE (vector .svg output) + CAIRO_SURFACE.finish
- CAIRO_SURFACE.make_from_png (PNG READ, round-trip tested pixel-exact)
- CAIRO_SURFACE.make_similar + Content constants; device offset/scale
- CAIRO_DEVICE (non-owning: status/flush/finish) + CAIRO_SURFACE.device
- status_message on surface/context; SIMPLE_CAIRO.cairo_version
- 11 new tests (matrix algebra numeric, PNG round-trip, SVG document)

### Added (Phase C-1)
- CAIRO_SURFACE.make_for_dc: cairo surface painting straight onto a
  Windows device context (cairo_win32_surface_create) - the live-window
  route. Suite test against the screen DC.
- spike_gui / simple_cairo_gui_spike target: pure-Win32 interactive
  SV_BLOCK_EDITOR spike (inline-C window + message pump, no Vision2;
  every pixel painted by simple_cairo, blitted via make_for_dc)

## [1.3.0] - 2026-09-02

### Added (Phase D - S07: the glyph API, for simple_shaping)
- CAIRO_FONT_FACE: cairo_font_face_t over a Windows font realization -
  `make_for_hfont` (cairo_win32_font_face_create_for_hfont) and
  `make_for_logfontw_hfont`; `status` / `is_valid` / `status_message`,
  `reference_count`, reference-counted `destroy`. A null HFONT reports an
  invalid face rather than raising.
- CAIRO_GLYPH_ARRAY: marshalled cairo_glyph_t array, 1-based, zeroed on
  creation, `put` / `glyph_id` / `x` / `y` / `area`. The struct layout is
  REPORTED by C (`Glyph_struct_size`, `Glyph_index_offset`,
  `Glyph_x_offset`, `Glyph_y_offset`) and every field is written through
  the shim, so no caller and no Eiffel code assumes it. Verified on win64
  with MSVC 14.44 and MinGW gcc: 24 bytes, id at 0, x at 8, y at 16.
- CAIRO_CONTEXT: `set_font_face`, `show_glyphs` (three parallel arrays:
  ids, x, y), `show_glyph_array` (zero-copy), `glyph_extents`,
  `glyph_array_extents`. Empty runs are no-ops that measure as six zeros,
  never cairo errors.
- SIMPLE_CAIRO facade: `font_face_for_hfont`,
  `font_face_for_logfontw_hfont`, `glyph_array`.
- 15 new tests (87 total, was 72), including a pixel test that resolves
  real glyph ids with GetGlyphIndicesW and asserts ink on the surface,
  three contract-violation tests, and the same-N tripwire below.

### Known cairo behavior, documented and pinned (see CAIRO_FONT_FACE)
- SAME-N TRAP: at exactly `set_font_size (N)` where N is the HFONT's own
  pixel size, and with `Antialias_default`, cairo 1.17.2's win32 backend
  reuses the caller's HFONT as its internal scaled font (which it builds
  at 32 x N), so glyphs render at about 1/32 size with no error reported.
  Same-N is the normal case for a shaping caller. Fix: call
  `set_font_antialias (Antialias_subpixel)` once per context before
  drawing glyphs - any explicit mode works and subpixel keeps ClearType.
  Pinned by `test_same_n_needs_explicit_antialias`.
- HFONT LIFETIME: cairo's win32 font-face cache is keyed on face name,
  weight and italic only - not on the HFONT, not on the height - so a
  cached face outlives the CAIRO_FONT_FACE that made it. Never
  DeleteObject an HFONT cairo may still hold; the dangling handle
  surfaces as CAIRO_STATUS_WIN32_GDI_ERROR (41) and poisons the shared
  face for the rest of the process.

## [1.2.0] - 2026-08-21

### Added (Phase B - S10: compositing and patterns)
- CAIRO_PATTERN deferred base: extend/filter get+set, status, disposal
- CAIRO_GRADIENT re-parented onto CAIRO_PATTERN (public API unchanged)
- CAIRO_SOLID_PATTERN, CAIRO_SURFACE_PATTERN (tiling via Extend_repeat)
- CAIRO_MESH_PATTERN with contracted patch discipline (in_patch ghost)
- CAIRO_CONTEXT: set_operator/drawing_operator + all 29 operator
  constants, set_source_surface, mask, mask_surface, set_pattern
- arc_negative exposed (shim existed unwired since 1.0.0)
- Facade factories: solid_pattern[_rgba], surface_pattern, mesh_pattern
- 12 new tests: pixel-exact operator/mask/tiling/pad checks, mesh corner
  sampling, two contract-violation tests
- demo target simple_cairo_demo: DEMO_APP draws the simple_narrate
  reference editor window headless to PNG (private faces via FR_PRIVATE
  or --system-fonts fallback) - Milestone M1, evidence in demo/RUN_LOG.md

## [1.1.0] - 2026-08-21

### Added (Layer 0 - S09, driven by simple_narrate)
- CAIRO_TEXT_EXTENTS: full six-field measurement record; x_advance is
  the layout number (width is ink coverage and excludes trailing spaces)
- CAIRO_FONT_EXTENTS: ascent, descent, line height, max advances
- CAIRO_CONTEXT.text_extents / font_extents (buffer-marshalled, one C call)
- text_width / text_height re-expressed over text_extents
- set_antialias, set_font_antialias, set_font_hint_style + constants
- clip, clip_preserve, reset_clip, clip_rectangle, clip_extents
- push_group / pop_group_to_source with group_depth contract
- set_dash / clear_dash
- CAIRO_SURFACE.flush / mark_dirty (required around raw data access)
- 18 new tests including the wrap-loop acceptance test and three
  contract-violation tests that double as assertion-liveness proof

## [1.0.0] - 2025-12-29

### Added
- Initial release
- SIMPLE_CAIRO facade class with factory methods
- CAIRO_SURFACE for image surfaces (ARGB32, RGB24, A8, A1 formats)
- CAIRO_CONTEXT with fluent API for drawing operations
- CAIRO_GRADIENT for linear and radial gradients
- Basic shapes: rectangles, circles, lines, arcs, Bezier curves
- Rounded rectangle support
- Color support: RGB, RGBA, hex
- Text rendering with font selection
- Coordinate transforms: translate, scale, rotate
- Waveform visualization for audio applications
- PNG export capability
- Cross-platform header (Windows/Linux)
- Comprehensive test suite
