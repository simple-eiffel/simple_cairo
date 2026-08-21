/* spike_win.h - pure Win32 window scaffolding for the SV_BLOCK_EDITOR spike.
   No Vision2 anywhere: RegisterClass + CreateWindowExW + a blocking message
   pump, with input forwarded to Eiffel through a small event queue.
   Single-window by design; this is spike scaffolding, not library code. */

#ifndef SPIKE_WIN_H
#define SPIKE_WIN_H

#include <windows.h>

/* Event queue: [type, a, b, c] per slot.
   type 0 none | 1 mouse_move(x,y) | 2 lbutton_down(x,y) | 3 char(code)
        | 4 keydown(vk: arrows only) | 6 expose | 7 timer_blink */
#define SPIKE_QCAP 1024
static HWND s_spike_hwnd = 0;
static int  s_spike_q[SPIKE_QCAP][4];
static int  s_spike_qhead = 0, s_spike_qtail = 0;

static void spike_push(int t, int a, int b, int c) {
    int next = (s_spike_qtail + 1) % SPIKE_QCAP;
    if (next == s_spike_qhead) return; /* full: drop */
    s_spike_q[s_spike_qtail][0] = t;
    s_spike_q[s_spike_qtail][1] = a;
    s_spike_q[s_spike_qtail][2] = b;
    s_spike_q[s_spike_qtail][3] = c;
    s_spike_qtail = next;
}

static LRESULT CALLBACK spike_wndproc(HWND h, UINT m, WPARAM w, LPARAM l) {
    switch (m) {
        case WM_MOUSEMOVE:
            spike_push(1, (int)(short)LOWORD(l), (int)(short)HIWORD(l), 0);
            return 0;
        case WM_LBUTTONDOWN:
            SetFocus(h);
            spike_push(2, (int)(short)LOWORD(l), (int)(short)HIWORD(l), 0);
            return 0;
        case WM_CHAR:
            spike_push(3, (int)w, 0, 0);
            return 0;
        case WM_KEYDOWN:
            if (w >= VK_LEFT && w <= VK_DOWN) spike_push(4, (int)w, 0, 0);
            return 0;
        case WM_TIMER:
            spike_push(7, 0, 0, 0);
            return 0;
        case WM_PAINT: {
            PAINTSTRUCT ps;
            BeginPaint(h, &ps);
            EndPaint(h, &ps);
            spike_push(6, 0, 0, 0);
            return 0;
        }
        case WM_ERASEBKGND:
            return 1; /* we paint everything; no flicker */
        case WM_DESTROY:
            KillTimer(h, 1);
            PostQuitMessage(0);
            return 0;
    }
    return DefWindowProcW(h, m, w, l);
}

/* Create the window with an exact client size; returns HWND (0 on failure). */
static void* spike_create_window(const wchar_t* title, int cw, int ch) {
    WNDCLASSW wc;
    RECT r;
    HWND h;
    SetProcessDPIAware();
    ZeroMemory(&wc, sizeof(wc));
    wc.lpfnWndProc = spike_wndproc;
    wc.hInstance = GetModuleHandleW(0);
    wc.hCursor = LoadCursorW(0, (LPCWSTR)IDC_IBEAM);
    wc.lpszClassName = L"SimpleCairoSpikeWindow";
    RegisterClassW(&wc);
    r.left = 0; r.top = 0; r.right = cw; r.bottom = ch;
    AdjustWindowRect(&r, WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX, FALSE);
    h = CreateWindowExW(0, L"SimpleCairoSpikeWindow", title,
        WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,
        CW_USEDEFAULT, CW_USEDEFAULT,
        r.right - r.left, r.bottom - r.top, 0, 0, GetModuleHandleW(0), 0);
    s_spike_hwnd = h;
    if (h) {
        ShowWindow(h, SW_SHOW);
        UpdateWindow(h);
        SetTimer(h, 1, 530, 0); /* caret blink */
    }
    return (void*)h;
}

/* Blocking pump: waits for one message, dispatches it.
   Returns 0 when WM_QUIT was received, else 1. */
static int spike_pump(void) {
    MSG m;
    BOOL r = GetMessageW(&m, 0, 0, 0);
    if (r <= 0) return 0;
    TranslateMessage(&m);
    DispatchMessageW(&m);
    return 1;
}

/* Pop one queued event into out4; returns the type (0 = queue empty). */
static int spike_next_event(int* out4) {
    if (s_spike_qhead == s_spike_qtail) return 0;
    out4[0] = s_spike_q[s_spike_qhead][0];
    out4[1] = s_spike_q[s_spike_qhead][1];
    out4[2] = s_spike_q[s_spike_qhead][2];
    out4[3] = s_spike_q[s_spike_qhead][3];
    s_spike_qhead = (s_spike_qhead + 1) % SPIKE_QCAP;
    return out4[0];
}

static void* spike_get_dc(void)          { return s_spike_hwnd ? (void*)GetDC(s_spike_hwnd) : 0; }
static void  spike_release_dc(void* dc)  { if (s_spike_hwnd && dc) ReleaseDC(s_spike_hwnd, (HDC)dc); }

/* High-resolution milliseconds. */
static double spike_now_ms(void) {
    LARGE_INTEGER f, c;
    QueryPerformanceFrequency(&f);
    QueryPerformanceCounter(&c);
    return (double)c.QuadPart * 1000.0 / (double)f.QuadPart;
}

#endif /* SPIKE_WIN_H */
