note
	description: "[
		CAIRO_GLYPH_ARRAY - a marshalled cairo_glyph_t array.

		A glyph is an id plus an ABSOLUTE position: cairo_glyph_t is
		{ unsigned long index; double x; double y; }. The id is a
		physical glyph index of the font face in force, NOT a character;
		the position is where the glyph's origin goes in user space, NOT
		an advance. A shaper produces both; cairo consumes both and never
		re-measures.

		WHY THIS CLASS EXISTS: so no caller ever has to know the struct
		layout. On win64 `unsigned long' is 4 bytes and the doubles force
		8-byte alignment, so cairo_glyph_t is 24 bytes with 4 bytes of
		padding after `index' - index at 0, x at 8, y at 16. Those
		numbers are VERIFIED, not assumed, and they are verified at run
		time: `Glyph_struct_size' and the three offsets are reported by
		the C compiler through the shim, every field is written by the
		shim, and the test suite asserts what came back. An LP64 build
		(`unsigned long' 8 bytes, no padding, the same 24 in total)
		therefore needs no change here.

		Indices are 1-based, Eiffel-style. `make' zeroes the whole array,
		so an unfilled slot draws glyph 0 at the origin rather than
		garbage. The empty array is legal and paints nothing.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_GLYPH_ARRAY

create
	make, make_from_arrays

feature {NONE} -- Initialization

	make (a_count: INTEGER)
			-- Room for `a_count' glyphs, all zeroed.
		require
			count_not_negative: a_count >= 0
		do
			count := a_count
			create buffer.make (a_count.max (1) * Glyph_struct_size)
			c_glyph_zero (buffer.item, a_count)
		ensure
			count_set: count = a_count
			room_reserved: buffer.count >= a_count * Glyph_struct_size
		end

	make_from_arrays (a_glyph_ids: ARRAY [NATURAL_32]; a_xs, a_ys: ARRAY [REAL_64])
			-- Glyph run from three parallel arrays: ids, x positions,
			-- y positions. All three must be the same length; the arrays'
			-- own lower bounds are respected, so a slice works.
		require
			ids_and_xs_agree: a_glyph_ids.count = a_xs.count
			xs_and_ys_agree: a_xs.count = a_ys.count
		local
			i: INTEGER
		do
			count := a_glyph_ids.count
			create buffer.make (count.max (1) * Glyph_struct_size)
			c_glyph_zero (buffer.item, count)
			from
				i := 1
			until
				i > count
			loop
				put (i, a_glyph_ids [a_glyph_ids.lower + i - 1],
					a_xs [a_xs.lower + i - 1], a_ys [a_ys.lower + i - 1])
				i := i + 1
			end
		ensure
			count_set: count = a_glyph_ids.count
		end

feature -- Access

	count: INTEGER
			-- Number of glyphs.

	area: POINTER
			-- Base address of the cairo_glyph_t array, for the C calls
			-- that consume it. Valid only while Current is alive.
		do
			Result := buffer.item
		end

	glyph_id (a_i: INTEGER): NATURAL_32
			-- Physical glyph index at slot `a_i'.
		require
			in_range: a_i >= 1 and a_i <= count
		do
			Result := c_glyph_index_at (buffer.item, a_i - 1)
		end

	x (a_i: INTEGER): REAL_64
			-- User-space x of the glyph at slot `a_i'.
		require
			in_range: a_i >= 1 and a_i <= count
		do
			Result := c_glyph_x_at (buffer.item, a_i - 1)
		end

	y (a_i: INTEGER): REAL_64
			-- User-space y (baseline) of the glyph at slot `a_i'.
		require
			in_range: a_i >= 1 and a_i <= count
		do
			Result := c_glyph_y_at (buffer.item, a_i - 1)
		end

feature -- Status

	is_empty: BOOLEAN
			-- Are there no glyphs? An empty run paints nothing and
			-- measures as six zeros - it is never a cairo error.
		do
			Result := count = 0
		end

feature -- Element Change

	put (a_i: INTEGER; a_glyph_id: NATURAL_32; a_x, a_y: REAL_64)
			-- Set slot `a_i' to `a_glyph_id' at (`a_x', `a_y').
		require
			in_range: a_i >= 1 and a_i <= count
		do
			c_glyph_put (buffer.item, a_i - 1, a_glyph_id, a_x, a_y)
		ensure
			id_set: glyph_id (a_i) = a_glyph_id
			x_set: x (a_i) = a_x
			y_set: y (a_i) = a_y
		end

feature -- Layout (reported by C, never assumed)

	Glyph_struct_size: INTEGER
			-- sizeof (cairo_glyph_t). 24 on win64.
		once
			Result := c_glyph_sizeof
		ensure
			positive: Result > 0
		end

	Glyph_index_offset: INTEGER
			-- Byte offset of the id field. 0 on win64.
		once
			Result := c_glyph_offset_index
		ensure
			non_negative: Result >= 0
		end

	Glyph_x_offset: INTEGER
			-- Byte offset of x. 8 on win64 (4 bytes of `unsigned long'
			-- plus 4 bytes of padding).
		once
			Result := c_glyph_offset_x
		ensure
			after_index: Result > Glyph_index_offset
		end

	Glyph_y_offset: INTEGER
			-- Byte offset of y. 16 on win64.
		once
			Result := c_glyph_offset_y
		ensure
			after_x: Result > Glyph_x_offset
		end

feature {NONE} -- Implementation

	buffer: MANAGED_POINTER
			-- The marshalled cairo_glyph_t array.

feature {NONE} -- C Externals

	c_glyph_sizeof: INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_glyph_sizeof();"
		end

	c_glyph_offset_index: INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_glyph_offset_index();"
		end

	c_glyph_offset_x: INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_glyph_offset_x();"
		end

	c_glyph_offset_y: INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_glyph_offset_y();"
		end

	c_glyph_zero (a_base: POINTER; a_count: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_glyph_zero($a_base, $a_count);"
		end

	c_glyph_put (a_base: POINTER; a_i: INTEGER; a_id: NATURAL_32; a_x, a_y: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_glyph_put($a_base, $a_i, (unsigned int)$a_id, $a_x, $a_y);"
		end

	c_glyph_index_at (a_base: POINTER; a_i: INTEGER): NATURAL_32
		external "C inline use %"simple_cairo.h%""
		alias "return (EIF_NATURAL_32)sc_glyph_index_at($a_base, $a_i);"
		end

	c_glyph_x_at (a_base: POINTER; a_i: INTEGER): REAL_64
		external "C inline use %"simple_cairo.h%""
		alias "return sc_glyph_x_at($a_base, $a_i);"
		end

	c_glyph_y_at (a_base: POINTER; a_i: INTEGER): REAL_64
		external "C inline use %"simple_cairo.h%""
		alias "return sc_glyph_y_at($a_base, $a_i);"
		end

invariant
	count_not_negative: count >= 0
	buffer_holds_the_run: buffer.count >= count * Glyph_struct_size

end
