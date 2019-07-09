import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileBioForm extends StatefulWidget {
  const ProfileBioForm({Key key}) : super(key: key);

  @override
  _ProfileBioFormState createState() => _ProfileBioFormState();
}

class _ProfileBioFormState extends State<ProfileBioForm> {
  ProfileBloc _profileBloc;

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

  Widget _buildBioFormCard() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      height: 200.0,
      child: Card(
        child: Container(
          padding: EdgeInsets.only(top: 55.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  'Complete Bio Information',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                SizedBox(height: 20.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.black87, fontSize: 20.0),
                        decoration: InputDecoration(
                          hintText: 'Enter Fullname',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: (String value) =>
                            _profileBloc.setProfileFullname(fullname: value),
                      ),
                    ),
                    _profileBloc.profileState == ProfileState.Loading
                        ? Container(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Container(),
                    SizedBox(width: 20.0),
                  ],
                ),
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
        _buildBioFormCard(),
        _buildTitleImage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final ProfileBloc _profileBloc = Provider.of<ProfileBloc>(context);
    _profileBloc = Provider.of<ProfileBloc>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        child: Center(
          child: Container(
            height: 250.0,
            width: 400.0,
            child: _buildFormBodyStack(),
          ),
        ),
      ),
    );
  }
}
