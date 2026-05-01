# Changelog

All notable changes to StoryFormatDetector are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2026-04-24

### Fixed
- Rejected Blorb `FORM` headers whose declared size cannot contain the required
  type tag.
- Bounded `GLUL` chunk walking to the declared `FORM` extent so trailing bytes
  outside the form can no longer misclassify a file as Glulx.

## [1.0.1] - 2026-04-16

### Fixed
- Fixed Blorb walking so truncated prefixes return an unknown result instead of
  incorrectly falling back to Z-machine Blorb.

### Note
- `1.0.1` was tagged but not published as a GitHub release.

## [1.0.0] - 2026-04-15

### Added
- Initial Swift package release.
- Detection from magic bytes for Z-machine, Glulx, and Blorb containers,
  including IFF chunk walking for Blorb story-type detection.
- Extension-based detection for Hugo, Alan, ADRIFT, TADS, Adventuron, web, and
  Twine artifacts.
- `validate(data:fileExtension:)` API with `DetectionError` failures for import
  flows that need explainable errors.

[Unreleased]: https://github.com/downtempo/story-format-detector/compare/1.0.2...HEAD
[1.0.2]: https://github.com/downtempo/story-format-detector/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/downtempo/story-format-detector/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/downtempo/story-format-detector/releases/tag/1.0.0
