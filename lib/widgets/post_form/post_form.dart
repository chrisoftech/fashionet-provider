import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
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

  final _categoryScrollController = ScrollController();
  final _scrollThreshold = 200.0;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _availabilityController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> get _scaffoldKey => widget.scaffoldKey;

  PostBloc _postBloc;
  CategoryBloc _categoryBloc;

  int _currentPostImageIndex = 0;

  final List<String> _selectedCategories = [];
  bool _isItemAvailable = false;

  List<Asset> _images = List<Asset>();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();

    _categoryScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();

    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _availabilityController.dispose();

    _categoryScrollController.removeListener(_onScroll);

    print('Form disposed');
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      print('sroll next');
      _categoryBloc.fetchMoreCategories();
    }
  }

  bool get _isSavePostFABEnabled {
    return _postBloc.postState == PostState.Loading ? false : true;
  }

  void _hideKeyPad() {
    FocusScope.of(context).requestFocus(FocusNode());
    // _scaffoldKey.currentState..hideCurrentSnackBar();
  }

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
            actionBarTitle: "Post Image(s)",
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
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
        onPageChanged: (int index) {
          setState(() {
            _currentPostImageIndex = index;
          });
        },
        items: _images.map((Asset asset) {
          return Builder(
            builder: (BuildContext context) {
              return AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              );
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

  Widget _buildCategorySynopsis({@required PostCategory category}) {
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
              '${category.title}',
              softWrap: true,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Consumer<CategoryBloc>(builder:
        (BuildContext context, CategoryBloc categoryBloc, Widget child) {
      _categoryBloc = categoryBloc;

      return Container(
        height: 100.0,
        child: ListView.builder(
          controller: _categoryScrollController,
          itemCount: categoryBloc.moreCategoriesAvailable
              ? categoryBloc.postCategories.length + 1
              : categoryBloc.postCategories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            if (index >= categoryBloc.postCategories.length) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0)));
            } else {
              final PostCategory _postCategory =
                  categoryBloc.postCategories[index];

              return Material(
                elevation: 10.0,
                child: InkWell(
                  onTap: () {
                    final String _categoryId = _postCategory.categoryId;

                    if (_selectedCategories.contains(_categoryId)) {
                      // remove categoryId from list if it exists
                      setState(() {
                        _selectedCategories.removeWhere(
                            (String categoryId) => categoryId == _categoryId);
                      });
                    } else {
                      // check if number of list items == 4 (MaxCategoriesAllowed)
                      if (_selectedCategories.length == 4) {
                        _showMessageSnackBar(
                            content:
                                'Maximum number of categories allowed reached!',
                            icon: Icons.error_outline,
                            isError: true);

                        return;
                      }

                      // add categoryId to list if it does not exist in list already
                      setState(() {
                        _selectedCategories.add(_categoryId);
                      });
                    }
                    print(_selectedCategories.length);
                  },
                  child: Stack(
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl: '${_postCategory.imageUrl}',
                          placeholder: (context, image) =>
                              CircularProgressIndicator(strokeWidth: 2.0),
                          errorWidget: (context, image, error) =>
                              Icon(Icons.error),
                          imageBuilder:
                              (BuildContext context, ImageProvider image) {
                            return Container(
                              height: 100.0,
                              width: 100.0,
                              margin: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }),
                      _buildCategorySynopsis(category: _postCategory),
                      !_selectedCategories.contains(_postCategory.categoryId)
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
            }
          },
        ),
      );
    });
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

  Future<void> _scrollToStart() async {
    await _categoryScrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn);

    await _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn);
  }

  void _resetForm() {
    _images.clear();
    _formKey.currentState.reset();

    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();

    _isItemAvailable = false;
    _availabilityController.text = _isItemAvailable ? 'YES' : 'NO';

    _selectedCategories.clear();
    _scrollToStart();
  }

  Future<void> _onUploadFABClicked() async {
    _hideKeyPad();
    // _resetForm()

    if (_images.isEmpty) {
      _showMessageSnackBar(
          content: 'Please select post image(s) to continue!',
          icon: Icons.error_outline,
          isError: true);

      _scrollToStart();

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
      categories: _selectedCategories,
    );

    if (_isPostCreated) {
      // fetch posts after creating
      await _postBloc.fetchPosts();

      _showMessageSnackBar(
          content: 'Post is created sucessfully',
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
                Consumer<CategoryBloc>(builder: (BuildContext context,
                    CategoryBloc categoryBloc, Widget child) {
                  return categoryBloc.categoryState == CategoryState.Loading
                      ? CircularProgressIndicator()
                      : categoryBloc.postCategories.length == 0
                          ? Center(
                              child: Text('No Categories'),
                            )
                          : _buildCategoryList();
                }),
                SizedBox(height: 60.0),
              ],
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

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Stack(
          children: <Widget>[
            _buildCustomScrollView(
                formContainerPaddingValue: _formContainerPaddingValue),
            _buildCustomSavePostFAB(),
          ],
        ),
      ),
    );
  }
}
