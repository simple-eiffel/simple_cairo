# 7S-05: SECURITY - simple_cairo

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Security Considerations

### 1. File System Access
- **Risk:** PNG/PDF write operations could overwrite arbitrary files
- **Mitigation:** Caller must validate paths; contracts ensure non-empty filenames

### 2. Memory Management
- **Risk:** Native handle leaks if destroy not called
- **Mitigation:** Clear ownership model; destroy features with postconditions

### 3. Buffer Handling
- **Risk:** Waveform drawing takes raw POINTER to sample data
- **Mitigation:** Caller must ensure valid pointer and count; contract requires non-null pointer and positive count

### 4. External DLL
- **Risk:** Cairo DLL could be tampered with
- **Mitigation:** Use system-installed or verified DLL distribution

### 5. Text Rendering
- **Risk:** UTF-8 conversion for text rendering
- **Mitigation:** Uses Eiffel UTF_CONVERTER for safe conversion

## Attack Vectors

| Vector | Likelihood | Impact | Mitigation |
|--------|------------|--------|------------|
| Path traversal | Low | Medium | Caller responsibility |
| Memory corruption | Low | High | Contract enforcement |
| DLL hijacking | Low | High | Proper DLL location |

## Recommendations

1. Validate file paths before passing to write_png
2. Always call destroy on surfaces and contexts
3. Ensure Cairo DLL is from trusted source
