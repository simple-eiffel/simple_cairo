# 7S-02: STANDARDS - simple_cairo


**Date**: 2026-01-23

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Applicable Standards

### Cairo Graphics Library
- Cairo 1.x API: https://www.cairographics.org/documentation/
- Surface types: Image, PDF, SVG, PostScript
- Drawing model: Path-based vector graphics

### Color Standards
- sRGB color space
- ARGB32 pixel format (pre-multiplied alpha)
- RGB24 format (no alpha)
- A8/A1 formats (alpha-only masks)

### PDF Standards
- PDF 1.4 output format
- Page sizes in points (72 points = 1 inch)
- Standard page sizes: A4 (595.28x841.89), Letter (612x792)

### Text Rendering
- FreeType font rendering
- UTF-8 text encoding for Unicode support
- Font slant: Normal, Italic, Oblique
- Font weight: Normal, Bold

## Compliance Notes

The implementation wraps Cairo's C API using Eiffel inline C externals, maintaining API compatibility with the underlying library while providing Eiffel-native types and contracts.
