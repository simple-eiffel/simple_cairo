note
	description: "Test application for simple_cairo library"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run test suite.
		local
			l_runner: EQA_TEST_SET_RUNNER
			l_tests: LIB_TESTS
		do
			create l_tests.default_create
			create l_runner
			l_runner.run_all (l_tests)
			print ("Tests completed%N")
		end

end
