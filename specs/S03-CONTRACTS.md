# S03: CONTRACTS - simple_cairo

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Design by Contract Summary

### SIMPLE_CAIRO Contracts

#### create_surface
```eiffel
require
    valid_width: a_width > 0
    valid_height: a_height > 0
ensure
    result_exists: Result /= Void
```

#### create_context
```eiffel
require
    surface_valid: a_surface.is_valid
ensure
    result_exists: Result /= Void
```

### CAIRO_CONTEXT Contracts

#### set_color_rgb
```eiffel
require
    valid: is_valid
    valid_r: a_r >= 0 and a_r <= 1
    valid_g: a_g >= 0 and a_g <= 1
    valid_b: a_b >= 0 and a_b <= 1
```

#### arc
```eiffel
require
    valid: is_valid
    positive_radius: a_radius > 0
```

#### set_line_width
```eiffel
require
    valid: is_valid
    positive: a_width > 0
```

#### show_text
```eiffel
require
    valid: is_valid
```

### CAIRO_SURFACE Contracts

#### make
```eiffel
require
    valid_width: a_width > 0
    valid_height: a_height > 0
ensure
    handle_set: handle /= default_pointer implies is_valid
```

#### write_png
```eiffel
require
    valid: is_valid
    filename_not_empty: not a_filename.is_empty
```

### CAIRO_GRADIENT Contracts

#### add_stop_rgb
```eiffel
require
    valid: is_valid
    valid_offset: a_offset >= 0 and a_offset <= 1
    valid_r: a_r >= 0 and a_r <= 1
    valid_g: a_g >= 0 and a_g <= 1
    valid_b: a_b >= 0 and a_b <= 1
```

### Class Invariants

#### SIMPLE_CAIRO
```eiffel
invariant
    last_error_attached: last_error /= Void
```

#### CAIRO_CONTEXT
```eiffel
invariant
    surface_attached: surface /= Void
```

#### CAIRO_PDF_SURFACE
```eiffel
invariant
    positive_dimensions: width > 0 and height > 0
```
