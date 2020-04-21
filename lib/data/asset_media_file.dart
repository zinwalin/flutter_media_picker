class AssetMediaFile {
  /// Unique identifier for the file
  String id;

  /// Date added in seconds (unix timestamp)
  int dateAdded;

  /// Original file path
  String path;

  /// Thumbnails from android (NOT iOS) need to have their orientation fixed
  /// based on the returned [orientation]
  /// usage: RotatedBox(
  ///                  quarterTurns: Platform.isIOS
  ///                      ? 0
  ///                      : orientationToQuarterTurns(mediaFile.orientation),
  ///                  child: Image.file(
  ///                    File(mediaFile.thumbnailPath),
  ///                    fit: BoxFit.cover,
  ///                    )
  /// Note: If thumbnail returned is null you will have to call [MediaPickerBuilder.getThumbnail]
  String thumbnailPath;

  /// Orientation in degrees (i.e. 0, 90, 180, 270)
  int orientation;

  int height;
  int width;

  /// Video duration in seconds
  int duration;

  /// Supported on Android only
  String mimeType;
  MediaType type;

  AssetMediaFile(
      {this.id,
      this.dateAdded,
      this.path,
      this.thumbnailPath,
      this.orientation,
      this.type});

  AssetMediaFile.fromJson(Map<dynamic, dynamic> json)
      :
        // id = json['id'],
        // dateAdded = json['dateAdded'],
        path = json['path'],
        // thumbnailPath = json['thumbnailPath'],
        // orientation = json['orientation'],
        duration = json['duration']?.round() ?? 0,
        // mimeType = json['mimeType'],
        type = MediaType.values[json['type'] == 'image' ? 0 : 1]
        // width = json['width'],
        // height = json['height']
        ;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetMediaFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum MediaType { IMAGE, VIDEO }
