note
	description: "[
		Stands in for the Windows calls the Cairo tests make. The tests that need
		a screen DC, GDI fonts or EMF printing run on Windows only, so these are
		never relied on: they answer nothing.
	]"
	author: "Larry Rix"

class
	CAIRO_TEST_PLATFORM

feature {NONE} -- Stand-ins

	c_get_screen_dc: POINTER
		do
		end

	c_release_screen_dc (a_dc: POINTER)
		do
		end

	c_logfontw_size: INTEGER = 92

	c_fill_logfontw (a_buf: POINTER; a_pixel_size: INTEGER)
		do
		end

	c_fill_logfontw_consolas (a_buf: POINTER; a_pixel_size: INTEGER)
		do
		end

	c_create_font_indirect_w (a_logfontw: POINTER): POINTER
		do
		end

	c_glyph_id_for_char (a_hfont: POINTER; a_code: INTEGER): INTEGER
		do
			Result := -1
		end

	c_new_emf_dc: POINTER
		do
		end

	c_close_emf (a_dc: POINTER): POINTER
		do
		end

	c_emf_record_count (a_emf: POINTER): INTEGER
		do
		end

	c_delete_emf (a_emf: POINTER)
		do
		end

end
