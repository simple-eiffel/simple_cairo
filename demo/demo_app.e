note
	description: "[
		Milestone demo: the simple_narrate editor window, drawn entirely
		by simple_cairo and written to PNG - headless, no browser, no
		Pillow, no window. The acceptance target set by Larry 2026-08-21:
		'let me know when simple_cairo is capable of making the
		PIL->PNG-ish GUI that was drawn for simple_narrate.'

		Everything here is public simple_cairo API: rounded cards,
		hairlines, clip-drawn severity stripes, measured word wrap via
		text_extents.x_advance, split-preview tint runs, tracked-caps
		chips, icons as paths, slider, progress bar. Fonts are loaded
		process-private via AddFontResourceExW (demo-local external;
		the library stays pure Cairo) with system-face fallback.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_APP

create
	make

feature {NONE} -- Initialization

	make
		local
			surface: CAIRO_SURFACE
			out_name: STRING
			l_args: ARGUMENTS_32
		do
			create cairo.make
			create l_args
			if l_args.argument_count >= 1 and then l_args.argument (1).same_string ("--system-fonts") then
				use_system_fonts := True
			end
			f_display := {STRING_32} "Segoe UI"
			f_body := {STRING_32} "Georgia"
			f_mono := {STRING_32} "Consolas"
			if use_system_fonts then
				print ("Fonts: system fallbacks by request (--system-fonts)%N")
			else
				load_private_fonts
			end
			surface := cairo.create_surface (Page_w * 2, Page_h * 2)
			ctx := cairo.create_context (surface)
			ctx.scale (2.0, 2.0).do_nothing

			draw_background
			draw_toolbar
			draw_map_rail
			draw_blocks
			draw_panel
			draw_status

			surface.flush.do_nothing
			if use_system_fonts then
				out_name := "demo_editor_window_systemfonts.png"
			else
				out_name := "demo_editor_window.png"
			end
			if surface.write_png (out_name) then
				print ("Wrote " + out_name + " (" + (Page_w * 2).out + "x" + (Page_h * 2).out + ")%N")
			else
				print ("FAILED to write PNG%N")
			end
			ctx.destroy
			surface.destroy
		end

feature {NONE} -- State

	use_system_fonts: BOOLEAN

	cairo: SIMPLE_CAIRO
	ctx: CAIRO_CONTEXT

	f_display: STRING_32
	f_body: STRING_32
	f_mono: STRING_32

feature {NONE} -- Page & palette

	Page_w: INTEGER = 1480
	Page_h: INTEGER = 860

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

feature {NONE} -- Fonts

	load_private_fonts
			-- Register the vendored faces process-private; keep the
			-- system-face defaults from make when any are missing.
		local
			dir: STRING_32
			n: INTEGER
		do
			dir := {STRING_32} "D:\prod\simple_narrate\docs\_artwork\src\_fonts\"
			n := 0
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
				print ("Fonts: 3 private faces loaded (Archivo, Literata, IBM Plex Mono)%N")
			else
				print ("Fonts: " + n.out + "/3 private faces; using system fallbacks%N")
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

	set_font (a_family: STRING_32; a_size: REAL_64; a_bold: BOOLEAN)
		do
			if a_bold then
				ctx.select_font (a_family, ctx.Slant_normal, ctx.Weight_bold).do_nothing
			else
				ctx.select_font (a_family, ctx.Slant_normal, ctx.Weight_normal).do_nothing
			end
			ctx.set_font_size (a_size).do_nothing
		end

feature {NONE} -- Text helpers

	adv (a_s: STRING_32): REAL_64
		do
			Result := ctx.text_extents (a_s).x_advance
		end

	txt (a_x, a_y: REAL_64; a_s: STRING_32; a_color: NATURAL_32)
		do
			ctx.set_color_hex (a_color).move_to (a_x, a_y).show_text (a_s).do_nothing
		end

	tracked (a_x, a_y: REAL_64; a_s: STRING_32; a_color: NATURAL_32; a_tr: REAL_64): REAL_64
			-- Draw with letter tracking; return the end pen x.
		local
			x: REAL_64
			one: STRING_32
		do
			x := a_x
			ctx.set_color_hex (a_color).do_nothing
			across a_s as c loop
				create one.make (1)
				one.extend (c)
				ctx.move_to (x, a_y).show_text (one).do_nothing
				x := x + adv (one) + a_tr
			end
			Result := x
		end

	tracked_w (a_s: STRING_32; a_tr: REAL_64): REAL_64
		local
			one: STRING_32
		do
			across a_s as c loop
				create one.make (1)
				one.extend (c)
				Result := Result + adv (one) + a_tr
			end
		end

