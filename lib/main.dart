import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/modules/modules.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthBloc>.value(value: AuthBloc.instance()),
        ChangeNotifierProvider<ProfileBloc>.value(value: ProfileBloc.instance())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FashioNet',
        theme: ThemeData(
          fontFamily: 'QuickSand',
          primarySwatch: Colors.indigo,
          accentColor: Colors.orange,
        ),
        home: new DynamicInitialPage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomePage(),
        },
      ),
    );
  }
}

class DynamicInitialPage extends StatefulWidget {
  
  @override
  _DynamicInitialPageState createState() => _DynamicInitialPageState();
}

class _DynamicInitialPageState extends State<DynamicInitialPage> {
  bool _hasProfile;

  Future<void> _getHasProfile({@required ProfileBloc profileBloc}) async {
    final bool hasProfile = await profileBloc.hasProfile;
    setState(() {
      _hasProfile = hasProfile;
    });
  }

  Widget _displayedAuthenticatedPage({@required ProfileBloc profileBloc}) {
    return _hasProfile
        ? HomePage()
        // : ProfileFormPage();
        : ProfileForm();
  }

  @override
  Widget build(BuildContext context) {
    // final AuthBloc _authBloc = Provider.of<AuthBloc>(context);
    final ProfileBloc _profileBloc = Provider.of<ProfileBloc>(context);

    return Consumer<AuthBloc>(
      builder: (BuildContext context, AuthBloc authBloc, Widget child) {
        switch (authBloc.authState) {
          case AuthState.Uninitialized:
            return SplashPage();
          case AuthState.Authenticating:
          case AuthState.Authenticated:
            _getHasProfile(profileBloc: _profileBloc);

            return _hasProfile != null
                ? _displayedAuthenticatedPage(profileBloc: _profileBloc)
                : Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(child: CircularProgressIndicator()));

          case AuthState.Unauthenticated:
            return AuthPage();
          // return IntroPage();
        }
      },
    );
  }
}
