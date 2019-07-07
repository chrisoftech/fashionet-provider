import 'package:country_code_picker/country_code_picker.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerificationForm extends StatefulWidget {
  @override
  _VerificationFormFormState createState() => _VerificationFormFormState();
}

class _VerificationFormFormState extends State<VerificationForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();

  String _selectedCountryCode;
  String _countryIsoCode;

  @override
  void initState() {
    _selectedCountryCode = '+233';
    _countryIsoCode = 'GH';
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  bool _isLoginButtonEnabled({@required AuthBloc authBloc}) {
    final bool _isLoading =
        authBloc.verificationState == VerificationState.Loading ? true : false;
    return _isLoading ? false : true;
  }

  Future<void> _onLoginButtonTapped({@required AuthBloc authBloc}) async {
    if (_selectedCountryCode == null || _selectedCountryCode.isEmpty) {
      _showErrorSnackBar();
      return;
    }

    if (!_formKey.currentState.validate()) return;

    final String phoneNumberWithCode =
        '$_selectedCountryCode${_phoneNumberController.text}';

    final bool _isPhoneNumberVerified = await authBloc.verifyPhoneNumber(
        phoneNumber: phoneNumberWithCode, countryIsoCode: _countryIsoCode);

    if (_isPhoneNumberVerified) {
      _showMessageSnackBar(
          content: 'Verification code sent to $phoneNumberWithCode',
          icon: Icons.check,
          isError: false);
    } else {
      _showMessageSnackBar(
          content:
              'Sorry! We could not validate this phone number ($phoneNumberWithCode)',
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
              Expanded(child: Text('Please select a country code')),
              Icon(Icons.error_outline, color: Colors.red),
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

  Widget _buildLoginFormTitle() {
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
        Text(
          'Sign in to continue to app',
          style: TextStyle(
              color: Colors.white70,
              fontSize: 20.0,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildVerificationFormFields() {
    return Row(
      children: <Widget>[
        CountryCodePicker(
          onChanged: (CountryCode countryCode) {
            _countryIsoCode = countryCode.code;
            _selectedCountryCode = countryCode.toString();
          },
          initialSelection: '+233',
          favorite: ['+233'],
          showCountryOnly: false,
          textStyle: TextStyle(color: Colors.white, fontSize: 28.0),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _phoneNumberController,
            style: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.w500),
            decoration:
                InputDecoration(contentPadding: EdgeInsets.only(bottom: 5.0)),
            validator: (String value) {
              return value.isEmpty ? 'Enter a valid phone number!' : null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationControlButton({@required AuthBloc authBloc}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        onTap: !_isLoginButtonEnabled(authBloc: authBloc)
            ? null
            : () => _onLoginButtonTapped(authBloc: authBloc),
        child: Container(
          height: 50.0,
          width: 200.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.white70),
              borderRadius: BorderRadius.circular(30.0)),
          child: authBloc.verificationState == VerificationState.Loading
              ? CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'LOGIN',
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildLoginFormTitle(),
          SizedBox(height: 30.0),
          Text(
            'Please select your country code and enter your phone number (+xxx xxxx xxxx xxx)',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.0),
          _buildVerificationFormFields(),
          SizedBox(height: 30.0),
          _buildVerificationControlButton(authBloc: _authBloc),
        ],
      ),
    );
  }
}
