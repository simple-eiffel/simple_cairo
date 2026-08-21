# S09: LAYER 0 EXPANSION - simple_cairo

**Status:** FORWARD SPEC (the S01–S08 set is backwash; this specifies new work)
**Date:** 2026-08-21
**Driver:** `simple_narrate` Phase 2 — `SV_BLOCK_EDITOR` (wrapped, tinted, caret-addressable prose) and `SV_BLOCK_LIST` (Cairo-rendered rows blitted into EV_GRID). See `simple_narrate/specs/gui/style_spec.md` §7.
**Scope statement (Larry, 2026-08-21):** *"A simple_cairo that I can use for anything on a native Windows PC."* General-purpose 2D — one API that paints a window, writes a PNG, or lays out a PDF page. The narrate GUI is the forcing consumer, not the boundary of the ambition.

---

## 1. Baseline — evidence, not memory

```
/d/prod/ec.sh check -config simple_cairo.ecf -target simple_cairo_tests
→ System Recompiled. ✓ Syntax and type check passed          (2026-08-21)
```

v1.0.0, five classes, 1,566 source lines, 30 tests, `void_safety=all`,
SCOOP-capable, assertions all-on. Vendored `cairo.h` (full API) plus pdf/svg/ps/
win32/ft headers in `Clib/`, `cairo.lib` import library, `cairo.dll` at repo
root. All C lives as static functions in `Clib/simple_cairo.h` — the established
single-header pattern; **no separate `.c` files, preserved by this spec.**

### 1.1 Correction to the narrate style spec's assessment

`style_spec.md` §1 claimed *"grep extents returns nothing — you can draw a word;
you cannot measure one."* The grep was literal truth, substantively misleading:
**`text_width` and `text_height` exist** (`cairo_context.e:445,456` over
`sc_text_width` / `sc_text_height`, each calling `cairo_text_extents` and
returning one field).

What is actually missing is narrower and still blocking:

| For real text layout you need | Have |
|---|---|
| `x_advance` — where the pen goes next | ✗ (width ≠ advance) |
| full extents record (bearings, advances) | ✗ |
| `font_extents` — ascent, descent, line height | ✗ |
| antialias / hinting control for crisp small text | ✗ |
| clip (partial redraw), groups (flicker-free rows) | ✗ |
| dash patterns | ✗ (caps/joins exist) |
| `flush` / `mark_dirty` around raw `data` access | ✗ (and `data` exists — reading it without flush is undefined) |

⚠ **Why width is not advance:** `width` is ink coverage — it excludes trailing
whitespace entirely and shifts with bearings. A wrap loop that accumulates
`width` drifts a few pixels per word and cannot even see a space. The layout
number is `x_advance`. This single field is the difference between the wrap
loop working and almost-working.

---

## 2. Deliverables

Eight, each small. Contracts are the specification; bodies shown only where the
marshalling pattern is the point.

### D1 — `CAIRO_TEXT_EXTENTS` (new class)

Immutable value object over cairo's six-field extents record.

```eiffel
class CAIRO_TEXT_EXTENTS
create {CAIRO_CONTEXT} make_from_buffer

feature -- Access
    x_bearing: REAL_64      -- offset from origin to leftmost ink (may be negative)
    y_bearing: REAL_64      -- offset from baseline to topmost ink (typically negative)
    width:     REAL_64      -- ink width
    height:    REAL_64      -- ink height
    x_advance: REAL_64      -- pen advance after showing the text (THE layout number)
    y_advance: REAL_64      -- vertical advance (0 for horizontal scripts)

invariant
    non_negative_width:  width >= 0.0
    non_negative_height: height >= 0.0
    -- bearings and advances are deliberately unconstrained: negative is legal
    -- (RTL advances, left-overhanging glyphs).
```

### D2 — `CAIRO_FONT_EXTENTS` (new class)

```eiffel
class CAIRO_FONT_EXTENTS
create {CAIRO_CONTEXT} make_from_buffer

feature -- Access
    ascent:        REAL_64  -- baseline to top of tallest glyph
    descent:       REAL_64  -- baseline to bottom of lowest glyph (positive)
    height:        REAL_64  -- recommended line spacing
    max_x_advance: REAL_64
    max_y_advance: REAL_64

invariant
    non_negative_ascent:  ascent >= 0.0
    non_negative_descent: descent >= 0.0
    positive_height:      height > 0.0
```

`height` is the line-to-line distance; `ascent` places the first baseline;
`ascent + descent` sizes a caret. These three numbers are what `SV_BLOCK_EDITOR`
stands on.

### D3 — measurement on `CAIRO_CONTEXT`

One C call per measurement, marshalled through a `MANAGED_POINTER` the shim
fills. This is the struct-return pattern for the whole expansion:

