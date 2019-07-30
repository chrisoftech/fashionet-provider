import 'package:fashionet_provider/models/models.dart';
import 'package:meta/meta.dart';

class Post {
  final String userId;
  final String postId;
  final String title;
  final String description;
  final double price;
  final bool isAvailable;
  final List<dynamic> imageUrls;
  final List<String> categories;
  final dynamic created;
  final dynamic lastUpdate;
  final Profile profile;

  Post({
    @required this.userId,
    @required this.postId,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.isAvailable,
    @required this.imageUrls,
    @required this.categories,
    @required this.created,
    @required this.lastUpdate,
    @required this.profile,
  });
}
