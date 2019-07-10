import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileBusinessForm extends StatefulWidget {
  @override
  _ProfileBusinessFormState createState() => _ProfileBusinessFormState();
}

class _ProfileBusinessFormState extends State<ProfileBusinessForm> {
  ProfileBloc _profileBloc;

  Widget _buildTitleImage() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 100.0,
        width: 100.0,
        // color: Colors.grey,
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
          'Christian,',
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
              'Please we will required your business information!',
              style: TextStyle(),
            ),
          ],
        ),
        Divider(color: Colors.grey),
        SizedBox(height: 10.0),
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

  Widget _buildBusinessFormFields() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                style: TextStyle(color: Colors.black87, fontSize: 20.0),
                decoration: InputDecoration(
                  hintText: 'Enter Business Name',
                  prefixIcon: Icon(Icons.store),
                ),
                onChanged: (String value) {
                  _profileBloc.profileBusiness['businessName'] = value;
                },
              ),
            ),
            _buildTextFieldSuffix(),
            SizedBox(width: 20.0),
          ],
        ),
        SizedBox(height: 20.0),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                keyboardType: TextInputType.multiline,
                style: TextStyle(color: Colors.black87, fontSize: 20.0),
                decoration: InputDecoration(
                  hintText: 'Enter Business Details',
                  prefixIcon: Icon(Icons.details),
                ),
                onChanged: (String value) {
                  _profileBloc.profileBusiness['businessDetails'] = value;
                },
              ),
            ),
            _buildTextFieldSuffix(),
            // _profileBloc.profileState == ProfileState.Loading
            //     ? Container(
            //         height: 20.0,
            //         width: 20.0,
            //         child: CircularProgressIndicator(strokeWidth: 2),
            //       )
            //     : Container(),
            SizedBox(width: 20.0),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessFormCard() {
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
                _buildBusinessFormFields(),
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
        _buildBusinessFormCard(),
        _buildTitleImage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _profileBloc = Provider.of<ProfileBloc>(context);

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