```eiffel
text_extents (a_text: READABLE_STRING_GENERAL): CAIRO_TEXT_EXTENTS
        -- Full extents of `a_text` in the current font.
    require
        valid: is_valid
    local
        l_str: C_STRING
        l_buf: MANAGED_POINTER
    do
        create l_str.make (to_utf8 (a_text))
        create l_buf.make (48)                       -- 6 × REAL_64
        c_text_extents (handle, l_str.item, l_buf.item)
        create Result.make_from_buffer (l_buf)
    ensure
        result_attached: Result /= Void

font_extents: CAIRO_FONT_EXTENTS
        -- Metrics of the current font at the current size.
    require
        valid: is_valid
    -- same pattern, 40-byte buffer, 5 fields
```

`text_width` / `text_height` remain, re-expressed over `text_extents` so the
old and new paths cannot disagree:

```eiffel
text_width (a_text: READABLE_STRING_GENERAL): REAL_64
    do
        Result := text_extents (a_text).width
    ensure
        agrees: Result = text_extents (a_text).width
```

### D4 — antialias and hinting (fluent)

No `CAIRO_FONT_OPTIONS` class. The options object is created, applied, and
destroyed inside one shim call — three fluent features, zero new lifecycle for
the caller to get wrong:

```eiffel
set_antialias (a_mode: INTEGER): like Current           -- shapes and text
    require valid: is_valid
            known_mode: a_mode >= Antialias_default and a_mode <= Antialias_best

set_font_antialias (a_mode: INTEGER): like Current      -- text only
set_font_hint_style (a_style: INTEGER): like Current    -- grid fitting

feature -- Antialias Constants  (cairo enum values)
    Antialias_default: INTEGER = 0
    Antialias_none:    INTEGER = 1
    Antialias_gray:    INTEGER = 2
    Antialias_subpixel: INTEGER = 3
    Antialias_fast:    INTEGER = 4
    Antialias_good:    INTEGER = 5
    Antialias_best:    INTEGER = 6

feature -- Hint Style Constants
    Hint_style_default: INTEGER = 0
    Hint_style_none:    INTEGER = 1
    Hint_style_slight:  INTEGER = 2
    Hint_style_medium:  INTEGER = 3
    Hint_style_full:    INTEGER = 4
```

### D5 — clipping (fluent)

```eiffel
clip: like Current                 -- current path becomes the clip; path is consumed
clip_preserve: like Current        -- same, path kept
reset_clip: like Current
clip_rectangle (a_x, a_y, a_w, a_h: REAL_64): like Current
        -- Convenience: rectangle + clip in one call.
    require valid: is_valid
            positive_extent: a_w > 0.0 and a_h > 0.0

clip_extents: TUPLE [x1, y1, x2, y2: REAL_64]
        -- Bounding box of the current clip, user space.
    ensure ordered: Result.x2 >= Result.x1 and Result.y2 >= Result.y1
```

Decision: a `TUPLE`, not a rectangle class — Phase B introduces `CAIRO_RECT`
when patterns and path extents give it three users. One consumer does not
justify a class.

### D6 — groups (fluent)

```eiffel
push_group: like Current
        -- Redirect drawing to an intermediate surface.
    require valid: is_valid

pop_group_to_source: like Current
        -- End the group; the intermediate becomes the source pattern.
        -- Follow with `paint` to composite — the flicker-free row pattern:
        --   ctx.push_group ... draw row ... pop_group_to_source.paint
    require valid: is_valid
```

⚠ Not modelled in the type system: pop without push is a cairo status error,
not a crash; `status` reports it. A `group_depth` ghost counter with
`require group_open: group_depth > 0` is the honest contract — include it:
maintained in Eiffel (`push_group` increments, `pop_group_to_source`
decrements), `invariant group_depth_non_negative: group_depth >= 0`.

### D7 — dash (fluent)

```eiffel
set_dash (a_dashes: ARRAY [REAL_64]; a_offset: REAL_64): like Current
    require
        valid: is_valid
        has_segments: not a_dashes.is_empty
        all_non_negative: across a_dashes as d all d >= 0.0 end
        some_ink: across a_dashes as d some d > 0.0 end   -- all-zero is a cairo error

clear_dash: like Current
        -- Back to solid lines.
```

Marshalling: `MANAGED_POINTER` of `count × 8`, `put_real_64` loop, one shim call.

### D8 — surface flush / mark_dirty

```eiffel
flush: like Current
        -- Complete pending drawing. REQUIRED before reading `data`.
mark_dirty: like Current
        -- Declare external writes to `data`. REQUIRED after them.
```

Plus a header-comment correction on the existing `data` query naming the
flush-before-read rule. The blit in `sv_cairo_canvas.copy_surface_to_drawing_area`
reads `data` today — whether it flushes first gets checked during
implementation, and fixed there if not.

---

## 3. C shim additions (`Clib/simple_cairo.h`)

