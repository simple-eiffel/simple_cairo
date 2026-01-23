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
