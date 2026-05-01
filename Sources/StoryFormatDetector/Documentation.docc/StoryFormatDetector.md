# ``StoryFormatDetector``

Identify interactive fiction artifact formats from bytes or file extensions.

## Overview

StoryFormatDetector answers what kind of IF file an artifact appears to be. It
is intentionally separate from downstream playability: a consumer can recognize
a format even when that consumer cannot open it yet.

Use byte detection when reliable magic signatures exist. Use extension detection
for formats whose identity is conventionally carried by the file name.

## Topics

### Detection

- ``StoryFormatDetector/detect(data:)``
- ``StoryFormatDetector/detect(fileExtension:)``
- ``StoryFormatDetector/validate(data:fileExtension:)``

### Results

- ``StoryFormat``
- ``DetectionError``
