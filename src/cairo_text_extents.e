note
	description: "[
		Text extents record from cairo_text_extents.

		x_advance is the layout number: where the pen moves after showing
		the text. width is ink coverage only - it excludes trailing
		whitespace and shifts with bearings, so wrap loops must accumulate
		x_advance, never width.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_TEXT_EXTENTS

create {CAIRO_CONTEXT}
	make_from_buffer

feature {NONE} -- Initialization

	make_from_buffer (a_buffer: MANAGED_POINTER)
			-- Read the six REAL_64 fields written by sc_text_extents.
		require
			buffer_large_enough: a_buffer.count >= 48
		do
			x_bearing := a_buffer.read_real_64 (0)
			y_bearing := a_buffer.read_real_64 (8)
			width := a_buffer.read_real_64 (16)
			height := a_buffer.read_real_64 (24)
			x_advance := a_buffer.read_real_64 (32)
			y_advance := a_buffer.read_real_64 (40)
		end

feature -- Access

	x_bearing: REAL_64
			-- Horizontal offset from origin to leftmost ink; may be negative.

	y_bearing: REAL_64
			-- Vertical offset from baseline to topmost ink; typically negative.

	width: REAL_64
			-- Ink width. NOT the layout number - see `x_advance'.

	height: REAL_64
			-- Ink height.

	x_advance: REAL_64
			-- Pen advance after showing the text. THE layout number.

	y_advance: REAL_64
			-- Vertical advance; zero for horizontal scripts.

invariant
	non_negative_width: width >= 0.0
	non_negative_height: height >= 0.0
	-- Bearings and advances are deliberately unconstrained:
	-- negative values are legal (RTL advances, left-overhanging glyphs).

end
