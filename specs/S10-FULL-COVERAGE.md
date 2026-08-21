# S10: FULL COVERAGE PLAN - simple_cairo

**Status:** FORWARD SPEC — master plan superseding S09 §4's wait-for-consumer pacing
**Date:** 2026-08-21
**Decision (Larry):** *"Let's go ALL THE WAY … we want full Eiffel access to Cairo."*
**North star (Larry, same day):** *"Something like Eiffel Vision 2 gave the 1990s folks, but a 2026 version where the API is high-level and hides a lot of boilerplate so that 80–90% of GUI job needs are present and accounted for, ready to be used."*

---

## 1. Why the consumer rule does not block this

S09 §4 held each phase until a consumer demanded it. That rule guards against
*speculative API invention* — the `simple_voice` failure, an API designed with
no ground truth. It does not bite here: **`cairo.h` is the ground truth.** Full
coverage means implementing a stable, exhaustively documented, twenty-year-old
contract, not guessing at one. The pacing changes; the discipline does not —
**every phase still lands as its own gated commit** (`ec.sh check`, `ec.sh
test`, suite run, output pasted).

And the coverage now has a destination: full Cairo is **the foundation layer of
the 2026 toolkit**. The toolkit itself lives in `simple_vision` and gets its own
research-and-spec cycle once the foundation is done; its 80–90% claim will be
defined there as a checklist (windows, dialogs, layout, the full input-widget
set, lists/trees/grids, menus/toolbars/status, styled text editing, theming,
async workers), not as a slogan.

---

## 2. Build evidence

Vendored headers: **cairo 1.17.2**. `cairo-features.h` — every flag on:

```
WIN32_SURFACE  WIN32_FONT  PNG_FUNCTIONS  SCRIPT_SURFACE  FT_FONT
PS_SURFACE  PDF_SURFACE  SVG_SURFACE  IMAGE_SURFACE  MIME_SURFACE
RECORDING_SURFACE  OBSERVER_SURFACE  USER_FONT  INTERPRETER
```

336 `cairo_public` functions in `cairo.h`, plus the pdf/svg/ps/win32 headers.
`cairo.lib` + `cairo.dll` (2.36 MB) in-repo. Baseline after Layer 0: v1.1.0,
48/48 tests green.

---

## 3. Coverage inventory

| API family | Now (v1.1.0) | Phase |
|---|---|---|
| Context lifecycle, save/restore, status | ✓ | — |
| Colors, sources (solid via set_color) | ✓ | — |
| Paths: move/line/curve/arc/rect/rounded/close | ✓ (`arc_negative` shim unexposed — **B closes**) | — |
| Stroke/fill/paint/clear + convenience shapes | ✓ | — |
| Line width/cap/join, **dash** | ✓ | — |
| Transforms translate/scale/rotate/identity | ✓ | — |
| Toy text + **full measurement** | ✓ (S09) | — |
| **Quality**: antialias, font AA, hinting | ✓ (S09) | — |
| **Clip**, **groups**, surface **flush/mark_dirty** | ✓ (S09) | — |
| Gradients linear/radial + stops | ✓ | B re-parents |
| **Operators** (29), get/set | — | **B** |
| **Patterns**: base class, solid, surface, extend/filter | — | **B** |
| **Mesh gradients** (coons/gouraud) | — | **B** |
| **Masks** (pattern + surface) | — | **B** |
| set_source_surface | — | **B** |
| PNG **read**; create_similar / similar_image; device offset+scale | — | **C** |
| **SVG / PS / recording / script** surfaces | — (PDF ✓) | **C** |
| **Win32 surface (HDC)** — draw into a live window | — | **C** |
| copy_page / show_page generalized; status_to_string; version query | — | **C** |
| **CAIRO_MATRIX** + get/set/transform; user↔device mapping | — | **D** |
| Path introspection (copy_path, iterate, append); path/fill/stroke extents; **in_fill / in_stroke hit tests**; rel_* moves; current point; fill rule; tolerance; miter; getters | — | **D** |
| Font faces (toy, get/set), scaled fonts + their extents; **glyph API**; `CAIRO_FONT_OPTIONS` first-class incl. **variations** (variable fonts, 1.16+); **Win32 LOGFONTW faces** (private fonts by handle) | — | **E** |
| Harden, docs site, naming pass, release | — | **F** |

## 4. Exclusions — each with its reason, none silent

| Excluded | Why |
|---|---|
| Everything in `cairo-deprecated.h` | deprecated upstream |
| FreeType font API (`cairo-ft.h`) | requires FreeType headers/libs we do not vendor; `WIN32_FONT` covers native needs including private fonts via LOGFONTW |
| User fonts, surface observers | C-callback surfaces — trampolines into Eiffel objects; revisit when a consumer exists |
| MIME data attachment | destroy-notify callback lifetime; revisit with a PDF-embedding consumer |
| cairo-script **interpreter** | separate library, not in `cairo.dll` (script *surface* output IS in scope, Phase C) |

## 5. Version arc and definition of done

B → 1.2.0, C → 1.3.0, D → 1.4.0, E → 1.5.0, F → **2.0.0** release.

