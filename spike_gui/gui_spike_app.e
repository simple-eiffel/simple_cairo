note
	description: "[
		SV_BLOCK_EDITOR interactive spike - the pure route.

		A real Win32 window (inline-C CreateWindowExW + blocking message
		pump, no Vision2 anywhere) whose every pixel is painted by
		simple_cairo, blitted through Phase C-1's CAIRO_SURFACE.make_for_dc.

		Interactions proven here, for Larry to operate as a user:
		  mouse move   hover caret preview
		  click        place the caret (character-accurate via x_advance)
		  typing       insert at caret, live re-wrap
		  Backspace    delete before caret
		  arrows       move caret (up/down keep the column)
		  Enter        split the block at the caret into two cards
		  Esc          reset to the original single block
		  close box    quit

		Split-preview tinting is per character: everything before the
		caret wears the blue wash, everything after the amber wash -
		narrate spec 8.4, live. Frame cost (relayout+render+blit) is
		measured with QueryPerformanceCounter and shown in the footer.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	GUI_SPIKE_APP

create
	make

feature {NONE} -- Initialization

	make
		local
			ns: NATIVE_STRING
			hwnd: POINTER
			done, dirty, text_dirty, first_png: BOOLEAN
			ev, code: INTEGER
			t0: REAL_64
		do
			create cairo.make
			f_display := {STRING_32} "Segoe UI"
			f_body := {STRING_32} "Georgia"
			f_mono := {STRING_32} "Consolas"
			load_private_fonts
			offscreen := cairo.create_surface (Win_w, Win_h)
			ctx := cairo.create_context (offscreen)

			text := initial_text.twin
			caret := default_caret_position
			hover_pos := -1
			blink_on := True
			create ev_buf.make (16)

			relayout
			render

			create ns.make (window_title)
			hwnd := c_create_window (ns.item, Win_w, Win_h)
			if hwnd = default_pointer then
				print ("FAILED to create window%N")
			else
				print ("Window up. Operate it: click to place the caret, type to edit,%N")
				print ("arrows to move, Enter to split at the caret, Esc to reset,%N")
				print ("close the window to quit. Frame times print below.%N")
				from
				until
					done
				loop
					if c_pump = 0 then
						done := True
					else
						from
							ev := c_next (ev_buf.item)
						until
							ev = 0
						loop
							code := ev_buf.read_integer_32 (4)
							if ev = 1 then
								on_motion (code, ev_buf.read_integer_32 (8))
								dirty := True
							elseif ev = 2 then
								if on_click (code, ev_buf.read_integer_32 (8)) then
									text_dirty := True
								end
								dirty := True
							elseif ev = 3 then
								if on_char (code) then
									text_dirty := True
								end
								dirty := True
							elseif ev = 4 then
								on_arrow (code)
								dirty := True
							elseif ev = 6 then
								dirty := True
							elseif ev = 7 then
								blink_on := not blink_on
								dirty := True
							end
							ev := c_next (ev_buf.item)
						end
						if dirty and not done then
							t0 := c_now_ms
							if text_dirty then
								relayout
							end
							render
							blit
							last_ms := c_now_ms - t0
							total_ms := total_ms + last_ms
							frames := frames + 1
							if text_dirty then
								print ({STRING_32} "frame " + ms_str (last_ms) + {STRING_32} " ms (relayout+render+blit)%N")
							end
							if not first_png then
								first_png := True
								if offscreen.write_png ("spike_first_frame.png") then
									print ("First frame written to spike_first_frame.png%N")
								end
							end
							dirty := False
							text_dirty := False
						end
					end
				end
				if frames > 0 then
					print ({STRING_32} "Session: " + frames.out.to_string_32 + {STRING_32} " frames, avg " + ms_str (total_ms / frames) + {STRING_32} " ms%N")
				end
			end
			ctx.destroy
			offscreen.destroy
		end

