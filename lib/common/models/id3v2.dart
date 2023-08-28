import 'dart:convert';
import 'dart:typed_data';

import 'package:audio_metadata_parser/common/models/block.dart';
import 'package:audio_metadata_parser/common/models/image_metadata.dart';
import 'package:audio_metadata_parser/common/utils.dart';

class ID3v2Frame extends Block {
  String id;

  ID3v2Frame(this.id, super.bytes);

  @override
  String toString() {
    return "Frame{id: $id, bytes: $bytes}";
  }
}

extension ID3v2FrameExtension on ID3v2Frame {
  String parseTextInFrameUntill0x00(int encoding) {
    List<int> resultBytes = [];
    if (encoding == 1 || encoding == 2) {
      // UTF16 text encoding
      while (true) {
        var bytes = readBytes(2);
        if (bytes[0] == 0 && bytes[1] == 0) break;
        resultBytes.addAll(bytes);
      }
    } else {
      // other text encodings
      while (true) {
        var byte = readByte();
        if (byte == 0) break;
        resultBytes.add(byte);
      }
    }
    return parseID3v2TextData(encoding, Uint8List.fromList(resultBytes));
  }

  AttachedPicture parseAsAttachedPicture(int reversion){
    late int pictureType;

    int encoding = readByte();

    String mime = "";
    // parse picture MIME
    // id3v2.2 and lower
    if (reversion <= 2) {
      var type = String.fromCharCodes(readBytes(3)).toLowerCase();
      mime = type == "jpg" ? "image/jpeg" : "image/$type";
    }
    // id3v2.3 and higher
    else {
      var type = "";
      while (atOffset() != 0) {
        type += String.fromCharCode(readByte());
      }

      mime = type;
      offset += 1;
    }

    // parse picture type
    pictureType = readByte();

    // parse description bytes to string
    String description = parseTextInFrameUntill0x00(encoding);

    // get image byte datas
    Uint8List bytes = this.bytes.sublist(offset);

    return AttachedPicture(
      pictureType: pictureType,
      mimeType: mime,
      description: description,
      bytes: bytes,
    );
  }

  String parseAsTextFrame() {
    return parseID3v2TextData(bytes[0], bytes.sublist(1));
  }
}

String parseID3v2TextData(int textEncoding, Uint8List bytes) {
  switch (textEncoding) {
    case 0:
      return latin1.decode(bytes);
    case 1:
      return parseUTF16StringWithBOM(bytes);
    case 2:
      return parseUTF16StringWithBOM([0xFE, 0xFF, ...bytes]);
    case 3:
      return utf8.decode(bytes);
  }

  // returns a empty string defaultly, if not parsed done
  return "";
}
