# Bundled Cairo for Windows

`cairo.dll` (repository root) and `lib/cairo.lib` are the x64 build from the
**cairo-windows 1.17.2** package, byte for byte:

| File | MD5 |
|---|---|
| `cairo.dll` | `0e1b421edb864ea340474935eee2a3b5` |
| `lib/cairo.lib` | `907d6217950d9d80e4353feec0cdb696` |

- **Cairo version:** 1.17.2. It matches the headers in `Clib/`.
- **Built in statically:** pixman, FreeType, libpng and zlib.
- **What the DLL imports:** only GDI32, MSIMG32, USER32 and KERNEL32, so no other DLL has to travel with it.
- **Why it's bundled:** so a Windows checkout builds and runs without a separate Cairo install. On Linux and macOS, simple_cairo uses the system's Cairo, through pkg-config, and these files are not used.

## License

Cairo is free software. Each file may be used under either the GNU Lesser General Public
License 2.1 or the Mozilla Public License 1.1. See `cairo-COPYING`,
`cairo-COPYING-LGPL-2.1` and `cairo-COPYING-MPL-1.1` in this folder. simple_cairo's own
Eiffel code stays under the MIT license. The DLL is linked dynamically and can be
replaced by any compatible cairo.dll.

## Known defect

This DLL cannot write PDF: `cairo_show_page` on a PDF surface fails with
CAIRO_STATUS_NO_MEMORY. CHANGELOG.md has the details. PNG, SVG, image surfaces and the Windows
printing surface work. A rebuilt DLL will replace it.
