note
	description: "[
		CAIRO_CONTEXT - Drawing context wrapper for Cairo.

		Provides fluent API for 2D drawing operations including:
		- Paths (lines, curves, arcs, rectangles)
		- Colors (RGB, RGBA, hex)
		- Fills and strokes
		- Gradients
		- Text
		- Waveforms (for audio visualization)

		Usage:
			ctx.set_color_hex (0x3498DB)
			   .fill_rect (10, 10, 100, 50)
			ctx.set_color_rgb (1.0, 0.0, 0.0)
			   .set_line_width (2.0)
			   .stroke_circle (200, 200, 50)
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_CONTEXT

create
	make

feature {NONE} -- Initialization

	make (a_surface: CAIRO_SURFACE)
			-- Create context for surface.
		require
			surface_valid: a_surface.is_valid
		do
			handle := c_context_create (a_surface.handle)
			surface := a_surface
		ensure
			handle_set: handle /= default_pointer implies is_valid
		end

feature -- Access

	handle: POINTER
			-- Underlying cairo_t pointer.

	surface: CAIRO_SURFACE
			-- Associated surface.

feature -- Status

	is_valid: BOOLEAN
			-- Is context valid?
		do
			Result := handle /= default_pointer and then c_context_status (handle) = 0
		end

	status: INTEGER
			-- Context status code (0 = OK).
		do
			if handle /= default_pointer then
				Result := c_context_status (handle)
			else
				Result := -1
			end
		end

feature -- State Management

	save: like Current
			-- Save current state.
		require
			valid: is_valid
		do
			c_save (handle)
			Result := Current
		end

	restore: like Current
			-- Restore saved state.
		require
			valid: is_valid
		do
			c_restore (handle)
			Result := Current
		end

feature -- Color (Fluent API)

	set_color_rgb (a_r, a_g, a_b: REAL_64): like Current
			-- Set color from RGB (0.0-1.0 range).
		require
			valid: is_valid
			valid_r: a_r >= 0 and a_r <= 1
			valid_g: a_g >= 0 and a_g <= 1
			valid_b: a_b >= 0 and a_b <= 1
		do
			c_set_rgb (handle, a_r, a_g, a_b)
			Result := Current
		end

	set_color_rgba (a_r, a_g, a_b, a_a: REAL_64): like Current
			-- Set color from RGBA (0.0-1.0 range).
		require
			valid: is_valid
			valid_r: a_r >= 0 and a_r <= 1
			valid_g: a_g >= 0 and a_g <= 1
			valid_b: a_b >= 0 and a_b <= 1
			valid_a: a_a >= 0 and a_a <= 1
		do
			c_set_rgba (handle, a_r, a_g, a_b, a_a)
			Result := Current
		end

	set_color_hex (a_hex: NATURAL_32): like Current
			-- Set color from hex (0xRRGGBB).
		require
			valid: is_valid
		do
			c_set_hex (handle, a_hex.as_integer_32)
			Result := Current
		end

	set_color_hex_alpha (a_hex: NATURAL_32): like Current
			-- Set color from hex with alpha (0xAARRGGBB).
		require
			valid: is_valid
		do
			c_set_hex_alpha (handle, a_hex.as_integer_32)
			Result := Current
		end

feature -- Line Properties (Fluent API)

	set_line_width (a_width: REAL_64): like Current
			-- Set line width.
		require
			valid: is_valid
			positive: a_width > 0
		do
			c_set_line_width (handle, a_width)
			Result := Current
		end

	set_line_cap (a_cap: INTEGER): like Current
			-- Set line cap style (0=butt, 1=round, 2=square).
		require
			valid: is_valid
			valid_cap: a_cap >= 0 and a_cap <= 2
		do
			c_set_line_cap (handle, a_cap)
			Result := Current
		end

	set_line_join (a_join: INTEGER): like Current
			-- Set line join style (0=miter, 1=round, 2=bevel).
		require
			valid: is_valid
			valid_join: a_join >= 0 and a_join <= 2
		do
			c_set_line_join (handle, a_join)
			Result := Current
		end

