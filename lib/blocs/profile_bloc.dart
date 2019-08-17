import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

enum ProfileState { Default, Loading, Success, Failure }

class ProfileBloc with ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ImageRepository _imageRepository;
  final AuthBloc _authBloc;
  final PostRepository _postRepository;

  Asset _profileImage;
  Profile _postProfile;
  Profile _userProfile;
  List<Profile> _profileSubscriptions;
  static List<Post> _latestProfileSubscriptionPosts;

  ProfileState _profileState = ProfileState.Default;
  ProfileState _profileSubscriptionState = ProfileState.Default;
  ProfileState _userProfileState = ProfileState.Default;
  ProfileState _postProfileState = ProfileState.Default;

  ProfileBloc.instance()
      : _profileRepository = ProfileRepository(),
        _imageRepository = ImageRepository(),
        _authBloc = AuthBloc.instance(),
        _postRepository = PostRepository() {
    fetchUserProfile();
    fetchUserProfileSubscriptions();
  }

  // getters
  Future<bool> get hasProfile async {
    final String _userId = await _authBloc.getUser;
    final DocumentSnapshot _snapshot =
        await _profileRepository.hasProfile(userId: _userId);

    final bool _hasProfile =
        _snapshot.exists ? _snapshot.data['hasProfile'] : false;

    return _hasProfile == null || !_hasProfile ? false : true;
  }

  Asset get profileImage => _profileImage;
  Profile get postProfile => _postProfile;
  Profile get userProfile => _userProfile;
  List<Profile> get profileSubscriptions => _profileSubscriptions;
  static List<Post> get latestProfileSubscriptionPosts =>
      _latestProfileSubscriptionPosts != null
          ? _latestProfileSubscriptionPosts
          : []; // returns empty list if _latestFollowingProfilePost is null

  ProfileState get profileState => _profileState;
  ProfileState get profileSubscriptionState => _profileSubscriptionState;
  ProfileState get userProfileState => _userProfileState;
  ProfileState get postProfileState => _postProfileState;

  // setters
  void setProfileImage({@required Asset profileImage}) {
    _profileImage = profileImage;
    notifyListeners();
  }

  void setProfile({@required Profile postProfile}) {
    _postProfile = postProfile;
    notifyListeners();
  }

  void setUserProfile({@required Profile userProfile}) {
    _userProfile = userProfile;
    notifyListeners();
  }

  static void setLatestSubscribedProfilePost(
      {@required List<Post> followingProfilePosts}) {
    _latestProfileSubscriptionPosts = followingProfilePosts;
  }

  Future<void> togglePostBookmarkStatus(
      {@required Post post, @required String userId}) async {
    final bool _bookmarkStatus = post.isBookmarked;
    final bool _newBookmarkStatus = !_bookmarkStatus;

    final String _postId = post.postId;

    try {
      if (_newBookmarkStatus) {
        await _profileRepository.addToBookmark(postId: _postId, userId: userId);
      } else {
        await _profileRepository.removeFromBookmark(
            postId: _postId, userId: userId);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> toggleFollowProfilePageStatus(
      {@required Profile profile}) async {
    // final String _profileId = profile.userId;
    final String _userId = await _authBloc.getUser;

    final String _postUserId = profile.userId;

    final bool _followingStatus = profile.isFollowing;
    final bool _newFollowingStatus = !_followingStatus;

    try {
      if (_newFollowingStatus) {
        await _profileRepository.subscribeTo(
            postUserId: _postUserId, userId: _userId);
      } else {
        await _profileRepository.unsubscribeFrom(
            postUserId: _postUserId, userId: _userId);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Post> _getPost(
      {@required DocumentSnapshot document,
      @required Profile postUserProfile}) async {
    final String _currentUserId = await _authBloc.getUser; // get current-user

    DocumentSnapshot _document = document;

    final String _postId = _document.documentID;
    final String _userId = _document.data['userId'];

    final Profile _profile = postUserProfile;

    final _post = Post(
      userId: _userId,
      postId: _postId,
      title: _document.data['title'],
      description: _document.data['description'],
      price: _document.data['price'],
      isAvailable: _document.data['isAvailable'],
      imageUrls: _document.data['imageUrls'],
      categories: _document.data['category'],
      created: _document.data['created'],
      lastUpdate: _document.data['lastUpdate'],
      profile: _profile,
    );

    // get post bookmark status for current user
    final bool _isBookmarked = await _postRepository.isBookmarked(
        postId: _postId, userId: _currentUserId);

    // get post user following status for current user
    final bool _isFollowing = await _profileRepository.isSubscribedTo(
        postUserId: _userId, userId: _currentUserId);

    // get post bookmark count
    QuerySnapshot _snapshot =
        await _postRepository.fetchPostBookmarks(postId: _postId);
    final int _postBookmarkCount = _snapshot.documents.length;

    return _post.copyWith(
        isBookmarked: _isBookmarked,
        bookmarkCount: _postBookmarkCount,
        profile: _profile.copyWith(isFollowing: _isFollowing));
  }

  Future<Profile> _fetchSubscribedProfile(
      {@required String postUserId, @required String currentUserId}) async {
    DocumentSnapshot _snapshot =
        await _profileRepository.fetchProfile(userId: postUserId);

    final Profile _postProfile = Profile(
      userId: _snapshot.documentID,
      firstName: _snapshot.data['firstName'],
      lastName: _snapshot.data['lastName'],
      businessName: _snapshot.data['businessName'],
      businessDescription: _snapshot.data['businessDescription'],
      phoneNumber: _snapshot.data['phoneNumber'],
      otherPhoneNumber: _snapshot.data['otherPhoneNumber'],
      businessLocation: _snapshot.data['businessLocation'],
      profileImageUrl: _snapshot.data['profileImageUrl'],
      hasProfile: _snapshot.data['hasProfile'],
      created: _snapshot.data['created'],
      lastUpdate: _snapshot.data['lastUpdate'],
    );

    // get post user following status for current user
    final bool _isFollowing = await _profileRepository.isSubscribedTo(
        postUserId: postUserId, userId: currentUserId);

    // get follower count
    final QuerySnapshot snapshot =
        await _profileRepository.fetchProfileSubscribers(userId: postUserId);
    final int _profileSubscribersCount = snapshot.documents.length;

    return _postProfile.copyWith(
        followersCount: _profileSubscribersCount, isFollowing: _isFollowing);
  }

  Future<Post> _fetchSubscribedLatestPosts(
      {@required String postUserId, @required Profile postUserProfile}) async {
    QuerySnapshot _snapshot =
        await _postRepository.fetchSubscribedLatestPosts(userId: postUserId);

    final List<Post> _latesPosts = [];

    for (int i = 0; i < _snapshot.documents.length; i++) {
      final DocumentSnapshot document = _snapshot.documents[i];
      final Post _post =
          await _getPost(document: document, postUserProfile: postUserProfile);

      _latesPosts.add(_post);
    }

    // return the first-post of this subscription profile
    return _latesPosts[0];
  }

  Future<void> fetchUserProfileSubscriptions() async {
    try {
      _profileSubscriptionState = ProfileState.Loading;
      notifyListeners();

      final String _userId = await _authBloc.getUser;

      final QuerySnapshot _snapshot =
          await _profileRepository.fetchProfileSubscriptions(userId: _userId);

      final List<Profile> profile = [];
      final List<Post> profileLatestPost = [];

      print(
          'UserProfileFollowing Snapshot lenght ${_snapshot.documents.length}');

      for (int i = 0; i < _snapshot.documents.length; i++) {
        final DocumentSnapshot document = _snapshot.documents[i];
        final String _profileId = document.documentID;
        final Profile _profile = await _fetchSubscribedProfile(
            postUserId: _profileId, currentUserId: _userId);

        final Post _profileLatestPost = await _fetchSubscribedLatestPosts(
            postUserId: _profileId, postUserProfile: _profile);

        profile.add(_profile);
        profileLatestPost.add(_profileLatestPost);
      }

      _profileSubscriptions = profile; // get profile of subscriptions
      _latestProfileSubscriptionPosts =
          profileLatestPost; // get profile-post first-post of subscriptions
      _profileSubscriptionState = ProfileState.Success;
      notifyListeners();

      return;
    } catch (e) {
      print(e.toString());

      _profileSubscriptionState = ProfileState.Failure;
      notifyListeners();
      return;
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      // _userProfileState = ProfileState.Loading;
      // notifyListeners();

      final String _userId = await _authBloc.getUser;
      DocumentSnapshot _snapshot =
          await _profileRepository.fetchProfile(userId: _userId);

      if (!_snapshot.exists) {
        print('UserId do not exit');
        return;
      }

      final Profile _userProfile = Profile(
        userId: _snapshot.documentID,
        firstName: _snapshot.data['firstName'],
        lastName: _snapshot.data['lastName'],
        businessName: _snapshot.data['businessName'],
        businessDescription: _snapshot.data['businessDescription'],
        phoneNumber: _snapshot.data['phoneNumber'],
        otherPhoneNumber: _snapshot.data['otherPhoneNumber'],
        businessLocation: _snapshot.data['businessLocation'],
        profileImageUrl: _snapshot.data['profileImageUrl'],
        hasProfile: _snapshot.data['hasProfile'],
        created: _snapshot.data['created'],
        lastUpdate: _snapshot.data['lastUpdate'],
      );

      final QuerySnapshot snapshot =
          await _profileRepository.fetchProfileSubscribers(userId: _userId);
      final int _userProfileFollowersCount = snapshot.documents.length;

      setUserProfile(
          userProfile: _userProfile.copyWith(
              followersCount: _userProfileFollowersCount));
      // _userProfileState = ProfileState.Success;
      // notifyListeners();
      return;
    } catch (e) {
      print(e.toString());

      // _userProfileState = ProfileState.Failure;
      // notifyListeners();
      return;
    }
  }

  Future<bool> fetchProfile({@required String userId}) async {
    try {
      _postProfileState = ProfileState.Loading;
      notifyListeners();

      DocumentSnapshot _snapshot =
          await _profileRepository.fetchProfile(userId: userId);

      if (!_snapshot.exists) {
        print('UserId do not exit');
        return true;
      }

      final Profile _postProfile = Profile(
        userId: _snapshot.documentID,
        firstName: _snapshot.data['firstName'],
        lastName: _snapshot.data['lastName'],
        businessName: _snapshot.data['businessName'],
        businessDescription: _snapshot.data['businessDescription'],
        phoneNumber: _snapshot.data['phoneNumber'],
        otherPhoneNumber: _snapshot.data['otherPhoneNumber'],
        businessLocation: _snapshot.data['businessLocation'],
        profileImageUrl: _snapshot.data['profileImageUrl'],
        hasProfile: _snapshot.data['hasProfile'],
        created: _snapshot.data['created'],
        lastUpdate: _snapshot.data['lastUpdate'],
      );

      // get follower count
      final QuerySnapshot snapshot =
          await _profileRepository.fetchProfileSubscribers(userId: userId);
      final int _profileSubscribersCount = snapshot.documents.length;

      setProfile(
          postProfile:
              _postProfile.copyWith(followersCount: _profileSubscribersCount));

      _postProfileState = ProfileState.Success;
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());

      _postProfileState = ProfileState.Failure;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createProfile(
      {@required String firstName,
      @required String lastName,
      @required String businessName,
      @required String businessDescription,
      @required String phoneNumber,
      String otherPhoneNumber,
      @required String businessLocation}) async {
    try {
      _profileState = ProfileState.Loading;
      notifyListeners();

      final String _userId = await _authBloc.getUser;

      final String _profileImageUrl = await _imageRepository.saveProfileImage(
          userId: _userId, asset: profileImage);

      await _profileRepository.createProfile(
        userId: _userId,
        firstName: firstName,
        lastName: lastName,
        businessName: businessName,
        businessDescription: businessDescription,
        phoneNumber: phoneNumber,
        otherPhoneNumber: otherPhoneNumber,
        businessLocation: businessLocation,
        profileImageUrl: _profileImageUrl,
      );

      _profileState = ProfileState.Success;
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());

      _profileState = ProfileState.Failure;
      notifyListeners();
      return false;
    }
  }
}
