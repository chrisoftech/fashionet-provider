import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

class CategoryForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CategoryForm({Key key, @required this.scaffoldKey}) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final ScrollController _scrollController = ScrollController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> get _scaffoldKey => widget.scaffoldKey;

  //  Widget _buildPostCardBackgroundImage() {
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: <Widget>[
  //       Container(child: _buildPostImageCarousel()),
  //       _images.length > 1 ? _buildPostImageCarouselIndicator() : Container(),
  //     ],
  //   );
  // }

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
                    onTap: () {},
                    // !_isSavePostFABEnabled ? null : () => _loadAssets(),
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
              child:
                  // _images.isNotEmpty
                  //     ? _buildPostCardBackgroundImage()
                  //     :
                  InkWell(
                splashColor: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50.0),
                onTap: () {},
                // !_isSavePostFABEnabled ? null : () => _loadAssets(),
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

  Widget _buildCustomSavePostFAB() {
    // final double _buttonWidth =
    //     _postBloc.postState == PostState.Loading ? 50.0 : 150.0;

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
              onTap: () {},
              // !_isSavePostFABEnabled ? null : () => _onUploadFABClicked(),
              splashColor: Colors.black38,
              borderRadius: BorderRadius.circular(25.0),
              child: AnimatedContainer(
                height: 50.0,
                width: 150.0,
                duration: Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child:
                    // _postBloc.postState == PostState.Loading
                    //     ? CircularProgressIndicator()
                    //     :
                    Row(
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
                    onPressed: () {},
                    // !_isSavePostFABEnabled ? null : () => _loadAssets(),
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
                SizedBox(height: 70.0),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCustomScrollView({@required double formContainerPaddingValue}) {
    return KeyboardAvoider(
      autoScroll: true,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          _buildSliverAppBar(),
          _buildSliverList(),
        ],
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

    return Material(
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
