note
	description: "[
		CAIRO_SURFACE - Wrapper for cairo_surface_t.

		Represents an image surface for Cairo drawing operations.
		Supports PNG output and raw pixel access.

		Usage:
			local
				surface: CAIRO_SURFACE
			do
				create surface.make (800, 600)
				-- ... draw with context ...
				surface.write_png ("output.png")
				surface.destroy
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_SURFACE

create
	make, make_with_format, make_from_handle, make_for_dc, make_from_png, make_similar

feature {NONE} -- Initialization

	make (a_width, a_height: INTEGER)
			-- Create ARGB32 surface.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			handle := c_surface_create (a_width, a_height)
		ensure
			handle_set: handle /= default_pointer implies is_valid
		end

	make_with_format (a_format, a_width, a_height: INTEGER)
			-- Create surface with specified format.
		require
			valid_format: a_format >= 0 and a_format <= 3
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			handle := c_surface_create_format (a_format, a_width, a_height)
		ensure
			handle_set: handle /= default_pointer implies is_valid
		end

	make_for_dc (a_hdc: POINTER)
			-- Phase C-1: surface that paints straight onto a Windows device
			-- context. Caller owns the HDC; destroy this surface before
			-- releasing the DC. Owned (not shared): destroy really destroys.
		require
			dc_not_null: a_hdc /= default_pointer
		do
			handle := c_win32_surface_create (a_hdc)
		ensure
			owned: not is_shared
		end

	make_from_png (a_path: READABLE_STRING_GENERAL)
			-- Load a PNG file into a new image surface.
		require
			path_not_empty: not a_path.is_empty
		local
			s: C_STRING
		do
			create s.make (a_path.to_string_8)
			handle := c_surface_from_png (s.item)
		end

	make_similar (a_other: CAIRO_SURFACE; a_content, a_width, a_height: INTEGER)
			-- Surface compatible with a_other. Content: Content_color,
			-- Content_alpha or Content_color_alpha.
		require
			other_valid: a_other.is_valid
			positive: a_width > 0 and a_height > 0
		do
			handle := c_surface_similar (a_other.handle, a_content, a_width, a_height)
		ensure
			owned: not is_shared
		end

	make_from_handle (a_handle: POINTER)
			-- Create wrapper around existing cairo_surface_t.
			-- Used by CAIRO_PDF_SURFACE to provide compatible interface.
		require
			valid_handle: a_handle /= default_pointer
		do
			handle := a_handle
			is_shared := True
		ensure
			handle_set: handle = a_handle
			is_shared: is_shared
		end

