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
