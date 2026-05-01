# Changelog

All notable changes to StoryFormatDetector are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2026-05-01

### Fixed
- Improved Blorb detection by walking the IFF chunk structure instead of relying
  on a fixed prefix window.

## [1.0.0] - 2026-04-15

### Added
- Initial Swift package release.
- Detection from magic bytes for Z-machine, Glulx, and Blorb containers.
- Extension-based detection for Hugo, Alan, ADRIFT, TADS, Adventuron, web, and
  Twine artifacts.
- `validate(data:fileExtension:)` API with `DetectionError` failures for import
  flows that need explainable errors.

[Unreleased]: https://github.com/downtempo/story-format-detector/compare/1.0.2...HEAD
[1.0.2]: https://github.com/downtempo/story-format-detector/compare/1.0.0...1.0.2
[1.0.0]: https://github.com/downtempo/story-format-detector/releases/tag/1.0.0
