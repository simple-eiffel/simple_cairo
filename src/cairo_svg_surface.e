note
	description: "[
		CAIRO_SVG_SURFACE - vector output to an .svg file. Sizes are in
		points (72 per inch). Call finish (inherited surface behavior via
		CAIRO_SURFACE.finish) before destroy to flush the document.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_SVG_SURFACE

inherit
	CAIRO_SURFACE

create
	make_svg

feature {NONE} -- Initialization

	make_svg (a_path: READABLE_STRING_GENERAL; a_width_pt, a_height_pt: REAL_64)
		require
			path_not_empty: not a_path.is_empty
			positive: a_width_pt > 0.0 and a_height_pt > 0.0
		local
			s: C_STRING
		do
			create s.make (a_path.to_string_8)
			make_from_handle (c_svg_create (s.item, a_width_pt, a_height_pt))
			is_shared := False
		ensure
			owned: not is_shared
		end

feature {NONE} -- C Externals

	c_svg_create (a_path: POINTER; a_w, a_h: REAL_64): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_svg_surface_create((const char*)$a_path, $a_w, $a_h);"
		end

end
