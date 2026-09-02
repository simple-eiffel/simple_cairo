<p align="center">
  <img src="docs/images/logo.svg" alt="simple_cairo logo" width="400">
</p>

# simple_cairo

**[Documentation](https://simple-eiffel.github.io/simple_cairo/)** | **[GitHub](https://github.com/simple-eiffel/simple_cairo)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

**Cross-platform 2D graphics library** wrapping Cairo for Eiffel applications.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Production** - Core functionality complete, edge-case tests passing

## Features

- **Surfaces** - ARGB32, RGB24, A8, A1 image formats
- **Drawing** - Rectangles, circles, lines, arcs, Bezier curves
- **Colors** - RGB, RGBA, hex color support
- **Gradients** - Linear and radial gradients with color stops
- **Text** - Font selection, sizing, and rendering
- **Glyphs** - Paint pre-shaped glyph runs through a Windows HFONT
- **Transforms** - Translate, scale, rotate
- **Waveforms** - Audio visualization for speech applications
- **PNG Export** - Save surfaces to PNG files

## Installation

### Prerequisites

#### Windows

1. Download Cairo from [GTK+ for Windows](https://www.gtk.org/docs/installations/windows/) or build from source
2. Set `CAIRO_PATH` environment variable to your Cairo installation directory
3. Ensure `cairo.dll` is in your PATH or application directory

#### Linux

```bash
sudo apt install libcairo2-dev   # Debian/Ubuntu
sudo dnf install cairo-devel     # Fedora
sudo pacman -S cairo             # Arch
```

### Add to Your ECF

```xml
<library name="simple_cairo" location="$SIMPLE_EIFFEL/simple_cairo/simple_cairo.ecf"/>
```

## Quick Start

```eiffel
local
    cairo: SIMPLE_CAIRO
    surface: CAIRO_SURFACE
    ctx: CAIRO_CONTEXT
do
    create cairo.make
    surface := cairo.create_surface (400, 300)
    ctx := cairo.create_context (surface)

    -- Clear to white
    ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing

    -- Draw blue rounded rectangle
    ctx.set_color_hex (0x3498DB)
       .rounded_rectangle (50, 50, 300, 200, 20)
       .fill.do_nothing

    -- Draw red circle outline
    ctx.set_color_hex (0xE74C3C)
       .set_line_width (4.0)
       .stroke_circle (200, 150, 50).do_nothing

    -- Save to file
    surface.write_png ("output.png")

    ctx.destroy
    surface.destroy
end
```

## Gradients

```eiffel
local
    grad: CAIRO_GRADIENT
do
    -- Create vertical gradient
    grad := cairo.vertical_gradient (0, 100)
    grad.add_stop_hex (0.0, 0x3498DB)   -- Blue at top
        .add_stop_hex (1.0, 0x2ECC71)   -- Green at bottom
        .do_nothing

    -- Fill rectangle with gradient
    ctx.set_gradient (grad)
       .fill_rect (0, 0, 200, 100).do_nothing

    grad.destroy
end
```

## Waveform Visualization

For audio/speech applications:

```eiffel
-- Draw waveform from int16 PCM samples
ctx.set_color_hex (0x3498DB)
   .set_line_width (1.0)
   .draw_waveform_i16 (samples_pointer, sample_count, 10, 10, 380, 100).do_nothing
```

## Glyph API

For text that has already been shaped elsewhere (simple_shaping, Uniscribe,
DirectWrite), paint the glyph ids and positions directly - cairo does no
shaping and never re-measures:

```eiffel
local
    face: CAIRO_FONT_FACE
    ids: ARRAY [NATURAL_32]
    xs, ys: ARRAY [REAL_64]
do
    -- `hfont' is a Windows HFONT the caller owns and keeps alive.
    face := cairo.font_face_for_hfont (hfont)

    -- REQUIRED at same-N: an explicit antialias mode. See below.
    ctx.set_font_antialias (ctx.Antialias_subpixel).do_nothing

    ctx.set_font_face (face).set_font_size (16.0).do_nothing
    ctx.show_glyphs (ids, xs, ys).do_nothing   -- absolute positions

    face.destroy
end
```

`ids` are PHYSICAL glyph indices of that HFONT (what `GetGlyphIndicesW` or
a shaper returns), not characters. `xs` / `ys` are absolute user-space
positions of each glyph origin, not advances. The three arrays must be the
same length; an empty run is a no-op. `ctx.glyph_extents (ids, xs, ys)`
measures the same run and returns six zeros for an empty one.

### Two rules the win32 font backend imposes

**Same-N.** Cairo ignores the LOGFONT height and sizes through the font
matrix, so shape at pixel size N and call `set_font_size (N)`. But at
exactly that size, with `Antialias_default`, cairo 1.17.2 reuses your
HFONT as its own internal scaled font (which it builds at 32 x N) and
renders at about 1/32 size - silently. Setting any explicit antialias
mode first avoids it; `Antialias_subpixel` keeps ClearType.

**HFONT lifetime.** Cairo's font-face cache is keyed on face name, weight
and italic - not on your HFONT - so the face it built outlives the
`CAIRO_FONT_FACE` object. Never `DeleteObject` an HFONT cairo may still
hold: the dangling handle surfaces as `CAIRO_STATUS_WIN32_GDI_ERROR` (41)
and poisons the shared face for the rest of the process.

## API Classes

| Class | Purpose |
|-------|---------|
| SIMPLE_CAIRO | Facade - Factory for surfaces, contexts, gradients |
| CAIRO_SURFACE | Image surface wrapper |
| CAIRO_CONTEXT | Drawing context with fluent API |
| CAIRO_GRADIENT | Linear and radial gradient patterns |
| CAIRO_FONT_FACE | Font face over a Windows HFONT, for glyph painting |
| CAIRO_GLYPH_ARRAY | Marshalled cairo_glyph_t run: ids + absolute positions |

## Dependencies

- Cairo library (libcairo)
- ISE EiffelBase

## License

MIT License - See LICENSE file

---

Part of the **Simple Eiffel** ecosystem.
