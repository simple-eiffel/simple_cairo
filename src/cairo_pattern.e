note
	description: "[
		CAIRO_PATTERN - Common ancestor for all cairo paint sources.

		A pattern is what a drawing operation paints WITH: a solid color,
		a gradient, a repeated surface, or a mesh. Descendants create the
		handle; this class owns sampling behavior (extend, filter),
		status, and disposal.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CAIRO_PATTERN

feature -- Access

	handle: POINTER
			-- Underlying cairo_pattern_t pointer.

feature -- Status

	is_valid: BOOLEAN
			-- Is the pattern usable?
		do
			Result := handle /= default_pointer
		end

	status: INTEGER
			-- Cairo status code (0 = OK).
		require
			valid: is_valid
		do
			Result := c_pattern_status (handle)
		end

feature -- Sampling (Fluent API)

	set_extend (a_mode: INTEGER): like Current
			-- How the pattern continues beyond its natural bounds.
		require
			valid: is_valid
			known_mode: a_mode >= Extend_none and a_mode <= Extend_pad
		do
			c_pattern_set_extend (handle, a_mode)
			Result := Current
		ensure
			set: extend_mode = a_mode
		end

	extend_mode: INTEGER
			-- Current extend mode.
		require
			valid: is_valid
		do
			Result := c_pattern_get_extend (handle)
		end

	set_filter (a_mode: INTEGER): like Current
			-- Resampling filter used when the pattern is transformed.
		require
			valid: is_valid
			known_mode: a_mode >= Filter_fast and a_mode <= Filter_gaussian
		do
			c_pattern_set_filter (handle, a_mode)
			Result := Current
		ensure
			set: filter_mode = a_mode
		end

	filter_mode: INTEGER
			-- Current filter mode.
		require
			valid: is_valid
		do
			Result := c_pattern_get_filter (handle)
		end

feature -- Extend Constants

	Extend_none: INTEGER = 0
	Extend_repeat: INTEGER = 1
	Extend_reflect: INTEGER = 2
	Extend_pad: INTEGER = 3

feature -- Filter Constants

	Filter_fast: INTEGER = 0
	Filter_good: INTEGER = 1
	Filter_best: INTEGER = 2
	Filter_nearest: INTEGER = 3
	Filter_bilinear: INTEGER = 4
	Filter_gaussian: INTEGER = 5

feature -- Disposal

	destroy
			-- Release pattern resources.
		do
			if handle /= default_pointer then
				c_pattern_destroy (handle)
				handle := default_pointer
			end
		ensure
			destroyed: handle = default_pointer
		end

feature {NONE} -- C Externals

	c_pattern_status (a_pattern: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_pattern_status((cairo_pattern_t*)$a_pattern);"
		end

	c_pattern_set_extend (a_pattern: POINTER; a_mode: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_pattern_set_extend((cairo_pattern_t*)$a_pattern, $a_mode);"
		end

	c_pattern_get_extend (a_pattern: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_pattern_get_extend((cairo_pattern_t*)$a_pattern);"
		end

	c_pattern_set_filter (a_pattern: POINTER; a_mode: INTEGER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_pattern_set_filter((cairo_pattern_t*)$a_pattern, $a_mode);"
		end

	c_pattern_get_filter (a_pattern: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_pattern_get_filter((cairo_pattern_t*)$a_pattern);"
		end

	c_pattern_destroy (a_pattern: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_pattern_destroy((cairo_pattern_t*)$a_pattern);"
		end

end
