import 'package:meta/meta.dart';

class Profile {
  final String userId;
  final String firstName;
  final String lastName;
  final String businessName;
  final String businessDescription;
  final String businessLocation;
  final String phoneNumber;
  final String otherPhoneNumber;
  final String profileImageUrl;
  final bool hasProfile;
  final dynamic created;
  final dynamic lastUpdate;

  Profile({
    @required this.userId,
    @required this.firstName,
    @required this.lastName,
    @required this.businessName,
    @required this.businessDescription,
    @required this.businessLocation,
    @required this.phoneNumber,
    @required this.otherPhoneNumber,
    @required this.profileImageUrl,
    @required this.hasProfile,
    @required this.created,
    @required this.lastUpdate,
  });
}
