note
	description: "[
		CAIRO_FONT_FACE - a cairo_font_face_t over a Windows font
		realization: an HFONT, optionally with the LOGFONTW it came from.

		This is the paint half of a shaped-text pipeline. The shaper
		(simple_shaping) realizes a font as an HFONT, shapes through it,
		and emits PHYSICAL glyph indices; a face built here from that
		same HFONT draws those indices through ExtTextOutW with
		ETO_GLYPH_INDEX, so the two id spaces are the same one.

		SAME-N RULE (D-S03 / DR-009): cairo IGNORES the LOGFONT height
		fields. It sizes text through the font matrix, which is to say
		through CAIRO_CONTEXT.set_font_size. Shape at pixel size N, then
		set_font_size (N) on this face - otherwise the shaper's positions
		and cairo's glyphs describe different type.

		SAME-N TRAP - READ THIS BEFORE PAINTING (measured on cairo
		1.17.2 / win64). At exactly set_font_size (N), where N is the
		pixel size the HFONT was built at, and with the DEFAULT antialias
		mode, cairo's win32 backend reuses the caller's HFONT as its own
		internal SCALED font - which it builds at 32 x N - so glyphs come
		back about 1/32 of full size: a 16 px capital H measures 4x1
		instead of 12x11, and paints to match. Nothing reports an error.
		And same-N is the ONE case a shaping caller is always in.

		The fix is one line per context, before any glyph is drawn:

			ctx.set_font_antialias (ctx.Antialias_subpixel)

		ANY explicit antialias mode works - an explicit mode changes the
		quality cairo asks for and so forces it to build its own properly
		scaled HFONT - and subpixel keeps ClearType, so the workaround
		costs no rendering quality. Every size OTHER than N is correct
		either way. Pinned by test_same_n_needs_explicit_antialias.

		HFONT LIFETIME - the second half of the same trap. Cairo's win32
		font-face hash table is keyed on face name, weight and italic, and
		ignores BOTH the height and the HFONT. So the face cairo builds
		from an HFONT outlives every CAIRO_FONT_FACE object wrapping it,
		and is handed back for every later HFONT of the same family. Two
		consequences:

		  * The trap size follows the FIRST HFONT cairo saw for a family;
		    it cannot be dodged by choosing sizes.
		  * DeleteObject on an HFONT cairo has cached leaves cairo holding
		    a dangling GDI handle. The next paint through it fails with
		    CAIRO_STATUS_WIN32_GDI_ERROR (41), which poisons the context
		    AND the shared face for the rest of the process. Keep every
		    HFONT alive as long as cairo might paint with it - for a font
		    registry, that is the life of the process.

		LIFETIME: the caller owns the HFONT and must keep it alive for as
		long as the face is used, then release it AFTER `destroy'. The
		face is reference counted; `destroy' drops this object's
		reference, and `reference_count' reports what cairo still holds
		(a context that has the face installed holds one of its own).

		A bad handle never raises: a null HFONT gives a face with
		`is_valid' False and a non-zero `status'.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_FONT_FACE

create
	make_for_hfont, make_for_logfontw_hfont

feature {NONE} -- Initialization

	make_for_hfont (a_hfont: POINTER)
			-- Face for the font realization `a_hfont'.
			-- A null HFONT yields an invalid face, not an exception.
		do
			handle := c_face_for_hfont (a_hfont)
		ensure
			null_hfont_is_invalid: a_hfont = default_pointer implies not is_valid
		end

	make_for_logfontw_hfont (a_logfontw: POINTER; a_hfont: POINTER)
			-- Face for `a_hfont', described by `a_logfontw'.
			-- This is the constructor a shaper wants: it hands cairo the
			-- LOGFONTW it already built, so cairo need not recover one
			-- with GetObjectW. Either argument may be null, but a face
			-- made from two nulls is invalid, not an exception.
		do
			handle := c_face_for_logfontw_hfont (a_logfontw, a_hfont)
		ensure
			both_null_is_invalid: (a_logfontw = default_pointer and
				a_hfont = default_pointer) implies not is_valid
		end

feature -- Access

	handle: POINTER
			-- Underlying cairo_font_face_t pointer.

feature -- Status

	is_valid: BOOLEAN
			-- Is the face usable as a paint source?
		do
			Result := handle /= default_pointer and then c_face_status (handle) = 0
		end

	status: INTEGER
			-- Cairo status code (0 = OK); -1 when there is no handle at all.
		do
			if handle /= default_pointer then
				Result := c_face_status (handle)
			else
				Result := -1
			end
		end

	status_message: STRING_32
			-- Human-readable form of `status'.
		local
			c: C_STRING
		do
			create c.make_by_pointer (c_status_string (status))
			Result := c.string.to_string_32
		end

	reference_count: INTEGER
			-- References cairo still holds on this face; 0 once destroyed.
			-- A context with the face installed holds one of its own, so
			-- this is normally 1 before `set_font_face' and 2 after.
		do
			Result := c_face_ref_count (handle)
		ensure
			non_negative: Result >= 0
		end

feature -- Disposal

	destroy
			-- Drop this object's reference to the face. Cairo frees the
			-- face when the last reference goes; release the HFONT after
			-- this, never before.
		do
			if handle /= default_pointer then
				c_face_destroy (handle)
				handle := default_pointer
			end
		ensure
			destroyed: handle = default_pointer
			not_valid: not is_valid
		end

feature {NONE} -- C Externals

	c_face_for_hfont (a_hfont: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_win32_face_for_hfont($a_hfont);"
		end

	c_face_for_logfontw_hfont (a_logfontw, a_hfont: POINTER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_win32_face_for_logfontw_hfont($a_logfontw, $a_hfont);"
		end

	c_face_status (a_face: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_font_face_status((cairo_font_face_t*)$a_face);"
		end

	c_face_ref_count (a_face: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_font_face_ref_count((cairo_font_face_t*)$a_face);"
		end

	c_face_destroy (a_face: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_font_face_destroy((cairo_font_face_t*)$a_face);"
		end

	c_status_string (a_s: INTEGER): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return (void*)sc_status_string($a_s);"
		end

invariant
	valid_needs_handle: is_valid implies handle /= default_pointer

end
