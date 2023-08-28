class ImageMetadata {
  ImageMetadata({
    this.description,
    this.mimeType,
    this.bytes,
  });

  String? description;
  String? mimeType;
  List<int>? bytes;

  @override
  String toString() {
    return "ImageMetadata{description: $description, mimeType: $mimeType, "
      "bytes: ${bytes == null ? null : "<length: ${bytes?.length}>"}}";

  }
}

/// Used in id3v2 and flac
class AttachedPicture extends ImageMetadata {
  AttachedPicture({
    this.pictureType,
    super.description,
    super.mimeType,
    super.bytes,
  });

  int? pictureType;
}
