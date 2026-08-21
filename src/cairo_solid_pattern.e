note
	description: "Solid-color paint source. The pattern form of set_color."
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_SOLID_PATTERN

inherit
	CAIRO_PATTERN

create
	make_rgb, make_rgba

feature {NONE} -- Initialization

	make_rgb (a_r, a_g, a_b: REAL_64)
			-- Opaque solid color (components 0.0 - 1.0).
		require
			valid_r: a_r >= 0.0 and a_r <= 1.0
			valid_g: a_g >= 0.0 and a_g <= 1.0
			valid_b: a_b >= 0.0 and a_b <= 1.0
		do
			handle := c_pattern_create_rgb (a_r, a_g, a_b)
		ensure
			valid: is_valid
		end

	make_rgba (a_r, a_g, a_b, a_a: REAL_64)
			-- Translucent solid color (components 0.0 - 1.0).
		require
			valid_r: a_r >= 0.0 and a_r <= 1.0
			valid_g: a_g >= 0.0 and a_g <= 1.0
			valid_b: a_b >= 0.0 and a_b <= 1.0
			valid_a: a_a >= 0.0 and a_a <= 1.0
		do
			handle := c_pattern_create_rgba (a_r, a_g, a_b, a_a)
		ensure
			valid: is_valid
		end

feature {NONE} -- C Externals

	c_pattern_create_rgb (a_r, a_g, a_b: REAL_64): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_pattern_create_rgb($a_r, $a_g, $a_b);"
		end

	c_pattern_create_rgba (a_r, a_g, a_b, a_a: REAL_64): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_pattern_create_rgba($a_r, $a_g, $a_b, $a_a);"
		end

end