feature -- Access

	handle: POINTER
			-- Underlying cairo_surface_t pointer.

	is_shared: BOOLEAN
			-- Is this a shared handle (don't destroy on cleanup)?

	width: INTEGER
			-- Surface width in pixels.
		require
			valid: is_valid
		do
			Result := c_surface_width (handle)
		ensure
			positive: Result > 0
		end

	height: INTEGER
			-- Surface height in pixels.
		require
			valid: is_valid
		do
			Result := c_surface_height (handle)
		ensure
			positive: Result > 0
		end

	stride: INTEGER
			-- Bytes per row.
		require
			valid: is_valid
		do
			Result := c_surface_stride (handle)
		end

	data: POINTER
			-- Raw pixel data pointer.
			-- Call `flush' before reading through this pointer and
			-- `mark_dirty' after writing through it - cairo requires both.
		require
			valid: is_valid
		do
			Result := c_surface_data (handle)
		end

feature -- Content Constants

	Content_color: INTEGER = 0x1000
	Content_alpha: INTEGER = 0x2000
	Content_color_alpha: INTEGER = 0x3000

feature -- Device

	device: detachable CAIRO_DEVICE
			-- Backing device, when the surface type has one (image surfaces
			-- return Void). Non-owning view.
		require
			valid: is_valid
		local
			h: POINTER
		do
			h := c_surface_device (handle)
			if h /= default_pointer then
				create Result.make_shared (h)
			end
		end

feature -- Geometry

	set_device_offset (a_x, a_y: REAL_64): like Current
		require
			valid: is_valid
		do
			c_surface_set_device_offset (handle, a_x, a_y)
			Result := Current
		end

	device_offset: TUPLE [x, y: REAL_64]
		require
			valid: is_valid
		local
			b: MANAGED_POINTER
		do
			create b.make (16)
			c_surface_get_device_offset (handle, b.item)
			Result := [b.read_real_64 (0), b.read_real_64 (8)]
		end

	set_device_scale (a_x, a_y: REAL_64): like Current
		require
			valid: is_valid
			positive: a_x > 0.0 and a_y > 0.0
		do
			c_surface_set_device_scale (handle, a_x, a_y)
			Result := Current
		end

	device_scale: TUPLE [x, y: REAL_64]
		require
			valid: is_valid
		local
			b: MANAGED_POINTER
		do
			create b.make (16)
			c_surface_get_device_scale (handle, b.item)
			Result := [b.read_real_64 (0), b.read_real_64 (8)]
		end

feature -- Diagnostics

	status_message: STRING_32
			-- Human-readable form of status (cairo_status_to_string).
		local
			c: C_STRING
		do
			create c.make_by_pointer (c_status_string (status))
			Result := c.string.to_string_32
		end

feature -- Synchronization

	finish: like Current
			-- Finish the surface: flush the document to its file (SVG, PDF)
			-- and drop external resources. Drawing afterwards is an error.
		require
			valid: is_valid
		do
			c_surface_finish (handle)
			Result := Current
		end


	flush: like Current
			-- Complete pending drawing. Required before reading `data'.
		require
			valid: is_valid
		do
			c_surface_flush (handle)
			Result := Current
		end

	mark_dirty: like Current
			-- Declare external writes through `data'. Required after them.
		require
			valid: is_valid
		do
			c_surface_mark_dirty (handle)
			Result := Current
		end

feature -- Status

	is_valid: BOOLEAN
			-- Is surface valid for drawing?
		do
			Result := handle /= default_pointer and then c_surface_status (handle) = 0
		end

	status: INTEGER
			-- Surface status code (0 = OK).
		do
			if handle /= default_pointer then
				Result := c_surface_status (handle)
			else
				Result := -1
			end
		end

feature -- Output

	write_png (a_filename: READABLE_STRING_GENERAL): BOOLEAN
			-- Write surface to PNG file.
		require
			valid: is_valid
			filename_not_empty: not a_filename.is_empty
		local
			l_filename: C_STRING
		do
			create l_filename.make (a_filename.to_string_8)
			Result := c_surface_write_png (handle, l_filename.item) = 0
		end

feature -- Disposal

	destroy
			-- Release surface resources.
			-- Does nothing if surface is shared (created via make_from_handle).
		do
			if handle /= default_pointer and not is_shared then
				c_surface_destroy (handle)
				handle := default_pointer
			elseif is_shared then
				handle := default_pointer
			end
		ensure
			destroyed: handle = default_pointer
		end

feature {NONE} -- C Externals

	c_surface_create (a_width, a_height: INTEGER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_create($a_width, $a_height);"
		end

	c_surface_create_format (a_format, a_width, a_height: INTEGER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_create_format($a_format, $a_width, $a_height);"
		end

	c_surface_destroy (a_surface: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_destroy((cairo_surface_t*)$a_surface);"
		end

	c_surface_width (a_surface: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_width((cairo_surface_t*)$a_surface);"
		end

	c_surface_height (a_surface: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_height((cairo_surface_t*)$a_surface);"
		end

	c_surface_stride (a_surface: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_stride((cairo_surface_t*)$a_surface);"
		end

	c_surface_data (a_surface: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_data((cairo_surface_t*)$a_surface);"
		end

	c_surface_write_png (a_surface, a_filename: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_write_png((cairo_surface_t*)$a_surface, (const char*)$a_filename);"
		end

	c_surface_status (a_surface: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_status((cairo_surface_t*)$a_surface);"
		end

	c_surface_flush (a_surface: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_flush((cairo_surface_t*)$a_surface);"
		end

	c_surface_mark_dirty (a_surface: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_mark_dirty((cairo_surface_t*)$a_surface);"
		end

	c_win32_surface_create (a_hdc: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_win32_surface_create($a_hdc);"
		end

	c_surface_from_png (a_path: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_from_png((const char*)$a_path);"
		end

	c_surface_similar (a_other: POINTER; a_content, a_w, a_h: INTEGER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_similar((cairo_surface_t*)$a_other, $a_content, $a_w, $a_h);"
		end

	c_surface_finish (a_surface: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_finish((cairo_surface_t*)$a_surface);"
		end

	c_surface_set_device_offset (a_surface: POINTER; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_set_device_offset((cairo_surface_t*)$a_surface, $a_x, $a_y);"
		end

	c_surface_get_device_offset (a_surface, a_xy: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_get_device_offset((cairo_surface_t*)$a_surface, (double*)$a_xy);"
		end

	c_surface_set_device_scale (a_surface: POINTER; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_set_device_scale((cairo_surface_t*)$a_surface, $a_x, $a_y);"
		end

	c_surface_get_device_scale (a_surface, a_xy: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_get_device_scale((cairo_surface_t*)$a_surface, (double*)$a_xy);"
		end

	c_surface_device (a_surface: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_device((cairo_surface_t*)$a_surface);"
		end

	c_status_string (a_s: INTEGER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return (void*)sc_status_string($a_s);"
		end

invariant
	destroyed_implies_null: not is_valid implies handle = default_pointer

end
