# S05: CONSTRAINTS - simple_cairo

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_cairo

## Technical Constraints

### 1. External Dependency
- **Constraint:** Requires libcairo-2.dll at runtime
- **Impact:** Applications must distribute or ensure Cairo is installed
- **Mitigation:** Bundle DLL with application

### 2. Windows Platform
- **Constraint:** C header uses Windows-specific patterns
- **Impact:** Currently Windows-only
- **Mitigation:** Could add Unix variants to header

### 3. Native Handle Management
- **Constraint:** All objects wrap native pointers that must be freed
- **Impact:** Caller must call `destroy` or memory leaks occur
- **Mitigation:** Clear documentation, postconditions on destroy

### 4. PDF Finalization
- **Constraint:** PDF must be destroyed to finalize the file
- **Impact:** Incomplete PDF if destroy not called
- **Mitigation:** Documented in class notes

### 5. Thread Safety
- **Constraint:** Cairo contexts are not thread-safe
- **Impact:** Cannot share context between SCOOP processors
- **Mitigation:** Create separate contexts per thread

## Resource Limits

| Resource | Limit | Notes |
|----------|-------|-------|
| Surface size | Limited by memory | ~4 bytes/pixel for ARGB32 |
| PDF pages | Unlimited | Limited by disk space |
| Font size | > 0 | No maximum enforced |
| Color values | 0.0-1.0 | Clamped by Cairo |

## Performance Constraints

| Operation | Constraint |
|-----------|------------|
| Large surfaces | Memory bound |
| Complex paths | CPU bound |
| PDF generation | I/O bound |
| Text rendering | Font loading once |
