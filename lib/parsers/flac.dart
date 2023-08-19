import 'dart:convert';

import '../audio_metadata_parser.dart';
import '../common/utils.dart';

class FLACMetaDataParser implements AudioMetadataParser {
  List<int> bytes;
  int offset = 0;
  int length = 0;

  List<int>? _readBytes(int length) {
    if (bytes.length >= length + offset) {
      var result = bytes.sublist(offset, offset + length);
      offset += length;
      return result;
    }
    return null;
  }

  FLACMetaDataParser(this.bytes) {
    offset = 4;
  }

  @override
  AudioMetadata parse() {
    AudioMetadata result = AudioMetadata();

    while (true) {
      var metadataBlock = _getMetadataBlock();
      if (metadataBlock.blockType == 127) break;

      switch (metadataBlock.blockType) {
        // VORBIS_COMMENT
        case 4:
          var offset = 0;

          // skip vendor string
          var vendorLength = parseIntFromBytes(
              metadataBlock.bytes.sublist(0, 4).reversed.toList());
          offset = 4 + vendorLength;

          // parse user comment list length
          var listLength = parseIntFromBytes(metadataBlock.bytes
              .sublist(offset, offset + 4)
              .reversed
              .toList());
          offset += 4;

          // parse all comments
          for (int i = 0; i < listLength; i++) {
            var commentLength = parseIntFromBytes(metadataBlock.bytes
                .sublist(offset, offset + 4)
                .reversed
                .toList());
            offset += 4;

            List<String> commentContent = utf8
                .decode(
                    metadataBlock.bytes.sublist(offset, offset + commentLength))
                .split("=");
            offset += commentLength;

            if (commentContent.length < 2) continue;
            switch (commentContent[0].toUpperCase()) {
              case "TITLE":
                result.title = commentContent[1];
                break;

              case "ALBUM":
                result.album = commentContent[1];
                break;

              case "ARTIST":
                result.artist == null
                    ? result.artist = [commentContent[1]]
                    : result.artist!.add(commentContent[1]);
                break;

              case "ALBUMARTIST":
                result.albumArtist = commentContent[1];
                break;

              case "TRACKNUMBER":
                result.trackNumber = int.tryParse(commentContent[1]);
                break;

              case "TOTALTRACKS":
              case "TRACKTOTAL":
                result.albumTrackCount = int.tryParse(commentContent[1]);
                break;

              case "GENRE":
                result.genre = commentContent[1];
                break;

              case "YEAR":
                result.year = int.tryParse(commentContent[1]);
                break;
            }
          }
          break;

        // PICTURE
        case 6:
          int offset = 0;

          int type = parseIntFromBytes(
              metadataBlock.bytes.sublist(offset, offset + 4));
          offset += 4;

          int mimeStringLength = parseIntFromBytes(
              metadataBlock.bytes.sublist(offset, offset + 4));
          offset += 4;
          String mimeString = ascii.decode(
              metadataBlock.bytes.sublist(offset, offset + mimeStringLength));
          offset += mimeStringLength;

          int descriptionLength = parseIntFromBytes(
              metadataBlock.bytes.sublist(offset, offset + 4));
          offset += 4;
          String description = utf8.decode(
              metadataBlock.bytes.sublist(offset, offset + descriptionLength));
          offset += descriptionLength;

          // skip width height color depth and indexed-color pictures's colors
          offset += 4 * 4;

          int pictureDataLength = parseIntFromBytes(
              metadataBlock.bytes.sublist(offset, offset + 4));
          offset += 4;

          List<int> pictureData =
              metadataBlock.bytes.sublist(offset, offset + pictureDataLength);

          var parsedPicture = _AttachedPicture(
            type,
            ImageMetadata(
              description: description,
              imageMIMEType: mimeString,
              imageByteData: pictureData,
            ),
          );

          if (type == 3 || type == 6) {
            result.frontCoverImage = parsedPicture.image;
          }

          break;
      }

      if (metadataBlock.isLast) break;
    }

    return result;
  }

  FLACMetadataBlock _getMetadataBlock() {
    int frameLength = 0;

    // parse this block is last and blockType
    bool isLast = (bytes[offset] & 0x80) >> 7 == 1;
    int blockType = bytes[offset] & 0x7F;
    offset += 1;

    //parse length
    frameLength = parseIntFromBytes(_readBytes(3) ?? []);

    List<int> content = _readBytes(frameLength) ?? [];

    return FLACMetadataBlock(blockType, isLast, content);
  }
}

class FLACMetadataBlock {
  int blockType;
  bool isLast;
  List<int> bytes;
  FLACMetadataBlock(this.blockType, this.isLast, this.bytes);

  @override
  String toString() {
    return "FLACMetadataBlock{blockType: $blockType, isLast: $isLast, bytes: $bytes}";
  }
}

// parsed data of APIC frame
class _AttachedPicture {
  _AttachedPicture(this.pictureType, this.image);

  int? pictureType;
  ImageMetadata? image;
}
