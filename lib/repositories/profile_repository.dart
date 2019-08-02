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

  Future<DocumentSnapshot> fetchProfile({@required String userId}) {
    return _profileCollection.document(userId).get();
  }

  Future<bool> isBookmarked(
      {@required String postId, @required String userId}) async {
    final DocumentSnapshot snapshot = await _profileCollection
        .document(userId)
        .collection('bookmarks')
        .document(postId)
        .get();

    return snapshot.exists;
  }

  Future<void> addToBookmark(
      {@required String postId, @required String userId}) {
    return _profileCollection
        .document(userId)
        .collection('bookmarks')
        .document(postId)
        .setData({
      'isBookmarked': true,
      'lastUpdate': _firestoreTimestamp,
    });
  }

  Future<void> removeFromBookmark(
      {@required String postId, @required String userId}) {
    return _profileCollection
        .document(userId)
        .collection('bookmarks')
        .document(postId)
        .delete();
  }

  Future<bool> isFollowing(
      {@required String postUserId, @required String userId}) async {
    final DocumentSnapshot snapshot = await _profileCollection
        .document(userId)
        .collection('following')
        .document(postUserId)
        .get();

    return snapshot.exists;
  }

  Future<void> addToFollowing(
      {@required String postUserId, @required String userId}) {
    return _profileCollection
        .document(userId)
        .collection('following')
        .document(postUserId)
        .setData({'isFollowing': true});
  }

  Future<void> removeFromFollowing(
      {@required String postUserId, @required String userId}) {
    return _profileCollection
        .document(userId)
        .collection('following')
        .document(postUserId)
        .delete();
  }

   Future<bool> isFollower(
      {@required String postUserId, @required String userId}) async {
    final DocumentSnapshot snapshot = await _profileCollection
        .document(postUserId)
        .collection('followers')
        .document(userId)
        .get();

    return snapshot.exists;
  }

  Future<void> addToFollowers(
      {@required String postUserId, @required String userId}) {
    return _profileCollection
        .document(postUserId)
        .collection('followers')
        .document(userId)
        .setData({'isFollowing': true});
  }

  Future<void> removeFromFollowers(
      {@required String postUserId, @required String userId}) {
    return _profileCollection
        .document(postUserId)
        .collection('followers')
        .document(userId)
        .delete();
  }

  Future<QuerySnapshot> fetchBookmarkedPosts({@required String userId}) {
    return _profileCollection
        .document(userId)
        .collection('bookmarks')
        .orderBy('lastUpdate', descending: true)
        .getDocuments();
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
