class ItemMedia {
  final int id;
  final String fileUrl;
  final String? thumbnailUrl;
  final String fileType;

  ItemMedia({
    required this.id,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileType,
  });

  factory ItemMedia.fromJson(Map<String, dynamic> json) {
    return ItemMedia(
      id: json['id'],
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      fileType: json['file_type'],
    );
  }
}