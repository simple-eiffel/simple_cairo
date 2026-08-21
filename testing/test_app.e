note
	description: "Test application for simple_cairo library"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run test suite.
		do
			print ("Running simple_cairo tests...%N%N")
			passed := 0
			failed := 0

			run_lib_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Execution

	run_lib_tests
			-- Run LIB_TESTS test cases.
		local
			l_tests: LIB_TESTS
		do
			create l_tests.default_create
			l_tests.on_prepare

			run_test (agent l_tests.test_surface_creation, "test_surface_creation")
			run_test (agent l_tests.test_surface_formats, "test_surface_formats")
			run_test (agent l_tests.test_context_creation, "test_context_creation")
			run_test (agent l_tests.test_basic_drawing, "test_basic_drawing")
			run_test (agent l_tests.test_fluent_api, "test_fluent_api")
			run_test (agent l_tests.test_linear_gradient, "test_linear_gradient")
			run_test (agent l_tests.test_radial_gradient, "test_radial_gradient")
			run_test (agent l_tests.test_gradient_drawing, "test_gradient_drawing")
			run_test (agent l_tests.test_transforms, "test_transforms")
			run_test (agent l_tests.test_text_drawing, "test_text_drawing")
			run_test (agent l_tests.test_text_metrics, "test_text_metrics")
			run_test (agent l_tests.test_complex_path, "test_complex_path")
			run_test (agent l_tests.test_rounded_rectangle, "test_rounded_rectangle")
			run_test (agent l_tests.test_minimum_surface_size, "test_minimum_surface_size")
			run_test (agent l_tests.test_large_surface, "test_large_surface")
			run_test (agent l_tests.test_drawing_at_boundaries, "test_drawing_at_boundaries")
			run_test (agent l_tests.test_drawing_outside_boundaries, "test_drawing_outside_boundaries")
			run_test (agent l_tests.test_negative_coordinates, "test_negative_coordinates")
			run_test (agent l_tests.test_minimum_line_width, "test_minimum_line_width")
			run_test (agent l_tests.test_very_thin_line_width, "test_very_thin_line_width")
			run_test (agent l_tests.test_very_thick_line_width, "test_very_thick_line_width")
			run_test (agent l_tests.test_minimum_radius_circle, "test_minimum_radius_circle")
			run_test (agent l_tests.test_empty_text, "test_empty_text")
			run_test (agent l_tests.test_text_metrics_empty_string, "test_text_metrics_empty_string")
			run_test (agent l_tests.test_color_boundaries, "test_color_boundaries")
			run_test (agent l_tests.test_gradient_single_stop, "test_gradient_single_stop")
			run_test (agent l_tests.test_gradient_many_stops, "test_gradient_many_stops")
			run_test (agent l_tests.test_save_restore_stack, "test_save_restore_stack")
			run_test (agent l_tests.test_multiple_surfaces, "test_multiple_surfaces")
			run_test (agent l_tests.test_rapid_create_destroy, "test_rapid_create_destroy")

			-- Layer 0 (S09)
			run_test (agent l_tests.test_text_extents_basic, "test_text_extents_basic")
			run_test (agent l_tests.test_text_extents_monotonic_advance, "test_text_extents_monotonic_advance")
			run_test (agent l_tests.test_trailing_space_advance_exceeds_width, "test_trailing_space_advance_exceeds_width")
			run_test (agent l_tests.test_text_extents_empty, "test_text_extents_empty")
			run_test (agent l_tests.test_text_extents_deterministic, "test_text_extents_deterministic")
			run_test (agent l_tests.test_font_extents_sane, "test_font_extents_sane")
			run_test (agent l_tests.test_text_width_agrees_with_extents, "test_text_width_agrees_with_extents")
			run_test (agent l_tests.test_clip_restricts_painting, "test_clip_restricts_painting")
			run_test (agent l_tests.test_reset_clip_restores_full_extents, "test_reset_clip_restores_full_extents")
			run_test (agent l_tests.test_group_composites_on_pop, "test_group_composites_on_pop")
			run_test (agent l_tests.test_dash_reduces_ink, "test_dash_reduces_ink")
			run_test (agent l_tests.test_antialias_none_two_tone_edge, "test_antialias_none_two_tone_edge")
			run_test (agent l_tests.test_font_quality_smoke, "test_font_quality_smoke")
			run_test (agent l_tests.test_flush_mark_dirty_smoke, "test_flush_mark_dirty_smoke")
			run_test (agent l_tests.test_wrap_loop, "test_wrap_loop")
			run_test (agent l_tests.test_dash_rejects_all_zero, "test_dash_rejects_all_zero")
			run_test (agent l_tests.test_clip_rectangle_rejects_zero_extent, "test_clip_rectangle_rejects_zero_extent")
			run_test (agent l_tests.test_pop_group_requires_push, "test_pop_group_requires_push")

			-- Phase B (S10)
			run_test (agent l_tests.test_operator_clear_erases, "test_operator_clear_erases")
			run_test (agent l_tests.test_operator_roundtrip, "test_operator_roundtrip")
			run_test (agent l_tests.test_set_source_surface_places, "test_set_source_surface_places")
			run_test (agent l_tests.test_surface_pattern_repeat, "test_surface_pattern_repeat")
			run_test (agent l_tests.test_solid_pattern_paints, "test_solid_pattern_paints")
			run_test (agent l_tests.test_gradient_extend_pad_endpoints, "test_gradient_extend_pad_endpoints")
			run_test (agent l_tests.test_mask_surface_gates_paint, "test_mask_surface_gates_paint")
			run_test (agent l_tests.test_mesh_corner_colors, "test_mesh_corner_colors")
			run_test (agent l_tests.test_pattern_filter_roundtrip, "test_pattern_filter_roundtrip")
			run_test (agent l_tests.test_arc_negative_draws, "test_arc_negative_draws")
			run_test (agent l_tests.test_operator_rejects_unknown, "test_operator_rejects_unknown")
			run_test (agent l_tests.test_pattern_extend_rejects_unknown, "test_pattern_extend_rejects_unknown")
		end

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and report result.
		local
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_rescued := True
			retry
		end

feature {NONE} -- State

	passed: INTEGER
			-- Number of passed tests.

	failed: INTEGER
			-- Number of failed tests.

end
