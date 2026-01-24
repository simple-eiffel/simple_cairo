# S06: BOUNDARIES - simple_cairo

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## API Boundaries

### Public Interface (Exported to ANY)

#### SIMPLE_CAIRO
- `make` - Constructor
- `create_surface`, `create_surface_format` - Surface factory
- `create_context` - Context factory
- `linear_gradient`, `radial_gradient` - Gradient factory
- `vertical_gradient`, `horizontal_gradient` - Convenience gradients
- `last_error`, `has_error` - Error status
- Format constants: `Format_argb32`, `Format_rgb24`, etc.

#### CAIRO_CONTEXT
- All drawing operations (fluent API)
- All color operations
- All transform operations
- All text operations
- `handle` - For advanced interop
- `surface` - Associated surface
- `is_valid`, `status` - State queries
- `destroy` - Cleanup

#### CAIRO_SURFACE
- `make`, `make_with_format`, `make_from_handle` - Constructors
- `width`, `height`, `stride`, `data` - Properties
- `is_valid`, `status` - State queries
- `write_png` - PNG output
- `destroy` - Cleanup

#### CAIRO_GRADIENT
- `make_linear`, `make_radial` - Constructors
- `add_stop_*` - Color stop methods
- `two_color`, `three_color` - Convenience
- `is_valid`, `is_linear`, `is_radial` - Type queries
- `destroy` - Cleanup

#### CAIRO_PDF_SURFACE
- `make`, `make_a4`, `make_letter` - Constructors
- `show_page`, `set_page_size` - Page management
- `set_title`, `set_author`, etc. - Metadata
- `as_surface` - Convert to CAIRO_SURFACE
- `destroy` - Cleanup

### Internal Interface (NONE or restricted)

- All `c_*` externals are `{NONE}`
- UTF-8 conversion helpers are `{NONE}`
- Implementation details hidden

## Integration Points

| Component | Interface | Direction |
|-----------|-----------|-----------|
| Cairo DLL | C inline | Outbound |
| File system | write_png | Outbound |
| Caller code | Public API | Inbound |
