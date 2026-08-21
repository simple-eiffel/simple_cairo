note
	description: "[
		Font metrics record from cairo_font_extents.

		ascent places the first baseline below the top of a text box;
		height is the recommended line-to-line distance; ascent + descent
		sizes a caret. These three numbers are what any text layout
		stands on.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_FONT_EXTENTS

create {CAIRO_CONTEXT}
	make_from_buffer

feature {NONE} -- Initialization

	make_from_buffer (a_buffer: MANAGED_POINTER)
			-- Read the five REAL_64 fields written by sc_font_extents.
		require
			buffer_large_enough: a_buffer.count >= 40
		do
			ascent := a_buffer.read_real_64 (0)
			descent := a_buffer.read_real_64 (8)
			height := a_buffer.read_real_64 (16)
			max_x_advance := a_buffer.read_real_64 (24)
			max_y_advance := a_buffer.read_real_64 (32)
		end

feature -- Access

	ascent: REAL_64
			-- Baseline to top of tallest glyph.

	descent: REAL_64
			-- Baseline to bottom of lowest glyph; positive.

	height: REAL_64
			-- Recommended line-to-line spacing.

	max_x_advance: REAL_64
			-- Widest advance of any glyph in the font.

	max_y_advance: REAL_64
			-- Vertical analogue; zero for horizontal scripts.

invariant
	non_negative_ascent: ascent >= 0.0
	non_negative_descent: descent >= 0.0
	positive_height: height > 0.0

end
