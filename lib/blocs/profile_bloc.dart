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

  Asset _profileImage;
  Profile _postProfile;
  Profile _userProfile;
  List<Profile> _profileFollowing;

  ProfileState _profileState = ProfileState.Default;
  ProfileState _profileFollowingState = ProfileState.Default;
  ProfileState _userProfileState = ProfileState.Default;
  ProfileState _postProfileState = ProfileState.Default;

  ProfileBloc.instance()
      : _profileRepository = ProfileRepository(),
        _imageRepository = ImageRepository(),
        _authBloc = AuthBloc.instance() {
    fetchUserProfile();
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
  List<Profile> get profileFollowing => _profileFollowing;

  ProfileState get profileState => _profileState;
  ProfileState get profileFollowingState => _profileFollowingState;
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

  Future<void> togglePostBookmarkStatus(
      {@required Post post, @required String userId}) async {
    final bool _bookmarkStatus = post.isBookmarked;
    final bool _newBookmarkStatus = !_bookmarkStatus;

    final String _postId = post.postId;

    try {
      if (_newBookmarkStatus) {
        await _profileRepository.addToBookmark(postId: _postId, userId: userId);
        print('Bookmarked user');
      } else {
        await _profileRepository.removeFromBookmark(
            postId: _postId, userId: userId);
        print('Not Bookmarked user');
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

    // final Profile _updatedProfile =
    //     profile.copyWith(isFollowing: _newFollowingStatus);

    // if (_newFollowingStatus) {
    //   _profileFollowing.insert(0, _updatedProfile);
    // } else {
    //   _profileFollowing
    //       .removeWhere((Profile following) => following.userId == _profileId);
    // }
    // notifyListeners();

    try {
      if (_newFollowingStatus) {
        await _profileRepository.addToFollowing(
            postUserId: _postUserId, userId: _userId);
        print('Following user');
      } else {
        await _profileRepository.removeFromFollowing(
            postUserId: _postUserId, userId: _userId);
        print('Not Following user');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Profile> _fetchFollowingProfile(
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
    final bool _isFollowing = await _profileRepository.isFollowing(
        postUserId: postUserId, userId: currentUserId);

    // get follower count
    final QuerySnapshot snapshot =
        await _profileRepository.getProfileFollowers(userId: postUserId);
    final int _profileFollowersCount = snapshot.documents.length;

    return _postProfile.copyWith(
        followersCount: _profileFollowersCount, isFollowing: _isFollowing);
  }

  Future<void> fetchUserProfileFollowing() async {
    try {
      _profileFollowingState = ProfileState.Loading;
      notifyListeners();

      final String _userId = await _authBloc.getUser;

      final QuerySnapshot _snapshot =
          await _profileRepository.getProfileFollowing(userId: _userId);

      final List<Profile> profile = [];

      print('Snapshot lenght ${_snapshot.documents.length}');

      for (int i = 0; i < _snapshot.documents.length; i++) {
        final DocumentSnapshot document = _snapshot.documents[i];
        final String _profileId = document.documentID;
        final Profile _profile = await _fetchFollowingProfile(
            postUserId: _profileId, currentUserId: _userId);

        profile.add(_profile);
      }

      _profileFollowing = profile;
      _profileFollowingState = ProfileState.Success;
      notifyListeners();

      return;
    } catch (e) {
      print(e.toString());

      _profileFollowingState = ProfileState.Failure;
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
          await _profileRepository.getProfileFollowers(userId: _userId);
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
          await _profileRepository.getProfileFollowers(userId: userId);
      final int _profileFollowersCount = snapshot.documents.length;

      setProfile(
          postProfile:
              _postProfile.copyWith(followersCount: _profileFollowersCount));

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
