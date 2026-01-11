/*
 * simple_cairo.h - Cross-platform Cairo 2D graphics wrapper for Eiffel
 *
 * Provides a simplified interface to Cairo for 2D vector graphics.
 * Supports: surfaces, paths, gradients, text, and image output.
 *
 * Windows: Link against cairo.dll
 * Linux: Link against libcairo (pkg-config --libs cairo)
 *
 * Following Eric Bezault's recommended pattern: implementations in .h file,
 * called from Eiffel inline C with use directive.
 *
 * Copyright (c) 2025 Larry Rix - MIT License
 */

#ifndef SIMPLE_CAIRO_H
#define SIMPLE_CAIRO_H

#include <cairo.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* ============ SURFACE MANAGEMENT ============ */

/* Create an image surface with ARGB32 format */
static cairo_surface_t* sc_surface_create(int width, int height) {
    return cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
}

/* ============ PDF SURFACE ============ */

#ifdef CAIRO_HAS_PDF_SURFACE
#include <cairo-pdf.h>

/* Create a PDF surface
 * width/height in points (72 points = 1 inch)
 * A4 = 595 x 842 points, Letter = 612 x 792 points
 */
static cairo_surface_t* sc_pdf_surface_create(const char* filename, double width, double height) {
    if (!filename) return NULL;
    return cairo_pdf_surface_create(filename, width, height);
}

/* Set PDF page size (call before drawing each page) */
static void sc_pdf_surface_set_size(cairo_surface_t* surface, double width, double height) {
    if (surface) cairo_pdf_surface_set_size(surface, width, height);
}

/* Show page and start new one (for multi-page PDFs) */
static void sc_pdf_show_page(cairo_t* cr) {
    if (cr) cairo_show_page(cr);
}

/* Add document metadata */
static void sc_pdf_set_metadata(cairo_surface_t* surface, int metadata_type, const char* value) {
    if (!surface || !value) return;
    cairo_pdf_metadata_t mt;
    switch (metadata_type) {
        case 0: mt = CAIRO_PDF_METADATA_TITLE; break;
        case 1: mt = CAIRO_PDF_METADATA_AUTHOR; break;
        case 2: mt = CAIRO_PDF_METADATA_SUBJECT; break;
        case 3: mt = CAIRO_PDF_METADATA_KEYWORDS; break;
        case 4: mt = CAIRO_PDF_METADATA_CREATOR; break;
        default: return;
    }
    cairo_pdf_surface_set_metadata(surface, mt, value);
}

#else
/* Stubs when PDF support not available */
static cairo_surface_t* sc_pdf_surface_create(const char* filename, double width, double height) {
    (void)filename; (void)width; (void)height;
    return NULL;
}
static void sc_pdf_surface_set_size(cairo_surface_t* surface, double width, double height) {
    (void)surface; (void)width; (void)height;
}
static void sc_pdf_show_page(cairo_t* cr) { (void)cr; }
static void sc_pdf_set_metadata(cairo_surface_t* surface, int metadata_type, const char* value) {
    (void)surface; (void)metadata_type; (void)value;
}
#endif

/* Create an image surface with specified format (0=ARGB32, 1=RGB24, 2=A8, 3=A1) */
static cairo_surface_t* sc_surface_create_format(int format, int width, int height) {
    cairo_format_t fmt;
    switch (format) {
        case 0: fmt = CAIRO_FORMAT_ARGB32; break;
        case 1: fmt = CAIRO_FORMAT_RGB24; break;
        case 2: fmt = CAIRO_FORMAT_A8; break;
        case 3: fmt = CAIRO_FORMAT_A1; break;
        default: fmt = CAIRO_FORMAT_ARGB32; break;
    }
    return cairo_image_surface_create(fmt, width, height);
}

/* Destroy a surface */
static void sc_surface_destroy(cairo_surface_t* surface) {
    if (surface) cairo_surface_destroy(surface);
}

/* Get surface width */
static int sc_surface_width(cairo_surface_t* surface) {
    return surface ? cairo_image_surface_get_width(surface) : 0;
}

/* Get surface height */
static int sc_surface_height(cairo_surface_t* surface) {
    return surface ? cairo_image_surface_get_height(surface) : 0;
}

