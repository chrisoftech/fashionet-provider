import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class ProfileRepository {
  final Firestore _firestore;
  final CollectionReference _profileCollection;

  ProfileRepository()
      : _firestore = Firestore.instance,
        _profileCollection = Firestore.instance.collection('profile');

  Future<void> saveProfileImageUrl(
      {@required String userId, @required String profileImageUrl}) async {
    return await _profileCollection.document(userId).setData({
      'profileImageUrl': profileImageUrl,
    }, merge: true);
  }

  Future<void> saveProfileFullname(
      {@required String userId, @required String fullname}) {
    return _profileCollection.document(userId).setData({
      'fullname': fullname,
    }, merge: true);
  }
}
