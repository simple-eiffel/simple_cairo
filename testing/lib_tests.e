note
	description: "Test suite for simple_cairo library"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	LIB_TESTS

inherit
	EQA_TEST_SET
		redefine
			on_prepare
		end

feature -- Setup

	on_prepare
			-- Setup before tests.
		do
			create cairo.make
		end

feature -- Access

	cairo: SIMPLE_CAIRO
			-- Cairo facade for testing.

feature -- Surface Tests

	test_surface_creation
			-- Test creating an image surface.
		note
			testing: "covers/{CAIRO_SURFACE}.make"
		local
			surface: CAIRO_SURFACE
		do
			surface := cairo.create_surface (100, 100)
			assert ("surface created", surface /= Void)
			assert ("surface valid", surface.is_valid)
			assert ("width correct", surface.width = 100)
			assert ("height correct", surface.height = 100)
			surface.destroy
			assert ("destroyed", not surface.is_valid)
		end

	test_surface_formats
			-- Test different surface formats.
		note
			testing: "covers/{SIMPLE_CAIRO}.create_surface_format"
		local
			surface: CAIRO_SURFACE
		do
			-- ARGB32
			surface := cairo.create_surface_format (cairo.Format_argb32, 50, 50)
			assert ("argb32 valid", surface.is_valid)
			surface.destroy

			-- RGB24
			surface := cairo.create_surface_format (cairo.Format_rgb24, 50, 50)
			assert ("rgb24 valid", surface.is_valid)
			surface.destroy
		end

