note
	description: "[
		Mesh gradient (coons patches). Build patches between begin_patch
		and end_patch: a path of up to four sides, four corner colors,
		optional interior control points.

		The patch discipline is contracted: side and color calls require
		an open patch, begin requires none open - the same ghost-counter
		move as CAIRO_CONTEXT.group_depth.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_MESH_PATTERN

inherit
	CAIRO_PATTERN

create
	make

feature {NONE} -- Initialization

	make
			-- Create an empty mesh.
		do
			handle := c_mesh_create
		ensure
			valid: is_valid
			no_open_patch: not in_patch
		end

feature -- Status

	in_patch: BOOLEAN
			-- Is a patch currently open?

feature -- Patch Construction (Fluent API)

	begin_patch: like Current
			-- Open a new patch.
		require
			valid: is_valid
			no_open_patch: not in_patch
		do
			c_mesh_begin_patch (handle)
			in_patch := True
			Result := Current
		ensure
			open: in_patch
		end

	end_patch: like Current
			-- Close the current patch.
		require
			valid: is_valid
			patch_open: in_patch
		do
			c_mesh_end_patch (handle)
			in_patch := False
			Result := Current
		ensure
			closed: not in_patch
		end

	move_to (a_x, a_y: REAL_64): like Current
			-- Start the patch path.
		require
			valid: is_valid
			patch_open: in_patch
		do
			c_mesh_move_to (handle, a_x, a_y)
			Result := Current
		end

	line_to (a_x, a_y: REAL_64): like Current
			-- Add a straight side.
		require
			valid: is_valid
			patch_open: in_patch
		do
			c_mesh_line_to (handle, a_x, a_y)
			Result := Current
		end

	curve_to (a_x1, a_y1, a_x2, a_y2, a_x3, a_y3: REAL_64): like Current
			-- Add a curved side.
		require
			valid: is_valid
			patch_open: in_patch
		do
			c_mesh_curve_to (handle, a_x1, a_y1, a_x2, a_y2, a_x3, a_y3)
			Result := Current
		end

	set_corner_color_rgb (a_corner: INTEGER; a_r, a_g, a_b: REAL_64): like Current
			-- Color of corner 0..3 of the open patch.
		require
			valid: is_valid
			patch_open: in_patch
			valid_corner: a_corner >= 0 and a_corner <= 3
		do
			c_mesh_set_corner_rgb (handle, a_corner, a_r, a_g, a_b)
			Result := Current
		end

	set_corner_color_rgba (a_corner: INTEGER; a_r, a_g, a_b, a_a: REAL_64): like Current
			-- Translucent color of corner 0..3 of the open patch.
		require
			valid: is_valid
			patch_open: in_patch
			valid_corner: a_corner >= 0 and a_corner <= 3
		do
			c_mesh_set_corner_rgba (handle, a_corner, a_r, a_g, a_b, a_a)
			Result := Current
		end

	set_control_point (a_point: INTEGER; a_x, a_y: REAL_64): like Current
			-- Interior control point 0..3 of the open patch.
		require
			valid: is_valid
			patch_open: in_patch
			valid_point: a_point >= 0 and a_point <= 3
		do
			c_mesh_set_control_point (handle, a_point, a_x, a_y)
			Result := Current
		end

feature {NONE} -- C Externals

	c_mesh_create: POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_mesh_create();"
		end

	c_mesh_begin_patch (a_pattern: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_begin_patch((cairo_pattern_t*)$a_pattern);"
		end

	c_mesh_end_patch (a_pattern: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_end_patch((cairo_pattern_t*)$a_pattern);"
		end

	c_mesh_move_to (a_pattern: POINTER; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_move_to((cairo_pattern_t*)$a_pattern, $a_x, $a_y);"
		end

	c_mesh_line_to (a_pattern: POINTER; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_line_to((cairo_pattern_t*)$a_pattern, $a_x, $a_y);"
		end

	c_mesh_curve_to (a_pattern: POINTER; a_x1, a_y1, a_x2, a_y2, a_x3, a_y3: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_curve_to((cairo_pattern_t*)$a_pattern, $a_x1, $a_y1, $a_x2, $a_y2, $a_x3, $a_y3);"
		end

	c_mesh_set_corner_rgb (a_pattern: POINTER; a_corner: INTEGER; a_r, a_g, a_b: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_set_corner_rgb((cairo_pattern_t*)$a_pattern, (unsigned int)$a_corner, $a_r, $a_g, $a_b);"
		end

	c_mesh_set_corner_rgba (a_pattern: POINTER; a_corner: INTEGER; a_r, a_g, a_b, a_a: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_set_corner_rgba((cairo_pattern_t*)$a_pattern, (unsigned int)$a_corner, $a_r, $a_g, $a_b, $a_a);"
		end

	c_mesh_set_control_point (a_pattern: POINTER; a_point: INTEGER; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_mesh_set_control_point((cairo_pattern_t*)$a_pattern, (unsigned int)$a_point, $a_x, $a_y);"
		end

end
