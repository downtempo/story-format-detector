# Testing

## Baseline Commands

```bash
swift build
swift test
```

## Test Ownership

Tests in this package should cover shared detection behavior:

- magic-byte detection for Z-machine and Glulx
- Blorb IFF chunk walking, including truncated-prefix behavior
- extension fallback for extension-only formats
- `validate(data:fileExtension:)` success and error paths
- case-insensitive extension handling
- minimum-size behavior for formats that require enough header bytes

## When To Add Tests

Add or update tests when changing:

- `StoryFormat` cases
- magic-byte detection
- Blorb walking
- extension mappings
- validation errors
- documented detection policy

## Downstream Testing Boundary

A consumer such as Foyer should test whether a detected format is openable in
that app. Do not encode Foyer's current interpreter support directly into this
package's tests unless the shared detector semantics themselves changed.

## Handoff Rule

If package tests were not run, say so explicitly in the PR handoff so downstream
consumers can account for the gap before bumping.