Same static-function, null-guarded style as the existing 63. New:

```c
sc_text_extents(cairo_t*, const char*, double out[6])   /* xb yb w h xa ya */
sc_font_extents(cairo_t*, double out[5])                /* asc desc h maxxa maxya */
sc_set_antialias(cairo_t*, int)
sc_set_font_antialias(cairo_t*, int)     /* options create/get/set/apply/destroy inside */
sc_set_font_hint_style(cairo_t*, int)    /* ditto */
sc_clip(cairo_t*)  sc_clip_preserve(cairo_t*)  sc_reset_clip(cairo_t*)
sc_clip_extents(cairo_t*, double out[4])
sc_push_group(cairo_t*)  sc_pop_group_to_source(cairo_t*)
sc_set_dash(cairo_t*, const double*, int, double)
sc_clear_dash(cairo_t*)                  /* cairo_set_dash(cr, NULL, 0, 0) */
sc_surface_flush(cairo_surface_t*)
sc_surface_mark_dirty(cairo_surface_t*)
```

Null pointers: no-op (out-buffers zeroed), matching house convention.

---

## 4. Out of scope — the phases that follow

| Phase | Content | Waits because |
|---|---|---|
| **B — compositing** | operators, masks, surface-as-source, patterns beyond gradients, `CAIRO_RECT` | narrate's row blit goes through EV_PIXMAP, not cairo→cairo |
| **C — surfaces & I/O** | PNG *read*, SVG surface, PS surface, recording surface, **Win32/HDC surface** (draw straight into a live window — the fullest form of "anything on Windows") | nothing in Layer 1 consumes them yet |
| **D — text beyond the toy API** | glyph-level control, `show_text_glyphs`. **Pango is a stated non-goal** — its glib dependency tree contradicts the single-DLL deployment | toy API + extents serves Latin-script UI text |
| **E — geometry** | matrix get/set, device↔user mapping, path introspection | |
| **F — harden & ship** | X-series assault, mutation pass, docs, release | after A–E land |

Each phase gets its own S-doc when its consumer exists. That is the standing
rule this library was nearly a victim of: **wrap what a consumer proves it
needs.**

---

## 5. Testing plan

Per the ecosystem standard: `TEST_SET_BASE` sets driven by `TEST_APP`, run from
`ec.sh test`'s F_code binary. Everything below is **headless** — an
`ARGB32` surface plus `data`/`stride` reads is a complete assertion substrate;
no window is ever needed. (One endianness note: ARGB32 pixels read as
`NATURAL_32` are `0xAARRGGBB` on little-endian Windows.)

**Measurement**
- non-empty ASCII: `width > 0`, `x_advance > 0`
- `"ab"` advance > `"a"` advance (monotonic)
- `"a "` (trailing space): `x_advance > width` — ★ the width-is-not-advance
  proof, pinned as a test so the distinction can never silently regress
- empty string: all six fields zero
- determinism: two calls, equal records
- `font_extents` after `select_font`: `ascent > 0`, `height > 0`
- old-vs-new agreement: `text_width (s) = text_extents (s).width`

**Clip** — paint white; `clip_rectangle (5,5,10,10)`; paint red; `flush`; assert
pixel (10,10) red and (2,2) white via `data`. Then `reset_clip`; assert
`clip_extents` = full surface.

**Groups** — `push_group`, paint red, `pop_group_to_source`, `paint` → pixel
red. Contract test: `pop_group_to_source` without push violates
`group_open`.

**Dash** — solid line vs `set_dash (<<4.0, 4.0>>, 0)`: dashed row has strictly
fewer inked pixels; `clear_dash` restores solid count.

**Antialias** — diagonal line with `Antialias_none`: edge row contains exactly
two distinct pixel values; default: more than two.

**Contract violations** — each new `require` exercised from the failing side
(`assert_violates_precondition`), including `set_dash` all-zero and
`clip_rectangle` zero-extent.

**★ The acceptance test is the consumer's loop.** `test_wrap_loop` implements
the actual `SV_BLOCK_EDITOR` algorithm against the new API — accumulate
`x_advance` per word, break at 200 px, place lines at `font_extents.height` —
and asserts every produced line's advance sum ≤ 200 and line count > 1 for a
known sentence. When this test is green, "usable for simple_narrate" is a fact
with a name, not a feeling.

---

## 6. Definition of done

1. `ec.sh check` then `ec.sh test -config simple_cairo.ecf -target
   simple_cairo_tests` — all existing 30 tests still green, all new tests green,
   output pasted into the work log. Compilation is the gate; nothing is claimed
   without it.
2. `test_wrap_loop` green (§5's acceptance).
3. CHANGELOG entry; version to 1.1.0.
4. Pushed to `simple-eiffel/simple_cairo`; `oracle-cli` handoff updated; any
   new failure pattern recorded as a gotcha before moving on.