/* Get surface stride (bytes per row) */
static int sc_surface_stride(cairo_surface_t* surface) {
    return surface ? cairo_image_surface_get_stride(surface) : 0;
}

/* Get raw pixel data pointer */
static unsigned char* sc_surface_data(cairo_surface_t* surface) {
    if (!surface) return NULL;
    cairo_surface_flush(surface);
    return cairo_image_surface_get_data(surface);
}

/* Write surface to PNG file. Returns 0 on success. */
static int sc_surface_write_png(cairo_surface_t* surface, const char* filename) {
    if (!surface || !filename) return -1;
    return (int)cairo_surface_write_to_png(surface, filename);
}

/* Check surface status. Returns 0 if OK. */
static int sc_surface_status(cairo_surface_t* surface) {
    return surface ? (int)cairo_surface_status(surface) : -1;
}

/* ============ CONTEXT MANAGEMENT ============ */

/* Create a drawing context for a surface */
static cairo_t* sc_context_create(cairo_surface_t* surface) {
    return surface ? cairo_create(surface) : NULL;
}

/* Destroy a context */
static void sc_context_destroy(cairo_t* cr) {
    if (cr) cairo_destroy(cr);
}

/* Check context status. Returns 0 if OK. */
static int sc_context_status(cairo_t* cr) {
    return cr ? (int)cairo_status(cr) : -1;
}

/* Save current state */
static void sc_save(cairo_t* cr) {
    if (cr) cairo_save(cr);
}

/* Restore saved state */
static void sc_restore(cairo_t* cr) {
    if (cr) cairo_restore(cr);
}

/* ============ COLOR & SOURCE ============ */

/* Set source color (RGB, 0-1 range) */
static void sc_set_rgb(cairo_t* cr, double r, double g, double b) {
    if (cr) cairo_set_source_rgb(cr, r, g, b);
}

/* Set source color (RGBA, 0-1 range) */
static void sc_set_rgba(cairo_t* cr, double r, double g, double b, double a) {
    if (cr) cairo_set_source_rgba(cr, r, g, b, a);
}

/* Set source color from hex (0xRRGGBB) */
static void sc_set_hex(cairo_t* cr, unsigned int hex) {
    if (!cr) return;
    double r = ((hex >> 16) & 0xFF) / 255.0;
    double g = ((hex >> 8) & 0xFF) / 255.0;
    double b = (hex & 0xFF) / 255.0;
    cairo_set_source_rgb(cr, r, g, b);
}

/* Set source color from hex with alpha (0xAARRGGBB) */
static void sc_set_hex_alpha(cairo_t* cr, unsigned int hex) {
    if (!cr) return;
    double a = ((hex >> 24) & 0xFF) / 255.0;
    double r = ((hex >> 16) & 0xFF) / 255.0;
    double g = ((hex >> 8) & 0xFF) / 255.0;
    double b = (hex & 0xFF) / 255.0;
    cairo_set_source_rgba(cr, r, g, b, a);
}

/* ============ LINE PROPERTIES ============ */

/* Set line width */
static void sc_set_line_width(cairo_t* cr, double width) {
    if (cr) cairo_set_line_width(cr, width);
}

/* Set line cap style (0=butt, 1=round, 2=square) */
static void sc_set_line_cap(cairo_t* cr, int cap) {
    if (!cr) return;
    cairo_line_cap_t c;
    switch (cap) {
        case 0: c = CAIRO_LINE_CAP_BUTT; break;
        case 1: c = CAIRO_LINE_CAP_ROUND; break;
        case 2: c = CAIRO_LINE_CAP_SQUARE; break;
        default: c = CAIRO_LINE_CAP_BUTT; break;
    }
    cairo_set_line_cap(cr, c);
}

/* Set line join style (0=miter, 1=round, 2=bevel) */
static void sc_set_line_join(cairo_t* cr, int join) {
    if (!cr) return;
    cairo_line_join_t j;
    switch (join) {
        case 0: j = CAIRO_LINE_JOIN_MITER; break;
        case 1: j = CAIRO_LINE_JOIN_ROUND; break;
        case 2: j = CAIRO_LINE_JOIN_BEVEL; break;
        default: j = CAIRO_LINE_JOIN_MITER; break;
    }
    cairo_set_line_join(cr, j);
}

/* ============ PATH CONSTRUCTION ============ */

