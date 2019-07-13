import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileFormPage extends StatefulWidget {
  @override
  _ProfileFormPageState createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  Function _onContinueButtonClicked;

  Widget _buildCustomSaveProfileFAB(
      {@required BuildContext context, @required ProfileBloc profileBloc}) {
    return Material(
      elevation: 10.0,
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(25.0),
      child: InkWell(
        onTap: () => _onContinueButtonClicked(),
        splashColor: Colors.black38,
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          height: 50.0,
          width: 150.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: profileBloc.profileState == ProfileState.Loading
              ? CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Continue',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5.0),
                    Icon(
                      Icons.arrow_right,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProfileBloc _profileBloc = Provider.of<ProfileBloc>(context);

    return Scaffold(
      floatingActionButton: _buildCustomSaveProfileFAB(
          context: context, profileBloc: _profileBloc),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ProfileForm(),
    );
  }
}
