note
	description: "[
		CAIRO_GRADIENT - Wrapper for Cairo gradient patterns.

		Supports linear and radial gradients with color stops.

		Usage:
			local
				grad: CAIRO_GRADIENT
			do
				create grad.make_linear (0, 0, 0, 100)  -- Vertical gradient
				grad.add_stop_hex (0.0, 0x3498DB)       -- Blue at top
				   .add_stop_hex (1.0, 0x2ECC71)        -- Green at bottom

				ctx.set_gradient (grad)
				   .fill_rect (0, 0, 200, 100)
				grad.destroy
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_GRADIENT

create
	make_linear, make_radial

feature {NONE} -- Initialization

	make_linear (a_x0, a_y0, a_x1, a_y1: REAL_64)
			-- Create linear gradient from (x0,y0) to (x1,y1).
		do
			handle := c_gradient_linear (a_x0, a_y0, a_x1, a_y1)
			is_linear := True
		ensure
			linear: is_linear
		end

	make_radial (a_cx0, a_cy0, a_r0, a_cx1, a_cy1, a_r1: REAL_64)
			-- Create radial gradient between two circles.
		require
			valid_r0: a_r0 >= 0
			valid_r1: a_r1 >= 0
		do
			handle := c_gradient_radial (a_cx0, a_cy0, a_r0, a_cx1, a_cy1, a_r1)
			is_linear := False
		ensure
			radial: not is_linear
		end

feature -- Access

	handle: POINTER
			-- Underlying cairo_pattern_t pointer.

	is_linear: BOOLEAN
			-- Is this a linear gradient?

	is_radial: BOOLEAN
			-- Is this a radial gradient?
		do
			Result := not is_linear
		end

feature -- Status

	is_valid: BOOLEAN
			-- Is gradient valid?
		do
			Result := handle /= default_pointer
		end

feature -- Color Stops (Fluent API)

	add_stop_rgb (a_offset, a_r, a_g, a_b: REAL_64): like Current
			-- Add color stop (RGB 0.0-1.0).
		require
			valid: is_valid
			valid_offset: a_offset >= 0 and a_offset <= 1
			valid_r: a_r >= 0 and a_r <= 1
			valid_g: a_g >= 0 and a_g <= 1
			valid_b: a_b >= 0 and a_b <= 1
		do
			c_gradient_add_stop_rgb (handle, a_offset, a_r, a_g, a_b)
			Result := Current
		end

	add_stop_rgba (a_offset, a_r, a_g, a_b, a_a: REAL_64): like Current
			-- Add color stop (RGBA 0.0-1.0).
		require
			valid: is_valid
			valid_offset: a_offset >= 0 and a_offset <= 1
			valid_r: a_r >= 0 and a_r <= 1
			valid_g: a_g >= 0 and a_g <= 1
			valid_b: a_b >= 0 and a_b <= 1
			valid_a: a_a >= 0 and a_a <= 1
		do
			c_gradient_add_stop_rgba (handle, a_offset, a_r, a_g, a_b, a_a)
			Result := Current
		end

	add_stop_hex (a_offset: REAL_64; a_hex: NATURAL_32): like Current
			-- Add color stop from hex (0xRRGGBB).
		require
			valid: is_valid
			valid_offset: a_offset >= 0 and a_offset <= 1
		do
			c_gradient_add_stop_hex (handle, a_offset, a_hex.as_integer_32)
			Result := Current
		end

feature -- Convenience

	two_color (a_color1, a_color2: NATURAL_32): like Current
			-- Simple two-color gradient.
		require
			valid: is_valid
		do
			c_gradient_add_stop_hex (handle, 0.0, a_color1.as_integer_32)
			c_gradient_add_stop_hex (handle, 1.0, a_color2.as_integer_32)
			Result := Current
		end

	three_color (a_color1, a_color2, a_color3: NATURAL_32): like Current
			-- Three-color gradient.
		require
			valid: is_valid
		do
			c_gradient_add_stop_hex (handle, 0.0, a_color1.as_integer_32)
			c_gradient_add_stop_hex (handle, 0.5, a_color2.as_integer_32)
			c_gradient_add_stop_hex (handle, 1.0, a_color3.as_integer_32)
			Result := Current
		end

feature -- Disposal

	destroy
			-- Release gradient resources.
		do
			if handle /= default_pointer then
				c_pattern_destroy (handle)
				handle := default_pointer
			end
		ensure
			destroyed: handle = default_pointer
		end

feature {NONE} -- C Externals

	c_gradient_linear (a_x0, a_y0, a_x1, a_y1: REAL_64): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_gradient_linear($a_x0, $a_y0, $a_x1, $a_y1);"
		end

	c_gradient_radial (a_cx0, a_cy0, a_r0, a_cx1, a_cy1, a_r1: REAL_64): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_gradient_radial($a_cx0, $a_cy0, $a_r0, $a_cx1, $a_cy1, $a_r1);"
		end

	c_gradient_add_stop_rgb (a_pattern: POINTER; a_offset, a_r, a_g, a_b: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_gradient_add_stop_rgb((cairo_pattern_t*)$a_pattern, $a_offset, $a_r, $a_g, $a_b);"
		end

	c_gradient_add_stop_rgba (a_pattern: POINTER; a_offset, a_r, a_g, a_b, a_a: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_gradient_add_stop_rgba((cairo_pattern_t*)$a_pattern, $a_offset, $a_r, $a_g, $a_b, $a_a);"
		end

	c_gradient_add_stop_hex (a_pattern: POINTER; a_offset: REAL_64; a_hex: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_gradient_add_stop_hex((cairo_pattern_t*)$a_pattern, $a_offset, (unsigned int)$a_hex);"
		end

	c_pattern_destroy (a_pattern: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_pattern_destroy((cairo_pattern_t*)$a_pattern);"
		end

end
