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

end