feature {NONE} -- Shape helpers

	fill_rrect (a_x, a_y, a_w, a_h, a_r: REAL_64; a_fill: NATURAL_32)
		do
			ctx.set_color_hex (a_fill).rounded_rectangle (a_x, a_y, a_w, a_h, a_r).fill.do_nothing
		end

	frame_rrect (a_x, a_y, a_w, a_h, a_r: REAL_64; a_fill, a_border: NATURAL_32; a_lw: REAL_64)
		do
			ctx.set_color_hex (a_fill).rounded_rectangle (a_x, a_y, a_w, a_h, a_r).fill_preserve.do_nothing
			ctx.set_color_hex (a_border).set_line_width (a_lw).stroke.do_nothing
		end

	hline (a_x, a_y, a_w: REAL_64; a_color: NATURAL_32)
		do
			ctx.set_color_hex (a_color).fill_rect (a_x, a_y, a_w, 1.0).do_nothing
		end

	vsep (a_x, a_y, a_h: REAL_64)
		do
			ctx.set_color_hex (C_line).fill_rect (a_x, a_y, 1.0, a_h).do_nothing
		end

	warn_glyph (a_x, a_y, a_s: REAL_64; a_color: NATURAL_32)
		do
			ctx.set_color_hex (a_color).move_to (a_x + a_s / 2, a_y)
				.line_to (a_x, a_y + a_s).line_to (a_x + a_s, a_y + a_s)
				.close_path.fill.do_nothing
			ctx.set_color_hex (C_panel)
				.fill_rect (a_x + a_s / 2 - 0.7, a_y + 3.2, 1.4, a_s - 6.6)
				.fill_rect (a_x + a_s / 2 - 0.7, a_y + a_s - 2.6, 1.4, 1.4).do_nothing
		end

feature {NONE} -- Icons (paths, returning width used)

	Icon_none: INTEGER = 0
	Icon_play: INTEGER = 1
	Icon_refresh: INTEGER = 2
	Icon_check: INTEGER = 3
	Icon_up: INTEGER = 4
	Icon_down: INTEGER = 5

	icon_w (a_kind: INTEGER): REAL_64
		do
			if a_kind = Icon_none then
				Result := 0.0
			else
				Result := 9.0
			end
		end

	draw_icon (a_kind: INTEGER; a_x, a_cy: REAL_64; a_color: NATURAL_32)
		do
			ctx.set_color_hex (a_color).set_line_width (1.6).do_nothing
			if a_kind = Icon_play then
				ctx.move_to (a_x + 1.0, a_cy - 4.0).line_to (a_x + 1.0, a_cy + 4.0)
					.line_to (a_x + 8.0, a_cy).close_path.fill.do_nothing
			elseif a_kind = Icon_refresh then
				ctx.new_path.arc (a_x + 4.5, a_cy, 3.6, 0.7, 5.6).stroke.do_nothing
				ctx.move_to (a_x + 7.4, a_cy - 3.4).line_to (a_x + 9.2, a_cy - 1.2)
					.line_to (a_x + 6.2, a_cy - 0.6).close_path.fill.do_nothing
			elseif a_kind = Icon_check then
				ctx.move_to (a_x + 0.6, a_cy + 0.4).line_to (a_x + 3.4, a_cy + 3.2)
					.line_to (a_x + 8.6, a_cy - 3.4).stroke.do_nothing
			elseif a_kind = Icon_up then
				ctx.move_to (a_x + 4.5, a_cy + 4.0).line_to (a_x + 4.5, a_cy - 3.0).stroke.do_nothing
				ctx.move_to (a_x + 1.2, a_cy - 1.2).line_to (a_x + 4.5, a_cy - 4.4)
					.line_to (a_x + 7.8, a_cy - 1.2).close_path.fill.do_nothing
			elseif a_kind = Icon_down then
				ctx.move_to (a_x + 4.5, a_cy - 4.0).line_to (a_x + 4.5, a_cy + 3.0).stroke.do_nothing
				ctx.move_to (a_x + 1.2, a_cy + 1.2).line_to (a_x + 4.5, a_cy + 4.4)
					.line_to (a_x + 7.8, a_cy + 1.2).close_path.fill.do_nothing
			end
		end

