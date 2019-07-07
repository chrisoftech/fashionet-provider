import 'package:fashionet_provider/modules/modules.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _navigateToAuthPage;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _navigateToAuthPage() {
    HapticFeedback.vibrate();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AuthPage(),
      ),
    );
  }

  Widget _buildStackBackgroundImage(
      {@required double deviceHeight, @required double deviceWidth}) {
    return Positioned(
      height: deviceHeight,
      width: deviceWidth,
      child: Image.asset(
        'assets/images/temp7.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildStackBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black12,
            Colors.black87,
          ],
        ),
      ),
    );
  }

  Widget _builTopFlexibleContent() {
    return Flexible(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'FASHIONet',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 45.0,
                  fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 30.0),
            Text(
              'Connecting the world of fashion in your smart-phone',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomFlexibleContent() {
    return Flexible(
      child: Container(
        child: Column(
          children: <Widget>[
            Spacer(),
            Text(
              'Continue With',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Material(
                    elevation: 5.0,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30.0),
                      onTap: _navigateToAuthPage,
                      child: Container(
                        height: 50.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 2.0, color: Colors.white70),
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Row(
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
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            RichText(
              text: TextSpan(
                text: 'Don\'t have an account yet? ',
                children: [
                  TextSpan(
                    text: 'SIGN UP',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: _tapGestureRecognizer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackBodyContent(
      {@required double deviceHeight, @required double deviceWidth}) {
    return Positioned(
      height: deviceHeight,
      width: deviceWidth,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          children: <Widget>[
            Flexible(child: Container()),
            _builTopFlexibleContent(),
            _buildBottomFlexibleContent(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Stack(
          children: <Widget>[
            _buildStackBackgroundImage(
                deviceHeight: _deviceHeight, deviceWidth: _deviceWidth),
            _buildStackBackgroundGradient(),
            _buildStackBodyContent(
                deviceHeight: _deviceHeight, deviceWidth: _deviceWidth),
          ],
        ),
      ),
    );
  }
}
