# GUI spike run log (M2 - the pure route)

Target: an interactive window Larry can operate as a user, with NO Vision2 -
inline-C Win32 window + message pump, every pixel painted by simple_cairo,
blitted via Phase C-1's CAIRO_SURFACE.make_for_dc.

## Gates (verbatim)

    ec.sh check  simple_cairo_tests      -> clean
    ec.sh check  simple_cairo_gui_spike  -> clean (after 4 self-review fixes:
                                            STRING_32 building in ms_str, .floor
                                            -> truncated_to_integer, two mixed
                                            STRING_8/32 concats in prints)
    ec.sh test   simple_cairo_tests      -> 61 passed, 0 failed
                                            (incl. test_win32_surface_for_screen_dc)
    ec.sh test   simple_cairo_gui_spike  -> F_code built

## Launch (2026-08-21, verbatim)

    Fonts: 3 private faces loaded
    Window up. Operate it: click to place the caret, type to edit,
    arrows to move, Enter to split at the caret, Esc to reset,
    close the window to quit. Frame times print below.
    First frame written to spike_first_frame.png

First frame committed beside this log; frame cost is measured live
(QueryPerformanceCounter) and shown in the window footer.

## What only a human can verify

The FEEL: click accuracy, typing latency, wrap stability while editing,
whether the split preview reads instantly. That verification is Larry's,
by design - it is the M2 acceptance.

## Session telemetry (2026-08-21, Larry at the controls)

    19 edit frames (full relayout+render+blit): 6.7 - 8.8 ms
    Session: 1819 frames, avg 6.3 ms

Worst case is half a 60 Hz frame budget (16.7 ms) - from a deliberately
naive renderer: per-character select_font and show_text, no glyph cache,
no partial redraw, full-window repaint every frame. The headroom is the
finding.

## Verdict

M2 ACCEPTED - Larry, 2026-08-21: "yeah man ... THAT does it!!!"

Per the gate he set, this opens simple_narrate's GUI.
