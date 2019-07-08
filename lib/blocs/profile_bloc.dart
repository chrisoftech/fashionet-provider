import 'package:fashionet_provider/conts/const.dart';
import 'package:fashionet_provider/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileBloc with ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileBloc.instance() : _profileRepository = ProfileRepository();

  Future<bool> get hasProfile async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(HAS_PROFILE) != null && prefs.getBool(HAS_PROFILE)
        ? true
        : false;
  }

  Future<void> persistProfileWizardProgress({@required int wizardIndex}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PROFILE_WIZARD_INDEX, wizardIndex);
  }
}
