import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/modules/modules.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthBloc>.value(value: AuthBloc.instance())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FashioNet',
        theme: ThemeData(
          fontFamily: 'QuickSand',
          primarySwatch: Colors.indigo,
          accentColor: Colors.orange,
        ),
        home: Consumer<AuthBloc>(
          builder: (BuildContext context, AuthBloc authBloc, Widget child) {
            switch (authBloc.authState) {
              case AuthState.Uninitialized:
                return SplashPage();
              case AuthState.Authenticating:
              case AuthState.Authenticated:
                print('Authenticatedddddddd');
                return HomePage();
              case AuthState.Unauthenticated:
                return IntroPage();
            }
          },
        ),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomePage(),
        },
      ),
    );
  }
}
