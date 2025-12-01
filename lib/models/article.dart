import 'media_type.dart';

class Article {
  String id;
  String headline;
  String htmlBody;
  MediaType mediaType;
  String? coverMediaPath;
  String? editedImagePath;
  String? videoThumbnailPath;

  Article({
    required this.id,
    required this.headline,
    required this.htmlBody,
    required this.mediaType,
    this.coverMediaPath,
    this.editedImagePath,
    this.videoThumbnailPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headline': headline,
      'htmlBody': htmlBody,
      'mediaType': mediaType.toString(),
      'coverMediaPath': coverMediaPath,
      'editedImagePath': editedImagePath,
      'videoThumbnailPath': videoThumbnailPath,
    };
  }
}
