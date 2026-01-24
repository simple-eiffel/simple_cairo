# S07: SPEC SUMMARY - simple_cairo

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Executive Summary

simple_cairo provides a complete Eiffel wrapper for the Cairo 2D graphics library, enabling high-quality vector graphics rendering, PDF generation, and image output.

## Key Design Decisions

### 1. Fluent API Pattern
All CAIRO_CONTEXT drawing methods return `like Current`, enabling method chaining:
```eiffel
ctx.set_color_hex (0xFF0000)
   .fill_rect (10, 10, 100, 50)
   .set_color_hex (0x0000FF)
   .stroke_circle (200, 200, 30)
```

### 2. Facade Pattern
SIMPLE_CAIRO acts as factory, hiding complexity of surface/context creation.

### 3. Explicit Resource Management
Native handles require explicit `destroy` calls. No automatic garbage collection of Cairo resources.

### 4. Inline C Pattern
Uses Eric Bezault pattern for C interop - all C code in inline externals, single header file.

## Class Summary

| Class | Purpose | Lines |
|-------|---------|-------|
| SIMPLE_CAIRO | Factory facade | 153 |
| CAIRO_CONTEXT | Drawing operations | 751 |
| CAIRO_SURFACE | Image surface | 208 |
| CAIRO_GRADIENT | Gradient patterns | 182 |
| CAIRO_PDF_SURFACE | PDF output | 272 |

## Feature Summary

- **Surfaces:** Image (4 formats), PDF
- **Drawing:** Paths, shapes, fills, strokes
- **Colors:** RGB, RGBA, hex
- **Gradients:** Linear, radial
- **Text:** Font selection, rendering, measuring
- **Transforms:** Translate, scale, rotate
- **Output:** PNG files, PDF documents

## Contract Coverage

- All public features have preconditions
- Surface/context validity checked before operations
- Color values validated (0.0-1.0 range)
- Dimensions validated (positive values)
- Class invariants maintain consistency
