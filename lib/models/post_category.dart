import 'package:meta/meta.dart';

class PostCategory {
  final String userId;
  final String categoryId;
  final String title;
  final String description;
  final String imageUrl;
  final dynamic created;
  final dynamic lastUpdate;

  PostCategory({
    @required this.userId,
    @required this.categoryId,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.created,
    @required this.lastUpdate,
  });
}
