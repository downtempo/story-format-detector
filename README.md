# StoryFormatDetector

StoryFormatDetector identifies interactive fiction story and project formats from
file bytes or file extensions. It is a small Swift package with no dependencies
beyond Foundation.

Use it when an app, importer, cataloging tool, or test harness needs to answer:
"What kind of IF artifact is this file?"

Detection is not the same as launch support. This package intentionally detects
more formats than any single consumer may be able to open. For example, Foyer
can use StoryFormatDetector to recognize Alan, ADRIFT, TADS, Adventuron, web,
and Twine artifacts even when Foyer's current interpreter stack cannot launch
all of them.

## Supported Formats

| Format | Extensions | Detection method |
|--------|-----------|-----------------|
| Z-machine | .z1-.z8, .zblorb | Version byte (1-8) at offset 0 |
| Glulx | .ulx, .gblorb | `Glul` signature at offset 0 |
| Blorb (generic) | .blorb | Extension only when container type is not otherwise known |
| Blorb (Z-machine) | .zblorb | IFF container (`FORM` + `IFRS`) without `GLUL` chunk |
| Blorb (Glulx) | .gblorb | IFF container (`FORM` + `IFRS`) with `GLUL` chunk |
| Hugo | .hex, .hdx | Extension only |
| Alan | .acd | Extension only |
| ADRIFT | .taf | Extension only |
| TADS 2 | .gam | Extension only |
| TADS 3 | .t3 | Extension only |
| Adventuron | .aastory | Extension only |
| Web package | .html, .htm | Extension only |
| Twine source/project | .twee, .tw2, .tw3 | Extension only |

Extension-only formats trust the file name. See the
[Detection Policy](docs/architecture/detection-policy.md) for the distinction
between reliable byte signatures and extension fallback.

Blorb files are IFF containers that bundle a story file with cover art and other
resources. The detector walks the IFF chunk structure to find a `GLUL` execution
chunk, so it still works when a large resource index pushes the story chunk well
past the start of the file.

Twine source and project files are tracked separately from browser-playable HTML
packages, keeping authoring formats distinct from compiled web releases.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/downtempo/story-format-detector.git", from: "1.0.2"),
]
```

Then add `StoryFormatDetector` to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["StoryFormatDetector"]
)
```

## Usage

### Detect from file data

```swift
import StoryFormatDetector

let data = try Data(contentsOf: storyFileURL)

if let format = StoryFormatDetector.detect(data: data) {
    print(format) // e.g. .zcode or .glulx
}
```

### Detect from file extension

```swift
if let format = StoryFormatDetector.detect(fileExtension: "z5") {
    print(format) // .zcode
}

if let format = StoryFormatDetector.detect(fileExtension: "twee") {
    print(format) // .twineSource
}
```

### Validate with extension fallback

`validate` combines both detection methods: magic bytes first, then extension as
a fallback. It throws `DetectionError` on failure instead of returning `nil`,
which is useful in file import flows where you need to explain what went wrong.

```swift
do {
    let format = try StoryFormatDetector.validate(data: data, fileExtension: "ulx")
    print(format) // e.g. .glulx
} catch DetectionError.unsupportedFormat(let ext) {
    // Unknown format for the given extension
} catch DetectionError.unreadable {
    // File too short to be a valid story file
}
```

## Docs

- [Doc Map](docs/DOCMAP.yaml)
- [Detection Policy](docs/architecture/detection-policy.md)
- [Consumer Adoption](docs/process/consumer-adoption.md)
- [Testing](docs/process/testing.md)
- [Changelog](CHANGELOG.md)

## Requirements

- Swift 5.9+
- iOS 13+ / macOS 10.15+ / visionOS 1+

## Author

[Andy Volk](https://andyvolk.com)

## License

MIT. See [LICENSE](LICENSE) for details.
