note
	description: "[
		Draws outlined text on a surface of its own, on its own SCOOP processor, for
		LIB_TESTS.test_text_on_two_threads: font sizes change every round, as a layout that fits
		its words does, so new scaled fonts are made all the time.
	]"
	author: "Larry Rix"

class
	CAIRO_TEXT_WORKER

create
	make

feature {NONE} -- Initialization

	make
		do
		end

feature -- Access

	is_done: BOOLEAN
			-- Has `run' finished?

	final_status: INTEGER
			-- The context's status when `run' finished (0 = OK).

	rounds_done: INTEGER
			-- Rounds drawn before the context failed or the rounds ran out.

	started_ms, ended_ms: INTEGER_64
			-- When `run' started and ended (milliseconds since the computer started).

feature -- Work

	run (a_rounds: INTEGER)
			-- Draw `a_rounds' lines of text, stopping early if the context fails.
		local
			l_cairo: SIMPLE_CAIRO
			l_surface: CAIRO_SURFACE
			l_context: CAIRO_CONTEXT
			i: INTEGER
		do
			started_ms := tick_ms
			create l_cairo.make
			l_surface := l_cairo.create_surface (600, 120)
			l_context := l_cairo.create_context (l_surface)
			from i := 1 until i > a_rounds or not l_context.is_valid loop
				l_context.select_font ("Impact", l_context.Slant_normal, l_context.Weight_normal)
					.set_font_size (20 + (i \\ 800) * 0.173)
					.move_to (10, 100)
					.text_path ("WORKER " + i.out).fill.do_nothing
				i := i + 1
			end
			final_status := l_context.status
			rounds_done := i - 1
			l_context.destroy
			l_surface.destroy
			ended_ms := tick_ms
			is_done := True
				-- No postcondition: one on a separate call makes the caller wait for it, and
				-- the test needs the two processors drawing at the same time.
		end

feature -- Clock

	tick_ms: INTEGER_64
			-- Milliseconds since the computer started.
		external
			"C inline use <windows.h>"
		alias
			"return (EIF_INTEGER_64) GetTickCount64();"
		end

end
