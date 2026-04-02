# StoryFormatDetector

Interactive fiction (IF) games are distributed as binary story files, browser-playable packages, and source/project files in several incompatible formats: Infocom's Z-machine, the newer Glulx VM, Hugo, Alan, the TADS runtime, ADRIFT, Adventuron packages, Blorb containers, HTML releases, and Twine source files. If you're building an IF interpreter, library app, or cataloging tool for Apple platforms, you need to identify which format a file uses before you can do anything else with it.

StoryFormatDetector is a small Swift package that handles this. It inspects the leading bytes of a file when a reliable magic signature exists, and falls back to file extension matching for formats that are best identified by extension. It has no dependencies beyond Foundation.

Formats marked "Extension only" rely on the file extension being correct; this package does not currently verify a separate magic signature for those formats.

## Supported formats

| Format | Extensions | Detection method |
|--------|-----------|-----------------|
| Z-machine | .z1-.z8, .zblorb | Version byte (1-8) at offset 0 |
| Glulx | .ulx, .gblorb | `Glul` signature at offset 0 |
| Blorb (generic) | .blorb | Extension only when container type is not otherwise known |
| Blorb (Z-machine) | .zblorb | IFF container (`FORM`+`IFRS`) without `GLUL` chunk |
| Blorb (Glulx) | .gblorb | IFF container (`FORM`+`IFRS`) with `GLUL` chunk |
| Hugo | .hex, .hdx | Extension only (no reliable magic bytes) |
| Alan | .acd | Extension only (no reliable magic bytes) |
| ADRIFT | .taf | Extension only (no reliable magic bytes) |
| TADS 2 | .gam | Extension only (no reliable magic bytes) |
| TADS 3 | .t3 | Extension only (no reliable magic bytes) |
| Adventuron | .aastory | Extension only (no reliable magic bytes) |
| Web package | .html, .htm | Extension only |
| Twine source/project | .twee, .tw2, .tw3 | Extension only |

Blorb files are IFF (Interchange File Format) containers that bundle a story file with cover art and other resources. The detector walks the IFF chunk structure to find a `GLUL` execution chunk, so it still works when a large resource index pushes the story chunk well past the start of the file. When all you have is a `.blorb` extension and not the container contents, the detector reports the generic `.blorb` format.

Twine source and project files are tracked separately from browser-playable HTML packages, keeping authoring formats distinct from compiled web releases.

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/downtempo/story-format-detector.git", from: "1.0.0"),
]
```

Then add `StoryFormatDetector` to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["StoryFormatDetector"]
),
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

### Validate (magic bytes with extension fallback)

`validate` combines both detection methods: magic bytes first, then extension as a fallback. It throws `DetectionError` on failure instead of returning `nil`, which is useful in file import flows where you need to explain what went wrong. Binary story formats that require a real header still enforce minimum-size checks; extension-only formats validate from the extension when no magic signature is available.

```swift
do {
    let format = try StoryFormatDetector.validate(data: data, fileExtension: "ulx")
    print(format) // e.g. .glulx
} catch DetectionError.unsupportedFormat(let ext) {
    // Unknown format for the given extension
} catch DetectionError.unreadable {
    // File too short to be a valid story file (< 64 bytes)
}
```

## Requirements

- Swift 5.9+
- iOS 13+ / macOS 10.15+ / visionOS 1+

This package has been verified locally with `swift test` and clean Xcode builds for `My Mac`, `Any iOS Simulator Device`, and `Any visionOS Simulator Device`.

## Author

[Andy Volk](https://andyvolk.com)

## License

MIT. See [LICENSE](LICENSE) for details.
