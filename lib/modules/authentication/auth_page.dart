import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  Widget _buildAuthenticationPageBody(
      {@required double deviceHeight,
      @required double deviceWidth,
      @required AuthBloc authBloc}) {
    return Container(
      height: deviceHeight,
      width: deviceWidth,
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30.0),
                authBloc.authLevel == AuthLevel.Verification
                    ? VerificationForm()
                    : LoginForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGradientBackground(
      {@required deviceHeight, @required deviceWidth}) {
    final double _gradientHeight = deviceHeight / 4;

    return Positioned(
      top: 0.0,
      height: _gradientHeight,
      width: deviceWidth,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.transparent,
              Colors.black54,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGradientBackground(
      {@required deviceHeight, @required deviceWidth}) {
    final double _gradientHeight = deviceHeight / 4.5;

    return Positioned(
      bottom: 0.0,
      height: _gradientHeight,
      width: deviceWidth,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black87,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;

    final AuthBloc _authBloc = Provider.of<AuthBloc>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              _buildAuthenticationPageBody(
                  deviceHeight: _deviceHeight,
                  deviceWidth: _deviceWidth,
                  authBloc: _authBloc),
              _buildBottomGradientBackground(
                  deviceHeight: _deviceHeight, deviceWidth: _deviceWidth),
              _buildTopGradientBackground(
                  deviceHeight: _deviceHeight, deviceWidth: _deviceWidth),
            ],
          ),
        ),
      ),
    );
  }
}
