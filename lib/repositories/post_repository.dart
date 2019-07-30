import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class PostRepository {
  // final Firestore _firestore;
  final FieldValue _firestoreTimestamp;
  final CollectionReference _postCollection;

  PostRepository()
      : _firestoreTimestamp = FieldValue.serverTimestamp(),
        _postCollection = Firestore.instance.collection('posts');

  Future<DocumentReference> createPost(
      {@required List<String> imageUrls,
      @required String userId,
      @required String title,
      @required String description,
      @required double price,
      @required bool isAvailable,
      @required List<String> categories}) {
    return _postCollection.add({
      'imageUrls': imageUrls,
      'userId': userId,
      'title': title,
      'description': description,
      'price': price,
      'isAvailable': isAvailable,
      'category': categories,
      'created': _firestoreTimestamp,
      'lastUpdate': _firestoreTimestamp,
    });
  }
}
