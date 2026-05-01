# Consumer Adoption

## Read This When

- You are adding StoryFormatDetector to an app, importer, cataloger, or test
  harness.
- You are deciding how to separate detection from local playability.
- You are preparing a package bump in a downstream consumer such as Foyer.

## What This Package Owns

StoryFormatDetector owns:

- `StoryFormat` cases and their detection semantics
- magic-byte detection for formats with reliable signatures
- extension fallback for formats without reliable signatures
- validation errors that help import flows explain unsupported files
- tests for shared detection behavior

## What Consumers Own

Consumers own:

- format-to-openability or format-to-playability policy
- interpreter availability and launch behavior
- file import UI and error messaging
- sandbox/security checks around opening files
- richer metadata extraction beyond identifying the file type

## Adoption Guidance

1. Use `detect(data:)` when you have enough bytes and only need a best-effort
   format answer.
2. Use `detect(fileExtension:)` when cataloging by name or preparing UI before
   bytes are loaded.
3. Use `validate(data:fileExtension:)` in import flows that need thrown errors.
4. Map the returned `StoryFormat` into the consumer's local openability policy.
5. Keep unsupported-but-recognized formats distinct from unknown files.

## Downstream Verification After A Bump

After bumping StoryFormatDetector, a consumer should verify:

- representative import fixtures still identify as expected
- unsupported-but-recognized formats still produce the intended user-facing
  message
- openable formats still route to the correct interpreter or handler
- extension-only formats do not accidentally bypass consumer security checks

## Canonical Docs

- Detection policy: [`docs/architecture/detection-policy.md`](../architecture/detection-policy.md)
- Testing policy: [`docs/process/testing.md`](testing.md)

Consumer-specific launch/openability docs belong in the consumer repo.
