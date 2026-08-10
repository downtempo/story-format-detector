# Contributing

StoryFormatDetector is a small, deliberately focused library. It detects interactive fiction file and package formats from magic bytes and file extensions. That scope is intentional and will stay narrow.

## Before opening a pull request

If you want to add support for a new format or change detection behavior, open an issue first. Not because contributions are unwelcome, but because it helps to agree on scope and approach before anyone writes code. Bug fixes and documentation improvements can go straight to a PR.

## Running the tests

```bash
swift test
```

The test suite uses XCTest. All tests must pass before a PR will be merged.

## Hosted CI

Routine build and test coverage runs on Linux because the package has no
Apple-only imports or native targets. Superseded pull-request runs are
cancelled. The manual Apple readiness workflow runs native tests plus iOS and
visionOS Simulator builds before a release or when platform-specific work is
introduced.

## Code style

- Prefer modern Swift and avoid deprecated APIs
- No external dependencies beyond Foundation
- Public API changes need doc comments and, for behavior changes, new tests

## License

By contributing, you agree that your changes will be released under the MIT license that covers this project.
