# 7S-04: SIMPLE-STAR - simple_cairo


**Date**: 2026-01-23

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Ecosystem Integration

### Dependencies on Other simple_* Libraries
- None (standalone graphics library)

### Libraries That May Depend on simple_cairo
- **simple_chart** - For rendering charts and graphs
- **simple_pdf** - For PDF document generation
- **simple_audio** - For waveform visualization
- **simple_gui** - For custom widget rendering

### Integration Patterns

#### With simple_file
```eiffel
-- Save rendered image
surface.write_png (file_path)
```

#### With simple_audio (waveform visualization)
```eiffel
-- Draw waveform from PCM samples
ctx.draw_waveform_i16 (samples_ptr, sample_count, x, y, width, height)
```

#### With simple_pdf (document generation)
```eiffel
-- Create PDF with Cairo
create pdf.make_a4 ("document.pdf")
pdf.set_title ("My Document")
create ctx.make (pdf.as_surface)
-- Draw content...
ctx.destroy
pdf.destroy
```

## Namespace Conventions
- Main facade: SIMPLE_CAIRO
- Supporting classes: CAIRO_* prefix
- C header: simple_cairo.h