feature {NONE} -- Widgets

	Style_normal: INTEGER = 0
	Style_primary: INTEGER = 1
	Style_disabled: INTEGER = 2

	button (a_x, a_y: REAL_64; a_icon: INTEGER; a_label: STRING_32; a_style: INTEGER): REAL_64
			-- Draw a 24px button; return its right edge.
		local
			w, tx: REAL_64
			fg, bg, bd: NATURAL_32
			iw: REAL_64
		do
			set_font (f_display, 11.0, False)
			iw := icon_w (a_icon)
			w := 18.0 + iw + adv (a_label)
			if a_icon /= Icon_none and not a_label.is_empty then
				w := w + 5.0
			end
			if a_style = Style_primary then
				fg := C_blue
				bg := C_blue_wash
				bd := C_blue
			elseif a_style = Style_disabled then
				fg := C_dim
				bg := C_bar
				bd := C_line
			else
				fg := C_ink
				bg := C_panel
				bd := C_line
			end
			frame_rrect (a_x, a_y, w, 24.0, 3.0, bg, bd, 1.0)
			tx := a_x + 9.0
			if a_icon /= Icon_none then
				draw_icon (a_icon, tx, a_y + 12.0, fg)
				tx := tx + iw + 5.0
			end
			set_font (f_display, 11.0, False)
			txt (tx, a_y + 16.0, a_label, fg)
			Result := a_x + w
		end

	chip (a_x, a_y: REAL_64; a_label: STRING_32; a_fg, a_bg, a_bd: NATURAL_32): REAL_64
			-- Tracked-caps chip; return right edge.
		local
			w: REAL_64
		do
			set_font (f_mono, 9.5, False)
			w := tracked_w (a_label, 0.6) + 12.0
			frame_rrect (a_x, a_y, w, 17.0, 2.0, a_bg, a_bd, 1.0)
			tracked (a_x + 6.0, a_y + 12.5, a_label, a_fg, 0.6).do_nothing
			Result := a_x + w
		end

feature {NONE} -- Word wrap (the S09 acceptance algorithm, live)

	wrap_tokens (a_tokens: ARRAYED_LIST [TUPLE [word: STRING_32; bold: BOOLEAN]];
	             a_size, a_maxw: REAL_64): ARRAYED_LIST [ARRAYED_LIST [TUPLE [word: STRING_32; bold: BOOLEAN; x: REAL_64]]]
		local
			row: ARRAYED_LIST [TUPLE [word: STRING_32; bold: BOOLEAN; x: REAL_64]]
			x, sp, w: REAL_64
		do
			create Result.make (4)
			create row.make (8)
			set_font (f_body, a_size, False)
			sp := adv ({STRING_32} " ")
			x := 0.0
			across a_tokens as tk loop
				set_font (f_body, a_size, tk.bold)
				w := adv (tk.word)
				if x > 0.0 and then x + sp + w > a_maxw then
					Result.extend (row)
					create row.make (8)
					x := 0.0
				end
				if x > 0.0 then
					x := x + sp
				end
				row.extend ([tk.word, tk.bold, x])
				x := x + w
			end
			if not row.is_empty then
				Result.extend (row)
			end
		end

	tokens_from (a_text: STRING_32): ARRAYED_LIST [TUPLE [word: STRING_32; bold: BOOLEAN]]
			-- Split on spaces; words containing an exclamation mark are emphasis.
		local
			parts: LIST [STRING_32]
		do
			create Result.make (32)
			parts := a_text.split (' ')
			across parts as p loop
				if not p.is_empty then
					Result.extend ([p, p.has ('!')])
				end
			end
		end

