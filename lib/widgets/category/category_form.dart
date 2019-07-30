import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CategoryForm extends StatefulWidget {
  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _titleFocusNode = FocusNode();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CategoryBloc _categoryBloc;

  List<Asset> _images = List<Asset>();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();

    _titleFocusNode.addListener(_isTitleFieldFocused);
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
    _titleFocusNode.dispose();

    _titleController.dispose();
    _descriptionController.dispose();
  }

  void _isTitleFieldFocused() {
    if (_titleFocusNode.hasFocus) {
      print('Textfield has focus ${_titleFocusNode.hasFocus}');
      setState(() {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(seconds: 1), curve: Curves.easeOut);
      });
    }
  }

  bool get _isSaveCategoryFABEnabled {
    return _categoryBloc.categoryState == CategoryState.Loading ? false : true;
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
          maxImages: 1,
          enableCamera: true,
          selectedAssets: _images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#abcdef",
            actionBarTitle: "Category Image",
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

  Widget _buildPostCardBackgroundImage() {
    return AssetThumb(
      asset: _images[0],
      width: 300,
      height: 300,
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
                    onTap:
                        !_isSaveCategoryFABEnabled ? null : () => _loadAssets(),
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
                    'You can take or choose one category image.',
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
                      onTap: !_isSaveCategoryFABEnabled
                          ? null
                          : () => _loadAssets(),
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
      focusNode: _titleFocusNode,
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
          content: 'Please enter category details in form to continue!',
          icon: Icons.error_outline,
          isError: true);

      return;
    }

    final bool _isCategoryCreated = await _categoryBloc.createCategory(
      title: _titleController.text,
      description: _descriptionController.text,
      asset: _images[0],
    );

    // fetch categories after creating
    await _categoryBloc.fetchCategories();

    if (_isCategoryCreated) {
      _showMessageSnackBar(
          content: 'Category is created sucessfully',
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

  Widget _buildCustomSaveCategoryFAB() {
    final double _buttonWidth =
        _categoryBloc.categoryState == CategoryState.Loading ? 50.0 : 150.0;

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
              onTap: !_isSaveCategoryFABEnabled
                  ? null
                  : () => _onUploadFABClicked(),
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
                child: _categoryBloc.categoryState == CategoryState.Loading
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
                        !_isSaveCategoryFABEnabled ? null : () => _loadAssets(),
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
                    sectionDetails: 'Enter category details'),
                _buildTitleTextFormField(),
                _buildDescriptionTextFormField(),
                SizedBox(height: 20.0),
                _buildCustomSaveCategoryFAB(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCustomScrollView({@required double formContainerPaddingValue}) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        _buildSliverAppBar(),
        _buildSliverList(),
      ],
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

    _categoryBloc = Provider.of<CategoryBloc>(context);

    return Dialog(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: _buildCustomScrollView(
            formContainerPaddingValue: _formContainerPaddingValue),
      ),
    );
  }
}
