import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class ProfileRepository {
  final Firestore _firestore;

  ProfileRepository() : _firestore = Firestore.instance;

  Future<void> saveProfileImageUrl(
      {@required String userId, @required String profileImageUrl}) async {
    return await _firestore.collection('profile').document(userId).setData({
      'profileImageUrl': profileImageUrl,
    }, merge: true);
  }
}
