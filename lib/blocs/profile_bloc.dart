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

  ProfileState _profileState = ProfileState.Default;

  ProfileBloc.instance()
      : _profileRepository = ProfileRepository(),
        _imageRepository = ImageRepository(),
        _authBloc = AuthBloc.instance();

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

  ProfileState get profileState => _profileState;

  // setters
  void setProfileImage({@required Asset profileImage}) {
    _profileImage = profileImage;
    notifyListeners();
  }

  Future<Profile> fetchProfile({@required String userId}) async {
    DocumentSnapshot _snapshot =
        await _profileRepository.fetchProfile(userId: userId);

    if (!_snapshot.exists) {
      print('UserId do not exit');
    }

    return Profile(
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

      // await Future.delayed(Duration(seconds: 5));

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
