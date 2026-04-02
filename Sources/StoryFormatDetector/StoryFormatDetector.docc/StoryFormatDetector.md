# ``StoryFormatDetector``

Identify interactive fiction story file and package formats from magic bytes or file extensions.

## Overview

Interactive fiction games are distributed as binary story files, browser-playable packages, and source/project files in several incompatible formats. StoryFormatDetector inspects the leading bytes of a story file and falls back to file extension matching when the bytes are ambiguous.

### Supported formats

| Format | Extensions | Detection method |
|--------|-----------|-----------------|
| Z-machine | .z1-.z8, .zblorb | Version byte (1-8) at offset 0 |
| Glulx | .ulx, .gblorb | `Glul` signature at offset 0 |
| Blorb (generic) | .blorb | Extension only |
| Blorb (Z) | .zblorb | IFF container without `GLUL` chunk |
| Blorb (Glulx) | .gblorb | IFF container with `GLUL` chunk |
| Hugo | .hex, .hdx | Extension only |
| Alan | .acd | Extension only |
| ADRIFT | .taf | Extension only |
| Adventuron | .aastory | Extension only |
| Web package | .html, .htm | Extension only |
| Twine source/project | .twee, .tw2, .tw3 | Extension only |
| TADS 2 | .gam | Extension only |
| TADS 3 | .t3 | Extension only |

### Quick start

```swift
import StoryFormatDetector

let data = try Data(contentsOf: storyFileURL)

// Magic byte detection (returns nil if unrecognized)
if let format = StoryFormatDetector.detect(data: data) {
    print(format) // e.g. .zcode or .glulx
}

// Validated detection with DetectionError (magic bytes + extension fallback)
let format = try StoryFormatDetector.validate(data: data, fileExtension: "z5")
```

## Topics

### Essentials

- <doc:GettingStarted>

### Detection

- ``StoryFormatDetector``
- ``StoryFormat``
- ``DetectionError``
