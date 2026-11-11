# lib/

`cairo.lib` is the x64 import library for the cairo 1.18.0 in `../runtime/windows/`,
generated from that DLL's exports. The DLLs, their versions, checksums, licenses and
provenance are in `../runtime/windows/README.md`.

Before 2026-11-11 this folder held cairo 1.17.2 (the cairo-windows package): it could not
write PDF (cairo_show_page failed with CAIRO_STATUS_NO_MEMORY) and collapsed glyphs at the
HFONT's own size under the default antialias mode. 1.18.0 fixes both.