feature {NONE} -- Sections

	draw_background
		do
			ctx.set_color_hex (C_bg).paint.do_nothing
		end

	draw_toolbar
		local
			x: REAL_64
			blocker, meta: STRING_32
			pw: REAL_64
		do
			ctx.set_color_hex (C_bar).fill_rect (0.0, 0.0, 1480.0, 40.0).do_nothing
			hline (0.0, 40.0, 1480.0, C_line)
			set_font (f_display, 13.0, True)
			txt (14.0, 25.0, {STRING_32} "The Day Yahweh Looked Defeated", C_ink)
			x := 14.0 + adv ({STRING_32} "The Day Yahweh Looked Defeated") + 12.0
			meta := {STRING_32} "chatterbox %/183/ andrew %/183/ gate 0.95"
			set_font (f_mono, 10.5, False)
			txt (x, 25.0, meta, C_dim)
			x := x + adv (meta) + 14.0
			vsep (x, 11.0, 18.0)
			x := x + 13.0
			x := button (x, 8.0, Icon_none, {STRING_32} "Undo", Style_normal) + 8.0
			x := button (x, 8.0, Icon_none, {STRING_32} "Redo", Style_disabled) + 14.0
			vsep (x, 11.0, 18.0)
			x := x + 13.0
			x := button (x, 8.0, Icon_none, {STRING_32} "Render Dirty (12)", Style_normal) + 8.0
			x := button (x, 8.0, Icon_none, {STRING_32} "Run Gate", Style_disabled) + 8.0

			blocker := {STRING_32} "blocked %/183/ 12 unapproved %/183/ fidelity 0.87"
			set_font (f_display, 11.0, True)
			pw := adv ({STRING_32} "Publish")
			set_font (f_mono, 10.0, False)
			pw := pw + 8.0 + adv (blocker) + 24.0
			frame_rrect (1480.0 - 14.0 - pw, 8.0, pw, 24.0, 3.0, C_signal_wash, C_signal, 1.2)
			set_font (f_display, 11.0, True)
			txt (1480.0 - 14.0 - pw + 12.0, 24.0, {STRING_32} "Publish", C_signal)
			set_font (f_mono, 10.0, False)
			txt (1480.0 - 14.0 - pw + 12.0 + adv ({STRING_32} "Publish") + 6.0, 24.0, blocker, C_signal)
		end

	Rail_states: STRING = "AAAAAAHDRRAAADDRAAAFRAADAARADAAAARADAAANNNNN"
			-- 44 cells; A approved, R rendered, D dirty, F failed, N new, H here.

	draw_map_rail
		local
			i, col, row: INTEGER
			cx, cy: REAL_64
			c: CHARACTER
			fill: NATURAL_32
			names: ARRAY [STRING_32]
			cols: ARRAY [NATURAL_32]
			ly: REAL_64
		do
			ctx.set_color_hex (C_bar).fill_rect (0.0, 41.0, 88.0, 791.0).do_nothing
			vsep (88.0, 41.0, 791.0)
			set_font (f_mono, 9.0, False)
			tracked (10.0, 58.0, {STRING_32} "MAP", C_dim, 1.2).do_nothing
			from
				i := 1
			until
				i > 44
			loop
				col := (i - 1) \\ 4
				row := (i - 1) // 4
				cx := 10.0 + col * 18.0
				cy := 68.0 + row * 18.0
				c := Rail_states [i]
				if c = 'A' or c = 'H' then
					fill := C_green
				elseif c = 'R' then
					fill := C_blue
				elseif c = 'D' then
					fill := C_amber
				elseif c = 'F' then
					fill := C_signal
				else
					fill := C_line
				end
				fill_rrect (cx, cy, 14.0, 14.0, 2.0, fill)
				if c = 'H' then
					ctx.set_color_hex (C_ink).set_line_width (1.6)
						.rounded_rectangle (cx - 2.0, cy - 2.0, 18.0, 18.0, 3.0).stroke.do_nothing
				end
				i := i + 1
			end
			names := <<{STRING_32} "approved", {STRING_32} "rendered", {STRING_32} "dirty",
			           {STRING_32} "failed", {STRING_32} "new">>
			cols := <<C_green, C_blue, C_amber, C_signal, C_line>>
			set_font (f_mono, 8.5, False)
			from
				i := 1
			until
				i > 5
			loop
				ly := 300.0 + i * 16.0
				fill_rrect (10.0, ly - 7.0, 7.0, 7.0, 1.0, cols [i])
				txt (21.0, ly, names [i], C_dim)
				i := i + 1
			end
		end

	card (a_y, a_h: REAL_64; a_stripe: NATURAL_32; a_selected: BOOLEAN)
		do
			frame_rrect (100.0, a_y, 1060.0, a_h, 3.0, C_panel, C_line, 1.0)
			ctx.save.clip_rectangle (100.0, a_y, 5.0, a_h).do_nothing
			fill_rrect (100.0, a_y, 1060.0, a_h, 3.0, a_stripe)
			ctx.restore.do_nothing
			if a_selected then
				ctx.set_color_hex (C_blue).set_line_width (2.0)
					.rounded_rectangle (99.0, a_y - 1.0, 1062.0, a_h + 2.0, 4.0).stroke.do_nothing
			end
		end

	card_head (a_y: REAL_64; a_ord, a_kind: STRING_32; a_state: STRING_32;
	           a_sfg, a_sbg, a_sbd: NATURAL_32; a_fid: STRING_32)
		local
			x: REAL_64
		do
			set_font (f_mono, 10.0, False)
			txt (122.0, a_y + 12.0, a_ord, C_dim)
			x := 122.0 + adv (a_ord) + 10.0
			x := chip (x, a_y, a_kind, C_dim, C_bar, C_line) + 8.0
			x := chip (x, a_y, a_state, a_sfg, a_sbg, a_sbd) + 10.0
			set_font (f_mono, 11.0, False)
			txt (x, a_y + 12.5, a_fid, C_ink)
			last_head_x := x + adv (a_fid) + 12.0
		end

	last_head_x: REAL_64

	action_row (a_y: REAL_64; a_items: ARRAY [TUPLE [icon: INTEGER; label: STRING_32; style: INTEGER]])
		local
			x: REAL_64
			i: INTEGER
		do
			x := 122.0
			from
				i := a_items.lower
			until
				i > a_items.upper
			loop
				if a_items [i].icon = -1 then
					vsep (x + 3.0, a_y + 3.0, 18.0)
					x := x + 13.0
				else
					x := button (x, a_y, a_items [i].icon, a_items [i].label, a_items [i].style) + 6.0
				end
				i := i + 1
			end
		end

	draw_blocks
		do
			draw_block_1
			draw_block_2
			draw_block_3
			draw_block_4
		end

	draw_block_1
		local
			y: REAL_64
		do
			y := 52.0
			card (y, 100.0, C_green, False)
			card_head (y + 14.0, {STRING_32} "07", {STRING_32} "HEADING",
				{STRING_32} "APPROVED", C_green, C_green_wash, C_green, {STRING_32} "0.98")
			set_font (f_body, 12.0, False)
			txt (122.0, y + 52.0, {STRING_32} "The Day Yahweh Looked Defeated", C_ink)
			action_row (y + 64.0, <<
				[Icon_play, {STRING_32} "Play", Style_normal],
				[Icon_refresh, {STRING_32} "New Take", Style_normal],
				[Icon_check, {STRING_32} "Approved", Style_disabled],
				[-1, {STRING_32} "", 0],
				[Icon_none, {STRING_32} "Split Here", Style_disabled],
				[Icon_up, {STRING_32} "", Style_normal],
				[Icon_down, {STRING_32} "", Style_normal]>>)
		end

	Split_text: STRING_32
		once
			Result := {STRING_32} "And he's smart about it, too. He doesn't overreach. He doesn't claim the whole Bible is !one long lie!. He does the thing that actually works on thoughtful people, which is to say: I'm not asking you to distrust the text. I'm asking you to read it more honestly than your !pastor! does."
		end

	draw_block_2
		local
			y, tx, ty, lh, bx0, bx1: REAL_64
			rows: ARRAYED_LIST [ARRAYED_LIST [TUPLE [word: STRING_32; bold: BOOLEAN; x: REAL_64]]]
			gi, caret_gi: INTEGER
			ri: INTEGER
			caret_x, caret_y: REAL_64
			tone: NATURAL_32
			toks: ARRAYED_LIST [TUPLE [word: STRING_32; bold: BOOLEAN]]
		do
			y := 161.0
			card (y, 152.0, C_amber, True)
			card_head (y + 14.0, {STRING_32} "08", {STRING_32} "PROSE",
				{STRING_32} "DIRTY", C_amber, C_amber_wash, C_amber, {STRING_32} "%/8212/")
			warn_glyph (last_head_x, y + 16.0, 11.0, C_amber)
			set_font (f_mono, 9.5, False)
			txt (last_head_x + 16.0, y + 25.0, {STRING_32} "60-word sentence", C_amber)

			toks := tokens_from (Split_text)
			caret_gi := caret_index_of (toks, {STRING_32} "lie!.")

			rows := wrap_tokens (toks, 12.0, 1016.0)
			tx := 122.0
			ty := y + 56.0
			lh := 19.0
			caret_x := tx
			caret_y := ty

			-- Tint boxes first, then text on top.
			gi := 0
			from
				ri := 1
			until
				ri > rows.count
			loop
				across rows [ri] as w loop
					gi := gi + 1
					if gi <= caret_gi then
						tone := C_blue_wash
					else
						tone := C_amber_wash
					end
					set_font (f_body, 12.0, w.bold)
					bx0 := tx + w.x - 2.0
					bx1 := tx + w.x + adv (w.word) + 2.0
					ctx.set_color_hex (tone)
						.fill_rect (bx0, ty + (ri - 1) * lh - 12.0, bx1 - bx0 + 4.0, 17.0).do_nothing
					if gi = caret_gi then
						caret_x := bx1 + 2.0
						caret_y := ty + (ri - 1) * lh
					end
				end
				ri := ri + 1
			end
			from
				ri := 1
			until
				ri > rows.count
			loop
				across rows [ri] as w loop
					set_font (f_body, 12.0, w.bold)
					txt (tx + w.x, ty + (ri - 1) * lh, w.word, C_ink)
				end
				ri := ri + 1
			end
			ctx.set_color_hex (C_signal).fill_rect (caret_x, caret_y - 12.0, 2.2, 16.0).do_nothing

			action_row (y + 116.0, <<
				[Icon_play, {STRING_32} "Play", Style_disabled],
				[Icon_refresh, {STRING_32} "New Take", Style_normal],
				[Icon_check, {STRING_32} "Approve", Style_disabled],
				[-1, {STRING_32} "", 0],
				[Icon_none, {STRING_32} "Split Here", Style_primary],
				[Icon_up, {STRING_32} "", Style_normal],
				[Icon_down, {STRING_32} "", Style_normal]>>)
		end

	caret_index_of (a_toks: ARRAYED_LIST [TUPLE [word: STRING_32; bold: BOOLEAN]]; a_word: STRING_32): INTEGER
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > a_toks.count or Result > 0
			loop
				if a_toks [i].word.same_string (a_word) then
					Result := i
				end
				i := i + 1
			end
		end

	draw_block_3
		local
			y: REAL_64
			s: STRING_32
		do
			y := 321.0
			card (y, 100.0, C_blue, False)
			card_head (y + 14.0, {STRING_32} "09", {STRING_32} "PROSE",
				{STRING_32} "RENDERED", C_blue, C_blue_wash, C_blue, {STRING_32} "0.94")
			s := {STRING_32} "take 2 rendering"
			set_font (f_mono, 9.5, False)
			txt (1160.0 - 14.0 - adv (s), y + 25.0, s, C_blue)
			set_font (f_body, 12.0, False)
			txt (122.0, y + 52.0, {STRING_32} "He points at the stone, then at 2 Kings 3, then back at the stone, and he lets the two of them argue with each other while !he! stands off to the side looking reasonable.", C_ink)
			action_row (y + 64.0, <<
				[Icon_play, {STRING_32} "Play", Style_normal],
				[Icon_refresh, {STRING_32} "New Take", Style_normal],
				[Icon_check, {STRING_32} "Approve", Style_primary],
				[-1, {STRING_32} "", 0],
				[Icon_none, {STRING_32} "Split Here", Style_normal],
				[Icon_up, {STRING_32} "", Style_normal],
				[Icon_down, {STRING_32} "", Style_normal]>>)
		end

	draw_block_4
		local
			y: REAL_64
		do
			y := 429.0
			card (y, 100.0, C_signal, False)
			card_head (y + 14.0, {STRING_32} "10", {STRING_32} "SEPARATOR",
				{STRING_32} "FAILED", C_signal, C_signal_wash, C_signal, {STRING_32} "%/8212/")
			set_font (f_mono, 9.5, False)
			txt (last_head_x, y + 25.0, {STRING_32} "engine: CUDA out of memory", C_signal)
			set_font (f_body, 12.0, False)
			txt (122.0, y + 52.0, {STRING_32} "The Leash %/183/ The Day Yahweh Looked Defeated %/183/ And One Called Mercy", C_ink)
			action_row (y + 64.0, <<
				[Icon_none, {STRING_32} "Retry", Style_primary],
				[Icon_play, {STRING_32} "Play", Style_disabled],
				[Icon_check, {STRING_32} "Approve", Style_disabled],
				[-1, {STRING_32} "", 0],
				[Icon_none, {STRING_32} "Split Here", Style_normal],
				[Icon_up, {STRING_32} "", Style_normal],
				[Icon_down, {STRING_32} "", Style_normal]>>)
		end