feature -- Context Tests

	test_context_creation
			-- Test creating a drawing context.
		note
			testing: "covers/{CAIRO_CONTEXT}.make"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)
			assert ("context created", ctx /= Void)
			assert ("context valid", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_basic_drawing
			-- Test basic drawing operations.
		note
			testing: "covers/{CAIRO_CONTEXT}.fill_rect"
			testing: "covers/{CAIRO_CONTEXT}.stroke_circle"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (200, 200)
			ctx := cairo.create_context (surface)

			-- Clear to white
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing

			-- Draw blue rectangle
			ctx.set_color_hex (0x3498DB).fill_rect (10, 10, 50, 50).do_nothing

			-- Draw red circle outline
			ctx.set_color_hex (0xE74C3C)
			   .set_line_width (3.0)
			   .stroke_circle (100, 100, 40).do_nothing

			assert ("no error after drawing", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_fluent_api
			-- Test fluent API chaining.
		note
			testing: "covers/{CAIRO_CONTEXT}"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Chain multiple operations
			ctx.set_color_rgb (1, 1, 1)
			   .paint
			   .set_color_hex (0xFF0000)
			   .set_line_width (2.0)
			   .move_to (10, 10)
			   .line_to (90, 90)
			   .stroke.do_nothing

			assert ("chaining works", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

feature -- Gradient Tests

	test_linear_gradient
			-- Test linear gradient creation.
		note
			testing: "covers/{CAIRO_GRADIENT}.make_linear"
		local
			grad: CAIRO_GRADIENT
		do
			grad := cairo.linear_gradient (0, 0, 100, 100)
			assert ("gradient created", grad.is_valid)
			assert ("is linear", grad.is_linear)

			grad.add_stop_hex (0.0, 0xFF0000)
			    .add_stop_hex (1.0, 0x0000FF).do_nothing

			grad.destroy
			assert ("destroyed", not grad.is_valid)
		end

	test_radial_gradient
			-- Test radial gradient creation.
		note
			testing: "covers/{CAIRO_GRADIENT}.make_radial"
		local
			grad: CAIRO_GRADIENT
		do
			grad := cairo.radial_gradient (50, 50, 0, 50, 50, 50)
			assert ("gradient created", grad.is_valid)
			assert ("is radial", grad.is_radial)
			grad.destroy
		end

	test_gradient_drawing
			-- Test drawing with gradients.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_gradient"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			grad: CAIRO_GRADIENT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)
			grad := cairo.vertical_gradient (0, 100)

			grad.two_color (0x3498DB, 0x2ECC71).do_nothing
			ctx.set_gradient (grad).fill_rect (0, 0, 100, 100).do_nothing

			assert ("gradient drawing works", ctx.is_valid)
			grad.destroy
			ctx.destroy
			surface.destroy
		end

feature -- Transform Tests

	test_transforms
			-- Test coordinate transforms.
		note
			testing: "covers/{CAIRO_CONTEXT}.translate"
			testing: "covers/{CAIRO_CONTEXT}.scale"
			testing: "covers/{CAIRO_CONTEXT}.rotate"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.save
			   .translate (50, 50)
			   .scale (2.0, 2.0)
			   .rotate (0.785)  -- 45 degrees
			   .fill_rect (-10, -10, 20, 20)
			   .restore.do_nothing

			assert ("transforms work", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

feature -- Text Tests

	test_text_drawing
			-- Test text rendering.
		note
			testing: "covers/{CAIRO_CONTEXT}.show_text"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (200, 50)
			ctx := cairo.create_context (surface)

			ctx.set_color_rgb (0, 0, 0)
			   .select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal)
			   .set_font_size (20.0)
			   .move_to (10, 30)
			   .show_text ("Hello Cairo!").do_nothing

			assert ("text drawing works", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_text_metrics
			-- Test text measurement.
		note
			testing: "covers/{CAIRO_CONTEXT}.text_width"
			testing: "covers/{CAIRO_CONTEXT}.text_height"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			w, h: REAL_64
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.select_font ("Arial", 0, 0).set_font_size (20.0).do_nothing
			w := ctx.text_width ("Test")
			h := ctx.text_height ("Test")

			assert ("width positive", w > 0)
			assert ("height positive", h > 0)
			ctx.destroy
			surface.destroy
		end

feature -- Path Tests

	test_complex_path
			-- Test complex path construction.
		note
			testing: "covers/{CAIRO_CONTEXT}.curve_to"
			testing: "covers/{CAIRO_CONTEXT}.arc"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.new_path
			   .move_to (10, 10)
			   .curve_to (20, 20, 40, 0, 50, 10)
			   .arc (60, 60, 20, 0, 3.14159)
			   .close_path
			   .fill.do_nothing

			assert ("complex path works", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_rounded_rectangle
			-- Test rounded rectangle.
		note
			testing: "covers/{CAIRO_CONTEXT}.rounded_rectangle"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.set_color_hex (0x9B59B6)
			   .rounded_rectangle (10, 10, 80, 80, 10)
			   .fill.do_nothing

			assert ("rounded rect works", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

feature -- Edge Case Tests

	test_minimum_surface_size
			-- Test 1x1 pixel surface (minimum valid size).
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (1, 1)
			assert ("tiny surface valid", surface.is_valid)
			assert ("width is 1", surface.width = 1)
			assert ("height is 1", surface.height = 1)

			ctx := cairo.create_context (surface)
			assert ("context valid", ctx.is_valid)

			-- Should be able to draw a single point
			ctx.set_color_hex (0xFF0000).fill_rect (0, 0, 1, 1).do_nothing
			assert ("drawing works on tiny surface", ctx.is_valid)

			ctx.destroy
			surface.destroy
		end

	test_large_surface
			-- Test reasonably large surface (4K resolution).
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (3840, 2160)
			assert ("large surface valid", surface.is_valid)
			assert ("large width correct", surface.width = 3840)
			assert ("large height correct", surface.height = 2160)

			ctx := cairo.create_context (surface)
			ctx.fill_rect (0, 0, 3840, 2160).do_nothing
			assert ("drawing on large surface works", ctx.is_valid)

			ctx.destroy
			surface.destroy
		end

	test_drawing_at_boundaries
			-- Test drawing at surface edges.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Draw at exact boundaries
			ctx.fill_rect (0, 0, 10, 10).do_nothing          -- Top-left
			ctx.fill_rect (90, 0, 10, 10).do_nothing         -- Top-right
			ctx.fill_rect (0, 90, 10, 10).do_nothing         -- Bottom-left
			ctx.fill_rect (90, 90, 10, 10).do_nothing        -- Bottom-right

			-- Draw lines touching boundaries
			ctx.draw_line (0, 0, 99, 99).do_nothing          -- Diagonal
			ctx.draw_line (0, 50, 99, 50).do_nothing         -- Horizontal
			ctx.draw_line (50, 0, 50, 99).do_nothing         -- Vertical

			assert ("boundary drawing works", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_drawing_outside_boundaries
			-- Test drawing that extends beyond surface - should clip, not crash.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Draw rectangles extending outside
			ctx.fill_rect (-50, -50, 100, 100).do_nothing      -- Top-left overflow
			ctx.fill_rect (50, 50, 100, 100).do_nothing        -- Bottom-right overflow
			ctx.fill_rect (-100, 40, 300, 20).do_nothing       -- Horizontal overflow

			-- Draw circles centered outside
			ctx.fill_circle (-50, 50, 30).do_nothing           -- Left of surface
			ctx.fill_circle (150, 50, 30).do_nothing           -- Right of surface

			assert ("out of bounds drawing handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_negative_coordinates
			-- Test drawing with negative coordinates.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.move_to (-10, -10)
			   .line_to (50, 50)
			   .stroke.do_nothing

			ctx.fill_rect (-20, -20, 40, 40).do_nothing

			assert ("negative coords handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_minimum_line_width
			-- Test line drawing with minimum valid width.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Minimum positive line width (API requires positive)
			ctx.set_line_width (0.001)
			   .move_to (10, 10)
			   .line_to (90, 90)
			   .stroke.do_nothing

			-- Very thin width produces hairline
			assert ("minimum line width handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_very_thin_line_width
			-- Test very small but non-zero line width.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.set_line_width (0.001)
			   .move_to (10, 10)
			   .line_to (90, 90)
			   .stroke.do_nothing

			assert ("very thin line handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_very_thick_line_width
			-- Test very large line width.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.set_line_width (500.0)
			   .move_to (10, 10)
			   .line_to (90, 90)
			   .stroke.do_nothing

			assert ("very thick line handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_minimum_radius_circle
			-- Test circle with minimum valid radius.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Minimum positive radius (API requires positive_radius)
			ctx.fill_circle (50, 50, 0.001).do_nothing
			ctx.stroke_circle (50, 50, 0.001).do_nothing

			-- Very small radius produces point-like circle
			assert ("minimum radius handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_empty_text
			-- Test drawing empty string.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.select_font ("Arial", 0, 0)
			   .set_font_size (12.0)
			   .move_to (10, 50)
			   .show_text ("").do_nothing

			assert ("empty text handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_text_metrics_empty_string
			-- Test text measurement of empty string.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			w, h: REAL_64
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			ctx.select_font ("Arial", 0, 0).set_font_size (20.0).do_nothing
			w := ctx.text_width ("")
			h := ctx.text_height ("")

			-- Empty string should have 0 width, height may be font height
			assert ("empty text width zero or small", w >= 0 and w < 1)
			ctx.destroy
			surface.destroy
		end

	test_color_boundaries
			-- Test color values at boundaries.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Test RGB boundaries (0.0 to 1.0)
			ctx.set_color_rgb (0.0, 0.0, 0.0).fill_rect (0, 0, 20, 20).do_nothing
			ctx.set_color_rgb (1.0, 1.0, 1.0).fill_rect (20, 0, 20, 20).do_nothing
			ctx.set_color_rgba (0.0, 0.0, 0.0, 0.0).fill_rect (40, 0, 20, 20).do_nothing   -- Fully transparent
			ctx.set_color_rgba (1.0, 1.0, 1.0, 1.0).fill_rect (60, 0, 20, 20).do_nothing   -- Fully opaque

			-- Test hex boundaries
			ctx.set_color_hex (0x000000).fill_rect (0, 20, 20, 20).do_nothing   -- Black
			ctx.set_color_hex (0xFFFFFF).fill_rect (20, 20, 20, 20).do_nothing  -- White

			assert ("color boundaries handled", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_gradient_single_stop
			-- Test gradient with just one color stop.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			grad: CAIRO_GRADIENT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)
			grad := cairo.linear_gradient (0, 0, 100, 0)

			-- Single color stop - behavior depends on Cairo implementation
			grad.add_stop_hex (0.5, 0xFF0000).do_nothing

			ctx.set_gradient (grad).fill_rect (0, 0, 100, 100).do_nothing

			-- Should not crash even if behavior is undefined
			assert ("single stop gradient handled", ctx.is_valid)
			grad.destroy
			ctx.destroy
			surface.destroy
		end

	test_gradient_many_stops
			-- Test gradient with many color stops.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			grad: CAIRO_GRADIENT
			i: INTEGER
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)
			grad := cairo.linear_gradient (0, 0, 100, 0)

			-- Add many stops (rainbow + extra)
			from i := 0 until i > 100 loop
				grad.add_stop_rgb (i / 100.0, (i * 2) / 255.0, (255 - i * 2) / 255.0, 0.5).do_nothing
				i := i + 1
			end

			ctx.set_gradient (grad).fill_rect (0, 0, 100, 100).do_nothing

			assert ("many stops gradient handled", ctx.is_valid)
			grad.destroy
			ctx.destroy
			surface.destroy
		end

	test_save_restore_stack
			-- Test deep save/restore stack.
		note
			testing: "edge-case"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			i: INTEGER
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Deep save stack
			from i := 1 until i > 50 loop
				ctx.save.translate (1, 1).do_nothing
				i := i + 1
			end

			ctx.fill_rect (0, 0, 10, 10).do_nothing

			-- Restore all
			from i := 1 until i > 50 loop
				ctx.restore.do_nothing
				i := i + 1
			end

			assert ("deep save/restore works", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

	test_multiple_surfaces
			-- Test creating multiple surfaces simultaneously.
		note
			testing: "edge-case"
		local
			s1, s2, s3: CAIRO_SURFACE
			c1, c2, c3: CAIRO_CONTEXT
		do
			s1 := cairo.create_surface (100, 100)
			s2 := cairo.create_surface (200, 200)
			s3 := cairo.create_surface (50, 50)

			c1 := cairo.create_context (s1)
			c2 := cairo.create_context (s2)
			c3 := cairo.create_context (s3)

			-- Draw on all three
			c1.fill_rect (0, 0, 100, 100).do_nothing
			c2.fill_rect (0, 0, 200, 200).do_nothing
			c3.fill_rect (0, 0, 50, 50).do_nothing

			assert ("surface 1 valid", s1.is_valid and c1.is_valid)
			assert ("surface 2 valid", s2.is_valid and c2.is_valid)
			assert ("surface 3 valid", s3.is_valid and c3.is_valid)

			-- Cleanup in different order than creation
			c2.destroy
			s2.destroy
			c3.destroy
			s3.destroy
			c1.destroy
			s1.destroy
		end

	test_rapid_create_destroy
			-- Test rapid surface creation and destruction.
		note
			testing: "edge-case"
			testing: "stress"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			i: INTEGER
		do
			from i := 1 until i > 100 loop
				surface := cairo.create_surface (100, 100)
				ctx := cairo.create_context (surface)
				ctx.fill_rect (0, 0, 100, 100).do_nothing
				ctx.destroy
				surface.destroy
				i := i + 1
			end
			-- Memory should not leak (can't directly test, but should not crash)
			assert ("rapid create/destroy succeeded", True)
		end

feature -- Layer 0: Measurement Tests (S09)

	test_text_extents_basic
			-- Non-empty text has positive width, height, and advance.
		note
			testing: "covers/{CAIRO_CONTEXT}.text_extents"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			ext: CAIRO_TEXT_EXTENTS
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal).set_font_size (16.0).do_nothing
			ext := ctx.text_extents ("Measure")
			assert ("positive width", ext.width > 0.0)
			assert ("positive height", ext.height > 0.0)
			assert ("positive advance", ext.x_advance > 0.0)
			ctx.destroy
			surface.destroy
		end

	test_text_extents_monotonic_advance
			-- Appending a character strictly grows the advance.
		note
			testing: "covers/{CAIRO_CONTEXT}.text_extents"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal).set_font_size (16.0).do_nothing
			assert ("ab advances past a",
				ctx.text_extents ("ab").x_advance > ctx.text_extents ("a").x_advance)
			ctx.destroy
			surface.destroy
		end

	test_trailing_space_advance_exceeds_width
			-- THE width-is-not-advance proof: a trailing space adds advance
			-- but no ink, so for "a " x_advance > width. Pinned as a test so
			-- the distinction can never silently regress (S09 section 5).
		note
			testing: "covers/{CAIRO_CONTEXT}.text_extents"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			ext: CAIRO_TEXT_EXTENTS
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal).set_font_size (16.0).do_nothing
			ext := ctx.text_extents ("a ")
			assert ("advance exceeds ink width", ext.x_advance > ext.width)
			assert ("space advanced past bare a",
				ext.x_advance > ctx.text_extents ("a").x_advance)
			ctx.destroy
			surface.destroy
		end

	test_text_extents_empty
			-- Empty string measures all-zero.
		note
			testing: "covers/{CAIRO_CONTEXT}.text_extents"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			ext: CAIRO_TEXT_EXTENTS
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ext := ctx.text_extents ("")
			assert ("zero width", ext.width = 0.0)
			assert ("zero height", ext.height = 0.0)
			assert ("zero x_advance", ext.x_advance = 0.0)
			assert ("zero y_advance", ext.y_advance = 0.0)
			ctx.destroy
			surface.destroy
		end

	test_text_extents_deterministic
			-- Same text, same state: identical records.
		note
			testing: "covers/{CAIRO_CONTEXT}.text_extents"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			a, b: CAIRO_TEXT_EXTENTS
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal).set_font_size (14.0).do_nothing
			a := ctx.text_extents ("determinism")
			b := ctx.text_extents ("determinism")
			assert ("width equal", a.width = b.width)
			assert ("height equal", a.height = b.height)
			assert ("x_advance equal", a.x_advance = b.x_advance)
			assert ("x_bearing equal", a.x_bearing = b.x_bearing)
			assert ("y_bearing equal", a.y_bearing = b.y_bearing)
			ctx.destroy
			surface.destroy
		end

	test_font_extents_sane
			-- A selected font reports positive ascent and line height.
		note
			testing: "covers/{CAIRO_CONTEXT}.font_extents"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			fe: CAIRO_FONT_EXTENTS
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal).set_font_size (16.0).do_nothing
			fe := ctx.font_extents
			assert ("positive ascent", fe.ascent > 0.0)
			assert ("non-negative descent", fe.descent >= 0.0)
			assert ("positive line height", fe.height > 0.0)
			ctx.destroy
			surface.destroy
		end

	test_text_width_agrees_with_extents
			-- The legacy query and the full record cannot disagree.
		note
			testing: "covers/{CAIRO_CONTEXT}.text_width"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal).set_font_size (16.0).do_nothing
			assert ("width agrees",
				ctx.text_width ("agree") = ctx.text_extents ("agree").width)
			assert ("height agrees",
				ctx.text_height ("agree") = ctx.text_extents ("agree").height)
			ctx.destroy
			surface.destroy
		end

feature -- Layer 0: Clip, Group, Dash, Quality Tests (S09)

	test_clip_restricts_painting
			-- Paint inside a clip lands; outside it does not.
		note
			testing: "covers/{CAIRO_CONTEXT}.clip_rectangle"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (20, 20)
			ctx := cairo.create_context (surface)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.clip_rectangle (5.0, 5.0, 10.0, 10.0).do_nothing
			ctx.set_color_rgb (1.0, 0.0, 0.0).paint.do_nothing
			surface.flush.do_nothing
			assert ("inside clip is red", pixel (surface, 10, 10) = Red_pixel)
			assert ("outside clip is white", pixel (surface, 2, 2) = White_pixel)
			ctx.destroy
			surface.destroy
		end

	test_reset_clip_restores_full_extents
			-- After reset_clip the clip is the whole surface again.
		note
			testing: "covers/{CAIRO_CONTEXT}.reset_clip"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			ext: TUPLE [x1, y1, x2, y2: REAL_64]
		do
			surface := cairo.create_surface (20, 20)
			ctx := cairo.create_context (surface)
			ctx.clip_rectangle (2.0, 2.0, 5.0, 5.0).do_nothing
			ext := ctx.clip_extents
			assert ("clipped narrower", ext.x2 - ext.x1 < 20.0)
			ctx.reset_clip.do_nothing
			ext := ctx.clip_extents
			assert ("full width restored", ext.x2 - ext.x1 = 20.0)
			assert ("full height restored", ext.y2 - ext.y1 = 20.0)
			ctx.destroy
			surface.destroy
		end

	test_group_composites_on_pop
			-- push_group captures drawing; pop_group_to_source + paint lands it.
		note
			testing: "covers/{CAIRO_CONTEXT}.push_group"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (20, 20)
			ctx := cairo.create_context (surface)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.push_group.set_color_rgb (1.0, 0.0, 0.0).paint.pop_group_to_source.paint.do_nothing
			surface.flush.do_nothing
			assert ("group composited red", pixel (surface, 5, 5) = Red_pixel)
			assert ("depth balanced", ctx.group_depth = 0)
			ctx.destroy
			surface.destroy
		end

	test_dash_reduces_ink
			-- A dashed line inks strictly fewer pixels; clear_dash restores solid.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_dash"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			solid, dashed: INTEGER
		do
			surface := cairo.create_surface (40, 10)
			ctx := cairo.create_context (surface)
			ctx.set_antialias (ctx.Antialias_none).set_line_width (4.0).do_nothing
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.set_color_rgb (0.0, 0.0, 0.0).move_to (0.0, 5.0).line_to (40.0, 5.0).stroke.do_nothing
			surface.flush.do_nothing
			solid := row_ink_count (surface, 5)
			assert ("solid line inked", solid >= 30)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.set_dash (<<4.0, 4.0>>, 0.0).do_nothing
			ctx.set_color_rgb (0.0, 0.0, 0.0).move_to (0.0, 5.0).line_to (40.0, 5.0).stroke.do_nothing
			surface.flush.do_nothing
			dashed := row_ink_count (surface, 5)
			assert ("dash reduces ink", dashed < solid)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.clear_dash.do_nothing
			ctx.set_color_rgb (0.0, 0.0, 0.0).move_to (0.0, 5.0).line_to (40.0, 5.0).stroke.do_nothing
			surface.flush.do_nothing
			assert ("clear_dash restores solid", row_ink_count (surface, 5) = solid)
			ctx.destroy
			surface.destroy
		end

	test_antialias_none_two_tone_edge
			-- Antialias_none yields hard two-tone edges; smoothing yields more.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_antialias"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (30, 30)
			ctx := cairo.create_context (surface)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.set_line_width (2.0).do_nothing
			ctx.set_antialias (ctx.Antialias_none).do_nothing
			ctx.set_color_rgb (0.0, 0.0, 0.0).move_to (0.0, 0.0).line_to (30.0, 30.0).stroke.do_nothing
			surface.flush.do_nothing
			assert ("aliased edge is two-tone", distinct_count_in_row (surface, 15) <= 2)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.set_antialias (ctx.Antialias_good).do_nothing
			ctx.set_color_rgb (0.0, 0.0, 0.0).move_to (0.0, 0.0).line_to (30.0, 30.0).stroke.do_nothing
			surface.flush.do_nothing
			assert ("antialiased edge has gradient", distinct_count_in_row (surface, 15) > 2)
			ctx.destroy
			surface.destroy
		end

	test_font_quality_smoke
			-- Font antialias and hinting apply without fault and text still inks.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_font_antialias"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			y, ink: INTEGER
		do
			surface := cairo.create_surface (40, 24)
			ctx := cairo.create_context (surface)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_bold).set_font_size (14.0).do_nothing
			ctx.set_font_antialias (ctx.Antialias_none).set_font_hint_style (ctx.Hint_style_full).do_nothing
			ctx.set_color_rgb (0.0, 0.0, 0.0).move_to (2.0, 18.0).show_text ("Hi").do_nothing
			surface.flush.do_nothing
			from
				y := 0
			until
				y >= surface.height
			loop
				ink := ink + row_ink_count (surface, y)
				y := y + 1
			end
			assert ("text rendered ink", ink > 0)
			ctx.destroy
			surface.destroy
		end

	test_flush_mark_dirty_smoke
			-- Synchronization commands run without fault and keep validity.
		note
			testing: "covers/{CAIRO_SURFACE}.flush"
		local
			surface: CAIRO_SURFACE
		do
			surface := cairo.create_surface (8, 8)
			surface.flush.mark_dirty.do_nothing
			assert ("still valid", surface.is_valid)
			surface.destroy
		end

feature -- Layer 0: Acceptance (S09)

	test_wrap_loop
			-- S09 acceptance: the SV_BLOCK_EDITOR wrap algorithm against the
			-- new API. Accumulate x_advance per word, break at 200 px. When
			-- this is green, "usable for simple_narrate" is a fact with a name.
		note
			testing: "covers/{CAIRO_CONTEXT}.text_extents"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			words: LIST [STRING_32]
			line_width, space_adv, word_adv, max_width: REAL_64
			line_count: INTEGER
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal).set_font_size (16.0).do_nothing
			space_adv := ctx.text_extents (" ").x_advance
			assert ("space advances", space_adv > 0.0)
			max_width := 200.0
			words := ("the quick brown fox jumps over the lazy dog and keeps on running past the fence").to_string_32.split (' ')
			line_count := 1
			line_width := 0.0
			across words as w loop
				word_adv := ctx.text_extents (w).x_advance
				assert ("word fits alone", word_adv <= max_width)
				if line_width > 0.0 and then line_width + space_adv + word_adv > max_width then
					line_count := line_count + 1
					line_width := word_adv
				elseif line_width > 0.0 then
					line_width := line_width + space_adv + word_adv
				else
					line_width := word_adv
				end
				assert ("line within budget", line_width <= max_width)
			end
			assert ("wrapped to multiple lines", line_count > 1)
			ctx.destroy
			surface.destroy
		end

feature -- Layer 0: Contract Violation Tests (S09)

	test_dash_rejects_all_zero
			-- An all-zero dash pattern violates some_ink. This test doubles as
			-- the assertions-are-live proof: compiled-out preconditions fail it.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_dash"
		local
			surface: detachable CAIRO_SURFACE
			ctx: detachable CAIRO_CONTEXT
			violated, done: BOOLEAN
		do
			if not done then
				surface := cairo.create_surface (8, 8)
				ctx := cairo.create_context (surface)
				if attached ctx as c then
					c.set_dash (<<0.0, 0.0>>, 0.0).do_nothing
				end
			end
			assert ("all-zero dash rejected", violated)
			if attached ctx as c then
				c.destroy
			end
			if attached surface as s then
				s.destroy
			end
		rescue
			violated := True
			done := True
			retry
		end

	test_clip_rectangle_rejects_zero_extent
			-- A zero-width clip rectangle violates positive_extent.
		note
			testing: "covers/{CAIRO_CONTEXT}.clip_rectangle"
		local
			surface: detachable CAIRO_SURFACE
			ctx: detachable CAIRO_CONTEXT
			violated, done: BOOLEAN
		do
			if not done then
				surface := cairo.create_surface (8, 8)
				ctx := cairo.create_context (surface)
				if attached ctx as c then
					c.clip_rectangle (0.0, 0.0, 0.0, 5.0).do_nothing
				end
			end
			assert ("zero extent rejected", violated)
			if attached ctx as c then
				c.destroy
			end
			if attached surface as s then
				s.destroy
			end
		rescue
			violated := True
			done := True
			retry
		end

	test_pop_group_requires_push
			-- pop_group_to_source with no open group violates group_open.
		note
			testing: "covers/{CAIRO_CONTEXT}.pop_group_to_source"
		local
			surface: detachable CAIRO_SURFACE
			ctx: detachable CAIRO_CONTEXT
			violated, done: BOOLEAN
		do
			if not done then
				surface := cairo.create_surface (8, 8)
				ctx := cairo.create_context (surface)
				if attached ctx as c then
					c.pop_group_to_source.do_nothing
				end
			end
			assert ("unbalanced pop rejected", violated)
			if attached ctx as c then
				c.destroy
			end
			if attached surface as s then
				s.destroy
			end
		rescue
			violated := True
			done := True
			retry
		end

feature {NONE} -- Layer 0: Pixel Helpers

	White_pixel: NATURAL_32 = 0xFFFFFFFF
	Red_pixel: NATURAL_32 = 0xFFFF0000

	pixel (a_surface: CAIRO_SURFACE; a_x, a_y: INTEGER): NATURAL_32
			-- ARGB32 pixel at (a_x, a_y), read as 0xAARRGGBB (little-endian).
		require
			valid: a_surface.is_valid
			in_range: a_x >= 0 and a_y >= 0 and a_x < a_surface.width and a_y < a_surface.height
		local
			mp: MANAGED_POINTER
		do
			create mp.share_from_pointer (a_surface.data, a_surface.stride * a_surface.height)
			Result := mp.read_natural_32 (a_y * a_surface.stride + a_x * 4)
		end

	row_ink_count (a_surface: CAIRO_SURFACE; a_y: INTEGER): INTEGER
			-- Number of non-white pixels in row a_y.
		local
			x: INTEGER
		do
			from
				x := 0
			until
				x >= a_surface.width
			loop
				if pixel (a_surface, x, a_y) /= White_pixel then
					Result := Result + 1
				end
				x := x + 1
			end
		end

	distinct_count_in_row (a_surface: CAIRO_SURFACE; a_y: INTEGER): INTEGER
			-- Number of distinct pixel values in row a_y.
			-- ARRAYED_LIST.has compares identity; NATURAL_32 is expanded,
			-- so identity IS value here (oracle gotcha checked).
		local
			x: INTEGER
			seen: ARRAYED_LIST [NATURAL_32]
			p: NATURAL_32
		do
			create seen.make (8)
			from
				x := 0
			until
				x >= a_surface.width
			loop
				p := pixel (a_surface, x, a_y)
				if not seen.has (p) then
					seen.extend (p)
				end
				x := x + 1
			end
			Result := seen.count
		end

feature -- Phase B: Compositing & Pattern Tests (S10)

	test_operator_clear_erases
			-- Operator_clear paints transparency over everything.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_operator"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.set_operator (ctx.Operator_clear).paint.do_nothing
			surface.flush.do_nothing
			assert ("cleared to transparent", pixel (surface, 5, 5) = 0)
			ctx.destroy
			surface.destroy
		end

	test_operator_roundtrip
			-- Setter and getter agree.
		note
			testing: "covers/{CAIRO_CONTEXT}.drawing_operator"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			assert ("default is over", ctx.drawing_operator = ctx.Operator_over)
			ctx.set_operator (ctx.Operator_xor).do_nothing
			assert ("xor set", ctx.drawing_operator = ctx.Operator_xor)
			ctx.destroy
			surface.destroy
		end

	test_set_source_surface_places
			-- A source surface paints at its offset; Extend_none leaves the rest.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_source_surface"
		local
			src, dest: CAIRO_SURFACE
			sctx, dctx: CAIRO_CONTEXT
		do
			src := cairo.create_surface (10, 10)
			sctx := cairo.create_context (src)
			sctx.set_color_rgb (1.0, 0.0, 0.0).paint.do_nothing
			sctx.destroy
			dest := cairo.create_surface (20, 20)
			dctx := cairo.create_context (dest)
			dctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			dctx.set_source_surface (src, 5.0, 5.0).paint.do_nothing
			dest.flush.do_nothing
			assert ("inside placed source is red", pixel (dest, 7, 7) = Red_pixel)
			assert ("outside stays white", pixel (dest, 2, 2) = White_pixel)
			dctx.destroy
			dest.destroy
			src.destroy
		end

	test_surface_pattern_repeat
			-- Extend_repeat tiles the source.
		note
			testing: "covers/{CAIRO_SURFACE_PATTERN}.make_from_surface"
		local
			src, dest: CAIRO_SURFACE
			sctx, dctx: CAIRO_CONTEXT
			pat: CAIRO_SURFACE_PATTERN
		do
			src := cairo.create_surface (2, 2)
			sctx := cairo.create_context (src)
			sctx.set_color_rgb (1.0, 0.0, 0.0).fill_rect (0.0, 0.0, 1.0, 2.0).do_nothing
			sctx.set_color_rgb (0.0, 0.0, 1.0).fill_rect (1.0, 0.0, 1.0, 2.0).do_nothing
			sctx.destroy
			pat := cairo.surface_pattern (src)
			pat.set_extend (pat.Extend_repeat).set_filter (pat.Filter_nearest).do_nothing
			dest := cairo.create_surface (8, 8)
			dctx := cairo.create_context (dest)
			dctx.set_pattern (pat).paint.do_nothing
			dest.flush.do_nothing
			assert ("x0 red", pixel (dest, 0, 0) = Red_pixel)
			assert ("x1 blue", pixel (dest, 1, 0) = Blue_pixel)
			assert ("x2 tiles red again", pixel (dest, 2, 0) = Red_pixel)
			assert ("x3 tiles blue again", pixel (dest, 3, 0) = Blue_pixel)
			pat.destroy
			dctx.destroy
			dest.destroy
			src.destroy
		end

	test_solid_pattern_paints
			-- A solid pattern paints its exact color.
		note
			testing: "covers/{CAIRO_SOLID_PATTERN}.make_rgb"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			pat: CAIRO_SOLID_PATTERN
		do
			surface := cairo.create_surface (10, 10)
			ctx := cairo.create_context (surface)
			pat := cairo.solid_pattern (0.0, 1.0, 0.0)
			ctx.set_pattern (pat).paint.do_nothing
			surface.flush.do_nothing
			assert ("green painted", pixel (surface, 5, 5) = Green_pixel)
			pat.destroy
			ctx.destroy
			surface.destroy
		end

	test_gradient_extend_pad_endpoints
			-- Beyond its stops, a padded gradient holds its end colors exactly.
		note
			testing: "covers/{CAIRO_PATTERN}.set_extend"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			grad: CAIRO_GRADIENT
		do
			surface := cairo.create_surface (30, 4)
			ctx := cairo.create_context (surface)
			grad := cairo.linear_gradient (5.0, 0.0, 15.0, 0.0)
			grad.add_stop_rgb (0.0, 1.0, 0.0, 0.0).add_stop_rgb (1.0, 0.0, 0.0, 1.0).do_nothing
			grad.set_extend (grad.Extend_pad).do_nothing
			ctx.set_gradient (grad).paint.do_nothing
			surface.flush.do_nothing
			assert ("before start pads pure red", pixel (surface, 1, 1) = Red_pixel)
			assert ("after end pads pure blue", pixel (surface, 28, 1) = Blue_pixel)
			grad.destroy
			ctx.destroy
			surface.destroy
		end

	test_mask_surface_gates_paint
			-- The source lands only where the mask has alpha.
		note
			testing: "covers/{CAIRO_CONTEXT}.mask_surface"
		local
			mask_s, dest: CAIRO_SURFACE
			mctx, dctx: CAIRO_CONTEXT
		do
			mask_s := cairo.create_surface_format (cairo.Format_a8, 20, 20)
			mctx := cairo.create_context (mask_s)
			mctx.set_color_rgba (0.0, 0.0, 0.0, 1.0).fill_rect (5.0, 5.0, 10.0, 10.0).do_nothing
			mctx.destroy
			dest := cairo.create_surface (20, 20)
			dctx := cairo.create_context (dest)
			dctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			dctx.set_color_rgb (1.0, 0.0, 0.0).mask_surface (mask_s, 0.0, 0.0).do_nothing
			dest.flush.do_nothing
			assert ("inside mask is red", pixel (dest, 10, 10) = Red_pixel)
			assert ("outside mask stays white", pixel (dest, 2, 2) = White_pixel)
			dctx.destroy
			dest.destroy
			mask_s.destroy
		end

	test_mesh_corner_colors
			-- A coons patch shows each corner's color near that corner.
		note
			testing: "covers/{CAIRO_MESH_PATTERN}.set_corner_color_rgb"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			mesh: CAIRO_MESH_PATTERN
		do
			surface := cairo.create_surface (20, 20)
			ctx := cairo.create_context (surface)
			mesh := cairo.mesh_pattern
			mesh.begin_patch.move_to (0.0, 0.0).line_to (20.0, 0.0).line_to (20.0, 20.0).line_to (0.0, 20.0).do_nothing
			mesh.set_corner_color_rgb (0, 1.0, 0.0, 0.0).do_nothing
			mesh.set_corner_color_rgb (1, 0.0, 1.0, 0.0).do_nothing
			mesh.set_corner_color_rgb (2, 0.0, 0.0, 1.0).do_nothing
			mesh.set_corner_color_rgb (3, 1.0, 1.0, 0.0).do_nothing
			mesh.end_patch.do_nothing
			assert ("patch closed", not mesh.in_patch)
			ctx.set_pattern (mesh).paint.do_nothing
			surface.flush.do_nothing
			assert ("corner 0 reddish", channels_near (pixel (surface, 1, 1), 255, 0, 0, 60))
			assert ("corner 1 greenish", channels_near (pixel (surface, 18, 1), 0, 255, 0, 60))
			assert ("corner 2 bluish", channels_near (pixel (surface, 18, 18), 0, 0, 255, 60))
			assert ("corner 3 yellowish", channels_near (pixel (surface, 1, 18), 255, 255, 0, 60))
			mesh.destroy
			ctx.destroy
			surface.destroy
		end

	test_pattern_filter_roundtrip
			-- Extend and filter setters agree with their getters.
		note
			testing: "covers/{CAIRO_PATTERN}.set_filter"
		local
			pat: CAIRO_SOLID_PATTERN
		do
			pat := cairo.solid_pattern (0.5, 0.5, 0.5)
			pat.set_extend (pat.Extend_reflect).set_filter (pat.Filter_nearest).do_nothing
			assert ("extend roundtrip", pat.extend_mode = pat.Extend_reflect)
			assert ("filter roundtrip", pat.filter_mode = pat.Filter_nearest)
			pat.destroy
		end

	test_arc_negative_draws
			-- The clockwise arc inks pixels.
		note
			testing: "covers/{CAIRO_CONTEXT}.arc_negative"
		local
			surface: CAIRO_SURFACE
			ctx: CAIRO_CONTEXT
			y, ink: INTEGER
		do
			surface := cairo.create_surface (30, 30)
			ctx := cairo.create_context (surface)
			ctx.set_color_rgb (1.0, 1.0, 1.0).paint.do_nothing
			ctx.set_color_rgb (0.0, 0.0, 0.0).set_line_width (2.0).do_nothing
			ctx.arc_negative (15.0, 15.0, 10.0, 0.0, 3.14159).stroke.do_nothing
			surface.flush.do_nothing
			from
				y := 0
			until
				y >= surface.height
			loop
				ink := ink + row_ink_count (surface, y)
				y := y + 1
			end
			assert ("arc inked", ink > 0)
			ctx.destroy
			surface.destroy
		end

	test_operator_rejects_unknown
			-- An out-of-range operator violates known_operator.
		note
			testing: "covers/{CAIRO_CONTEXT}.set_operator"
		local
			surface: detachable CAIRO_SURFACE
			ctx: detachable CAIRO_CONTEXT
			violated, done: BOOLEAN
		do
			if not done then
				surface := cairo.create_surface (8, 8)
				ctx := cairo.create_context (surface)
				if attached ctx as c then
					c.set_operator (99).do_nothing
				end
			end
			assert ("unknown operator rejected", violated)
			if attached ctx as c then
				c.destroy
			end
			if attached surface as s then
				s.destroy
			end
		rescue
			violated := True
			done := True
			retry
		end

	test_pattern_extend_rejects_unknown
			-- An out-of-range extend mode violates known_mode.
		note
			testing: "covers/{CAIRO_PATTERN}.set_extend"
		local
			pat: detachable CAIRO_SOLID_PATTERN
			violated, done: BOOLEAN
		do
			if not done then
				pat := cairo.solid_pattern (0.1, 0.2, 0.3)
				if attached pat as p then
					p.set_extend (9).do_nothing
				end
			end
			assert ("unknown extend rejected", violated)
			if attached pat as p then
				p.destroy
			end
		rescue
			violated := True
			done := True
			retry
		end

feature {NONE} -- Phase B: Color Helpers

	Blue_pixel: NATURAL_32 = 0xFF0000FF
	Green_pixel: NATURAL_32 = 0xFF00FF00

	channels_near (a_pixel: NATURAL_32; a_r, a_g, a_b, a_tol: INTEGER): BOOLEAN
			-- Are the RGB channels of a_pixel within a_tol of the given values?
		local
			r, g, b: INTEGER
		do
			r := a_pixel.bit_shift_right (16).bit_and (0xFF).to_integer_32
			g := a_pixel.bit_shift_right (8).bit_and (0xFF).to_integer_32
			b := a_pixel.bit_and (0xFF).to_integer_32
			Result := (r - a_r).abs <= a_tol and (g - a_g).abs <= a_tol and (b - a_b).abs <= a_tol
		end

end
