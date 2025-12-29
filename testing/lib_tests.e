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

feature {NONE} -- Setup

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
			l_dummy: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (200, 200)
			ctx := cairo.create_context (surface)

			-- Clear to white
			l_dummy := ctx.set_color_rgb (1.0, 1.0, 1.0).paint

			-- Draw blue rectangle
			l_dummy := ctx.set_color_hex (0x3498DB).fill_rect (10, 10, 50, 50)

			-- Draw red circle outline
			l_dummy := ctx.set_color_hex (0xE74C3C)
			            .set_line_width (3.0)
			            .stroke_circle (100, 100, 40)

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
			l_dummy: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			-- Chain multiple operations
			l_dummy := ctx.set_color_rgb (1, 1, 1)
			            .paint
			            .set_color_hex (0xFF0000)
			            .set_line_width (2.0)
			            .move_to (10, 10)
			            .line_to (90, 90)
			            .stroke

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
			l_dummy: CAIRO_GRADIENT
		do
			grad := cairo.linear_gradient (0, 0, 100, 100)
			assert ("gradient created", grad.is_valid)
			assert ("is linear", grad.is_linear)

			l_dummy := grad.add_stop_hex (0.0, 0xFF0000)
			              .add_stop_hex (1.0, 0x0000FF)

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
			l_ctx: CAIRO_CONTEXT
			l_grad: CAIRO_GRADIENT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)
			grad := cairo.vertical_gradient (0, 100)

			l_grad := grad.two_color (0x3498DB, 0x2ECC71)
			l_ctx := ctx.set_gradient (grad).fill_rect (0, 0, 100, 100)

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
			l_dummy: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			l_dummy := ctx.save
			            .translate (50, 50)
			            .scale (2.0, 2.0)
			            .rotate (0.785)  -- 45 degrees
			            .fill_rect (-10, -10, 20, 20)
			            .restore

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
			l_dummy: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (200, 50)
			ctx := cairo.create_context (surface)

			l_dummy := ctx.set_color_rgb (0, 0, 0)
			            .select_font ("Arial", ctx.Slant_normal, ctx.Weight_normal)
			            .set_font_size (20.0)
			            .move_to (10, 30)
			            .show_text ("Hello Cairo!")

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
			l_dummy: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			l_dummy := ctx.select_font ("Arial", 0, 0).set_font_size (20.0)
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
			l_dummy: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			l_dummy := ctx.new_path
			            .move_to (10, 10)
			            .curve_to (20, 20, 40, 0, 50, 10)
			            .arc (60, 60, 20, 0, 3.14159)
			            .close_path
			            .fill

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
			l_dummy: CAIRO_CONTEXT
		do
			surface := cairo.create_surface (100, 100)
			ctx := cairo.create_context (surface)

			l_dummy := ctx.set_color_hex (0x9B59B6)
			            .rounded_rectangle (10, 10, 80, 80, 10)
			            .fill

			assert ("rounded rect works", ctx.is_valid)
			ctx.destroy
			surface.destroy
		end

end