/* Start a new sub-path */
static void sc_new_path(cairo_t* cr) {
    if (cr) cairo_new_path(cr);
}

/* Move to position (no line drawn) */
static void sc_move_to(cairo_t* cr, double x, double y) {
    if (cr) cairo_move_to(cr, x, y);
}

/* Draw line to position */
static void sc_line_to(cairo_t* cr, double x, double y) {
    if (cr) cairo_line_to(cr, x, y);
}

/* Draw cubic Bezier curve */
static void sc_curve_to(cairo_t* cr, double x1, double y1, double x2, double y2, double x3, double y3) {
    if (cr) cairo_curve_to(cr, x1, y1, x2, y2, x3, y3);
}

/* Draw arc (angles in radians) */
static void sc_arc(cairo_t* cr, double xc, double yc, double radius, double angle1, double angle2) {
    if (cr) cairo_arc(cr, xc, yc, radius, angle1, angle2);
}

/* Draw arc negative direction */
static void sc_arc_negative(cairo_t* cr, double xc, double yc, double radius, double angle1, double angle2) {
    if (cr) cairo_arc_negative(cr, xc, yc, radius, angle1, angle2);
}

/* Add rectangle to path */
static void sc_rectangle(cairo_t* cr, double x, double y, double width, double height) {
    if (cr) cairo_rectangle(cr, x, y, width, height);
}

/* Add rounded rectangle to path */
static void sc_rounded_rectangle(cairo_t* cr, double x, double y, double width, double height, double radius) {
    if (!cr) return;
    double r = radius;
    if (r > width / 2) r = width / 2;
    if (r > height / 2) r = height / 2;

    cairo_new_sub_path(cr);
    cairo_arc(cr, x + width - r, y + r, r, -M_PI/2, 0);
    cairo_arc(cr, x + width - r, y + height - r, r, 0, M_PI/2);
    cairo_arc(cr, x + r, y + height - r, r, M_PI/2, M_PI);
    cairo_arc(cr, x + r, y + r, r, M_PI, 3*M_PI/2);
    cairo_close_path(cr);
}

/* Close current sub-path */
static void sc_close_path(cairo_t* cr) {
    if (cr) cairo_close_path(cr);
}

/* ============ DRAWING OPERATIONS ============ */

/* Stroke the current path */
static void sc_stroke(cairo_t* cr) {
    if (cr) cairo_stroke(cr);
}

/* Stroke the current path, preserving it */
static void sc_stroke_preserve(cairo_t* cr) {
    if (cr) cairo_stroke_preserve(cr);
}

/* Fill the current path */
static void sc_fill(cairo_t* cr) {
    if (cr) cairo_fill(cr);
}

/* Fill the current path, preserving it */
static void sc_fill_preserve(cairo_t* cr) {
    if (cr) cairo_fill_preserve(cr);
}

/* Paint entire surface with current source */
static void sc_paint(cairo_t* cr) {
    if (cr) cairo_paint(cr);
}

/* Paint entire surface with alpha */
static void sc_paint_alpha(cairo_t* cr, double alpha) {
    if (cr) cairo_paint_with_alpha(cr, alpha);
}

