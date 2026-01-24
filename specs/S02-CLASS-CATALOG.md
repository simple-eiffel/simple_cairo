# S02: CLASS CATALOG - simple_cairo

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Class Hierarchy

```
SIMPLE_CAIRO (facade)
    |
    +-- creates --> CAIRO_SURFACE
    +-- creates --> CAIRO_CONTEXT
    +-- creates --> CAIRO_GRADIENT
    +-- creates --> CAIRO_PDF_SURFACE
```

## Class Descriptions

### SIMPLE_CAIRO
**Purpose:** Main facade for Cairo graphics library
**Role:** Factory for surfaces, contexts, and gradients
**Key Features:**
- `create_surface` - Create ARGB32 image surface
- `create_surface_format` - Create surface with specific format
- `create_context` - Create drawing context for surface
- `linear_gradient` / `radial_gradient` - Create gradient patterns
- `last_error` / `has_error` - Error tracking

### CAIRO_CONTEXT
**Purpose:** Drawing context wrapper for cairo_t
**Role:** Performs all drawing operations
**Key Features:**
- Color: `set_color_rgb`, `set_color_rgba`, `set_color_hex`
- Lines: `set_line_width`, `set_line_cap`, `set_line_join`
- Paths: `move_to`, `line_to`, `curve_to`, `arc`, `rectangle`
- Drawing: `stroke`, `fill`, `paint`, `clear`
- Shapes: `fill_rect`, `stroke_rect`, `fill_circle`, `stroke_circle`
- Transforms: `translate`, `scale`, `rotate`
- Text: `select_font`, `set_font_size`, `show_text`
- Waveform: `draw_waveform_i16`

### CAIRO_SURFACE
**Purpose:** Image surface wrapper for cairo_surface_t
**Role:** Holds pixel data, supports PNG output
**Key Features:**
- `make` - Create ARGB32 surface
- `make_with_format` - Create with specific format
- `write_png` - Save to PNG file
- `width`, `height`, `stride` - Surface dimensions
- `data` - Raw pixel data access

### CAIRO_GRADIENT
**Purpose:** Gradient pattern wrapper for cairo_pattern_t
**Role:** Defines color gradients for fills
**Key Features:**
- `make_linear` - Linear gradient
- `make_radial` - Radial gradient
- `add_stop_rgb`, `add_stop_rgba`, `add_stop_hex` - Color stops
- `two_color`, `three_color` - Convenience methods

### CAIRO_PDF_SURFACE
**Purpose:** PDF output surface
**Role:** Creates vector PDF files
**Key Features:**
- `make`, `make_a4`, `make_letter` - Create PDF surface
- `show_page` - Finish page, start new one
- `set_page_size` - Change page dimensions
- `set_title`, `set_author`, etc. - PDF metadata
- `as_surface` - Convert to CAIRO_SURFACE for drawing
