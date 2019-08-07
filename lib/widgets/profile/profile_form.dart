import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _otherPhoneNumberController = TextEditingController();
  final _businessLocationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AuthBloc _authBloc;
  ProfileBloc _profileBloc;

  List<Asset> _images = List<Asset>();
  String _error = 'No Error Dectected';

  Future<void> _loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    // clear existing selected profile image
    // profileBloc.setProfileImage(profileImage: null);

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 1,
          enableCamera: true,
          selectedAssets: _images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#abcdef",
            actionBarTitle: "FashioNet",
            allViewTitle: "All Photos",
            selectCircleStrokeColor: "#000000",
          ));
    } on PlatformException catch (e) {
      error = e.message;
      print(e.message);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _images = resultList;
      if (_images.isNotEmpty)
        _profileBloc.setProfileImage(profileImage: _images[0]);
      _error = error;
    });
  }

  Widget _buildImagePlaceHolder() {
    return Container(
      height: 110.0,
      width: 110.0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 110.0,
            width: 110.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black12,
              border: Border.all(width: 1.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/avatars/avatar.png'),
              ),
            ),
            child: _images.isEmpty
                ? Container()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(55.0),
                    child: AssetThumb(
                      asset: _images[0],
                      width: 300,
                      height: 300,
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Material(
              elevation: 10.0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                onTap: !_isContinueFABEnabled ? null : () => _loadAssets(),
                splashColor: Colors.black38,
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(
                    Icons.camera_alt,
                    size: 30.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageUploadForm() {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        children: <Widget>[
          _buildImagePlaceHolder(),
          SizedBox(width: 20.0),
          Text(
            'Add Profile Pix',
            style: TextStyle(
                color: Colors.black87,
                letterSpacing: -.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
      {@required String sectionTitle, String sectionDetails}) {
    return Column(
      children: <Widget>[
        // addDivider ? Divider(color: Colors.black54, height: 0.0) : Container(),
        Material(
          elevation: 5.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              '$sectionTitle',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 10.0),
        sectionDetails == null
            ? Container()
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 10.0),
                  Text('$sectionDetails'),
                ],
              ),
      ],
    );
  }

  Widget _buildFirstNameTextFormField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: InputDecoration(
        labelText: 'First Name',
        hintText: 'Enter First Name',
        filled: true,
      ),
      validator: (String value) {
        return value.isEmpty ? 'Please enter your firstname!' : null;
      },
    );
  }

  Widget _buildLastNameTextFormField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: InputDecoration(
        labelText: 'Last Name',
        hintText: 'Enter Last Name',
        filled: true,
      ),
      validator: (String value) {
        return value.isEmpty ? 'Please enter your lastname!' : null;
      },
    );
  }

  Widget _buildBusinessNameTextFormField() {
    return TextFormField(
      controller: _businessNameController,
      decoration: InputDecoration(
        labelText: 'Business Name',
        hintText: 'Enter Business Name',
        filled: true,
      ),
      validator: (String value) {
        return value.isEmpty ? 'Please enter your business name!' : null;
      },
    );
  }

  Widget _buildBusinessDescriptionTextFormField() {
    return TextFormField(
      controller: _businessDescriptionController,
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
          labelText: 'Business Description',
          hintText: 'Enter Business Description',
          filled: true),
      validator: (String value) {
        return value.isEmpty ? 'Please enter your business description!' : null;
      },
    );
  }

  Widget _buildPhoneNumberTextFormField() {
    return TextFormField(
      enabled: false,
      controller: _phoneNumberController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter Phone Number',
        filled: true,
      ),
      validator: (String value) {
        return value.isEmpty ? 'Please enter your mobile number!' : null;
      },
    );
  }

  Widget _buildOtherPhoneNumberTextFormField() {
    return TextFormField(
      controller: _otherPhoneNumberController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Other Phone Number',
        hintText: 'Enter Other Phone Number',
        filled: true,
      ),
    );
  }

  Widget _buildLocationTextFormField() {
    return TextFormField(
      controller: _businessLocationController,
      decoration: InputDecoration(
        labelText: 'Business Location',
        hintText: 'Enter Business Location / Address',
        prefixIcon: Icon(Icons.location_on),
        filled: true,
      ),
      validator: (String value) {
        return value.isEmpty ? 'Please enter your business location!' : null;
      },
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildSectionLabel(
              sectionTitle: 'Bio Section',
              sectionDetails: 'Enter your name(s)?'),
          _buildFirstNameTextFormField(),
          _buildLastNameTextFormField(),
          _buildSectionLabel(
              sectionTitle: 'Business Section',
              sectionDetails: 'Tell us about your business'),
          _buildBusinessNameTextFormField(),
          _buildBusinessDescriptionTextFormField(),
          _buildSectionLabel(
              sectionTitle: 'Contact(s) Section',
              sectionDetails: 'How can you be contacted?'),
          _buildPhoneNumberTextFormField(),
          _buildOtherPhoneNumberTextFormField(),
          _buildSectionLabel(
              sectionTitle: 'Location/Address Section',
              sectionDetails: 'Where can your clients locate you?'),
          _buildLocationTextFormField(),
        ],
      ),
    );
  }

  bool get _isContinueFABEnabled {
    return _profileBloc.profileState == ProfileState.Loading ? false : true;
  }

  _showMessageSnackBar(
      {@required String content,
      @required IconData icon,
      @required bool isError}) {
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState
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
  }

  void _hideKeyPad() {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState..hideCurrentSnackBar();
  }

  Future<void> _onContinueFABClicked() async {
    _hideKeyPad();

    if (_images.isEmpty) {
      _showMessageSnackBar(
          content: 'Please select a profile image to continue!',
          icon: Icons.error_outline,
          isError: true);
      return;
    }

    if (!_formKey.currentState.validate()) return;

    final bool _isProfileCreated = await _profileBloc.createProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      businessName: _businessNameController.text,
      businessDescription: _businessDescriptionController.text,
      phoneNumber: _phoneNumberController.text,
      otherPhoneNumber: _otherPhoneNumberController.text,
      businessLocation: _businessLocationController.text,
    );

    if (_isProfileCreated) {
      _showMessageSnackBar(
          content: 'Profile is created sucessfully',
          icon: Icons.check,
          isError: false);

      _profileBloc.fetchUserProfile(); // fetch user profile
    } else {
      _showMessageSnackBar(
          content: 'Sorry! Something went wrong! Try again',
          icon: Icons.error_outline,
          isError: true);
    }
  }

  Widget _buildCustomSaveProfileFAB() {
    final double _buttonWidth =
        _profileBloc.profileState == ProfileState.Loading ? 50.0 : 150.0;

    return Material(
      elevation: 10.0,
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(25.0),
      child: InkWell(
        onTap: !_isContinueFABEnabled ? null : () => _onContinueFABClicked(),
        splashColor: Colors.black38,
        borderRadius: BorderRadius.circular(25.0),
        child: AnimatedContainer(
          height: 50.0,
          width: _buttonWidth,
          duration: Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: _profileBloc.profileState == ProfileState.Loading
              ? CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Flexible(
                      child: Icon(
                        Icons.arrow_right,
                        size: 30.0,
                        color: Colors.white,
                      ),
                    ),
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

    _profileBloc = Provider.of<ProfileBloc>(context);
    _authBloc = Provider.of<AuthBloc>(context);

    _authBloc.getUserPhoneNumber.then((String authPhoneNumber) {
      setState(() => _phoneNumberController.text = authPhoneNumber);
    });

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _buildCustomSaveProfileFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: GestureDetector(
        onTap: () => _hideKeyPad(),
        child: SafeArea(
          child: Container(
            height: _deviceHeight,
            width: _deviceWidth,
            padding: EdgeInsets.only(bottom: 70.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Complete Profile',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Et nulla officia cupidatat nostrud ipsum. Ea minim ad sunt quis deserunt et ullamco.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              color: Colors.black38,
                              fontWeight: FontWeight.bold),
                        ),
                        _buildImageUploadForm(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  _buildProfileForm(),
                  // SizedBox(height: 80.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
