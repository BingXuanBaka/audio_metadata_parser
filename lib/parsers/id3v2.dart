import 'dart:convert';

import '../audio_metadata_parser.dart';
import '../common/utils.dart';

class ID3v2MetaDataParser implements AudioMetadataParser {
  late List<int> bytes;
  int offset = 0;
  int reversion = 0;
  int length = 0;

  List<int>? _readBytes(int length) {
    if (bytes.length >= length + offset) {
      var result = bytes.sublist(offset, offset + length);
      offset += length;
      return result;
    }
    return null;
  }

  ID3v2MetaDataParser(this.bytes) {
    reversion = bytes[3];

    offset = 6;
    length = parseSynchsafe(_readBytes(4) ?? []);
    print("total length: $length\r\n");
    offset = 10;
  }

  /// Parse metadata to [AudioMetadata]
  @override
  AudioMetadata parse() {
    List<MetadataBlock> rowMetadataBlocks = [];
    AudioMetadata result = AudioMetadata(rowMetadataBlocks: rowMetadataBlocks);
    try {
      while (offset < length) {
        var frame = _getFrame();
        rowMetadataBlocks.add(frame);
        //print(frame);

        switch (frame.id) {
          // Cover image
          case "APIC":
            var parsedPic = _parseAttachedPicture(frame.bytes);

            if (parsedPic.pictureType == 0x03) {
              result.frontCoverImage = parsedPic.image;
            }

            if (parsedPic.pictureType == 0x06) {
              result.frontCoverImage = parsedPic.image;
            }

            break;

          // Album name
          case "TALB":
            result.album = _parseTextData(
              frame.bytes[0],
              frame.bytes.sublist(1),
            );

            break;

          // Track name
          case "TIT2":
            result.title = _parseTextData(
              frame.bytes[0],
              frame.bytes.sublist(1),
            );

            break;

          // Comments
          case "COMM":
            int offset = 0;

            //print(frame.bytes);
            int encoding = frame.bytes[offset];
            offset += 1;

            // skip language settings
            offset += 3;

            // parse short description
            List<int> descriptionBytes = [];
            if (encoding == 1) {
              // UTF16 text encoding
              for (offset += 1;
                  frame.bytes[offset] != 0x00 || frame.bytes[offset - 1] != 0x00;
                  offset += 2) {
                descriptionBytes.addAll([frame.bytes[offset], frame.bytes[offset - 1]]);
              }
              offset += 1;
            } else {
              // other text encodings
              while (frame.bytes[offset] != 0) {
                descriptionBytes.add(frame.bytes[offset]);
                offset += 1;
              }
            }
            String description = _parseTextData(encoding, descriptionBytes);

            // read and parse main comment
            if (description == "") {
              result.comment =
                  _parseTextData(encoding, frame.bytes.sublist(offset));
            }

            break;

          // Artist
          case "TPE1":
            result.artist = _parseTextData(
              frame.bytes[0],
              frame.bytes.sublist(1),
            );

            break;

          // Album artist
          case "TPE2":
            result.albumArtist = _parseTextData(
              frame.bytes[0],
              frame.bytes.sublist(1),
            );

            break;

          // Year
          case "TYER":
            result.year = int.tryParse(
              _parseTextData(
                frame.bytes[0],
                frame.bytes.sublist(1),
              ).replaceAll(RegExp(r"[^0-9/]"), ""),
            );

            break;

          // Track number
          case "TRCK":
            List<String> strings = _parseTextData(
              frame.bytes[0],
              frame.bytes.sublist(1),
            ).replaceAll(RegExp(r"[^0-9/]"), "").split("/");

            result.trackNumber = int.tryParse(strings[0]);
            result.albumTrackCount =
                strings.length > 1 ? int.tryParse(strings[1]) : null;

            break;

          // Genre
          case "TCON":
            result.genre = _parseTextData(
              frame.bytes[0],
              frame.bytes.sublist(1),
            );

            break;
        }
      }
    } catch (e) {
      rethrow;
    }

    return result;
  }

  MetadataBlock _getFrame() {
    int frameLength = 0;
    //int compressedLength = 0;

    // parse frameID
    String frameID = String.fromCharCodes(_readBytes(4) ?? []);

    //parse length
    frameLength = parseIntFromBytes(_readBytes(4) ?? []);

    // parse flags
    //int flag1 = bytes[offset];
    int flag2 = bytes[offset + 1];
    offset += 2;

    // if compressed
    if ((flag2 & 0x40) >> 6 == 1) {
      //print("compressed");
      /*compressedLength = ((bytes[0] & 0x7F) << 24) |
      ((bytes[1] & 0xFF) << 16) |
      ((bytes[2] & 0xFF) << 8) |
      (bytes[3] & 0xFF);*/
    }

    List<int> content = _readBytes(frameLength) ?? [];

    return MetadataBlock(frameID, content);
  }

  String _parseTextData(int textEncoding, List<int> bytes) {
    switch (textEncoding) {
      case 0:
        return latin1.decode(bytes);
      case 1:
        return parseUTF16StringWithBOM(bytes);
    }

    // returns a empty string defaultly, if not parsed done
    return "";
  }

  // parse APIC frame
  _AttachedPicture _parseAttachedPicture(List<int> body) {
    int offset = 0;
    late int pictureType;
    ImageMetadata resultImage = ImageMetadata();

    int encoding = body[offset];
    offset += 1;

    var mimeType = "";
    // get MIMEType bytes until found 0x00
    while (body[offset] != 0) {
      mimeType += String.fromCharCode(body[offset]);
      offset += 1;
    }

    // parse picture MIME
    resultImage.imageMIMEType = mimeType;
    offset += 1;

    // parse picture type
    pictureType = body[offset];
    offset += 1;

    // get description bytes until found 0x00 (or [0x00, 0x00])
    List<int> descriptionBytes = [];
    if (encoding == 1) {
      // UTF16 text encoding
      for (offset += 1;
          body[offset] != 0x00 || body[offset - 1] != 0x00;
          offset += 2) {
        descriptionBytes.addAll([body[offset], body[offset - 1]]);
      }
      offset += 1;
    } else {
      // other text encodings
      while (body[offset] != 0) {
        descriptionBytes.add(body[offset]);
        offset += 1;
      }
      offset += 1;
    }

    // parse description bytes to string
    resultImage.description = _parseTextData(encoding, descriptionBytes);

    // get image byte datas
    resultImage.imageByteData = body.sublist(offset);

    return _AttachedPicture(pictureType, resultImage);
  }
}

// parsed data of APIC frame
class _AttachedPicture {
  _AttachedPicture(this.pictureType, this.image);

  int? pictureType;
  ImageMetadata? image;
}
