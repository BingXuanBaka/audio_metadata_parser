library audio_metadata_parser;

import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_parser/common/models/audio_metadata.dart';

import 'package:audio_metadata_parser/parsers/id3v2.dart';
import 'package:audio_metadata_parser/parsers/flac.dart';

abstract class AudioMetadataParser {
  factory AudioMetadataParser(File file) {
    Uint8List bytes = file.readAsBytesSync();
    return AudioMetadataParser.fromBytes(bytes);
  }

  factory AudioMetadataParser.fromBytes(Uint8List bytes) {
    if (String.fromCharCodes(bytes.sublist(0, 3)) == "ID3") {
      return ID3v2MetadataParser(bytes);
    }

    if (String.fromCharCodes(bytes.sublist(0, 4)) == "fLaC") {
      return FLACMetadataParser(bytes);
    }

    return UnknownMetadataParser();
  }

  /// Parse Metadata contains in parser,
  /// returns [AudioMetadata].
  AudioMetadata parse();
}

class UnknownMetadataParser implements AudioMetadataParser {
  @override
  AudioMetadata parse() => AudioMetadata();
}
