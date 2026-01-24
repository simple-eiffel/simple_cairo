# S04: FEATURE SPECS - simple_cairo

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Feature Specifications

### Surface Creation

| Feature | Signature | Description |
|---------|-----------|-------------|
| create_surface | (width, height: INTEGER): CAIRO_SURFACE | Create ARGB32 surface |
| create_surface_format | (format, width, height: INTEGER): CAIRO_SURFACE | Create with format |
| create_context | (surface: CAIRO_SURFACE): CAIRO_CONTEXT | Create drawing context |

### Gradient Creation

| Feature | Signature | Description |
|---------|-----------|-------------|
| linear_gradient | (x0, y0, x1, y1: REAL_64): CAIRO_GRADIENT | Linear gradient |
| radial_gradient | (cx0, cy0, r0, cx1, cy1, r1: REAL_64): CAIRO_GRADIENT | Radial gradient |
| vertical_gradient | (y0, y1: REAL_64): CAIRO_GRADIENT | Vertical linear |
| horizontal_gradient | (x0, x1: REAL_64): CAIRO_GRADIENT | Horizontal linear |

### Drawing Context - Colors

| Feature | Signature | Description |
|---------|-----------|-------------|
| set_color_rgb | (r, g, b: REAL_64): like Current | RGB 0.0-1.0 |
| set_color_rgba | (r, g, b, a: REAL_64): like Current | RGBA 0.0-1.0 |
| set_color_hex | (hex: NATURAL_32): like Current | Hex 0xRRGGBB |
| set_color_hex_alpha | (hex: NATURAL_32): like Current | Hex 0xAARRGGBB |

### Drawing Context - Paths

| Feature | Signature | Description |
|---------|-----------|-------------|
| new_path | : like Current | Start new path |
| move_to | (x, y: REAL_64): like Current | Move without line |
| line_to | (x, y: REAL_64): like Current | Line to point |
| curve_to | (x1, y1, x2, y2, x3, y3: REAL_64): like Current | Bezier curve |
| arc | (xc, yc, radius, angle1, angle2: REAL_64): like Current | Arc |
| rectangle | (x, y, width, height: REAL_64): like Current | Rectangle path |
| rounded_rectangle | (x, y, w, h, r: REAL_64): like Current | Rounded rectangle |
| close_path | : like Current | Close current path |

### Drawing Context - Operations

| Feature | Signature | Description |
|---------|-----------|-------------|
| stroke | : like Current | Stroke path |
| stroke_preserve | : like Current | Stroke keeping path |
| fill | : like Current | Fill path |
| fill_preserve | : like Current | Fill keeping path |
| paint | : like Current | Paint entire surface |
| paint_alpha | (alpha: REAL_64): like Current | Paint with alpha |
| clear | : like Current | Clear to transparent |

### Drawing Context - Convenience

| Feature | Signature | Description |
|---------|-----------|-------------|
| fill_rect | (x, y, w, h: REAL_64): like Current | Filled rectangle |
| stroke_rect | (x, y, w, h: REAL_64): like Current | Stroked rectangle |
| fill_circle | (cx, cy, r: REAL_64): like Current | Filled circle |
| stroke_circle | (cx, cy, r: REAL_64): like Current | Stroked circle |
| draw_line | (x1, y1, x2, y2: REAL_64): like Current | Line segment |

### Drawing Context - Text

| Feature | Signature | Description |
|---------|-----------|-------------|
| select_font | (family: STRING; slant, weight: INTEGER): like Current | Select font |
| set_font_size | (size: REAL_64): like Current | Set size |
| show_text | (text: STRING): like Current | Draw text |
| text_width | (text: STRING): REAL_64 | Measure width |
| text_height | (text: STRING): REAL_64 | Measure height |

### Drawing Context - Transforms

| Feature | Signature | Description |
|---------|-----------|-------------|
| translate | (tx, ty: REAL_64): like Current | Translate origin |
| scale | (sx, sy: REAL_64): like Current | Scale |
| rotate | (angle: REAL_64): like Current | Rotate (radians) |
| identity_matrix | : like Current | Reset transform |
| save | : like Current | Save state |
| restore | : like Current | Restore state |
