import 'package:carousel_slider/carousel_slider.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PostForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const PostForm({Key key, @required this.scaffoldKey}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final ScrollController _scrollController = ScrollController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _availabilityController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> get _scaffoldKey => widget.scaffoldKey;

  PostBloc _postBloc;
  int _currentPostImageIndex = 0;

  final List<int> _selectedCategories = [];
  bool _isItemAvailable = false;

  List<Asset> _images = List<Asset>();
  String _error = 'No Error Dectected';

  Future<void> _loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    // clear existing selected profile image
    // profileBloc.setProfileImage(profileImage: null);

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 5,
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
      // if (_images.isNotEmpty)
      // _profileBloc.setProfileImage(profileImage: _images[0]);
      _error = error;
    });
  }

  Widget _buildActivePostImage() {
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

  Widget _buildInactivePostImage() {
    return Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Color.fromRGBO(0, 0, 0, 0.4)));
  }

  Widget _buildPostImageCarouselIndicator() {
    List<Widget> dots = [];

    for (int i = 0; i < _images.length; i++) {
      dots.add(i == _currentPostImageIndex
          ? _buildActivePostImage()
          : _buildInactivePostImage());
    }

    return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dots,
        ));
  }

  Widget _buildPostImageCarousel() {
    return CarouselSlider(
        height: 400.0,
        viewportFraction: _images.length > 1 ? 0.8 : 1.0,
        enableInfiniteScroll: false,
        // enlargeCenterPage: true,
        onPageChanged: (int index) {
          setState(() {
            _currentPostImageIndex = index;
          });
        },
        items: _images.map((Asset asset) {
          return Builder(
            builder: (BuildContext context) {
              // return Image.asset('assets/images/temp$postImageUrl.jpg',
              //     fit: BoxFit.cover);

              return AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              );

              //return CachedNetworkImage(
              //   fit: BoxFit.cover,
              //   imageUrl: 'assets/images/temp$postImageUrl',
              //   placeholder: (context, url) =>
              //       Center(child: new CircularProgressIndicator()),
              //   errorWidget: (context, url, error) =>
              //       Center(child: new Icon(Icons.error)),
              // );
            },
          );
        }).toList());
  }

  Widget _buildPostCardBackgroundImage() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(child: _buildPostImageCarousel()),
        _images.length > 1 ? _buildPostImageCarouselIndicator() : Container(),
      ],
    );
  }

  Widget _buildFlexibleSpaceBackground() {
    final double _deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      child: Column(
        children: <Widget>[
          Material(
            elevation: 5.0,
            child: Container(
              height: 150.0,
              width: _deviceWidth,
              padding: EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    borderRadius: BorderRadius.circular(50.0),
                    onTap: !_isSavePostFABEnabled ? null : () => _loadAssets(),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt,
                          size: 30.0, color: Colors.white70),
                    ),
                  ),
                  SizedBox(height: 7.0),
                  Text(
                    'Add photo(s)',
                    style:
                        TextStyle(fontSize: 23.0, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'You can take or choose up to 5 images.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Material(
            child: Container(
              height: 300.0,
              width: _deviceWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.black54),
              child: _images.isNotEmpty
                  ? _buildPostCardBackgroundImage()
                  : InkWell(
                      splashColor: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(50.0),
                      onTap:
                          !_isSavePostFABEnabled ? null : () => _loadAssets(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.camera_alt,
                          size: 70.0,
                          color: Colors.white70,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
      {@required sectionTitle, @required sectionDetails}) {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 10.0),
            Text('$sectionDetails'),
          ],
        ),
        // Divider(color: Colors.black54, height: 0.0)
      ],
    );
  }

  Widget _buildTitleTextFormField() {
    return TextFormField(
      controller: _titleController,
      style: TextStyle(fontSize: 20.0),
      decoration: InputDecoration(
          labelText: 'Title', hintText: 'Enter Title', filled: true),
      validator: (String value) {
        return value.isEmpty ? 'Please enter post title!' : null;
      },
    );
  }

  Widget _buildDescriptionTextFormField() {
    return TextFormField(
      maxLines: 2,
      controller: _descriptionController,
      keyboardType: TextInputType.multiline,
      style: TextStyle(fontSize: 20.0),
      decoration: InputDecoration(
          labelText: 'Description',
          hintText: 'Enter description',
          filled: true),
      validator: (String value) {
        return value.isEmpty
            ? 'Please enter post details or description!'
            : null;
      },
    );
  }

  Widget _buildPriceTextFormField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 20.0),
      decoration: InputDecoration(
          labelText: 'Price', hintText: 'Enter price', filled: true),
      validator: (String value) {
        return value.isEmpty ? 'Please enter price of item!' : null;
      },
    );
  }

  Widget _buildIsProductAvailableFormField() {
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            _hideKeyPad();
            setState(() {
              _isItemAvailable = !_isItemAvailable;
              _availabilityController.text = _isItemAvailable ? 'YES' : 'NO';
            });
          },
          child: IgnorePointer(
            child: TextFormField(
              style: TextStyle(fontSize: 20.0),
              controller: _availabilityController,
              decoration: InputDecoration(
                  labelText: 'Is this item available?',
                  hintText: 'Item availability',
                  filled: true),
              validator: (String value) {
                return value.isEmpty || value == 'FALSE'
                    ? 'Please check item availability!'
                    : null;
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Switch(
            value: _isItemAvailable,
            onChanged: (bool value) {
              setState(() {
                _isItemAvailable = value;
                _availabilityController.text = value ? 'YES' : 'NO';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySynopsis({@required int categoryIndex}) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'John Doe $categoryIndex',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 100.0,
      child: ListView.builder(
        itemCount: 9,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Material(
            elevation: 10.0,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategories.contains(index)
                      ? _selectedCategories.removeWhere((int item) {
                          return item == index;
                        })
                      : _selectedCategories.add(index);
                });
                print(_selectedCategories.length);
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    width: 100.0,
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/temp$index.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  _buildCategorySynopsis(categoryIndex: index),
                  !_selectedCategories.contains(index)
                      ? Container()
                      : Positioned(
                          top: 10.0,
                          left: 15.0,
                          child: Container(
                            height: 80.0,
                            width: 90.0,
                            color: Colors.black38,
                            child: Center(
                              child: Icon(
                                Icons.check,
                                size: 40.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool get _isSavePostFABEnabled {
    return _postBloc.postState == PostState.Loading ? false : true;
  }

  void _hideKeyPad() {
    FocusScope.of(context).requestFocus(FocusNode());
    // _scaffoldKey.currentState..hideCurrentSnackBar();
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

  void _resetForm() {
    _images.clear();
    _formKey.currentState.reset();

    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();

    _isItemAvailable = false;
    _availabilityController.text = _isItemAvailable ? 'YES' : 'NO';
  }

  Future<void> _onUploadFABClicked() async {
    _hideKeyPad();

    if (_images.isEmpty) {
      _showMessageSnackBar(
          content: 'Please select post image(s) to continue!',
          icon: Icons.error_outline,
          isError: true);

      return;
    }

    if (!_formKey.currentState.validate()) {
      _showMessageSnackBar(
          content: 'Please enter post details in form to continue!',
          icon: Icons.error_outline,
          isError: true);

      return;
    }

    final bool _isPostCreated = await _postBloc.createPost(
      assets: _images,
      title: _titleController.text,
      description: _descriptionController.text,
      price: _priceController.text.isEmpty
          ? 0.0
          : double.parse(_priceController.text),
      isAvailable: _isItemAvailable,
      category: 'Category',
    );

    if (_isPostCreated) {
      _showMessageSnackBar(
          content: 'Profile is created sucessfully',
          icon: Icons.check,
          isError: false);

      _resetForm();
    } else {
      _showMessageSnackBar(
          content: 'Sorry! Something went wrong! Try again',
          icon: Icons.error_outline,
          isError: true);
    }
  }

  Widget _buildCustomSavePostFAB() {
    final double _buttonWidth =
        _postBloc.postState == PostState.Loading ? 50.0 : 150.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            elevation: 10.0,
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25.0),
            child: InkWell(
              onTap:
                  !_isSavePostFABEnabled ? null : () => _onUploadFABClicked(),
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
                child: _postBloc.postState == PostState.Loading
                    ? CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              'Upload',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Flexible(
                            child: Icon(
                              Icons.cloud_upload,
                              size: 30.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 500.0,
      pinned: true,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildFlexibleSpaceBackground(),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: Material(
          child: Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed:
                        !_isSavePostFABEnabled ? null : () => _loadAssets(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.image, size: 20.0),
                        SizedBox(width: 5.0),
                        Text('Open gallery'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          // padding: EdgeInsets.symmetric(
          //     horizontal: formContainerPaddingValue / 2),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _buildSectionLabel(
                      sectionTitle: 'Details Section',
                      sectionDetails: 'Enter post details'),
                  _buildTitleTextFormField(),
                  _buildDescriptionTextFormField(),
                  _buildPriceTextFormField(),
                  _buildIsProductAvailableFormField(),
                  _buildSectionLabel(
                      sectionTitle: 'Category Section',
                      sectionDetails:
                          'You can select up to 4 categories for a post'),
                  _buildCategoryList(),
                  SizedBox(height: 60.0),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCustomScrollView({@required double formContainerPaddingValue}) {
    return Material(
      child: KeyboardAvoider(
        autoScroll: true,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            _buildSliverAppBar(),
            _buildSliverList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final double _formContainerWidth =
        _deviceWidth > 550.0 ? 550.0 : _deviceWidth;

    final double _formContainerPaddingValue =
        (_deviceWidth > _formContainerWidth)
            ? (_deviceWidth - _formContainerWidth)
            : 0.0;

    // final PostBloc _postBloc = Provider.of<PostBloc>(context);
    _postBloc = Provider.of<PostBloc>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Stack(
        children: <Widget>[
          _buildCustomScrollView(
              formContainerPaddingValue: _formContainerPaddingValue),
          _buildCustomSavePostFAB(),
        ],
      ),
    );
  }
}
