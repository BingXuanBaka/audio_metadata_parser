import 'dart:convert';

import 'package:audio_metadata_parser/common/models/block.dart';
import 'package:audio_metadata_parser/common/utils.dart';

class FLACMetadataBlock extends Block {
  int blockType;
  bool isLast;

  FLACMetadataBlock(this.blockType, this.isLast, super.bytes);

  String readString(int length) {
    return utf8.decode(readBytes(length));
  }

  String readStringWithLength({bool? readLengthAsLE}) {
    var length = readLengthAsLE == true
        ? readBytesAsLEInt(4)
        : parseIntFromBytes(readBytes(4));
    return utf8.decode(readBytes(length));
  }

  @override
  String toString() {
    return "_FLACMetadataBlock{blockType: $blockType, isLast: $isLast, bytes: $bytes}";
  }
}

extension FLACMetadataBlockListExtension on FLACMetadataBlock {
  List<VorbisCommentBlock> parseToVorbisCommentBlockList() {
    if (blockType != 4) throw Exception("Wrong block type.");
    List<VorbisCommentBlock> result = [];

    // skip vendor string
    readStringWithLength(readLengthAsLE: true);

    // parse user comment list length
    var listLength = readBytesAsLEInt(4);

    // parse all comments
    for (int i = 0; i < listLength; i++) {
      List<String> commentContent =
          readStringWithLength(readLengthAsLE: true).split("=");
      if (commentContent.length < 2) continue;
      result.add(VorbisCommentBlock(commentContent[0], commentContent[1]));
    }

    return result;
  }
}

class VorbisCommentBlock {
  late String blockType;
  String content;

  VorbisCommentBlock(String blockType, this.content) {
    this.blockType = blockType.toUpperCase();
  }

  @override
  String toString() {
    return "VorbisCommentBlock{blockType: $blockType, content: $content}";
  }
}
