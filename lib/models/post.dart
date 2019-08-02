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
  final bool isBookmarked;

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
    this.isBookmarked = false,
  });

  Post copyWith({
    String userId,
    String postId,
    String title,
    String description,
    String price,
    String isAvailable,
    List<dynamic> imageUrls,
    List<String> categories,
    dynamic created,
    dynamic lastUpdate,
    Profile profile,
    bool isBookmarked = false,
  }) {
    return Post(
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrls: imageUrls ?? this.imageUrls,
      categories: categories ?? this.categories,
      created: created ?? this.created,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      profile: profile ?? this.profile,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
