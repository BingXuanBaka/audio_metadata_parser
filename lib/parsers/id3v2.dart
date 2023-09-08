import 'dart:typed_data';

import 'package:audio_metadata_parser/audio_metadata_parser.dart';
import 'package:audio_metadata_parser/common/models/audio_metadata.dart';
import 'package:audio_metadata_parser/common/models/id3v2.dart';
import 'package:audio_metadata_parser/common/utils.dart';

class ID3v2MetadataParser implements AudioMetadataParser {
  final Uint8List _bytes;

  late int reversion = 0;
  late int _length;

  ID3v2MetadataParser(this._bytes) {
    reversion = _bytes[3];

    _length = parseSynchsafe(_readBytes(4));
  }

  int offset = 6;

  Uint8List _readBytes(int length) {
    offset += length;
    return _bytes.sublist(offset - length, offset);
  }

  /*int _readByte() {
    offset += 1;
    return _bytes[offset - 1];
  }*/

  @override
  AudioMetadata parse() {
    AudioMetadata result = AudioMetadata();
    while (offset < _length) {
      var frame = _getFrame();

      switch (frame.id) {
        // Album name
        case "TALB":
        case "TAL":
          result.album = frame.parseAsTextFrame();
          break;

        // Track name
        case "TIT2":
        case "TT2":
          result.title = frame.parseAsTextFrame();
          break;

        // Artist
        case "TPE1":
        case "TP1":
          var frameText = frame.parseAsTextFrame();
          result.artist = frameText.split("/");
          break;

        // Album artist
        case "TPE2":
        case "TP2":
          result.albumArtist = frame.parseAsTextFrame();
          break;

        // Year
        case "TYER":
        case "TYR":
          result.year = int.tryParse(
            frame.parseAsTextFrame().replaceAll(RegExp(r"[^0-9/]"), ""),
          );
          break;

        // Track number
        case "TRCK":
        case "TRK":
          List<String> strings = frame
              .parseAsTextFrame()
              .replaceAll(RegExp(r"[^0-9/]"), "")
              .split("/");

          result.trackNumber = int.tryParse(strings[0]);
          result.albumTrackCount =
              strings.length > 1 ? int.tryParse(strings[1]) : null;

          break;

        // Genre
        case "TCON":
        case "TCO":
          result.genre = frame.parseAsTextFrame();
          break;

        // Cover image
        case "APIC":
        case "PIC":
          var parsedPic = frame.parseAsAttachedPicture(reversion);

          if (parsedPic.pictureType == 0x03) {
            result.frontCoverImage = parsedPic;
          }

          if (parsedPic.pictureType == 0x06) {
            result.frontCoverImage = parsedPic;
          }

          break;

        // Comments
        case "COMM":
        case "COM":
          //print(frame.bytes);
          int encoding = frame.readByte();

          // skip language settings
          frame.offset += 3;

          // skip short description
          frame.parseTextInFrameUntill0x00(encoding);

          // read and parse main comment
          result.comment =
              parseID3v2TextData(encoding, frame.bytes.sublist(frame.offset));

          break;

        // Lyrics
        case "USLT":
          int encoding = frame.readByte();

          // skip language
          frame.readBytes(3);

          // skip description
          frame.parseTextInFrameUntill0x00(encoding);

          // read and parse main lyrics
          result.lyrics =
              parseID3v2TextData(encoding, frame.bytes.sublist(frame.offset));

          break;
      }
    }

    return result;
  }

  ID3v2Frame _getFrame() {
    int frameLength = 0;
    //int compressedLength = 0;

    // parse frameID
    String frameID = String.fromCharCodes(_readBytes(reversion < 3 ? 3 : 4));

    //parse length
    frameLength = reversion >= 4
        ? parseSynchsafe(_readBytes(4))
        : parseIntFromBytes(_readBytes(reversion <= 2 ? 3 : 4));

    // skip flags
    offset += 2;

    Uint8List content = _readBytes(frameLength);

    return ID3v2Frame(frameID, content);
  }

  @override
  Future<AudioMetadata> parseAsync() => Future(() => parse());
}
