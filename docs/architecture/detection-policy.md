# Detection Policy

## Purpose

StoryFormatDetector identifies IF artifact formats. It does not decide whether a
particular app can open, launch, or fully support the detected format.

This distinction is important for downstream consumers such as Foyer: a format
can be detectable by this package even when it is not currently openable by that
consumer's interpreter stack.

## Detection vs. Openability

- **Detectable by package** means StoryFormatDetector can return a
  `StoryFormat` from bytes, extension, or both.
- **Openable by consumer** means a downstream app or tool has an interpreter,
  launcher, renderer, permissions, and UX policy for that format.

StoryFormatDetector should stay broader than any single consumer's current open
support. Consumers should map `StoryFormat` to their own playability or import
policy locally.

## Detection Order

`validate(data:fileExtension:)` uses this order:

1. Magic-byte detection when a reliable byte signature exists.
2. Extension fallback for formats without reliable magic bytes.
3. `DetectionError.unreadable` or `DetectionError.unsupportedFormat` when no
   trustworthy answer is available.

Magic-byte detection takes priority over extension labels because file names are
easier to get wrong than binary headers.

## Blorb Policy

Blorb detection walks the IFF chunk structure instead of scanning a fixed byte
window. A `GLUL` execution chunk identifies Glulx Blorb. A complete Blorb with no
`GLUL` chunk is treated as Z-machine Blorb. A truncated prefix returns `nil`
rather than guessing.

Generic `.blorb` remains a separate extension-only result when the caller has no
container bytes or the container type is otherwise unknown.

## Extension-Only Formats

Some IF formats have no simple, reliable magic signature for this package today.
Those are extension-only detections:

- Hugo
- Alan
- ADRIFT
- TADS 2
- TADS 3
- Adventuron
- Web packages
- Twine source/project files

Extension-only detection is still useful for import UX, cataloging, and telling
a user why a file is recognized but not currently playable.

## Consumer Responsibilities

Consumers should:

- read `StoryFormat` as identification, not launch permission
- maintain their own format-to-playability table
- explain unsupported-but-recognized formats distinctly from unknown files
- add consumer tests for their openability policy rather than changing detector
  semantics to match one app

Foyer-specific openability belongs in Foyer docs and tests. Shared detection
semantics belong here.
