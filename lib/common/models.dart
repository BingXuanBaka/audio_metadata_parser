class AudioMetadata {
  AudioMetadata({
    this.title,
    this.artist,
    this.album,
    this.comment,
    this.year,
    this.genre,
    this.trackNumber,
    this.albumTrackCount,
    this.frontCoverImage,
    this.lyrics,
  });

  String? title;
  List<String>? artist;
  String? album;
  String? albumArtist;
  String? comment;
  int? year;
  String? genre;
  int? trackNumber;
  int? albumTrackCount;
  ImageMetadata? frontCoverImage;
  List<Lyric>? lyrics;

  @override
  String toString() {
    return "Metadata{title: $title, artist: $artist, album: $album, albumArtist: $albumArtist, "
        "comment: $comment, year: $year, genre: $genre, trackNumber: $trackNumber, "
        "albumTrackCount: $albumTrackCount, frontCoverImage: $frontCoverImage, lyrics: $lyrics}";
  }
}

class Lyric {
  Lyric(this.content, {
    this.language,
  });

  String? language;
  String? content;

  @override 
  String toString() {
    return "Lyric{language: $language, content: $content}";
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
