note
	description: "[
		CAIRO_MATRIX - affine transformation as a first-class value.

		Six coefficients (xx yx xy yy x0 y0), full cairo matrix algebra:
		translate, scale, rotate, multiply, invert, and point/distance
		transforms. Used standalone or pushed to CAIRO_CONTEXT via
		set_matrix / transform.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_MATRIX

create
	make_identity, make_from_buffer

feature {NONE} -- Initialization

	make_identity
		local
			b: MANAGED_POINTER
		do
			create b.make (48)
			c_mx_identity (b.item)
			read (b)
		ensure
			identity: xx = 1.0 and yy = 1.0 and yx = 0.0 and xy = 0.0 and x0 = 0.0 and y0 = 0.0
		end

	make_from_buffer (a_b: MANAGED_POINTER)
		require
			big_enough: a_b.count >= 48
		do
			read (a_b)
		end

feature -- Access

	xx, yx, xy, yy, x0, y0: REAL_64

feature -- Operations (Fluent API)

	translated (a_tx, a_ty: REAL_64): like Current
		local
			b: MANAGED_POINTER
		do
			b := packed
			c_mx_translate (b.item, a_tx, a_ty)
			read (b)
			Result := Current
		end

	scaled (a_sx, a_sy: REAL_64): like Current
		local
			b: MANAGED_POINTER
		do
			b := packed
			c_mx_scale (b.item, a_sx, a_sy)
			read (b)
			Result := Current
		end

	rotated (a_radians: REAL_64): like Current
		local
			b: MANAGED_POINTER
		do
			b := packed
			c_mx_rotate (b.item, a_radians)
			read (b)
			Result := Current
		end

	multiplied (a_other: CAIRO_MATRIX): like Current
			-- Current := Current * a_other (cairo order: apply Current first).
		local
			b, o, r: MANAGED_POINTER
		do
			b := packed
			o := a_other.packed
			create r.make (48)
			c_mx_multiply (r.item, b.item, o.item)
			read (r)
			Result := Current
		end

	inverted: BOOLEAN
			-- Invert in place; False when singular (matrix unchanged).
		local
			b: MANAGED_POINTER
		do
			b := packed
			if c_mx_invert (b.item) = 0 then
				read (b)
				Result := True
			end
		end

feature -- Mapping

	transformed_point (a_x, a_y: REAL_64): TUPLE [x, y: REAL_64]
		local
			b, pxy: MANAGED_POINTER
		do
			b := packed
			create pxy.make (16)
			pxy.put_real_64 (a_x, 0)
			pxy.put_real_64 (a_y, 8)
			c_mx_point (b.item, pxy.item)
			Result := [pxy.read_real_64 (0), pxy.read_real_64 (8)]
		end

	transformed_distance (a_dx, a_dy: REAL_64): TUPLE [x, y: REAL_64]
		local
			b, pxy: MANAGED_POINTER
		do
			b := packed
			create pxy.make (16)
			pxy.put_real_64 (a_dx, 0)
			pxy.put_real_64 (a_dy, 8)
			c_mx_distance (b.item, pxy.item)
			Result := [pxy.read_real_64 (0), pxy.read_real_64 (8)]
		end

feature {CAIRO_MATRIX, CAIRO_CONTEXT} -- Marshalling

	packed: MANAGED_POINTER
		do
			create Result.make (48)
			Result.put_real_64 (xx, 0)
			Result.put_real_64 (yx, 8)
			Result.put_real_64 (xy, 16)
			Result.put_real_64 (yy, 24)
			Result.put_real_64 (x0, 32)
			Result.put_real_64 (y0, 40)
		end

	read (a_b: MANAGED_POINTER)
		do
			xx := a_b.read_real_64 (0)
			yx := a_b.read_real_64 (8)
			xy := a_b.read_real_64 (16)
			yy := a_b.read_real_64 (24)
			x0 := a_b.read_real_64 (32)
			y0 := a_b.read_real_64 (40)
		end

feature {NONE} -- C Externals

	c_mx_identity (a_m: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_matrix_init_identity((double*)$a_m);"
		end

	c_mx_translate (a_m: POINTER; a_tx, a_ty: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_matrix_translate((double*)$a_m, $a_tx, $a_ty);"
		end

	c_mx_scale (a_m: POINTER; a_sx, a_sy: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_matrix_scale((double*)$a_m, $a_sx, $a_sy);"
		end

	c_mx_rotate (a_m: POINTER; a_r: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_matrix_rotate((double*)$a_m, $a_r);"
		end

	c_mx_invert (a_m: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_matrix_invert((double*)$a_m);"
		end

	c_mx_multiply (a_out, a_a, a_b: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_matrix_multiply((double*)$a_out, (const double*)$a_a, (const double*)$a_b);"
		end

	c_mx_point (a_m, a_xy: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_matrix_transform_point((const double*)$a_m, (double*)$a_xy);"
		end

	c_mx_distance (a_m, a_xy: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_matrix_transform_distance((const double*)$a_m, (double*)$a_xy);"
		end

end