feature {NONE} -- State

	cairo: SIMPLE_CAIRO
	offscreen: CAIRO_SURFACE
	ctx: CAIRO_CONTEXT
	ev_buf: MANAGED_POINTER

	f_display: STRING_32
	f_body: STRING_32
	f_mono: STRING_32

	text: STRING_32
	caret: INTEGER
	hover_pos: INTEGER
	blink_on: BOOLEAN
	split_mode: BOOLEAN
	upper_text: STRING_32
		attribute
			create Result.make_empty
		end
	lower_text: STRING_32
		attribute
			create Result.make_empty
		end

	last_ms, total_ms: REAL_64
	frames: INTEGER

	-- Layout (rebuilt by relayout): per-position row and x, per-char advance/bold.
	pos_row: ARRAY [INTEGER]
		attribute
			create Result.make_filled (0, 0, 0)
		end
	pos_x: ARRAY [REAL_64]
		attribute
			create Result.make_filled (0.0, 0, 0)
		end
	ch_adv: ARRAY [REAL_64]
		attribute
			create Result.make_filled (0.0, 1, 0)
		end
	ch_bold: ARRAY [BOOLEAN]
		attribute
			create Result.make_filled (False, 1, 0)
		end
	row_count: INTEGER

	-- Hit rectangles recorded by render.
	btn_split_x, btn_split_y, btn_split_w: REAL_64
	btn_reset_x, btn_reset_y, btn_reset_w: REAL_64

feature {NONE} -- Fixed content and geometry

	window_title: STRING_32
		once
			Result := {STRING_32} "simple_cairo %/8212/ pure Win32 interactive spike (no Vision2)"
		end

	initial_text: STRING_32
		once
			Result := {STRING_32} "And he's smart about it, too. He doesn't overreach. He doesn't claim the whole Bible is !one long lie!. He does the thing that actually works on thoughtful people, which is to say: I'm not asking you to distrust the text. I'm asking you to read it more honestly than your !pastor! does."
		end

	default_caret_position: INTEGER
		local
			i: INTEGER
		do
			i := initial_text.substring_index ({STRING_32} "lie!.", 1)
			if i > 0 then
				Result := i + 4
			else
				Result := initial_text.count
			end
		end

	Win_w: INTEGER = 1100
	Win_h: INTEGER = 580
	Card_x: REAL_64 = 20.0
	Card_w: REAL_64 = 1060.0
	Text_x: REAL_64 = 42.0
	Text_maxw: REAL_64 = 1016.0
	Card_y: REAL_64 = 60.0
	Body_size: REAL_64 = 14.0
	Line_h: REAL_64 = 24.0

	C_bg: NATURAL_32 = 0xE9ECF1
	C_panel: NATURAL_32 = 0xFFFFFF
	C_bar: NATURAL_32 = 0xF5F7FA
	C_line: NATURAL_32 = 0xD3DAE3
	C_ink: NATURAL_32 = 0x1A2029
	C_dim: NATURAL_32 = 0x5A6573
	C_blue: NATURAL_32 = 0x1F5FA8
	C_blue_wash: NATURAL_32 = 0xC7DAF1
	C_green: NATURAL_32 = 0x1D6B52
	C_green_wash: NATURAL_32 = 0xE0F0E9
	C_amber: NATURAL_32 = 0x8A5A0B
	C_amber_wash: NATURAL_32 = 0xFAF1DD
	C_signal: NATURAL_32 = 0xAF3A22
	C_signal_wash: NATURAL_32 = 0xF8E7E2

	text_top: REAL_64
			-- Baseline of the first body row.
		do
			Result := Card_y + 62.0
		end

