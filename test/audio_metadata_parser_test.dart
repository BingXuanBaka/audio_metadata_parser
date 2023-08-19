import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:audio_metadata_parser/audio_metadata_parser.dart';

void main() {
  test("test id3v2.3", () {
    final parser = AudioMetadataParser(File("test/id3_23.bin"));
    final metadata = parser.parse();
    expect(metadata.title, "TrackName");
    expect(metadata.artist, ["SongArtist"]);
    expect(metadata.album, "AlbumName");
    expect(metadata.albumArtist, "AlbumArtist");
    expect(metadata.year, 2000);
    expect(metadata.trackNumber, 5);
    expect(metadata.albumTrackCount, 6);
  });
}
