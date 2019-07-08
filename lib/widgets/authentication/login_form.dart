import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  bool _isVerifyCodeButtonEnabled({@required AuthBloc authBloc}) {
    final bool _isAuthenticating =
        authBloc.authState == AuthState.Authenticating ? true : false;
    return _isAuthenticating ? false : true;
  }

  void _onRequestANewCode({@required AuthBloc authBloc}) {
    authBloc.authLevel = AuthLevel.Verification;
  }

  Future<void> _onVerifyCodeButtonPressed({@required AuthBloc authBloc}) async {
    if (!_formKey.currentState.validate()) {
      _showErrorSnackBar();
      return;
    }

    final bool _isAuthenticated = await authBloc.logInWithPhoneNumber(
        verificationCode: _verificationCodeController.text);

    if (_isAuthenticated) {
      _showMessageSnackBar(
          content: 'Authentication sucessfull',
          icon: Icons.verified_user,
          isError: false);

      Navigator.of(context).pop();
    } else {
      _showMessageSnackBar(
          content: 'Sorry! Something went wrong!',
          icon: Icons.error_outline,
          isError: true);
    }
  }

  _showErrorSnackBar() {
    Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                      'Please enter verification code we sent to your phone number')),
              Icon(Icons.info_outline, color: Colors.red),
            ],
          ),
        ),
      );
  }

  _showMessageSnackBar(
      {@required String content,
      @required IconData icon,
      @required bool isError}) {
    Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('$content')),
              Icon(icon, color: isError ? Colors.red : Colors.green),
            ],
          ),
        ),
      );
  }

  Widget _buildLoginFormTitle({@required String phoneNumber}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'FASHIONet',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        RichText(
          text: TextSpan(
            text: 'Please enter the verification code we sent to your phone ',
            style: TextStyle(
              color: Colors.white70,
              // fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: '$phoneNumber ',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              TextSpan(
                text: 'to continue.',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loginFormSubTitle() {
    return Text(
      'Code Verification',
      style: TextStyle(
          color: Colors.white70, fontSize: 25.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLoginFormField() {
    return TextFormField(
      maxLength: 6,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      controller: _verificationCodeController,
      style: TextStyle(
          color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        counterText: '',
        border: InputBorder.none,
      ),
      validator: (String value) {
        return value.length < 6
            ? 'Please enter the verification code sent to your number!'
            : null;
      },
    );
  }

  Widget _buidRequestNewCodeControlButton({@required AuthBloc authBloc}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onRequestANewCode(authBloc: authBloc),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Text(
            'Request a new code',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyCodeControlButton({@required AuthBloc authBloc}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        onTap: !_isVerifyCodeButtonEnabled(authBloc: authBloc)
            ? null
            : () => _onVerifyCodeButtonPressed(authBloc: authBloc),
        child: Container(
          height: 50.0,
          width: 200.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.white70),
              borderRadius: BorderRadius.circular(30.0)),
          child: authBloc.authState == AuthState.Authenticating
              ? CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'VERIFY CODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      size: 30.0,
                      color: Colors.white,
                    )
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc _authBloc = Provider.of<AuthBloc>(context);
    final String _authPhoneNumber = _authBloc.authPhoneNumber;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildLoginFormTitle(phoneNumber: _authPhoneNumber),
          SizedBox(height: 30.0),
          _loginFormSubTitle(),
          SizedBox(height: 10.0),
          _buildLoginFormField(),
          SizedBox(height: 20.0),
          _buidRequestNewCodeControlButton(authBloc: _authBloc),
          SizedBox(height: 30.0),
          _buildVerifyCodeControlButton(authBloc: _authBloc),
        ],
      ),
    );
  }
}