feature {NONE} -- Events

	on_motion (a_x, a_y: INTEGER)
		local
			p: INTEGER
		do
			if not split_mode then
				p := offset_at (a_x, a_y)
				hover_pos := p
			end
		end

	on_click (a_x, a_y: INTEGER): BOOLEAN
			-- Handle a click; True if the text changed (split performed).
		local
			p: INTEGER
		do
			if in_button (a_x, a_y, btn_reset_x, btn_reset_y, btn_reset_w) then
				do_reset
				Result := True
			elseif not split_mode and then in_button (a_x, a_y, btn_split_x, btn_split_y, btn_split_w) then
				do_split
				Result := True
			elseif not split_mode then
				p := offset_at (a_x, a_y)
				if p >= 0 then
					caret := p
					blink_on := True
				end
			end
		end

	on_char (a_code: INTEGER): BOOLEAN
			-- Handle WM_CHAR; True if the text changed.
		do
			if a_code = 27 then
				do_reset
				Result := True
			elseif split_mode then
				-- editing paused after a split; only Esc acts
			elseif a_code = 13 then
				do_split
				Result := True
			elseif a_code = 8 then
				if caret > 0 then
					text.remove (caret)
					caret := caret - 1
					Result := True
				end
			elseif a_code >= 32 then
				text.insert_character (a_code.to_character_32, caret + 1)
				caret := caret + 1
				Result := True
			end
			blink_on := True
		end

	on_arrow (a_vk: INTEGER)
		do
			if not split_mode then
				if a_vk = 37 and caret > 0 then
					caret := caret - 1
				elseif a_vk = 39 and caret < text.count then
					caret := caret + 1
				elseif a_vk = 38 then
					caret := nearest_on_row (pos_row [caret] - 1, pos_x [caret])
				elseif a_vk = 40 then
					caret := nearest_on_row (pos_row [caret] + 1, pos_x [caret])
				end
				blink_on := True
			end
		end

	do_split
		do
			if caret > 0 and caret < text.count then
				upper_text := text.substring (1, caret)
				lower_text := text.substring (caret + 1, text.count)
				upper_text.right_adjust
				lower_text.left_adjust
				split_mode := True
				print ("SPLIT at position " + caret.out + " -> "
					+ upper_text.count.out + " + " + lower_text.count.out + " chars%N")
			end
		end

	do_reset
		do
			split_mode := False
			text := initial_text.twin
			caret := default_caret_position
			hover_pos := -1
		end

	in_button (a_x, a_y: INTEGER; bx, by, bw: REAL_64): BOOLEAN
		do
			Result := bw > 0.0 and then
				a_x >= bx and a_x <= bx + bw and a_y >= by and a_y <= by + 26.0
		end

feature {NONE} -- Layout

	relayout
			-- Rebuild per-character geometry for `text' via x_advance.
		local
			n, i, k, row, wstart: INTEGER
			x, nx, a: REAL_64
			c: CHARACTER_32
			bold, disp: BOOLEAN
		do
			n := text.count
			create pos_row.make_filled (0, 0, n.max (0))
			create pos_x.make_filled (0.0, 0, n.max (0))
			create ch_adv.make_filled (0.0, 1, n)
			create ch_bold.make_filled (False, 1, n)
			row := 0
			x := 0.0
			wstart := 1
			from
				i := 1
			until
				i > n
			loop
				c := text [i]
				disp := bold or c = '!'
				if c = '!' then
					bold := not bold
				end
				set_font (f_body, Body_size, disp)
				a := adv (one_char (c))
				if c /= ' ' and then x + a > Text_maxw and then wstart < i then
					-- move the whole current word to the next row
					row := row + 1
					nx := 0.0
					from
						k := wstart
					until
						k > i - 1
					loop
						pos_row [k - 1] := row
						pos_x [k - 1] := nx
						nx := nx + ch_adv [k]
						k := k + 1
					end
					x := nx
				end
				pos_row [i - 1] := row
				pos_x [i - 1] := x
				ch_adv [i] := a
				ch_bold [i] := disp
				x := x + a
				if c = ' ' then
					wstart := i + 1
				end
				i := i + 1
			end
			pos_row [n] := row
			pos_x [n] := x
			row_count := row + 1
			if caret > n then
				caret := n
			end
			if hover_pos > n then
				hover_pos := -1
			end
		end

	offset_at (a_x, a_y: INTEGER): INTEGER
			-- Caret position under the mouse, or -1.
		local
			r, p, best: INTEGER
			d, bestd: REAL_64
		do
			Result := -1
			r := (((a_y - (text_top - 17.0)) / Line_h)).truncated_to_integer
			if r >= 0 and r < row_count then
				best := -1
				bestd := 1.0e9
				from
					p := 0
				until
					p > text.count
				loop
					if pos_row [p] = r then
						d := (Text_x + pos_x [p] - a_x).abs
						if d < bestd then
							bestd := d
							best := p
						end
					end
					p := p + 1
				end
				Result := best
			end
		end

	nearest_on_row (a_row: INTEGER; a_x: REAL_64): INTEGER
			-- Closest position on `a_row' to column `a_x'; caret unchanged
			-- when the row does not exist.
		local
			p, best: INTEGER
			d, bestd: REAL_64
		do
			Result := caret
			if a_row >= 0 and a_row < row_count then
				best := caret
				bestd := 1.0e9
				from
					p := 0
				until
					p > text.count
				loop
					if pos_row [p] = a_row then
						d := (pos_x [p] - a_x).abs
						if d < bestd then
							bestd := d
							best := p
						end
					end
					p := p + 1
				end
				Result := best
			end
		end

