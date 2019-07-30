import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:meta/meta.dart';

class CategoryRepository {
  final FieldValue _firestoreTimestamp;
  final CollectionReference _categoryCollection;

  CategoryRepository()
      : _firestoreTimestamp = FieldValue.serverTimestamp(),
        _categoryCollection = Firestore.instance.collection('categories');

  Future<QuerySnapshot> fetchCategories({@required PostCategory lastVisiblePostCategory}) {
    return lastVisiblePostCategory == null
        ? _categoryCollection
            .orderBy('lastUpdate', descending: true)
            .limit(5)
            .getDocuments()
        : _categoryCollection
            .orderBy('lastUpdate', descending: true)
            .startAfter([lastVisiblePostCategory.lastUpdate])
            .limit(5)
            .getDocuments();
  }

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
