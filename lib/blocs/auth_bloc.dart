import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter/cupertino.dart';
import 'package:libphonenumber/libphonenumber.dart';

enum AuthState { Uninitialized, Authenticated, Authenticating, Unauthenticated }
enum VerificationState { Default, Loading, Failure, Success }
enum AuthLevel { Verification, Authentication }

class AuthBloc with ChangeNotifier {
  FirebaseAuth _firebaseAuth;

  String _verificationId;
  String _authPhoneNumber;

  FirebaseUser _firebaseUser;
  AuthState _authState = AuthState.Uninitialized;
  VerificationState _verificationState = VerificationState.Default;
  AuthLevel _authLevel = AuthLevel.Verification;

  AuthBloc.instance() : _firebaseAuth = FirebaseAuth.instance {
    _firebaseAuth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  // getters
  String get authPhoneNumber => _authPhoneNumber;
  AuthState get authState => _authState;
  VerificationState get verificationState => _verificationState;
  AuthLevel get authLevel => _authLevel;

  Future<bool> get isSignedIn async {
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    return currentUser != null ? true : false;
  }

  Future<String> get getUser async {
    return (await _firebaseAuth.currentUser()).uid;
  }

  // setters
  set authPhoneNumber(String authPhoneNumber) {
    _authPhoneNumber = authPhoneNumber;
    notifyListeners();
  }

  set authLevel(AuthLevel authLevel) {
    _authLevel = authLevel;
    notifyListeners();
  }

  // methods
  Future<bool> verifyPhoneNumber(
      {@required String phoneNumber, @required String countryIsoCode}) async {
    try {
      _verificationState = VerificationState.Loading;
      notifyListeners();

      // if (!await PhoneNumberUtil.isValidPhoneNumber(
      //     phoneNumber: phoneNumber, isoCode: countryIsoCode)) {
      //   throw Exception('Invalid phone number!');
      // }

      // final PhoneVerificationCompleted verificationCompleted =
      //     (AuthCredential phoneAuthCredential) {
      //   _firebaseAuth.signInWithCredential(phoneAuthCredential);

      //   print('Received phone auth credential: $phoneAuthCredential');
      // };

      // final PhoneVerificationFailed verificationFailed =
      //     (AuthException authException) {
      //   print(
      //       'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      // };

      // final PhoneCodeSent codeSent =
      //     (String verificationId, [int forceResendingToken]) async {
      //   print('Please check your phone for the verification code.');

      //   _verificationId = verificationId;
      //   print('PhoneCodeSent $_verificationId');
      // };

      // final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
      //     (String verificationId) {
      //   _verificationId = verificationId;
      // };

      // store phone number
      authPhoneNumber = phoneNumber;

      await Future.delayed(Duration(seconds: 5));

      // await _firebaseAuth.verifyPhoneNumber(
      //     phoneNumber: phoneNumber,
      //     timeout: const Duration(seconds: 0),
      //     verificationCompleted: verificationCompleted,
      //     verificationFailed: verificationFailed,
      //     codeSent: codeSent,
      //     codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

      _verificationState = VerificationState.Success;
      _authLevel = AuthLevel.Authentication;
      notifyListeners();
      return true;
    } catch (e) {
      _verificationState = VerificationState.Failure;
      _authLevel = AuthLevel.Verification;
      notifyListeners();

      print(e.toString());
      return false;
      // throw (e.toString());
    }
  }

  Future<bool> logInWithPhoneNumber({@required String verificationCode}) async {
    try {
      _authState = AuthState.Authenticating;
      notifyListeners();

      // final AuthCredential credential = PhoneAuthProvider.getCredential(
      //   verificationId: _verificationId,
      //   smsCode: verificationCode,
      // );

      // final FirebaseUser user =
      //     await _firebaseAuth.signInWithCredential(credential);
      // final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      // assert(user.uid == currentUser.uid);

      // user != null
      //     ? print('Successfully signed in, uid: ' + user.uid)
      //     : print('Sign in failed');

      await Future.delayed(Duration(seconds: 5));

      _authState = AuthState.Authenticated;
      notifyListeners();

      return true;
    } catch (e) {
      _authState = AuthState.Unauthenticated;
      notifyListeners();

      print(e.toString());
      return false;
      // throw (e.toString());
    }
  }

  Future<void> signout() async {
    await _firebaseAuth.signOut();

    _authState = AuthState.Unauthenticated;
    notifyListeners();
    return;
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _authState = AuthState.Unauthenticated;
    } else {
      _firebaseUser = firebaseUser;
      _authState = AuthState.Authenticated;
    }
    notifyListeners();
  }
}
