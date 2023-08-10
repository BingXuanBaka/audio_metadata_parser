int parseSynchsafe(List<int> bytes) {
  return bytes.length >= 4
      ? ((bytes[0] & 0x7F) << 21) |
          ((bytes[1] & 0x7F) << 14) |
          ((bytes[2] & 0x7F) << 7) |
          (bytes[3] & 0x7F)
      : 0;
}

int parseIntFromBytes(List<int> bytes) {
  int result = 0;
  for (var i = 0; i < bytes.length; i++) {
    result = (result << 8) | bytes[i];
  }

  return result;
}

String parseUTF16StringWithBOM(List<int> data) {
  List<int> list = [];

  //BOM is UTF-16 LE
  if (data[0] << 8 | data[1] == 0xFFFE) {
    for (var i = 2; i < data.length; i += 2) {
      if (i + 1 < data.length) {
        // Merge two separate bytes into one single byte
        list.add(data[i] | data[i + 1] << 8);
      }
    }
  }

  //BOM is UTF-16 BE
  else {
    for (var i = 2; i < data.length; i += 2) {
      if (i + 1 < data.length) {
        // Merge two separate bytes into one single byte
        list.add(data[i] << 8 | data[i + 1]);
      }
    }
  }

  // Convert to string and return
  return String.fromCharCodes(list);
}
