import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:libphonenumber/libphonenumber.dart';

enum AuthState { Uninitialized, Authenticated, Authenticating, Unauthenticated }
enum VerificationState { Default, Loading, Failure, Success }

class AuthBloc with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  String _verificationId;

  FirebaseUser _firebaseUser;
  AuthState _authState = AuthState.Uninitialized;
  VerificationState _verificationState = VerificationState.Default;

  AuthBloc.instance() : _firebaseAuth = FirebaseAuth.instance {
    _firebaseAuth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  // getters
  AuthState get authState => _authState;

  VerificationState get verificationState => _verificationState;

  Future<bool> get isSignedIn async {
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    return currentUser != null ? true : false;
  }

  Future<String> get getUser async {
    return (await _firebaseAuth.currentUser()).uid;
  }

  // methods
  Future<void> verifyPhoneNumber(
      {@required String phoneNumber, @required String countryIsoCode}) async {
    try {
      _verificationState = VerificationState.Loading;
      notifyListeners();

      if (!await PhoneNumberUtil.isValidPhoneNumber(
          phoneNumber: phoneNumber, isoCode: countryIsoCode)) {
        throw Exception('Invalid phone number!');
      }

      final PhoneVerificationCompleted verificationCompleted =
          (AuthCredential phoneAuthCredential) {
        _firebaseAuth.signInWithCredential(phoneAuthCredential);

        print('Received phone auth credential: $phoneAuthCredential');
      };

      final PhoneVerificationFailed verificationFailed =
          (AuthException authException) {
        print(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      };

      final PhoneCodeSent codeSent =
          (String verificationId, [int forceResendingToken]) async {
        print('Please check your phone for the verification code.');

        _verificationId = verificationId;
        print('PhoneCodeSent $_verificationId');
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
          (String verificationId) {
        _verificationId = verificationId;
      };

      print(phoneNumber);

      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 0),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

      _verificationState = VerificationState.Success;
      notifyListeners();
    } catch (e) {
      _verificationState = VerificationState.Failure;
      notifyListeners();

      print(e.toString());
      throw (e.toString());
    }
  }

  Future<void> logInWithPhoneNumber({@required String verificationCode}) async {
    try {
      _authState = AuthState.Authenticating;
      notifyListeners();

      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: verificationCode,
      );

      final FirebaseUser user =
          await _firebaseAuth.signInWithCredential(credential);
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);

      user != null
          ? print('Successfully signed in, uid: ' + user.uid)
          : print('Sign in failed');

      _authState = AuthState.Authenticated;
      notifyListeners();
    } catch (e) {
      _authState = AuthState.Unauthenticated;
      notifyListeners();

      print(e.toString());
      throw (e.toString());
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