feature -- Path Construction (Fluent API)

	new_path: like Current
			-- Start a new path.
		require
			valid: is_valid
		do
			c_new_path (handle)
			Result := Current
		end

	move_to (a_x, a_y: REAL_64): like Current
			-- Move to position (no line).
		require
			valid: is_valid
		do
			c_move_to (handle, a_x, a_y)
			Result := Current
		end

	line_to (a_x, a_y: REAL_64): like Current
			-- Draw line to position.
		require
			valid: is_valid
		do
			c_line_to (handle, a_x, a_y)
			Result := Current
		end

	curve_to (a_x1, a_y1, a_x2, a_y2, a_x3, a_y3: REAL_64): like Current
			-- Draw cubic Bezier curve.
		require
			valid: is_valid
		do
			c_curve_to (handle, a_x1, a_y1, a_x2, a_y2, a_x3, a_y3)
			Result := Current
		end

	arc (a_xc, a_yc, a_radius, a_angle1, a_angle2: REAL_64): like Current
			-- Draw arc (angles in radians).
		require
			valid: is_valid
			positive_radius: a_radius > 0
		do
			c_arc (handle, a_xc, a_yc, a_radius, a_angle1, a_angle2)
			Result := Current
		end

	rectangle (a_x, a_y, a_width, a_height: REAL_64): like Current
			-- Add rectangle to path.
		require
			valid: is_valid
		do
			c_rectangle (handle, a_x, a_y, a_width, a_height)
			Result := Current
		end

	rounded_rectangle (a_x, a_y, a_width, a_height, a_radius: REAL_64): like Current
			-- Add rounded rectangle to path.
		require
			valid: is_valid
			positive_radius: a_radius >= 0
		do
			c_rounded_rectangle (handle, a_x, a_y, a_width, a_height, a_radius)
			Result := Current
		end

	close_path: like Current
			-- Close current sub-path.
		require
			valid: is_valid
		do
			c_close_path (handle)
			Result := Current
		end

feature -- Drawing Operations (Fluent API)

	stroke: like Current
			-- Stroke the current path.
		require
			valid: is_valid
		do
			c_stroke (handle)
			Result := Current
		end

	stroke_preserve: like Current
			-- Stroke the current path, preserving it.
		require
			valid: is_valid
		do
			c_stroke_preserve (handle)
			Result := Current
		end

	fill: like Current
			-- Fill the current path.
		require
			valid: is_valid
		do
			c_fill (handle)
			Result := Current
		end

	fill_preserve: like Current
			-- Fill the current path, preserving it.
		require
			valid: is_valid
		do
			c_fill_preserve (handle)
			Result := Current
		end

	paint: like Current
			-- Paint entire surface with current source.
		require
			valid: is_valid
		do
			c_paint (handle)
			Result := Current
		end

	paint_alpha (a_alpha: REAL_64): like Current
			-- Paint entire surface with alpha.
		require
			valid: is_valid
			valid_alpha: a_alpha >= 0 and a_alpha <= 1
		do
			c_paint_alpha (handle, a_alpha)
			Result := Current
		end

	clear: like Current
			-- Clear surface to transparent.
		require
			valid: is_valid
		do
			c_clear (handle)
			Result := Current
		end

feature -- Convenience Shapes (Fluent API)

	fill_rect (a_x, a_y, a_width, a_height: REAL_64): like Current
			-- Draw filled rectangle.
		require
			valid: is_valid
		do
			c_fill_rect (handle, a_x, a_y, a_width, a_height)
			Result := Current
		end

	stroke_rect (a_x, a_y, a_width, a_height: REAL_64): like Current
			-- Draw stroked rectangle.
		require
			valid: is_valid
		do
			c_stroke_rect (handle, a_x, a_y, a_width, a_height)
			Result := Current
		end

	fill_circle (a_cx, a_cy, a_radius: REAL_64): like Current
			-- Draw filled circle.
		require
			valid: is_valid
			positive_radius: a_radius > 0
		do
			c_fill_circle (handle, a_cx, a_cy, a_radius)
			Result := Current
		end

	stroke_circle (a_cx, a_cy, a_radius: REAL_64): like Current
			-- Draw stroked circle.
		require
			valid: is_valid
			positive_radius: a_radius > 0
		do
			c_stroke_circle (handle, a_cx, a_cy, a_radius)
			Result := Current
		end

	draw_line (a_x1, a_y1, a_x2, a_y2: REAL_64): like Current
			-- Draw a line.
		require
			valid: is_valid
		do
			c_draw_line (handle, a_x1, a_y1, a_x2, a_y2)
			Result := Current
		end

feature -- Gradients (Fluent API)

	set_gradient (a_gradient: CAIRO_GRADIENT): like Current
			-- Set gradient as source.
		require
			valid: is_valid
			gradient_valid: a_gradient.is_valid
		do
			c_set_source_pattern (handle, a_gradient.handle)
			Result := Current
		end

feature -- Transforms (Fluent API)

	translate (a_tx, a_ty: REAL_64): like Current
			-- Translate coordinate system.
		require
			valid: is_valid
		do
			c_translate (handle, a_tx, a_ty)
			Result := Current
		end

	scale (a_sx, a_sy: REAL_64): like Current
			-- Scale coordinate system.
		require
			valid: is_valid
		do
			c_scale (handle, a_sx, a_sy)
			Result := Current
		end

	rotate (a_angle: REAL_64): like Current
			-- Rotate coordinate system (radians).
		require
			valid: is_valid
		do
			c_rotate (handle, a_angle)
			Result := Current
		end

	identity_matrix: like Current
			-- Reset to identity matrix.
		require
			valid: is_valid
		do
			c_identity_matrix (handle)
			Result := Current
		end

