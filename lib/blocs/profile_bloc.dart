import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/consts/const.dart';
import 'package:fashionet_provider/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProfileState { Default, Loading, Success, Failure }

class ProfileBloc with ChangeNotifier {
  final ProfileRepository _profileRepository;
  final ImageRepository _imageRepository;
  final AuthBloc _authBloc;

  Asset _profileImage;
  String _profileFullname;
  Map<String, String> _profileBusiness = {
    'businessName': null,
    'businessDescription': null,
  };

  Map<String, String> _profileContacts = {
    'mobileNumber': null,
    'otherNumber': null,
  };

  ProfileState _profileState = ProfileState.Default;

  ProfileBloc.instance()
      : _profileRepository = ProfileRepository(),
        _imageRepository = ImageRepository(),
        _authBloc = AuthBloc.instance();

  // getters
  Future<bool> get hasProfile async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(HAS_PROFILE) != null && prefs.getBool(HAS_PROFILE)
        ? true
        : false;
  }

  Asset get profileImage => _profileImage;
  String get profileFullname => _profileFullname;
  Map<String, String> get profileBusiness => _profileBusiness;
  Map<String, String> get profileContacts => _profileContacts;

  ProfileState get profileState => _profileState;

  Future<int> get profileFormWizardProgressIndex async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PROFILE_WIZARD_INDEX) != null
        ? prefs.getInt(PROFILE_WIZARD_INDEX)
        : 0;
  }

  // setters
  void setProfileImage({@required Asset profileImage}) {
    _profileImage = profileImage;
    notifyListeners();
  }

  void setProfileFullname({@required String fullname}) {
    _profileFullname = fullname;
    notifyListeners();
  }

  void setProfileBusiness({@required Map<String, String> profileBusiness}) {
    _profileBusiness = profileBusiness;
    notifyListeners();
  }

  void setProfileContacts({@required Map<String, String> profileContacts}) {
    _profileContacts = profileContacts;
    notifyListeners();
  }

  Future<void> _persistProfileFormWizardProgress(
      {@required int nextWizardIndex}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PROFILE_WIZARD_INDEX, nextWizardIndex);
    return;
  }

  Future<bool> uploadProfileImage() async {
    try {
      _profileState = ProfileState.Loading;
      notifyListeners();

      // final String _userId = await _authBloc.getUser;

      // final String _profileImageUrl = await _imageRepository.saveProfileImage(
      //     userId: _userId, asset: profileImage);

      // await _profileRepository.saveProfileImageUrl(
      //     userId: _userId, profileImageUrl: _profileImageUrl);

      await Future.delayed(Duration(seconds: 5));

      // saves next profile-wizard-page-index for progress
      await _persistProfileFormWizardProgress(nextWizardIndex: 1);

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

  Future<bool> saveProfileFullname() async {
    try {
      _profileState = ProfileState.Loading;
      notifyListeners();

      // final String _userId = await _authBloc.getUser;
      // await _profileRepository.saveProfileFullname(
      //     userId: _userId, fullname: profileFullname);
      await Future.delayed(Duration(seconds: 5));

      // saves next profile-wizard-page-index for progress
      await _persistProfileFormWizardProgress(nextWizardIndex: 2);

      _profileState = ProfileState.Success;
      notifyListeners();
      return true;
    } catch (e) {
      _profileState = ProfileState.Failure;
      notifyListeners();

      return false;
    }
  }

  Future<bool> saveProfileBusiness() async {
    try {
      _profileState = ProfileState.Loading;
      notifyListeners();

      final String _userId = await _authBloc.getUser;
      _profileRepository.saveProfileBusiness(
          userId: _userId, profileBusiness: profileBusiness);

      // await Future.delayed(Duration(seconds: 3));

      // saves next profile-wizard-page-index for progress
      _persistProfileFormWizardProgress(nextWizardIndex: 3);

      _profileState = ProfileState.Success;
      notifyListeners();

      return true;
    } catch (e) {
      _profileState = ProfileState.Failure;
      notifyListeners();

      return false;
    }
  }

  Future<bool> saveProfileContacts() async {
    try {
      _profileState = ProfileState.Loading;
      notifyListeners();

      final String _userId = await _authBloc.getUser;
      _profileRepository.saveProfileContacts(
          userId: _userId, profileContacts: profileContacts);

      // await Future.delayed(Duration(seconds: 3));

      // saves next profile-wizard-page-index for progress
      _persistProfileFormWizardProgress(nextWizardIndex: 4);

      _profileState = ProfileState.Success;
      notifyListeners();

      return true;
    } catch (e) {
      _profileState = ProfileState.Failure;
      notifyListeners();

      return false;
    }
  }
}
