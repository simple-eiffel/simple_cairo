note
	description: "[
		A surface used as a paint source - stamp one drawing into another.
		With Extend_repeat this is the tiling primitive; with the default
		Extend_none the surface paints once at its placed position.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_SURFACE_PATTERN

inherit
	CAIRO_PATTERN

create
	make_from_surface

feature {NONE} -- Initialization

	make_from_surface (a_surface: CAIRO_SURFACE)
			-- Pattern sampling `a_surface'. Cairo keeps its own reference,
			-- so the pattern stays usable regardless of who destroys first.
		require
			surface_valid: a_surface.is_valid
		do
			handle := c_pattern_create_for_surface (a_surface.handle)
		ensure
			valid: is_valid
		end

feature {NONE} -- C Externals

	c_pattern_create_for_surface (a_surface: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_pattern_create_for_surface((cairo_surface_t*)$a_surface);"
		end

end
