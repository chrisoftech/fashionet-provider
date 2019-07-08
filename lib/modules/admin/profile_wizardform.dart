import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileWizardForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthBloc _authBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Profile Wizard!'),
            RaisedButton(
              child: Text('Logout'),
              onPressed: () => _authBloc.signout(),
            )
          ],
        ),
      ),
    );
  }
}