Per phase: `ec.sh check` clean (grep for `Error code` — the wrapper's checkmark
lies), `ec.sh test` builds F_code, full suite green with new tests, output
pasted, CHANGELOG entry, push, oracle log. Contract-violation tests per phase
keep proving assertions are live.

---

## 6. Beyond parity — the innovation charter

*(Larry, 2026-08-21: "And then — there is the beyond innovation.")*

Parity with 2026 toolkits is the floor. The ceiling is what only a
contract-first language can offer, and the seeds are already proven in this
ecosystem's own work this week:

| Innovation | Proven where |
|---|---|
| **Definitional state** — widget state *defined* by invariants, so stale-state bugs are unrepresentable, not merely handled | `approval_is_definitional`, narrate spec §18.1 |
| **Self-explaining controls** — a disabled control carries *why* as a first-class query, never a bare grey | `is_publishable` / Publish-names-its-blocker, §18.8 |
| **Accessibility as invariant** — theme pairs that cannot ship illegible; contrast checked by the class, not a linter | `tint_pair_legible`, style spec §4; caught a real 1.02:1 defect |
| **Headless-testable GUIs by construction** — every widget renders to an image surface and is pixel-assertable in CI, no window, no bot | this library's own test suite, 48/48 green headless |
| **Contract/validation split** — programmer errors vs content errors, formalized so release builds never silently lose gates | narrate §18.8 |
| **SCOOP-native workers** — UI responsiveness by the processor model, not by discipline | ecosystem standard, `concurrency=scoop` everywhere |

These go into the toolkit's own spec as requirements, not aspirations. This
file only refuses to let them be forgotten.

### 6.1 Toolkit architecture — Larry's three questions, parked answers

*(2026-08-21: tunable control fleet? control families? controls that control
controls?)* The answer the toolkit spec starts from is **all three, layered**:

1. **A small primitive fleet, heavily tunable** (~10 primitives: pressable,
   text run, text input, canvas, scroller, virtual list, split, image).
   Tuning = tokens globally + fluent contract-guarded setters per instance.
   Proof it suffices: the reference render's chips, toolbar buttons, and
   Publish blocker are one pressable wearing different tokens.
2. **Families as thin specializations, never re-implementations** — a spin box
   IS a text input + two pressables + a numeric-validation contract. Families
   exist to give callers vocabulary (the ecosystem's semantic-frame rules,
   applied to widgets).
3. **Composites are first-class, with one law: controls never wire to each
   other — they meet in a MODEL, and the model's invariants coordinate them.**
   A drawing toolbar does not set the canvas's pen; both bind to a
   DRAWING_MODEL where pen width is one contracted fact. This is
   approval_is_definitional generalized into the toolkit's architecture.

Innovation sourcing: the toolkit spec's research phase includes a deliberate
web sweep (declarative/reactive models a la SwiftUI/Compose, fine-grained
signals, GPU-first renderers, accessibility trees, live theming) — sussed
*against* the §6 DbC list, not adopted as fashion.

---

## 7. Milestone M1 — the reference render, drawn by Eiffel  ★ *reached 2026-08-21*

Acceptance target (Larry): *"let me know when simple_cairo is capable of making
the PIL->PNG-ish GUI that was drawn for simple_narrate."*

**Reached the same day, after S09 + Phase B.** `demo/demo_app.e`
(target `simple_cairo_demo`) draws the full simple_narrate editor window —
toolbar, map rail, four block cards with split-preview tints and caret, detail
panel, status strip — headless to `demo_editor_window.png` at 2960×1720, in the
real Archivo/Literata/Plex faces via a demo-local `FR_PRIVATE` load. Two run
configurations, outputs recorded verbatim in `demo/RUN_LOG.md`, PNGs committed.

The binding capability was S09's `x_advance`; nothing in the reference needed
Phases C–E. Which sharpens what C–E are *for*: not this picture, but live
windows (Win32/HDC), documents (SVG/PS/recording), geometry, and glyph-level
text.

### 7.1 Milestone M2 — the interactive editor, pure Win32  ★ *reached and ACCEPTED 2026-08-21*

Larry's gate: *"If we can prove that with an interactive GUI demo that I can
operate as a user, then we can open the gate to simple_narrate's GUI."* And his
directive on the route: *"Phase C's Win32/HDC surface as the 'no Vision2 at
all' pure route."*

Delivered the same day: `spike_gui/` — an inline-C Win32 window (no Vision2
anywhere) running the SV_BLOCK_EDITOR interaction model live: click-to-caret,
typing with re-wrap, arrows with column memory, per-character split tints,
Enter-split, Esc-reset, private faces. Blit = Phase C-1's `make_for_dc`.

Telemetry from Larry's own session: **1,819 frames, avg 6.3 ms; worst edit
frame 8.8 ms** — half a 60 Hz budget, from a deliberately naive renderer (no
glyph cache, no partial redraw). Accepted by Larry in as many words
("yeah man ... THAT does it!!!"). **The gate to simple_narrate's GUI is open**,
and the pure route is the presumptive architecture for the 2026 toolkit — its
research cycle should treat scrollbars, focus/IME, and accessibility as the
hard problems, not rendering or latency.
