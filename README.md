<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

> [!WARNING]  
> This package is still developing and may will have many breaking changes
> before publishing the first release.  
> **DO NOT** use in production currently.

## Features

Parses metadata from audio files. Currently only supports ID3v2 codecs.  
Supports of other codecs is still working on.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

To parsing metadata from a File, create an instance of `AudioMetadataParser`
and invoke `parse` to get a metadatas.

```dart
final parser = AudioMetadataParser(File(/*PATH_TO_FILE*/));
final metadata = parser.parse();
print("Parsed metadatas: $metadata");
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
