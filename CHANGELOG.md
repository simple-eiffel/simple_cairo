# Changelog

All notable changes to simple_cairo will be documented in this file.

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
