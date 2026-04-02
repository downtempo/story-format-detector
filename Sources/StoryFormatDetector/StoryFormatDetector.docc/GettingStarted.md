# Getting Started with StoryFormatDetector

Detect the format of an interactive fiction story file or package and handle unsupported files gracefully.

## Overview

Most apps that work with interactive fiction story files or packages need to identify the format before doing anything else. StoryFormatDetector gives you three ways to identify formats, depending on how much information you have and how you want to handle failures.

## Detect from file data

If you have the raw bytes of a file, ``StoryFormatDetector/detect(data:)`` inspects the leading bytes for known magic signatures. It returns `nil` if the bytes don't match any supported format.

```swift
import StoryFormatDetector

let data = try Data(contentsOf: storyFileURL)

if let format = StoryFormatDetector.detect(data: data) {
    // Route to the appropriate interpreter
}
```

This method requires at least 12 bytes to attempt any identification, and at least 64 bytes for Z-machine detection (to avoid false positives on short files). Formats such as Hugo, Alan, ADRIFT, TADS, Adventuron, Twine source files, generic Blorb containers, and HTML packages are identified by extension instead.

## Detect from a file extension

When you only have a filename or URL, ``StoryFormatDetector/detect(fileExtension:)`` maps known extensions to formats. Pass the extension without a leading dot.

```swift
let ext = url.pathExtension // e.g. "z5"
if let format = StoryFormatDetector.detect(fileExtension: ext) {
    // Route to the appropriate interpreter
}
```

Extension detection covers formats like Hugo, Alan, ADRIFT, TADS, Adventuron, Twine source files, generic Blorb containers, and HTML packages that lack distinctive magic bytes for this detector.

For these extension-only formats, detection depends on the filename extension being correct; the package does not currently verify a separate magic signature for them.

## Validate with full error reporting

For file import flows where you need to tell the user what went wrong, ``StoryFormatDetector/validate(data:fileExtension:)`` combines both detection methods and throws ``DetectionError`` on failure. Magic bytes take priority; the extension is the fallback. Binary story formats still enforce minimum-size checks, while extension-only formats can validate from the extension alone.

```swift
do {
    let format = try StoryFormatDetector.validate(
        data: data,
        fileExtension: url.pathExtension
    )
    // Use format to select the interpreter
} catch DetectionError.unsupportedFormat(let ext) {
    // Show the user that this file type isn't supported
} catch DetectionError.unreadable {
    // The file is too short to be a valid story file
}
```
