note
	description: "Test application for simple_cairo library"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_APP

inherit
	SIMPLE_TEST_RUNNER

create
	make

feature {NONE} -- Initialization

	make
			-- Run test suite.
		do
			create tests.make
			run_tests (tests)
		end

feature {NONE} -- Implementation

	tests: LIB_TESTS
			-- Test suite instance.

end