feature {NONE} -- Rendering

	render
		local
			body_h, card_h, y2: REAL_64
		do
			ctx.set_color_hex (C_bg).paint.do_nothing
			set_font (f_mono, 10.0, False)
			tracked (Card_x, 26.0, {STRING_32} "SIMPLE_CAIRO %/183/ PURE WIN32 %/183/ NO VISION2", C_dim, 1.2).do_nothing
			set_font (f_display, 15.0, True)
			txt (Card_x, 48.0, {STRING_32} "SV_BLOCK_EDITOR interactive spike", C_ink)

			if split_mode then
				y2 := draw_static_card (Card_y, {STRING_32} "08A", upper_text, C_green, C_green_wash, C_green)
				y2 := draw_static_card (y2 + 12.0, {STRING_32} "08B", lower_text, C_blue, C_blue_wash, C_blue)
				btn_split_w := 0.0
				btn_reset_x := Text_x
				btn_reset_y := y2 + 14.0
				btn_reset_w := button (btn_reset_x, btn_reset_y, {STRING_32} "Reset (Esc)", False)
				set_font (f_mono, 10.5, False)
				txt (Text_x + btn_reset_w + 16.0, btn_reset_y + 17.0,
					{STRING_32} "split done %/8212/ two blocks, exactly narrate spec 8.2", C_dim)
			else
				body_h := row_count * Line_h
				card_h := 62.0 + body_h + 56.0
				draw_card_frame (Card_y, card_h, C_amber, True)
				draw_editor_head (Card_y)
				draw_editor_body
				btn_split_x := Text_x
				btn_split_y := Card_y + 62.0 + body_h + 14.0
				btn_split_w := button (btn_split_x, btn_split_y, {STRING_32} "Split Here (Enter)", True)
				btn_reset_x := btn_split_x + btn_split_w + 10.0
				btn_reset_y := btn_split_y
				btn_reset_w := button (btn_reset_x, btn_reset_y, {STRING_32} "Reset (Esc)", False)
			end
			draw_footer
		end

	draw_card_frame (a_y, a_h: REAL_64; a_stripe: NATURAL_32; a_selected: BOOLEAN)
		do
			ctx.set_color_hex (C_panel).rounded_rectangle (Card_x, a_y, Card_w, a_h, 3.0).fill_preserve.do_nothing
			ctx.set_color_hex (C_line).set_line_width (1.0).stroke.do_nothing
			ctx.save.clip_rectangle (Card_x, a_y, 5.0, a_h).do_nothing
			ctx.set_color_hex (a_stripe).rounded_rectangle (Card_x, a_y, Card_w, a_h, 3.0).fill.do_nothing
			ctx.restore.do_nothing
			if a_selected then
				ctx.set_color_hex (C_blue).set_line_width (2.0)
					.rounded_rectangle (Card_x - 1.0, a_y - 1.0, Card_w + 2.0, a_h + 2.0, 4.0).stroke.do_nothing
			end
		end

	draw_editor_head (a_y: REAL_64)
		local
			x: REAL_64
		do
			set_font (f_mono, 10.0, False)
			txt (Text_x, a_y + 28.0, {STRING_32} "08", C_dim)
			x := Text_x + adv ({STRING_32} "08") + 10.0
			x := chip (x, a_y + 14.0, {STRING_32} "PROSE", C_dim, C_bar, C_line) + 8.0
			x := chip (x, a_y + 14.0, {STRING_32} "DIRTY", C_amber, C_amber_wash, C_amber) + 12.0
			warn_glyph (x, a_y + 17.0, 11.0)
			set_font (f_mono, 9.5, False)
			txt (x + 16.0, a_y + 26.0, {STRING_32} "60-word sentence", C_amber)
		end

	draw_editor_body
		local
			i, r: INTEGER
			x, y, w: REAL_64
			tone: NATURAL_32
			c: CHARACTER_32
		do
			-- tint boxes per character, split at the caret (narrate 8.4)
			from
				i := 1
			until
				i > text.count
			loop
				r := pos_row [i - 1]
				x := Text_x + pos_x [i - 1]
				y := text_top + r * Line_h
				w := ch_adv [i]
				if i <= caret then
					tone := C_blue_wash
				else
					tone := C_amber_wash
				end
				ctx.set_color_hex (tone).fill_rect (x, y - 17.0, w, 22.0).do_nothing
				i := i + 1
			end
			-- text
			from
				i := 1
			until
				i > text.count
			loop
				c := text [i]
				set_font (f_body, Body_size, ch_bold [i])
				txt (Text_x + pos_x [i - 1], text_top + pos_row [i - 1] * Line_h, one_char (c), C_ink)
				i := i + 1
			end
			-- hover preview
			if hover_pos >= 0 and hover_pos /= caret then
				ctx.set_color_hex (C_dim).fill_rect
					(Text_x + pos_x [hover_pos], text_top + pos_row [hover_pos] * Line_h - 17.0, 1.5, 22.0).do_nothing
			end
			-- the caret
			if blink_on then
				ctx.set_color_hex (C_signal).fill_rect
					(Text_x + pos_x [caret], text_top + pos_row [caret] * Line_h - 17.0, 2.2, 22.0).do_nothing
			end
		end

	draw_static_card (a_y: REAL_64; a_ord, a_text: STRING_32;
	                  a_fg, a_wash, a_stripe: NATURAL_32): REAL_64
			-- Draw a non-interactive result card; return its bottom y.
		local
			rows: INTEGER
			x: REAL_64
			card_h: REAL_64
		do
			rows := wrapped_rows (a_text)
			card_h := 58.0 + rows * Line_h + 12.0
			draw_card_frame (a_y, card_h, a_stripe, False)
			set_font (f_mono, 10.0, False)
			txt (Text_x, a_y + 26.0, a_ord, C_dim)
			x := Text_x + adv (a_ord) + 10.0
			x := chip (x, a_y + 12.0, {STRING_32} "PROSE", C_dim, C_bar, C_line) + 8.0
			x := chip (x, a_y + 12.0, {STRING_32} "SPLIT", a_fg, a_wash, a_stripe) + 8.0
			draw_wrapped (Text_x, a_y + 56.0, a_text).do_nothing
			Result := a_y + card_h
		end

	wrapped_rows (a_s: STRING_32): INTEGER
		do
			Result := draw_or_count (a_s, 0.0, 0.0, False)
		end

	draw_wrapped (a_x, a_y: REAL_64; a_s: STRING_32): INTEGER
		do
			Result := draw_or_count (a_s, a_x, a_y, True)
		end

	draw_or_count (a_s: STRING_32; a_x, a_y: REAL_64; a_draw: BOOLEAN): INTEGER
			-- Word-wrap `a_s' at Text_maxw; draw when asked; return row count.
			-- Simple single-pass with word buffering.
		local
			i, n: INTEGER
			x, a: REAL_64
			c: CHARACTER_32
			bold, disp: BOOLEAN
			word: STRING_32
			word_w: REAL_64
			word_bold: ARRAYED_LIST [BOOLEAN]
			row: INTEGER
		do
			n := a_s.count
			x := 0.0
			row := 0
			create word.make (16)
			create word_bold.make (16)
			word_w := 0.0
			from
				i := 1
			until
				i > n + 1
			loop
				if i <= n then
					c := a_s [i]
				else
					c := ' '
				end
				disp := bold or c = '!'
				if i <= n and c = '!' then
					bold := not bold
				end
				if c = ' ' then
					if x > 0.0 and then x + word_w > Text_maxw then
						row := row + 1
						x := 0.0
					end
					if a_draw then
						draw_word (a_x + x, a_y + row * Line_h, word, word_bold)
					end
					x := x + word_w
					set_font (f_body, Body_size, False)
					x := x + adv ({STRING_32} " ")
					word.wipe_out
					word_bold.wipe_out
					word_w := 0.0
				else
					set_font (f_body, Body_size, disp)
					a := adv (one_char (c))
					word.extend (c)
					word_bold.extend (disp)
					word_w := word_w + a
				end
				i := i + 1
			end
			Result := row + 1
		end

	draw_word (a_x, a_y: REAL_64; a_word: STRING_32; a_bold: ARRAYED_LIST [BOOLEAN])
		local
			i: INTEGER
			x: REAL_64
		do
			x := a_x
			from
				i := 1
			until
				i > a_word.count
			loop
				set_font (f_body, Body_size, a_bold [i])
				txt (x, a_y, one_char (a_word [i]), C_ink)
				x := x + adv (one_char (a_word [i]))
				i := i + 1
			end
		end

	draw_footer
		local
			y: REAL_64
			s: STRING_32
		do
			y := Win_h - 30.0
			ctx.set_color_hex (C_bar).fill_rect (0.0, y, Win_w, 30.0).do_nothing
			ctx.set_color_hex (C_line).fill_rect (0.0, y, Win_w, 1.0).do_nothing
			set_font (f_mono, 10.0, False)
			txt (14.0, y + 19.0,
				{STRING_32} "click: caret %/183/ type: edit %/183/ arrows: move %/183/ Enter: split %/183/ Esc: reset",
				C_dim)
			s := {STRING_32} "frame " + ms_str (last_ms) + {STRING_32} " ms"
			txt (Win_w - 14.0 - adv (s), y + 19.0, s, C_dim)
		end

feature {NONE} -- Blit (Phase C-1: cairo win32 surface on the window DC)

	blit
		local
			hdc: POINTER
			ws: CAIRO_SURFACE
			c2: CAIRO_CONTEXT
		do
			hdc := c_get_dc
			if hdc /= default_pointer then
				create ws.make_for_dc (hdc)
				if ws.is_valid then
					create c2.make (ws)
					c2.set_source_surface (offscreen, 0.0, 0.0).paint.do_nothing
					c2.destroy
				end
				ws.destroy
				c_release_dc (hdc)
			end
		end

feature {NONE} -- Small helpers (shared style with DEMO_APP)

	one_char (c: CHARACTER_32): STRING_32
		do
			create Result.make (1)
			Result.extend (c)
		end

	adv (a_s: STRING_32): REAL_64
		do
			Result := ctx.text_extents (a_s).x_advance
		end

	txt (a_x, a_y: REAL_64; a_s: STRING_32; a_color: NATURAL_32)
		do
			ctx.set_color_hex (a_color).move_to (a_x, a_y).show_text (a_s).do_nothing
		end

	tracked (a_x, a_y: REAL_64; a_s: STRING_32; a_color: NATURAL_32; a_tr: REAL_64): REAL_64
		local
			x: REAL_64
		do
			x := a_x
			ctx.set_color_hex (a_color).do_nothing
			across a_s as c loop
				ctx.move_to (x, a_y).show_text (one_char (c)).do_nothing
				x := x + adv (one_char (c)) + a_tr
			end
			Result := x
		end

	chip (a_x, a_y: REAL_64; a_label: STRING_32; a_fg, a_bg, a_bd: NATURAL_32): REAL_64
		local
			w, x: REAL_64
		do
			set_font (f_mono, 9.5, False)
			w := 12.0
			across a_label as c loop
				w := w + adv (one_char (c)) + 0.6
			end
			ctx.set_color_hex (a_bg).rounded_rectangle (a_x, a_y, w, 17.0, 2.0).fill_preserve.do_nothing
			ctx.set_color_hex (a_bd).set_line_width (1.0).stroke.do_nothing
			x := tracked (a_x + 6.0, a_y + 12.5, a_label, a_fg, 0.6)
			Result := a_x + w
		end

	button (a_x, a_y: REAL_64; a_label: STRING_32; a_primary: BOOLEAN): REAL_64
			-- Draw a button; return its WIDTH (caller stores the rect).
		local
			w: REAL_64
			fg, bg, bd: NATURAL_32
		do
			set_font (f_display, 11.5, False)
			w := 20.0 + adv (a_label)
			if a_primary then
				fg := C_blue
				bg := C_blue_wash
				bd := C_blue
			else
				fg := C_ink
				bg := C_panel
				bd := C_line
			end
			ctx.set_color_hex (bg).rounded_rectangle (a_x, a_y, w, 26.0, 3.0).fill_preserve.do_nothing
			ctx.set_color_hex (bd).set_line_width (1.0).stroke.do_nothing
			txt (a_x + 10.0, a_y + 17.5, a_label, fg)
			Result := w
		end

	warn_glyph (a_x, a_y, a_s: REAL_64)
		do
			ctx.set_color_hex (C_amber).move_to (a_x + a_s / 2, a_y)
				.line_to (a_x, a_y + a_s).line_to (a_x + a_s, a_y + a_s)
				.close_path.fill.do_nothing
			ctx.set_color_hex (C_panel)
				.fill_rect (a_x + a_s / 2 - 0.7, a_y + 3.2, 1.4, a_s - 6.6)
				.fill_rect (a_x + a_s / 2 - 0.7, a_y + a_s - 2.6, 1.4, 1.4).do_nothing
		end

	set_font (a_family: STRING_32; a_size: REAL_64; a_bold: BOOLEAN)
		do
			if a_bold then
				ctx.select_font (a_family, ctx.Slant_normal, ctx.Weight_bold).do_nothing
			else
				ctx.select_font (a_family, ctx.Slant_normal, ctx.Weight_normal).do_nothing
			end
			ctx.set_font_size (a_size).do_nothing
		end

	ms_str (a_ms: REAL_64): STRING_32
		local
			r10: INTEGER
		do
			r10 := (a_ms * 10.0).rounded
			create Result.make (8)
			Result.append_string_general ((r10 // 10).out)
			Result.append_character ('.')
			Result.append_string_general ((r10 \\ 10).out)
		end

	load_private_fonts
		local
			dir: STRING_32
			n: INTEGER
		do
			dir := {STRING_32} "D:\prod\simple_narrate\docs\_artwork\src\_fonts\"
			if add_font (dir + {STRING_32} "Archivo.ttf") then
				n := n + 1
			end
			if add_font (dir + {STRING_32} "Literata.ttf") then
				n := n + 1
			end
			if add_font (dir + {STRING_32} "IBMPlexMono.ttf") then
				n := n + 1
			end
			if n = 3 then
				f_display := {STRING_32} "Archivo"
				f_body := {STRING_32} "Literata"
				f_mono := {STRING_32} "IBM Plex Mono"
				print ("Fonts: 3 private faces loaded%N")
			else
				print ("Fonts: " + n.out + "/3; system fallbacks%N")
			end
		end

	add_font (a_path: STRING_32): BOOLEAN
		local
			f: RAW_FILE
			ns: NATIVE_STRING
		do
			create f.make_with_name (a_path)
			if f.exists then
				create ns.make (a_path)
				Result := c_add_font (ns.item) > 0
			end
		end

feature {NONE} -- C Externals (spike scaffolding)

	c_create_window (a_title: POINTER; a_w, a_h: INTEGER): POINTER
		external
			"C inline use %"spike_win.h%""
		alias
			"return spike_create_window((const wchar_t*)$a_title, $a_w, $a_h);"
		end

	c_pump: INTEGER
		external
			"C inline use %"spike_win.h%""
		alias
			"return spike_pump();"
		end

	c_next (a_buf: POINTER): INTEGER
		external
			"C inline use %"spike_win.h%""
		alias
			"return spike_next_event((int*)$a_buf);"
		end

	c_get_dc: POINTER
		external
			"C inline use %"spike_win.h%""
		alias
			"return spike_get_dc();"
		end

	c_release_dc (a_dc: POINTER)
		external
			"C inline use %"spike_win.h%""
		alias
			"spike_release_dc($a_dc);"
		end

	c_now_ms: REAL_64
		external
			"C inline use %"spike_win.h%""
		alias
			"return spike_now_ms();"
		end

	c_add_font (a_path: POINTER): INTEGER
		external
			"C inline use %"spike_win.h%""
		alias
			"return (int)AddFontResourceExW((LPCWSTR)$a_path, FR_PRIVATE, 0);"
		end

end
