class AudioMetadata {
  AudioMetadata({
    required this.rowMetadataBlocks,
    this.title,
    this.artist,
    this.album,
    this.comment,
    this.year,
    this.genre,
    this.trackNumber,
    this.albumTrackCount,
    this.frontCoverImage,
  });

  List<MetadataBlock> rowMetadataBlocks;
  String? title;
  String? artist;
  String? album;
  String? albumArtist;
  String? comment;
  int? year;
  String? genre;
  int? trackNumber;
  int? albumTrackCount;
  ImageMetadata? frontCoverImage;

  @override
  String toString() {
    return "Metadata{title: $title, artist: $artist, album: $album, albumArtist: $albumArtist, "
        "comment: $comment, year: $year, genre: $genre, trackNumber: $trackNumber, "
        "albumTrackCount: $albumTrackCount, frontCoverImage: $frontCoverImage}";
  }
}

class MetadataBlock {
  MetadataBlock(this.id, this.bytes);
  String id;
  List<int> bytes;

  @override
  String toString() {
    return "Frame{id: $id, bytes: $bytes}";
  }
}

class ImageMetadata {
  ImageMetadata({
    this.description,
    this.imageMIMEType,
    this.imageByteData,
  });

  String? description;
  String? imageMIMEType;
  List<int>? imageByteData;

  @override
  String toString() {
    return "ImageMetadata{description: $description, MIME: $imageMIMEType}";
  }
}

class CodecMetadata {
  CodecMetadata({this.encodedBy});
  final String? encodedBy;
}
