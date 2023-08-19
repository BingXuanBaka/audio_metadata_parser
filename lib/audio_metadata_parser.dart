library audio_metadata_parser;

import 'dart:io';

import 'common/models.dart';
export 'common/models.dart';

import 'parsers/id3v2.dart';
import 'parsers/flac.dart';

abstract class AudioMetadataParser {
  factory AudioMetadataParser(File file) {
    var bytes = file.readAsBytesSync();
    return AudioMetadataParser.fromBytes(bytes);
  }

  factory AudioMetadataParser.fromBytes(List<int> bytes) {
    if (String.fromCharCodes(bytes.sublist(0, 3)) == "ID3") {
      return ID3v2MetaDataParser(bytes);
    }

    if (String.fromCharCodes(bytes.sublist(0, 4)) == "fLaC") {
      return FLACMetaDataParser(bytes);
    }

    return UnknownMetadataParser();
  }

  AudioMetadata parse();
}

class UnknownMetadataParser implements AudioMetadataParser {
  @override
  AudioMetadata parse() => AudioMetadata();
}
