note
	description: "[
		CAIRO_PDF_SURFACE - PDF output surface for Cairo.

		Creates vector PDF files with full Cairo drawing capabilities.
		Supports multi-page documents, metadata, and standard page sizes.

		Usage:
			local
				pdf: CAIRO_PDF_SURFACE
				ctx: CAIRO_CONTEXT
			do
				create pdf.make_a4 ("output.pdf")
				create ctx.make (pdf.as_surface)

				-- Draw on page 1
				ctx.set_color_hex (0x000000)
				   .select_font ("Arial", 0, 0)
				   .set_font_size (24)
				   .move_to (72, 72)
				   .show_text ("Hello PDF!").do_nothing

				-- Next page
				pdf.show_page (ctx)

				-- Draw on page 2
				ctx.move_to (72, 72)
				   .show_text ("Page 2").do_nothing

				ctx.destroy
				pdf.destroy  -- Finalizes and closes PDF
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_PDF_SURFACE

create
	make, make_a4, make_letter

feature {NONE} -- Initialization

	make (a_filename: READABLE_STRING_GENERAL; a_width, a_height: REAL_64)
			-- Create PDF surface with dimensions in points (72 points = 1 inch).
		require
			filename_not_empty: not a_filename.is_empty
			valid_width: a_width > 0
			valid_height: a_height > 0
		local
			l_filename: C_STRING
		do
			create l_filename.make (a_filename.to_string_8)
			handle := c_pdf_surface_create (l_filename.item, a_width, a_height)
			width := a_width
			height := a_height
		ensure
			dimensions_set: width = a_width and height = a_height
		end

	make_a4 (a_filename: READABLE_STRING_GENERAL)
			-- Create A4 size PDF (210mm x 297mm = 595.28 x 841.89 points).
		require
			filename_not_empty: not a_filename.is_empty
		do
			make (a_filename, Page_a4_width, Page_a4_height)
		end

	make_letter (a_filename: READABLE_STRING_GENERAL)
			-- Create US Letter size PDF (8.5" x 11" = 612 x 792 points).
		require
			filename_not_empty: not a_filename.is_empty
		do
			make (a_filename, Page_letter_width, Page_letter_height)
		end

feature -- Access

	handle: POINTER
			-- Underlying cairo_surface_t pointer.

	width: REAL_64
			-- Page width in points.

	height: REAL_64
			-- Page height in points.

feature -- Status

	is_valid: BOOLEAN
			-- Is surface valid?
		do
			Result := handle /= default_pointer and then c_surface_status (handle) = 0
		end

	status: INTEGER
			-- Surface status code (0 = OK).
		do
			if handle /= default_pointer then
				Result := c_surface_status (handle)
			else
				Result := -1
			end
		end

feature -- Page Management

	show_page (a_context: CAIRO_CONTEXT)
			-- Finish current page and start a new one.
		require
			valid: is_valid
			context_valid: a_context.is_valid
		do
			c_pdf_show_page (a_context.handle)
		end

	set_page_size (a_width, a_height: REAL_64)
			-- Set size for subsequent pages.
		require
			valid: is_valid
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			c_pdf_surface_set_size (handle, a_width, a_height)
			width := a_width
			height := a_height
		ensure
			width_updated: width = a_width
			height_updated: height = a_height
		end

feature -- Metadata

	set_title (a_title: READABLE_STRING_GENERAL)
			-- Set PDF document title.
		require
			valid: is_valid
		local
			l_value: C_STRING
		do
			create l_value.make (a_title.to_string_8)
			c_pdf_set_metadata (handle, Metadata_title, l_value.item)
		end

	set_author (a_author: READABLE_STRING_GENERAL)
			-- Set PDF document author.
		require
			valid: is_valid
		local
			l_value: C_STRING
		do
			create l_value.make (a_author.to_string_8)
			c_pdf_set_metadata (handle, Metadata_author, l_value.item)
		end

	set_subject (a_subject: READABLE_STRING_GENERAL)
			-- Set PDF document subject.
		require
			valid: is_valid
		local
			l_value: C_STRING
		do
			create l_value.make (a_subject.to_string_8)
			c_pdf_set_metadata (handle, Metadata_subject, l_value.item)
		end

	set_keywords (a_keywords: READABLE_STRING_GENERAL)
			-- Set PDF document keywords.
		require
			valid: is_valid
		local
			l_value: C_STRING
		do
			create l_value.make (a_keywords.to_string_8)
			c_pdf_set_metadata (handle, Metadata_keywords, l_value.item)
		end

	set_creator (a_creator: READABLE_STRING_GENERAL)
			-- Set PDF document creator application.
		require
			valid: is_valid
		local
			l_value: C_STRING
		do
			create l_value.make (a_creator.to_string_8)
			c_pdf_set_metadata (handle, Metadata_creator, l_value.item)
		end

feature -- Conversion

	as_surface: CAIRO_SURFACE
			-- Get as generic CAIRO_SURFACE for use with CAIRO_CONTEXT.
			-- Note: This creates a wrapper that shares the handle.
		require
			valid: is_valid
		do
			create Result.make_from_handle (handle)
		end

feature -- Disposal

	destroy
			-- Finalize PDF and release resources.
		do
			if handle /= default_pointer then
				c_surface_destroy (handle)
				handle := default_pointer
			end
		ensure
			destroyed: handle = default_pointer
		end

feature -- Page Size Constants (in points, 72 points = 1 inch)

	Page_a4_width: REAL_64 = 595.28
	Page_a4_height: REAL_64 = 841.89

	Page_letter_width: REAL_64 = 612.0
	Page_letter_height: REAL_64 = 792.0

	Page_legal_width: REAL_64 = 612.0
	Page_legal_height: REAL_64 = 1008.0

	Page_a3_width: REAL_64 = 841.89
	Page_a3_height: REAL_64 = 1190.55

feature {NONE} -- Metadata Constants

	Metadata_title: INTEGER = 0
	Metadata_author: INTEGER = 1
	Metadata_subject: INTEGER = 2
	Metadata_keywords: INTEGER = 3
	Metadata_creator: INTEGER = 4

feature {NONE} -- C Externals

	c_pdf_surface_create (a_filename: POINTER; a_width, a_height: REAL_64): POINTER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_pdf_surface_create((const char*)$a_filename, $a_width, $a_height);"
		end

	c_pdf_surface_set_size (a_surface: POINTER; a_width, a_height: REAL_64)
		external "C inline use %"simple_cairo.h%""
		alias "sc_pdf_surface_set_size((cairo_surface_t*)$a_surface, $a_width, $a_height);"
		end

	c_pdf_show_page (a_cr: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_pdf_show_page((cairo_t*)$a_cr);"
		end

	c_pdf_set_metadata (a_surface: POINTER; a_type: INTEGER; a_value: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_pdf_set_metadata((cairo_surface_t*)$a_surface, $a_type, (const char*)$a_value);"
		end

	c_surface_destroy (a_surface: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_surface_destroy((cairo_surface_t*)$a_surface);"
		end

	c_surface_status (a_surface: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_surface_status((cairo_surface_t*)$a_surface);"
		end

invariant
	positive_dimensions: width > 0 and height > 0

end
