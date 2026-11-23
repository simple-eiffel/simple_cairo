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
| `freetype.dll` | 2.14.3 | 684,032 | `7a7fb5cf51bfab4f` | FreeType License (`freetype-LICENSE.TXT`, `freetype-FTL.TXT`) |
| `libexpat.dll` | 2.9.0 | 274,432 | `05997b58cea2c628` | MIT (`expat-COPYING`) |
| `libpng16.dll` | 1.6.59 | 198,656 | `d4547a7b9f58e452` | libpng license (`libpng-LICENSE`) |
| `pixman-1-0.dll` | 0.43.4 | 592,896 | `3686735bc0d04989` | MIT (`pixman-COPYING`) |
| `zlib.dll` | 1.3.1 | 89,088 | `7d86de8659d728d0` | zlib license (`zlib-LICENSE`) |

- **freetype.dll 2.14.3 (2026-11-22)** replaced poppler-windows' 2.12.1, which has CVE-2025-27363
  (an out-of-bounds write on crafted font files, on CISA's exploited list; fixed in 2.13.3). It is
  conda-forge `libfreetype6-2.14.3-hdbac1cb_2` (the source poppler-windows builds from; package
  SHA-256 `cbc650854003e434d4ff6c7b1a2667e38a4242ad8a391a1c5ff89721624065ce`, as published). Same
  imports (zlib.dll, libpng16.dll, and nothing from them that 1.3.1 and 1.6.44 lack), 220 exports
  covering all 33 cairo.dll and 22 fontconfig-1.dll call. `test_loaded_freetype_is_the_fleet_build`
  pins it.
- **libexpat.dll 2.9.0 and libpng16.dll 1.6.59 (2026-11-23)** replaced poppler-windows' 2.6.3
  and 1.6.44. Expat's `Changes` lists 33 CVEs fixed after 2.6.3; libpng's `CHANGES` lists 12
  after 1.6.44, seven rated high (CVE-2025-64720, CVE-2025-65018, CVE-2025-66293,
  CVE-2026-25646, CVE-2026-33416, CVE-2026-33636 among them). They are conda-forge
  `libexpat-2.9.0-hac47afa_0` and `libpng-1.6.59-hdc8cecf_0` (package SHA-256
  `d4a8e5aac8999a90cd71aa6f9f5c40d8594ed2b89cd7f898f997767ecc6cd52d` and
  `36050852deae6edc98d7b71489b8d07254e2753c69bd524bf5784927cd1f0b2c`, as published). Neither
  drops an export (expat 69 to 83, libpng 246 to 256). fontconfig-1.dll imports Expat **by
  ordinal**; all 11 ordinals name the same functions in 2.9.0. libpng's 10 zlib imports are all
  in zlib 1.3.1. libexpat now needs VCRUNTIME140.dll (memcpy and the like), which libpng and
  freetype already needed. `test_loaded_expat_is_the_fleet_build` and
  `test_loaded_libpng_is_the_fleet_build` pin them (both fail on the old files).
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
