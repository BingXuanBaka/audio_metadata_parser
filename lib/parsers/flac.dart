import 'dart:convert';
import 'dart:typed_data';

import 'package:audio_metadata_parser/audio_metadata_parser.dart';
import 'package:audio_metadata_parser/common/models/image_metadata.dart';
import 'package:audio_metadata_parser/common/models/audio_metadata.dart';
import 'package:audio_metadata_parser/common/models/flac.dart';
import 'package:audio_metadata_parser/common/utils.dart';

class FLACMetadataParser implements AudioMetadataParser {
  final Uint8List _bytes;

  FLACMetadataParser(this._bytes);

  int offset = 4;

  Uint8List _readBytes(int length) {
    offset += length;

    return _bytes.sublist(offset - length, offset);
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
          var comments = metadataBlock.parseToVorbisCommentBlockList();
          for (var comment in comments) {
            switch (comment.blockType) {
              case "TITLE":
                result.title = comment.content;
                break;

              case "ALBUM":
                result.album = comment.content;
                break;

              case "ARTIST":
                result.artist == null
                    ? result.artist = [comment.content]
                    : result.artist!.add(comment.content);
                break;

              case "ALBUMARTIST":
                result.albumArtist = comment.content;
                break;

              case "TRACKNUMBER":
                result.trackNumber = int.tryParse(comment.content);
                break;

              case "TOTALTRACKS":
              case "TRACKTOTAL":
                result.albumTrackCount = int.tryParse(comment.content);
                break;

              case "GENRE":
                result.genre = comment.content;
                break;

              case "YEAR":
                result.year = int.tryParse(comment.content);
                break;

              case "LYRICS":
                result.lyrics = comment.content;
                break;
            }
          }

        // PICTURE
        case 6:
          int type = metadataBlock.readBytesAsInt(4);

          // parse mimetype
          int mimeStringLength = metadataBlock.readBytesAsInt(4);
          String mimeString =
              ascii.decode(metadataBlock.readBytes(mimeStringLength));

          // parse description
          int descriptionLength = metadataBlock.readBytesAsInt(4);
          String description =
              utf8.decode(metadataBlock.readBytes(descriptionLength));

          // skip width height color depth and indexed-color pictures's colors
          metadataBlock.offset += 4 * 4;

          int bytesLength = metadataBlock.readBytesAsInt(4);
          Uint8List bytes = metadataBlock.readBytes(bytesLength);

          var parsedPicture = AttachedPicture(
            pictureType: type,
            description: description,
            mimeType: mimeString,
            bytes: bytes,
          );

          if (type == 3 || type == 6) {
            result.frontCoverImage = parsedPicture;
          }

          break;
      }

      // break when current Metadata block is the last
      if (metadataBlock.isLast) break;
    }

    return result;
  }

  FLACMetadataBlock _getMetadataBlock() {
    int frameLength = 0;

    // parse this block is last and blockType
    bool isLast = (_bytes[offset] & 0x80) >> 7 == 1;
    int blockType = _bytes[offset] & 0x7F;
    offset += 1;

    //parse length
    frameLength = parseIntFromBytes(_readBytes(3));

    Uint8List content = _readBytes(frameLength);

    return FLACMetadataBlock(blockType, isLast, content);
  }

  @override
  Future<AudioMetadata> parseAsync() => Future(() => parse());
}
