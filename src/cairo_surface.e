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
	make, make_with_format, make_from_handle

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
		require
			valid: is_valid
		do
			Result := c_surface_data (handle)
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

invariant
	destroyed_implies_null: not is_valid implies handle = default_pointer

end
