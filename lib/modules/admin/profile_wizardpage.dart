import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileWizardForm extends StatefulWidget {
  final ProfileBloc _profileBloc;

  const ProfileWizardForm({Key key, @required ProfileBloc profileBloc})
      : _profileBloc = profileBloc,
        super(key: key);

  @override
  _ProfileWizardFormState createState() => _ProfileWizardFormState();
}

class _ProfileWizardFormState extends State<ProfileWizardForm> {
  final _pageController = PageController(initialPage: 0, keepPage: true);
  PageView _pageView;

  int _currentWizardPageIndex = 0;
  BuildContext _context;

  ProfileBloc get _profileBloc => widget._profileBloc;

  @override
  void initState() {
    super.initState();
    _getManagePageRouteTransitions();
  }

  @override
  void dispose() {
    super.dispose();

    _pageController.dispose();
  }

  void _getManagePageRouteTransitions() {
    _profileBloc.profileFormWizardProgressIndex.then((int _wizardPageIndex) {
      setState(() {
        _pageController.jumpToPage(_wizardPageIndex);
      });
    });
  }

  bool _isContinueButonEnabled() {
    final bool _isLoading = _profileBloc.profileState == ProfileState.Loading;
    return _isLoading ? false : true;
  }

  void _jumpToPreviousPage({@required AuthBloc authBloc}) {
    if (_currentWizardPageIndex == 0) {
      authBloc.signout();
    } else {
      _pageController.jumpToPage(--_currentWizardPageIndex);
    }
  }

  Future _jumpToNextPage({@required AuthBloc authBloc}) async {
    if (_currentWizardPageIndex == 0) {
      await _uploadProfileImage();
    } else if (_currentWizardPageIndex == 1) {
      await _saveProfileFullname();
    } else if (_currentWizardPageIndex > 1) {
      authBloc.signout();
    } else if (_currentWizardPageIndex == 4) {
      Navigator.of(context).pushReplacementNamed('/home');
    }

    _getManagePageRouteTransitions();
  }

  Future<void> _uploadProfileImage() async {
    if (_profileBloc.profileImage == null) {
      _showErrorSnackBar(content: 'Please select an image to upload!');
      return;
    }

    final bool _isUploaded = await _profileBloc.uploadProfileImage();

    if (_isUploaded) {
      _showMessageSnackBar(
          content: 'Profile image upload sucessful',
          icon: Icons.check,
          isError: false);
    } else {
      _showMessageSnackBar(
          content: 'Sorry! Something went wrong! Try again',
          icon: Icons.error_outline,
          isError: true);
    }
  }

  Future<void> _saveProfileFullname() async {
    if (_profileBloc.profileFullname == null) {
      _showErrorSnackBar(content: 'Please enter your fullname to continue!');
      return;
    }

    final bool _isUploaded = await _profileBloc.saveProfileFullname();

    if (_isUploaded) {
      _showMessageSnackBar(
          content: 'Profile fullname saved sucessfully',
          icon: Icons.check,
          isError: false);
    } else {
      _showMessageSnackBar(
          content: 'Sorry! Something went wrong! Try again',
          icon: Icons.error_outline,
          isError: true);
    }
  }

  _showErrorSnackBar({@required String content}) {
    Scaffold.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: 4),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(content)),
              Icon(Icons.info_outline, color: Colors.red),
            ],
          ),
        ),
      );
  }

  _showMessageSnackBar(
      {@required String content,
      @required IconData icon,
      @required bool isError}) {
    Scaffold.of(_context)
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

  Widget _buildActiveWizardPage() {
    return Container(
      width: 9.0,
      height: 9.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(width: 2.0, color: Theme.of(context).accentColor),
      ),
    );
  }

  Widget _buildInactiveWizardPage() {
    return Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Color.fromRGBO(0, 0, 0, 0.4)));
  }

  Widget _buildFormWizardIndicator() {
    List<Widget> dots = [];

    for (int i = 0; i < 5; i++) {
      dots.add(i == _currentWizardPageIndex
          ? _buildActiveWizardPage()
          : _buildInactiveWizardPage());
    }

    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 20.0,
      height: 70.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dots,
      ),
    );
  }

  Widget _buildFormWizardActions({@required AuthBloc authBloc}) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      height: 80.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black54,
              ]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _currentWizardPageIndex > 0
                ? Container()
                : FlatButton(
                    splashColor: Colors.white30,
                    child: Text(
                      _currentWizardPageIndex == 0 ? 'Logout' : 'Previous',
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 20.0),
                    ),
                    onPressed: () => _jumpToPreviousPage(authBloc: authBloc),
                  ),
            FlatButton(
              splashColor: Colors.white30,
              child: Text(
                _currentWizardPageIndex == 4 ? 'Complete' : 'Continue',
                style: TextStyle(
                    color: Theme.of(context).accentColor, fontSize: 20.0),
              ),
              onPressed: !_isContinueButonEnabled()
                  ? null
                  : () => _jumpToNextPage(authBloc: authBloc),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc _authBloc = Provider.of<AuthBloc>(context);
    // final ProfileBloc _profileBloc = Provider.of<ProfileBloc>(context);

    _pageView = PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (int index) {
        setState(() {
          _currentWizardPageIndex = index;
        });
      },
      children: <Widget>[
        ProfileImageForm(),
        ProfileBioForm(),
        ProfileBioForm(),
        // ProfileBusinessForm(),
        // ProfileContactForm(),
        // ProfileLocationForm(),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Builder(
        builder: (BuildContext context) {
          _context = context;

          // _getProfileWizardProgressIndex(profileBloc: _profileBloc);

          return Stack(
            children: <Widget>[
              _pageView,
              _buildFormWizardIndicator(),
              _buildFormWizardActions(authBloc: _authBloc)
            ],
          );
        },
      ),
    );
  }
}