/* Clear surface to transparent */
static void sc_clear(cairo_t* cr) {
    if (!cr) return;
    cairo_save(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
    cairo_paint(cr);
    cairo_restore(cr);
}

/* ============ GRADIENTS ============ */

/* Create linear gradient */
static cairo_pattern_t* sc_gradient_linear(double x0, double y0, double x1, double y1) {
    return cairo_pattern_create_linear(x0, y0, x1, y1);
}

/* Create radial gradient */
static cairo_pattern_t* sc_gradient_radial(double cx0, double cy0, double r0, double cx1, double cy1, double r1) {
    return cairo_pattern_create_radial(cx0, cy0, r0, cx1, cy1, r1);
}

/* Add color stop to gradient (RGB) */
static void sc_gradient_add_stop_rgb(cairo_pattern_t* pattern, double offset, double r, double g, double b) {
    if (pattern) cairo_pattern_add_color_stop_rgb(pattern, offset, r, g, b);
}

/* Add color stop to gradient (RGBA) */
static void sc_gradient_add_stop_rgba(cairo_pattern_t* pattern, double offset, double r, double g, double b, double a) {
    if (pattern) cairo_pattern_add_color_stop_rgba(pattern, offset, r, g, b, a);
}

/* Add color stop from hex */
static void sc_gradient_add_stop_hex(cairo_pattern_t* pattern, double offset, unsigned int hex) {
    if (!pattern) return;
    double r = ((hex >> 16) & 0xFF) / 255.0;
    double g = ((hex >> 8) & 0xFF) / 255.0;
    double b = (hex & 0xFF) / 255.0;
    cairo_pattern_add_color_stop_rgb(pattern, offset, r, g, b);
}

/* Set pattern as source */
static void sc_set_source_pattern(cairo_t* cr, cairo_pattern_t* pattern) {
    if (cr && pattern) cairo_set_source(cr, pattern);
}

/* Destroy pattern */
static void sc_pattern_destroy(cairo_pattern_t* pattern) {
    if (pattern) cairo_pattern_destroy(pattern);
}

/* ============ TRANSFORMS ============ */

/* Translate coordinate system */
static void sc_translate(cairo_t* cr, double tx, double ty) {
    if (cr) cairo_translate(cr, tx, ty);
}

/* Scale coordinate system */
static void sc_scale(cairo_t* cr, double sx, double sy) {
    if (cr) cairo_scale(cr, sx, sy);
}

/* Rotate coordinate system (radians) */
static void sc_rotate(cairo_t* cr, double angle) {
    if (cr) cairo_rotate(cr, angle);
}

/* Reset to identity matrix */
static void sc_identity_matrix(cairo_t* cr) {
    if (cr) cairo_identity_matrix(cr);
}

/* ============ TEXT ============ */

/* Select font face */
static void sc_select_font(cairo_t* cr, const char* family, int slant, int weight) {
    if (!cr || !family) return;
    cairo_font_slant_t s = (slant == 1) ? CAIRO_FONT_SLANT_ITALIC :
                           (slant == 2) ? CAIRO_FONT_SLANT_OBLIQUE :
                           CAIRO_FONT_SLANT_NORMAL;
    cairo_font_weight_t w = (weight == 1) ? CAIRO_FONT_WEIGHT_BOLD :
                            CAIRO_FONT_WEIGHT_NORMAL;
    cairo_select_font_face(cr, family, s, w);
}

/* Set font size */
static void sc_set_font_size(cairo_t* cr, double size) {
    if (cr) cairo_set_font_size(cr, size);
}

/* Draw text at current position */
static void sc_show_text(cairo_t* cr, const char* text) {
    if (cr && text) cairo_show_text(cr, text);
}

/* Get text extents (returns width) */
static double sc_text_width(cairo_t* cr, const char* text) {
    if (!cr || !text) return 0;
    cairo_text_extents_t extents;
    cairo_text_extents(cr, text, &extents);
    return extents.width;
}

/* Get text height */
static double sc_text_height(cairo_t* cr, const char* text) {
    if (!cr || !text) return 0;
    cairo_text_extents_t extents;
    cairo_text_extents(cr, text, &extents);
    return extents.height;
}

/* ============ CONVENIENCE: SHAPES ============ */

/* Draw filled rectangle */
static void sc_fill_rect(cairo_t* cr, double x, double y, double w, double h) {
    if (!cr) return;
    cairo_rectangle(cr, x, y, w, h);
    cairo_fill(cr);
}

/* Draw stroked rectangle */
static void sc_stroke_rect(cairo_t* cr, double x, double y, double w, double h) {
    if (!cr) return;
    cairo_rectangle(cr, x, y, w, h);
    cairo_stroke(cr);
}

/* Draw filled circle */
static void sc_fill_circle(cairo_t* cr, double cx, double cy, double radius) {
    if (!cr) return;
    cairo_arc(cr, cx, cy, radius, 0, 2 * M_PI);
    cairo_fill(cr);
}

/* Draw stroked circle */
static void sc_stroke_circle(cairo_t* cr, double cx, double cy, double radius) {
    if (!cr) return;
    cairo_arc(cr, cx, cy, radius, 0, 2 * M_PI);
    cairo_stroke(cr);
}

/* Draw line */
static void sc_draw_line(cairo_t* cr, double x1, double y1, double x2, double y2) {
    if (!cr) return;
    cairo_move_to(cr, x1, y1);
    cairo_line_to(cr, x2, y2);
    cairo_stroke(cr);
}

/* ============ WAVEFORM DRAWING (for Speech Studio) ============ */

/* Draw waveform from sample data
 * samples: array of float samples (-1.0 to 1.0)
 * count: number of samples
 * x, y, width, height: drawing area
 */
static void sc_draw_waveform(cairo_t* cr, const float* samples, int count,
                             double x, double y, double width, double height) {
    if (!cr || !samples || count <= 0) return;

    double mid_y = y + height / 2;
    double samples_per_pixel = (double)count / width;

    cairo_new_path(cr);
    cairo_move_to(cr, x, mid_y);

    for (int px = 0; px < (int)width; px++) {
        int start_sample = (int)(px * samples_per_pixel);
        int end_sample = (int)((px + 1) * samples_per_pixel);
        if (end_sample > count) end_sample = count;

        /* Find min and max in this pixel's sample range */
        float min_val = 0, max_val = 0;
        for (int i = start_sample; i < end_sample; i++) {
            if (samples[i] < min_val) min_val = samples[i];
            if (samples[i] > max_val) max_val = samples[i];
        }

        /* Draw vertical line for this pixel */
        double y_min = mid_y - (max_val * height / 2);
        double y_max = mid_y - (min_val * height / 2);

        cairo_move_to(cr, x + px, y_min);
        cairo_line_to(cr, x + px, y_max);
    }

    cairo_stroke(cr);
}

/* Draw waveform from int16 PCM data */
static void sc_draw_waveform_i16(cairo_t* cr, const short* samples, int count,
                                  double x, double y, double width, double height) {
    if (!cr || !samples || count <= 0) return;

    double mid_y = y + height / 2;
    double samples_per_pixel = (double)count / width;

    cairo_new_path(cr);

    for (int px = 0; px < (int)width; px++) {
        int start_sample = (int)(px * samples_per_pixel);
        int end_sample = (int)((px + 1) * samples_per_pixel);
        if (end_sample > count) end_sample = count;

        short min_val = 0, max_val = 0;
        for (int i = start_sample; i < end_sample; i++) {
            if (samples[i] < min_val) min_val = samples[i];
            if (samples[i] > max_val) max_val = samples[i];
        }

        double y_min = mid_y - ((double)max_val / 32768.0 * height / 2);
        double y_max = mid_y - ((double)min_val / 32768.0 * height / 2);

        cairo_move_to(cr, x + px, y_min);
        cairo_line_to(cr, x + px, y_max);
    }

    cairo_stroke(cr);
}

/* ============ SHADOW EFFECT ============ */

/* Draw shadow behind current path (must call before fill/stroke)
 * offset_x, offset_y: shadow offset
 * blur: blur radius (approximated with alpha gradient)
 * color: shadow color (0xAARRGGBB)
 */
static void sc_draw_shadow(cairo_t* cr, double offset_x, double offset_y,
                           double blur, unsigned int color) {
    if (!cr) return;

    cairo_path_t* path = cairo_copy_path(cr);

    cairo_save(cr);
    cairo_translate(cr, offset_x, offset_y);

    /* Approximate blur with multiple passes at different alphas */
    double a = ((color >> 24) & 0xFF) / 255.0;
    double r = ((color >> 16) & 0xFF) / 255.0;
    double g = ((color >> 8) & 0xFF) / 255.0;
    double b = (color & 0xFF) / 255.0;

    int steps = (int)(blur / 2);
    if (steps < 1) steps = 1;
    if (steps > 10) steps = 10;

    for (int i = steps; i >= 0; i--) {
        double scale = 1.0 + (i * blur / steps / 50.0);
        double alpha = a * (1.0 - (double)i / (steps + 1)) * 0.5;

        cairo_save(cr);
        cairo_new_path(cr);
        cairo_append_path(cr, path);
        cairo_set_source_rgba(cr, r, g, b, alpha);
        cairo_fill(cr);
        cairo_restore(cr);
    }

    cairo_restore(cr);
    cairo_path_destroy(path);

    /* Restore original path */
    cairo_new_path(cr);
    cairo_append_path(cr, path);
}

#endif /* SIMPLE_CAIRO_H */
