# cairo for Windows: the fleet's one set

These seven DLLs are cairo 1.18.0 and the libraries it loads, the x64 build from the
**poppler-windows 24.08.0** release (built from conda-forge packages), byte for byte the
set simple_pdf shipped in its `bin` folder. Under Larry's rule (2026-11-11, BUILD_STANDARDS
section 9 in claude_eiffel_op_docs) simple_cairo **owns** them: every simple_* library that
needs cairo or any of these takes them from here, never carries its own copy, and the build
wrapper (`ec.sh`) copies this folder beside each Windows executable that depends on
simple_cairo.

| File | Version | Bytes | SHA-256 (first 16) | License |
|---|---|---|---|---|
| `cairo.dll` | 1.18.0 | 1,016,320 | `c690978c5be8486d` | LGPL 2.1 or MPL 1.1 (`cairo-COPYING*`) |
| `fontconfig-1.dll` | 2.14.2 | 282,624 | `cfce15422bcf0fce` | MIT-style (`fontconfig-COPYING`) |
| `freetype.dll` | 2.12.1 | 670,720 | `f878121d560f43c3` | FreeType License (`freetype-LICENSE.TXT`, `freetype-FTL.TXT`) |
| `libexpat.dll` | 2.6.3 | 402,432 | `1eef16676ab7cabc` | MIT (`expat-COPYING`) |
| `libpng16.dll` | 1.6.44 | 196,608 | `54789e18aceb43b5` | libpng license (`libpng-LICENSE`) |
| `pixman-1-0.dll` | 0.43.4 | 592,896 | `3686735bc0d04989` | MIT (`pixman-COPYING`) |
| `zlib.dll` | 1.3.1 | 89,088 | `7d86de8659d728d0` | zlib license (`zlib-LICENSE`) |

- **Versions** were read from the DLLs themselves at run time (`cairo_version_string`,
  `FcGetVersion`, `FT_Library_Version`, `pixman_version_string`, `png_get_libpng_ver`,
  `XML_ExpatVersion`, `zlibVersion`), loading this folder alone.
- **Headers** in `Clib/` are cairo 1.18.0's, from the release tarball (SHA-256
  `243a0736b978a33dee29f9cca7521733b78a65b5418206fef7bd1c3d4cf10b64`, as published).
  `Clib/cairo-features.h` is written from this cairo.dll's exports; the script interpreter
  is the one 1.17.2 feature this build lacks, and no simple_* library uses it.
- **`lib/cairo.lib`** is the import library generated from this cairo.dll's 415 exports
  (Visual Studio `lib /def`).
- **Licenses:** each library's own, at its version, in `licenses/`, fetched from the
  project's source at that release (cairo's from the 1.18.0 tarball). simple_cairo's own
  Eiffel code stays MIT; these DLLs are linked dynamically and can be replaced.
- **fontconfig** needs a configuration only when cairo's FreeType font path is used; the
  Windows font path (what simple_* draws text through) does not touch it.
- **Linux and macOS** keep the system's cairo through pkg-config (Ubuntu 1.18.0, Homebrew
  1.18.6); nothing here is used there.

Replacing any file here is a fleet change: run the DLL inventory first, then simple_cairo's
`test_loaded_cairo_is_the_fleet_build`, and every dependent's suite.
