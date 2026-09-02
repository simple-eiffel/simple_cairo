note
	description: "[
		SIMPLE_CAIRO - Facade for Cairo 2D graphics library.

		Provides simplified access to Cairo for vector graphics, gradients,
		text rendering, and waveform visualization.

		Usage:
			local
				cairo: SIMPLE_CAIRO
				surface: CAIRO_SURFACE
				ctx: CAIRO_CONTEXT
			do
				create cairo.make
				surface := cairo.create_surface (800, 600)
				ctx := cairo.create_context (surface)

				ctx.set_color_hex (0x3498DB)
				ctx.fill_rect (10, 10, 100, 50)

				surface.write_png ("output.png")
				ctx.destroy
				surface.destroy
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_CAIRO

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize Cairo wrapper.
		do
			last_error := ""
		ensure
			no_error: last_error.is_empty
		end

feature -- Surface Creation

	create_surface (a_width, a_height: INTEGER): CAIRO_SURFACE
			-- Create an ARGB32 image surface.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			create Result.make (a_width, a_height)
			if not Result.is_valid then
				last_error := "Failed to create surface"
			else
				last_error := ""
			end
		ensure
			result_exists: Result /= Void
		end

	create_surface_format (a_format, a_width, a_height: INTEGER): CAIRO_SURFACE
			-- Create surface with specified format.
			-- Formats: 0=ARGB32, 1=RGB24, 2=A8, 3=A1
		require
			valid_format: a_format >= 0 and a_format <= 3
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			create Result.make_with_format (a_format, a_width, a_height)
			if not Result.is_valid then
				last_error := "Failed to create surface"
			else
				last_error := ""
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Context Creation

	create_context (a_surface: CAIRO_SURFACE): CAIRO_CONTEXT
			-- Create drawing context for surface.
		require
			surface_valid: a_surface.is_valid
		do
			create Result.make (a_surface)
			if not Result.is_valid then
				last_error := "Failed to create context"
			else
				last_error := ""
			end
		ensure
			result_exists: Result /= Void
		end

feature -- Gradient Creation

	linear_gradient (a_x0, a_y0, a_x1, a_y1: REAL_64): CAIRO_GRADIENT
			-- Create linear gradient from (x0,y0) to (x1,y1).
		do
			create Result.make_linear (a_x0, a_y0, a_x1, a_y1)
		ensure
			result_exists: Result /= Void
		end

	radial_gradient (a_cx0, a_cy0, a_r0, a_cx1, a_cy1, a_r1: REAL_64): CAIRO_GRADIENT
			-- Create radial gradient between two circles.
		require
			valid_r0: a_r0 >= 0
			valid_r1: a_r1 >= 0
		do
			create Result.make_radial (a_cx0, a_cy0, a_r0, a_cx1, a_cy1, a_r1)
		ensure
			result_exists: Result /= Void
		end

	vertical_gradient (a_y0, a_y1: REAL_64): CAIRO_GRADIENT
			-- Create vertical linear gradient (top to bottom).
		do
			Result := linear_gradient (0, a_y0, 0, a_y1)
		end

	horizontal_gradient (a_x0, a_x1: REAL_64): CAIRO_GRADIENT
			-- Create horizontal linear gradient (left to right).
		do
			Result := linear_gradient (a_x0, 0, a_x1, 0)
		end

feature -- Pattern Creation

	solid_pattern (a_r, a_g, a_b: REAL_64): CAIRO_SOLID_PATTERN
			-- Opaque solid-color pattern.
		require
			valid_r: a_r >= 0.0 and a_r <= 1.0
			valid_g: a_g >= 0.0 and a_g <= 1.0
			valid_b: a_b >= 0.0 and a_b <= 1.0
		do
			create Result.make_rgb (a_r, a_g, a_b)
		ensure
			result_exists: Result /= Void
		end

	solid_pattern_rgba (a_r, a_g, a_b, a_a: REAL_64): CAIRO_SOLID_PATTERN
			-- Translucent solid-color pattern.
		require
			valid_r: a_r >= 0.0 and a_r <= 1.0
			valid_g: a_g >= 0.0 and a_g <= 1.0
			valid_b: a_b >= 0.0 and a_b <= 1.0
			valid_a: a_a >= 0.0 and a_a <= 1.0
		do
			create Result.make_rgba (a_r, a_g, a_b, a_a)
		ensure
			result_exists: Result /= Void
		end

	surface_pattern (a_surface: CAIRO_SURFACE): CAIRO_SURFACE_PATTERN
			-- Pattern that paints with `a_surface'.
		require
			surface_valid: a_surface.is_valid
		do
			create Result.make_from_surface (a_surface)
		ensure
			result_exists: Result /= Void
		end

	mesh_pattern: CAIRO_MESH_PATTERN
			-- Empty mesh gradient; add patches with begin_patch ... end_patch.
		do
			create Result.make
		ensure
			result_exists: Result /= Void
		end

feature -- Glyph Painting (Phase D - S07)

	font_face_for_hfont (a_hfont: POINTER): CAIRO_FONT_FACE
			-- Font face over a Windows HFONT, for painting shaped runs.
			-- SAME-N (D-S03 / DR-009): cairo ignores the LOGFONT height
			-- behind the HFONT - CAIRO_CONTEXT.set_font_size governs.
			-- A null or unusable HFONT yields an invalid face, not an
			-- exception; check `Result.is_valid'.
		do
			create Result.make_for_hfont (a_hfont)
			if not Result.is_valid then
				last_error := "Failed to create font face"
			else
				last_error := ""
			end
		ensure
			result_exists: Result /= Void
		end

	font_face_for_logfontw_hfont (a_logfontw, a_hfont: POINTER): CAIRO_FONT_FACE
			-- Font face over an HFONT plus the LOGFONTW it was made from.
			-- The constructor a shaper wants: it saves cairo a GetObjectW
			-- round trip and keeps the description authoritative.
		do
			create Result.make_for_logfontw_hfont (a_logfontw, a_hfont)
			if not Result.is_valid then
				last_error := "Failed to create font face"
			else
				last_error := ""
			end
		ensure
			result_exists: Result /= Void
		end

	glyph_array (a_count: INTEGER): CAIRO_GLYPH_ARRAY
			-- Zeroed room for `a_count' glyphs, to fill with ids and
			-- absolute positions and hand to CAIRO_CONTEXT.show_glyph_array.
		require
			count_not_negative: a_count >= 0
		do
			create Result.make (a_count)
			last_error := ""
		ensure
			result_exists: Result /= Void
			count_set: Result.count = a_count
		end

feature -- Library

	cairo_version: STRING_32
			-- Version of the linked cairo library (e.g. 1.17.2).
		local
			c: C_STRING
		do
			create c.make_by_pointer (c_version_string)
			Result := c.string.to_string_32
		ensure
			not_empty: not Result.is_empty
		end

feature {NONE} -- Library externals

	c_version_string: POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return (void*)sc_version_string();"
		end

feature -- Format Constants

	Format_argb32: INTEGER = 0
	Format_rgb24: INTEGER = 1
	Format_a8: INTEGER = 2
	Format_a1: INTEGER = 3

feature -- Status

	last_error: STRING
			-- Last error message, empty if no error.

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := not last_error.is_empty
		end

invariant
	last_error_attached: last_error /= Void

end