feature -- Text (Fluent API)

	select_font (a_family: READABLE_STRING_GENERAL; a_slant, a_weight: INTEGER): like Current
			-- Select font face. Slant: 0=normal, 1=italic, 2=oblique. Weight: 0=normal, 1=bold.
		require
			valid: is_valid
			family_not_empty: not a_family.is_empty
		local
			l_family: C_STRING
		do
			create l_family.make (a_family.to_string_8)
			c_select_font (handle, l_family.item, a_slant, a_weight)
			Result := Current
		end

	set_font_size (a_size: REAL_64): like Current
			-- Set font size.
		require
			valid: is_valid
			positive: a_size > 0
		do
			c_set_font_size (handle, a_size)
			Result := Current
		end

	show_text (a_text: READABLE_STRING_GENERAL): like Current
			-- Draw text at current position.
		require
			valid: is_valid
		local
			l_text: C_STRING
		do
			create l_text.make (a_text.to_string_8)
			c_show_text (handle, l_text.item)
			Result := Current
		end

	text_width (a_text: READABLE_STRING_GENERAL): REAL_64
			-- Get width of text.
		require
			valid: is_valid
		local
			l_text: C_STRING
		do
			create l_text.make (a_text.to_string_8)
			Result := c_text_width (handle, l_text.item)
		end

	text_height (a_text: READABLE_STRING_GENERAL): REAL_64
			-- Get height of text.
		require
			valid: is_valid
		local
			l_text: C_STRING
		do
			create l_text.make (a_text.to_string_8)
			Result := c_text_height (handle, l_text.item)
		end

feature -- Waveform Drawing

	draw_waveform_i16 (a_samples: POINTER; a_count: INTEGER;
	                   a_x, a_y, a_width, a_height: REAL_64): like Current
			-- Draw waveform from int16 PCM samples.
		require
			valid: is_valid
			samples_not_null: a_samples /= default_pointer
			positive_count: a_count > 0
		do
			c_draw_waveform_i16 (handle, a_samples, a_count, a_x, a_y, a_width, a_height)
			Result := Current
		end

feature -- Line Cap/Join Constants

	Cap_butt: INTEGER = 0
	Cap_round: INTEGER = 1
	Cap_square: INTEGER = 2

	Join_miter: INTEGER = 0
	Join_round: INTEGER = 1
	Join_bevel: INTEGER = 2

feature -- Font Constants

	Slant_normal: INTEGER = 0
	Slant_italic: INTEGER = 1
	Slant_oblique: INTEGER = 2

	Weight_normal: INTEGER = 0
	Weight_bold: INTEGER = 1

feature -- Disposal

	destroy
			-- Release context resources.
		do
			if handle /= default_pointer then
				c_context_destroy (handle)
				handle := default_pointer
			end
		ensure
			destroyed: handle = default_pointer
		end

