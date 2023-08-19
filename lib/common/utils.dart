int parseSynchsafe(List<int> bytes) {
  var result = 0;

  for (var i = 0; i < bytes.length; i++) {
    result = (result << 7) | (bytes[i] & 0x7F);
  }

  return result;
}

int parseIntFromBytes(List<int> bytes) {
  int result = 0;
  
  for (var i = 0; i < bytes.length; i++) {
    result = (result << 8) | (bytes[i] & 0xFF);
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
