import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class CategoryRepository {
  final FieldValue _firestoreTimestamp;
  final CollectionReference _categoryCollection;

  CategoryRepository()
      : _firestoreTimestamp = FieldValue.serverTimestamp(),
        _categoryCollection = Firestore.instance.collection('categories');

  Future<DocumentReference> createCategory(
      {@required String imageUrl,
      @required String userId,
      @required String title,
      @required String description}) {
    return _categoryCollection.add({
      'imageUrl': imageUrl,
      'userId': userId,
      'title': title,
      'description': description,
      'created': _firestoreTimestamp,
      'lastUpdate': _firestoreTimestamp,
    });
  }
}
