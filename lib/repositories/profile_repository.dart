import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class ProfileRepository {
  // final Firestore _firestore;
  final CollectionReference _profileCollection;
  final FieldValue _firestoreTimestamp;

  ProfileRepository()
      : _profileCollection = Firestore.instance.collection('profiles'),
        _firestoreTimestamp = FieldValue.serverTimestamp();

  Future<DocumentSnapshot> hasProfile({@required String userId}) async {
    return _profileCollection.document(userId).get();
  }

  Future<void> createProfile(
      {@required String userId,
      @required String firstName,
      @required String lastName,
      @required String businessName,
      @required String businessDescription,
      @required String phoneNumber,
      String otherPhoneNumber,
      @required String businessLocation,
      @required String profileImageUrl}) {
    return _profileCollection.document(userId).setData({
      'firstName': firstName,
      'lastName': lastName,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'phoneNumber': phoneNumber,
      'otherPhoneNumber': otherPhoneNumber,
      'businessLocation': businessLocation,
      'profileImageUrl': profileImageUrl,
      'hasProfile': true,
      'created': _firestoreTimestamp,
      'lastUpdate': _firestoreTimestamp,
    }, merge: true);
  }
}