feature {NONE} -- C Externals

	c_context_create (a_surface: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_context_create((cairo_surface_t*)$a_surface);"
		end

	c_context_destroy (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_context_destroy((cairo_t*)$a_cr);"
		end

	c_context_status (a_cr: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_context_status((cairo_t*)$a_cr);"
		end

	c_save (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_save((cairo_t*)$a_cr);"
		end

	c_restore (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_restore((cairo_t*)$a_cr);"
		end

	c_set_rgb (a_cr: POINTER; a_r, a_g, a_b: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_rgb((cairo_t*)$a_cr, $a_r, $a_g, $a_b);"
		end

	c_set_rgba (a_cr: POINTER; a_r, a_g, a_b, a_a: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_rgba((cairo_t*)$a_cr, $a_r, $a_g, $a_b, $a_a);"
		end

	c_set_hex (a_cr: POINTER; a_hex: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_hex((cairo_t*)$a_cr, (unsigned int)$a_hex);"
		end

	c_set_hex_alpha (a_cr: POINTER; a_hex: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_hex_alpha((cairo_t*)$a_cr, (unsigned int)$a_hex);"
		end

	c_set_line_width (a_cr: POINTER; a_width: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_line_width((cairo_t*)$a_cr, $a_width);"
		end

	c_set_line_cap (a_cr: POINTER; a_cap: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_line_cap((cairo_t*)$a_cr, $a_cap);"
		end

	c_set_line_join (a_cr: POINTER; a_join: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_line_join((cairo_t*)$a_cr, $a_join);"
		end

	c_new_path (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_new_path((cairo_t*)$a_cr);"
		end

	c_move_to (a_cr: POINTER; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_move_to((cairo_t*)$a_cr, $a_x, $a_y);"
		end

	c_line_to (a_cr: POINTER; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_line_to((cairo_t*)$a_cr, $a_x, $a_y);"
		end

	c_curve_to (a_cr: POINTER; a_x1, a_y1, a_x2, a_y2, a_x3, a_y3: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_curve_to((cairo_t*)$a_cr, $a_x1, $a_y1, $a_x2, $a_y2, $a_x3, $a_y3);"
		end

	c_arc (a_cr: POINTER; a_xc, a_yc, a_radius, a_angle1, a_angle2: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_arc((cairo_t*)$a_cr, $a_xc, $a_yc, $a_radius, $a_angle1, $a_angle2);"
		end

	c_rectangle (a_cr: POINTER; a_x, a_y, a_w, a_h: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_rectangle((cairo_t*)$a_cr, $a_x, $a_y, $a_w, $a_h);"
		end

	c_rounded_rectangle (a_cr: POINTER; a_x, a_y, a_w, a_h, a_r: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_rounded_rectangle((cairo_t*)$a_cr, $a_x, $a_y, $a_w, $a_h, $a_r);"
		end

	c_close_path (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_close_path((cairo_t*)$a_cr);"
		end

	c_stroke (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_stroke((cairo_t*)$a_cr);"
		end

	c_stroke_preserve (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_stroke_preserve((cairo_t*)$a_cr);"
		end

	c_fill (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_fill((cairo_t*)$a_cr);"
		end

	c_fill_preserve (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_fill_preserve((cairo_t*)$a_cr);"
		end

	c_paint (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_paint((cairo_t*)$a_cr);"
		end

	c_paint_alpha (a_cr: POINTER; a_alpha: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_paint_alpha((cairo_t*)$a_cr, $a_alpha);"
		end

	c_clear (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_clear((cairo_t*)$a_cr);"
		end

	c_fill_rect (a_cr: POINTER; a_x, a_y, a_w, a_h: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_fill_rect((cairo_t*)$a_cr, $a_x, $a_y, $a_w, $a_h);"
		end

	c_stroke_rect (a_cr: POINTER; a_x, a_y, a_w, a_h: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_stroke_rect((cairo_t*)$a_cr, $a_x, $a_y, $a_w, $a_h);"
		end

	c_fill_circle (a_cr: POINTER; a_cx, a_cy, a_r: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_fill_circle((cairo_t*)$a_cr, $a_cx, $a_cy, $a_r);"
		end

	c_stroke_circle (a_cr: POINTER; a_cx, a_cy, a_r: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_stroke_circle((cairo_t*)$a_cr, $a_cx, $a_cy, $a_r);"
		end

	c_draw_line (a_cr: POINTER; a_x1, a_y1, a_x2, a_y2: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_draw_line((cairo_t*)$a_cr, $a_x1, $a_y1, $a_x2, $a_y2);"
		end

	c_set_source_pattern (a_cr, a_pattern: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_source_pattern((cairo_t*)$a_cr, (cairo_pattern_t*)$a_pattern);"
		end

	c_translate (a_cr: POINTER; a_tx, a_ty: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_translate((cairo_t*)$a_cr, $a_tx, $a_ty);"
		end

	c_scale (a_cr: POINTER; a_sx, a_sy: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_scale((cairo_t*)$a_cr, $a_sx, $a_sy);"
		end

	c_rotate (a_cr: POINTER; a_angle: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_rotate((cairo_t*)$a_cr, $a_angle);"
		end

	c_identity_matrix (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_identity_matrix((cairo_t*)$a_cr);"
		end

	c_select_font (a_cr, a_family: POINTER; a_slant, a_weight: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_select_font((cairo_t*)$a_cr, (const char*)$a_family, $a_slant, $a_weight);"
		end

	c_set_font_size (a_cr: POINTER; a_size: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_set_font_size((cairo_t*)$a_cr, $a_size);"
		end

	c_show_text (a_cr, a_text: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_show_text((cairo_t*)$a_cr, (const char*)$a_text);"
		end

	c_text_width (a_cr, a_text: POINTER): REAL_64
		external "C inline use %"simple_cairo.h%""
		alias "return sc_text_width((cairo_t*)$a_cr, (const char*)$a_text);"
		end

	c_text_height (a_cr, a_text: POINTER): REAL_64
		external "C inline use %"simple_cairo.h%""
		alias "return sc_text_height((cairo_t*)$a_cr, (const char*)$a_text);"
		end

	c_draw_waveform_i16 (a_cr, a_samples: POINTER; a_count: INTEGER;
	                     a_x, a_y, a_w, a_h: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_draw_waveform_i16((cairo_t*)$a_cr, (const short*)$a_samples, $a_count, $a_x, $a_y, $a_w, $a_h);"
		end

invariant
	surface_attached: surface /= Void

end
