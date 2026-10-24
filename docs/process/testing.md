# Testing

## Baseline Commands

```bash
swift build
swift test
```

## Hosted CI

Routine build and test coverage runs on Ubuntu. The package currently uses
Foundation only, so its Apple deployment declarations do not by themselves
require a premium macOS runner. Superseded pull-request runs are cancelled.

The former manual hosted-Mac job is retired. Native Apple readiness is deferred
until a useful release or platform-specific change can use a qualified isolated
Mac execution route. No replacement GitHub runner is admitted or qualified by
this retirement. Public-repository runner admission requires a separate review
of workflow trust and assignment exposure.

The retained native commands for that future check are:

```bash
swift test
xcodebuild -scheme StoryFormatDetector -destination 'generic/platform=iOS Simulator' -skipPackagePluginValidation -skipMacroValidation build
xcodebuild -scheme StoryFormatDetector -destination 'generic/platform=visionOS Simulator' -skipPackagePluginValidation -skipMacroValidation build
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
