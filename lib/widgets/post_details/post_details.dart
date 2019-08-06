import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostDetails extends StatefulWidget {
  final Post post;

  const PostDetails({Key key, @required this.post}) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  int _currentPostImageIndex = 0;

  Post get _post => widget.post;

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
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey));
    // shape: BoxShape.circle, color: Color.fromRGBO(0, 0, 0, 0.4)));
  }

  Widget _buildPostImageCarouselIndicator() {
    List<Widget> dots = [];

    for (int i = 0; i < _post.imageUrls.length; i++) {
      dots.add(i == _currentPostImageIndex
          ? _buildActivePostImage()
          : _buildInactivePostImage());
    }

    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 20.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dots,
      ),
    );
  }

  Widget _buildPostImageCarousel() {
    final double _deviceHeight = MediaQuery.of(context).size.height;

    return CarouselSlider(
        height: _deviceHeight,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
        onPageChanged: (int index) {
          setState(() {
            _currentPostImageIndex = index;
          });
        },
        items: _post.imageUrls.map((dynamic postImageUrl) {
          return Builder(
            builder: (BuildContext context) {
              return CachedNetworkImage(
                imageUrl: '${postImageUrl.toString()}',
                placeholder: (context, imageUrl) =>
                    Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                errorWidget: (context, imageUrl, error) =>
                    Center(child: Icon(Icons.error)),
                imageBuilder: (BuildContext context, ImageProvider image) {
                  return Hero(
                    tag: '${_post.postId}_${_post.imageUrls[0]}',
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: image, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }).toList());
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: '${_post.profile.profileImageUrl}',
          placeholder: (context, imageUrl) =>
              Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          errorWidget: (context, imageUrl, error) =>
              Center(child: Icon(Icons.error)),
          imageBuilder: (BuildContext context, ImageProvider image) {
            return Hero(
              tag: '${_post.postId}_${_post.profile.profileImageUrl}',
              child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.0),
                    image: DecorationImage(image: image, fit: BoxFit.cover),
                  )),
            );
          },
        ),
        SizedBox(width: 10.0),
        Hero(
          tag: '${_post.postId}_${_post.profile.firstName}',
          child: Text(
            '${_post.profile.firstName} ${_post.profile.lastName}',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCardBackgroundImage() {
    final double _deviceWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          child: _post.imageUrls.length > 0
              ? _buildPostImageCarousel()
              : Image.asset('assets/avatars/bg-avatar.png', fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 0.0,
          height: 80.0,
          width: _deviceWidth,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ]),
            ),
          ),
        ),
        _post.imageUrls.length > 1
            ? _buildPostImageCarouselIndicator()
            : Container(),
        Positioned(
          top: 0.0,
          height: 60.0,
          width: _deviceWidth,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ]),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: Container(
        //     padding: EdgeInsets.only(top: 50.0),
        //     child:
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSliverAppBar({@required double deviceHeight}) {
    return SliverAppBar(
      centerTitle: true,
      title: _buildTitleRow(),
      expandedHeight: deviceHeight - 100.0,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildPostCardBackgroundImage(),
      ),
      actions: <Widget>[
        Consumer<PostBloc>(
            builder: (BuildContext context, PostBloc postBloc, Widget child) {
          return Material(
            color: Colors.transparent,
            child: IconButton(
              tooltip: 'Save this post',
              icon: Icon(
                _post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                postBloc.toggleBookmarkStatus(post: _post);
              },
            ),
          );
        }),
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPostPriceTag() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 30.0,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0)),
            // borderRadius: BorderRadius.circular(25.0),
          ),
          child: Text(
            'GHC ${_post.price}',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildPostTitleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${_post.profile.businessName}',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w900),
        ),
        Text(
          '${DateFormat.yMMMMEEEEd().format(_post.lastUpdate.toDate())}',
          style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(
                '${_post.title}',
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900),
              ),
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.bookmark,
                  color: Theme.of(context).accentColor,
                  size: 20.0,
                ),
                SizedBox(width: 5.0),
                Text('50k',
                    style: TextStyle(
                        color: Colors.black38, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        _buildPostPriceTag(),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildPostColorsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Colors',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        SizedBox(height: 10.0),
        Row(
          children: <Widget>[
            Icon(Icons.color_lens, size: 15.0),
            SizedBox(width: 5.0),
            Expanded(child: Text('Blue, Black, Grey')),
          ],
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildPostContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        SizedBox(height: 10.0),
        Row(
          children: <Widget>[
            Icon(Icons.access_time, size: 15.0),
            SizedBox(width: 5.0),
            Expanded(child: Text('Mon - Fri (9.00am - 6.00pm)')),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          children: <Widget>[
            Icon(Icons.phone_android, size: 15.0),
            SizedBox(width: 5.0),
            Text('${_post.profile.phoneNumber}'),
            _post.profile.otherPhoneNumber.isEmpty
                ? Container()
                : Text(' ,${_post.profile.otherPhoneNumber}'),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          children: <Widget>[
            Icon(Icons.location_on, size: 15.0),
            SizedBox(width: 5.0),
            Expanded(child: Text('${_post.profile.businessLocation}')),
          ],
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buidlDetailsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Details Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        Divider(),
        // SizedBox(height: 10.0),
        Text(
          '${_post.description}',
          softWrap: true,
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildPostDetails() {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;

    final double _contentHeight = _deviceHeight * 0.7;

    final double _contentWidthPadding =
        _deviceWidth > 450.0 ? _deviceWidth - 450.0 : 30.0;

    return Material(
      elevation: 5.0,
      child: Container(
        height: _contentHeight,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: _contentWidthPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildPostTitleInfo(),
                    _buildPostColorsInfo(),
                    _buildPostContactInfo(),
                    _buidlDetailsSummary(),
                    // add similar posts
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          child: Column(
            children: <Widget>[
              _buildPostDetails(),
            ],
          ),
        )
      ]),
    );
  }

  Widget _buildControlFAB() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(
        Icons.phone,
        size: 30.0,
        color: Colors.white70,
      ),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    // final double _deviceWidth = MediaQuery.of(context).size.width;

    // final PostBloc _postbloc = Provider.of<PostBloc>(context);

    return Scaffold(
        floatingActionButton: _buildControlFAB(),
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              _buildSliverAppBar(deviceHeight: _deviceHeight),
              _buildSliverList(),
            ],
          ),
        ));
  }
}
