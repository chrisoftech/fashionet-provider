import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileContactForm extends StatefulWidget {
  @override
  _ProfileContactFormState createState() => _ProfileContactFormState();
}

class _ProfileContactFormState extends State<ProfileContactForm> {
  ProfileBloc _profileBloc;
  TextEditingController _authPhoneNumberController = TextEditingController();

  Widget _buildTitleImage() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 100.0,
        width: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,
          border: Border.all(width: 2.0, color: Theme.of(context).primaryColor),
          image: DecorationImage(
              image: AssetImage('assets/images/temp7.jpg'), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildFormCardTitle() {
    return Column(
      children: <Widget>[
        Text(
          'A Little More,',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.0),
        Row(
          children: <Widget>[
            SizedBox(width: 10.0),
            Text(
              'Please complete your contact information!',
              style: TextStyle(),
            ),
          ],
        ),
        Divider(
          color: Colors.grey,
        ),
        SizedBox(height: 15.0),
      ],
    );
  }

  Widget _buildTextFieldSuffix() {
    if (_profileBloc.profileState == ProfileState.Loading) {
      return Container(
          height: 20.0,
          width: 20.0,
          child: CircularProgressIndicator(strokeWidth: 2));
    } else if (_profileBloc.profileState == ProfileState.Success) {
      return Container(
          height: 20.0,
          width: 20.0,
          child: Icon(Icons.check, color: Colors.green));
    } else if (_profileBloc.profileState == ProfileState.Failure) {
      return Container(
          height: 20.0,
          width: 20.0,
          child: Icon(Icons.error_outline, color: Colors.red));
    } else {
      return Container();
    }
  }

  Widget _buildContactFormFields() {
    return Column(
      children: <Widget>[
        TextField(
          enabled: false,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.black87, fontSize: 20.0),
          controller: _authPhoneNumberController,
          decoration: InputDecoration(
            hintText: 'Enter Mobile Number',
            prefixIcon: Icon(Icons.phone_android),
          ),
          // onChanged: (String value) {
          //   print('Mobile Number $value');
          //   _profileBloc.profileContacts['mobileNumber'] = value;
          // },
        ),
        SizedBox(height: 20.0),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Colors.black87, fontSize: 20.0),
                decoration: InputDecoration(
                  hintText: 'Enter Other Number (Optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
                onChanged: (String value) {
                  _profileBloc.profileContacts['otherNumber'] = value;
                },
              ),
            ),
            _buildTextFieldSuffix(),
            SizedBox(width: 20.0),
          ],
        ),
      ],
    );
  }

  Widget _buildContactFormCard() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      height: 300.0,
      child: Card(
        child: Container(
          padding: EdgeInsets.only(top: 55.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildFormCardTitle(),
                _buildContactFormFields()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormBodyStack() {
    return Stack(
      children: <Widget>[
        _buildContactFormCard(),
        _buildTitleImage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc _authBloc = Provider.of<AuthBloc>(context);

    _profileBloc = Provider.of<ProfileBloc>(context);
    _authBloc.getUserPhoneNumber.then((String authPhoneNumber) {
      setState(() {
        _authPhoneNumberController.text = authPhoneNumber;
        _profileBloc.profileContacts['mobileNumber'] =
            _authPhoneNumberController.text;
      });
    });

    return Container(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 350.0,
            width: 400.0,
            child: _buildFormBodyStack(),
          ),
        ),
      ),
    );
  }
}
