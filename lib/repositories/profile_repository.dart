import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionet_provider/conts/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final Firestore _firestore;

  ProfileRepository() : _firestore = Firestore.instance;

  
}