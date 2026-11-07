note
	description: "Windows calls the Cairo tests make: screen DC, GDI fonts and EMF printing."
	author: "Larry Rix"

class
	CAIRO_TEST_PLATFORM

feature {NONE} -- Win32 test externals

	c_get_screen_dc: POINTER
		external "C inline use <windows.h>"
		alias "return (void*)GetDC((HWND)0);"
		end

	c_release_screen_dc (a_dc: POINTER)
		external "C inline use <windows.h>"
		alias "ReleaseDC((HWND)0, (HDC)$a_dc);"
		end

	c_logfontw_size: INTEGER
			-- sizeof (LOGFONTW); 92 on win64.
		external "C inline use <windows.h>"
		alias "return (int)sizeof(LOGFONTW);"
		end

	c_fill_logfontw (a_buf: POINTER; a_pixel_size: INTEGER)
			-- Describe Segoe UI at `a_pixel_size' pixels into `a_buf'.
			-- lfHeight is NEGATIVE: the GDI convention for character height
			-- rather than cell height. Cairo ignores it when sizing (the
			-- same-N rule); it is here so the HFONT itself shapes at N.
		external "C inline use <windows.h>, <string.h>"
		alias "LOGFONTW* lf = (LOGFONTW*)$a_buf;%
			%memset(lf, 0, sizeof(LOGFONTW));%
			%lf->lfHeight = -($a_pixel_size);%
			%lf->lfWeight = FW_NORMAL;%
			%lf->lfCharSet = DEFAULT_CHARSET;%
			%lf->lfOutPrecision = OUT_TT_PRECIS;%
			%lf->lfClipPrecision = CLIP_DEFAULT_PRECIS;%
			%lf->lfQuality = DEFAULT_QUALITY;%
			%lf->lfPitchAndFamily = DEFAULT_PITCH | FF_DONTCARE;%
			%memcpy(lf->lfFaceName, L%"Segoe UI%", sizeof(L%"Segoe UI%"));"
		end

	c_fill_logfontw_consolas (a_buf: POINTER; a_pixel_size: INTEGER)
			-- As `c_fill_logfontw', but Consolas.
		external "C inline use <windows.h>, <string.h>"
		alias "LOGFONTW* lf = (LOGFONTW*)$a_buf;%
			%memset(lf, 0, sizeof(LOGFONTW));%
			%lf->lfHeight = -($a_pixel_size);%
			%lf->lfWeight = FW_NORMAL;%
			%lf->lfCharSet = DEFAULT_CHARSET;%
			%lf->lfOutPrecision = OUT_TT_PRECIS;%
			%lf->lfClipPrecision = CLIP_DEFAULT_PRECIS;%
			%lf->lfQuality = DEFAULT_QUALITY;%
			%lf->lfPitchAndFamily = DEFAULT_PITCH | FF_DONTCARE;%
			%memcpy(lf->lfFaceName, L%"Consolas%", sizeof(L%"Consolas%"));"
		end

	c_create_font_indirect_w (a_logfontw: POINTER): POINTER
		external "C inline use <windows.h>"
		alias "return (void*)CreateFontIndirectW((LOGFONTW*)$a_logfontw);"
		end

	c_glyph_id_for_char (a_hfont: POINTER; a_code: INTEGER): INTEGER
			-- Physical glyph index of `a_code' in `a_hfont', through
			-- GetGlyphIndicesW on a scratch memory DC. This is the id space
			-- a Uniscribe or DirectWrite shaper emits and the space
			-- cairo_glyph_t.index expects; -1 on failure, 0xFFFF when the
			-- font has no glyph for the character.
		external "C inline use <windows.h>"
		alias "HDC dc; HGDIOBJ old; WORD gi; WCHAR ch; DWORD r;%
			%dc = CreateCompatibleDC((HDC)0);%
			%if (!dc) return -1;%
			%old = SelectObject(dc, (HGDIOBJ)$a_hfont);%
			%ch = (WCHAR)($a_code);%
			%gi = 0;%
			%r = GetGlyphIndicesW(dc, &ch, 1, &gi, GGI_MARK_NONEXISTING_GLYPHS);%
			%SelectObject(dc, old);%
			%DeleteDC(dc);%
			%if (r == GDI_ERROR) return -1;%
			%return (int)gi;"
		end

	c_new_emf_dc: POINTER
		external "C inline use <windows.h>"
		alias "return (EIF_POINTER)CreateEnhMetaFileW(NULL, NULL, NULL, NULL);"
		end

	c_close_emf (a_dc: POINTER): POINTER
		external "C inline use <windows.h>"
		alias "return (EIF_POINTER)CloseEnhMetaFile((HDC)$a_dc);"
		end

	c_emf_record_count (a_emf: POINTER): INTEGER
		external "C inline use <windows.h>"
		alias "[
			ENHMETAHEADER l_h;
			if (GetEnhMetaFileHeader((HENHMETAFILE)$a_emf, sizeof(l_h), &l_h) == 0) return 0;
			return (EIF_INTEGER)l_h.nRecords;
		]"
		end

	c_delete_emf (a_emf: POINTER)
		external "C inline use <windows.h>"
		alias "DeleteEnhMetaFile((HENHMETAFILE)$a_emf);"
		end

end