feature {NONE} -- Right panel

	panel_card (a_y, a_h: REAL_64; a_title: STRING_32)
		do
			frame_rrect (1172.0, a_y, 294.0, a_h, 3.0, C_panel, C_line, 1.0)
			set_font (f_mono, 9.5, False)
			tracked (1186.0, a_y + 20.0, a_title, C_dim, 1.2).do_nothing
		end

	panel_row (a_y: REAL_64; a_label, a_value: STRING_32; a_value_color: NATURAL_32)
		do
			set_font (f_mono, 10.0, False)
			txt (1186.0, a_y, a_label, C_dim)
			txt (1452.0 - adv (a_value), a_y, a_value, a_value_color)
		end

	draw_panel
		local
			y: REAL_64
		do
			-- TAKES
			y := 52.0
			panel_card (y, 118.0, {STRING_32} "TAKES")
			set_font (f_mono, 9.0, False)
			txt (1186.0, y + 40.0, {STRING_32} "#", C_dim)
			txt (1208.0, y + 40.0, {STRING_32} "SEED", C_dim)
			txt (1330.0, y + 40.0, {STRING_32} "FID", C_dim)
			txt (1390.0, y + 40.0, {STRING_32} "WPM", C_dim)
			hline (1186.0, y + 46.0, 266.0, C_line)
			set_font (f_mono, 10.0, False)
			txt (1186.0, y + 62.0, {STRING_32} "1", C_green)
			txt (1208.0, y + 62.0, {STRING_32} "4417822", C_green)
			txt (1330.0, y + 62.0, {STRING_32} "0.94", C_green)
			txt (1390.0, y + 62.0, {STRING_32} "142", C_green)
			draw_icon (Icon_check, 1432.0, y + 58.0, C_green)
			set_font (f_mono, 10.0, False)
			txt (1186.0, y + 80.0, {STRING_32} "2", C_ink)
			txt (1208.0, y + 80.0, {STRING_32} "9902551", C_ink)
			txt (1330.0, y + 80.0, {STRING_32} "0.91", C_ink)
			txt (1390.0, y + 80.0, {STRING_32} "168", C_ink)
			txt (1186.0, y + 98.0, {STRING_32} "3", C_ink)
			txt (1208.0, y + 98.0, {STRING_32} "1180347", C_ink)
			txt (1330.0, y + 98.0, {STRING_32} "0.94", C_ink)
			txt (1390.0, y + 98.0, {STRING_32} "131", C_ink)

			-- PARAMETERS
			y := 180.0
			panel_card (y, 96.0, {STRING_32} "PARAMETERS")
			set_font (f_mono, 9.5, False)
			txt (1186.0, y + 38.0, {STRING_32} "exaggeration", C_dim)
			fill_rrect (1186.0, y + 46.0, 266.0, 4.0, 2.0, C_line)
			ctx.set_color_hex (C_blue).fill_circle (1186.0 + 266.0 * 0.7, y + 48.0, 5.0).do_nothing
			panel_row (y + 70.0, {STRING_32} "seed", {STRING_32} "4417822", C_ink)
			set_font (f_mono, 9.0, False)
			txt (1186.0, y + 86.0, {STRING_32} "changing either re-renders this block", C_dim)

			-- GATE
			y := 286.0
			panel_card (y, 172.0, {STRING_32} "GATE")
			set_font (f_mono, 22.0, True)
			txt (1186.0, y + 52.0, {STRING_32} "0.94", C_ink)
			set_font (f_mono, 9.5, False)
			txt (1186.0, y + 66.0, {STRING_32} "round-trip fidelity", C_dim)
			panel_row (y + 90.0, {STRING_32} "pace", {STRING_32} "142 wpm", C_ink)
			panel_row (y + 106.0, {STRING_32} "longest run", {STRING_32} "22.4 s", C_amber)
			panel_row (y + 122.0, {STRING_32} "boundary silence", {STRING_32} "410 ms", C_ink)
			warn_glyph (1186.0, y + 134.0, 9.0, C_amber)
			set_font (f_mono, 9.5, False)
			txt (1200.0, y + 142.0, {STRING_32} "60-word sentence", C_amber)
			warn_glyph (1186.0, y + 150.0, 9.0, C_amber)
			txt (1200.0, y + 158.0, {STRING_32} "unbroken run over 20 s", C_amber)

			-- LEXICON
			y := 468.0
			panel_card (y, 80.0, {STRING_32} "LEXICON")
			set_font (f_mono, 9.5, False)
			txt (1186.0, y + 38.0, {STRING_32} "2 unproven: Mesha, Chemosh", C_amber)
			button (1186.0, y + 46.0, Icon_none, {STRING_32} "Search Respellings", Style_primary).do_nothing
		end

	draw_status
		local
			x: REAL_64
			s: STRING_32
		do
			ctx.set_color_hex (C_bar).fill_rect (0.0, 832.0, 1480.0, 28.0).do_nothing
			hline (0.0, 832.0, 1480.0, C_line)
			set_font (f_mono, 10.0, False)
			x := 14.0
			txt (x, 850.0, {STRING_32} "rendering 3 of 12", C_dim)
			x := x + adv ({STRING_32} "rendering 3 of 12") + 12.0
			fill_rrect (x, 843.0, 130.0, 5.0, 2.5, C_line)
			fill_rrect (x, 843.0, 34.0, 5.0, 2.5, C_blue)
			x := x + 142.0
			vsep (x, 838.0, 16.0)
			x := x + 12.0
			txt (x, 850.0, {STRING_32} "worker alive %/183/ pid 8841", C_dim)
			x := x + adv ({STRING_32} "worker alive %/183/ pid 8841") + 12.0
			vsep (x, 838.0, 16.0)
			x := x + 12.0
			txt (x, 850.0, {STRING_32} "overall 0.87   12 unapproved", C_dim)
			s := {STRING_32} "saved"
			txt (1466.0 - adv (s), 850.0, s, C_dim)
		end

feature {NONE} -- C Externals (demo-local; the library stays pure Cairo)

	c_add_font (a_path: POINTER): INTEGER
			-- AddFontResourceExW with FR_PRIVATE: process-only registration.
		external
			"C inline use <windows.h>"
		alias
			"return (int)AddFontResourceExW((LPCWSTR)$a_path, FR_PRIVATE, 0);"
		end

end
