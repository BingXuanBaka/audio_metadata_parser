import 'dart:typed_data';

import 'package:audio_metadata_parser/common/utils.dart';

class Block {
  Uint8List bytes;

  Block(this.bytes);

  int offset = 0;

  Uint8List readBytes(int length) {
    offset += length;
    return bytes.sublist(offset - length, offset);
  }

  int readByte() {
    offset += 1;
    return bytes[offset - 1];
  }

  int atOffset() {
    return bytes[offset];
  }

  int readBytesAsInt(int length) {
    return parseIntFromBytes(readBytes(length));
  }

  int readBytesAsLEInt(int length) {
    return parseIntFromBytes(readBytes(length).reversed.toList());
  }

  @override
  String toString() {
    return "Block{bytes: $bytes}";
  }
}
