import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostItemCardDefault extends StatefulWidget {
  final List<dynamic> postImages;
  final Post post;

  const PostItemCardDefault(
      {Key key, @required this.postImages, @required this.post})
      : super(key: key);
  @override
  _PostItemCardDefaultState createState() => _PostItemCardDefaultState();
}

class _PostItemCardDefaultState extends State<PostItemCardDefault> {
  int _currentPostImageIndex = 0;

  List<dynamic> get _postImages => widget.postImages;
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
        ));
  }

  Widget _buildPostImageSynopsis() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 00.0,
      child: Container(
        height: 70.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.transparent, Colors.black87],
          ),
        ),
      ),
    );
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
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: image, fit: BoxFit.cover),
                    ),
                  );
                },
              );
            },
          );
        }).toList());
  }

  Widget _buildPostCardBackgroundImage() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          child: _postImages.length > 0
              ? _buildPostImageCarousel()
              : Image.asset('assets/avatars/bg-avatar.png', fit: BoxFit.cover),
        ),
        _buildPostImageSynopsis(),
        _post.imageUrls.length > 1
            ? _buildPostImageCarouselIndicator()
            : Container(),
      ],
    );
  }

  Widget _buildFollowTrailingButton() {
    final double _containerHeight = _post.profile.isFollowing ? 40.0 : 30.0;
    final double _containerWidth = _post.profile.isFollowing ? 40.0 : 100.0;

    return Consumer<PostBloc>(
      builder: (BuildContext context, PostBloc postBloc, Widget child) {
        return InkWell(
          onTap: () {
            postBloc.toggleFollowProfilePageStatus(currentPost: _post);
          },
          splashColor: Colors.black38,
          borderRadius: BorderRadius.circular(15.0),
          child: AnimatedContainer(
            height: _containerHeight,
            width: _containerWidth,
            duration: Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _post.profile.isFollowing
                    ? Container()
                    : Flexible(
                        flex: 2,
                        child: Text(
                          'FOLLOW',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                SizedBox(width: _post.profile.isFollowing ? 0.0 : 5.0),
                Flexible(
                  child: Center(
                    child: Icon(
                      _post.profile.isFollowing
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 20.0,
                      color: Colors.red,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserListTile() {
    return ListTile(
      onTap: () {},
      leading: Container(
        height: 50.0,
        width: 50.0,
        child: _post != null || _post.profile.profileImageUrl.isEmpty
            ? CachedNetworkImage(
                imageUrl: '${_post.profile.profileImageUrl}',
                placeholder: (context, imageUrl) =>
                    Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                errorWidget: (context, imageUrl, error) =>
                    Center(child: Icon(Icons.error)),
                imageBuilder: (BuildContext context, ImageProvider image) {
                  return Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: image, fit: BoxFit.cover),
                    ),
                  );
                },
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Image.asset('assets/avatars/ps-avatar.png',
                    fit: BoxFit.cover),
              ),
      ),
      title: Text('${_post.profile.firstName} ${_post.profile.lastName}',
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          Text('${DateFormat.yMMMMEEEEd().format(_post.lastUpdate.toDate())}'),
      trailing: _buildFollowTrailingButton(),
    );
  }

  Widget _buildPostListTile() {
    return ListTile(
      onTap: () {},
      title:
          Text('${_post.title}', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${_post.description}', overflow: TextOverflow.ellipsis),
      trailing: Consumer<PostBloc>(
          builder: (BuildContext context, PostBloc postBloc, Widget child) {
        return IconButton(
          tooltip: 'Save this post',
          icon: Icon(
            _post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            postBloc.toggleBookmarkStatus(post: _post);
          },
        );
      }),
    );
  }

  Widget _buildPostDetails() {
    return Column(
      children: <Widget>[
        _buildUserListTile(),
        _buildPostListTile(),
      ],
    );
  }

  Widget _buildPostItem() {
    final _deviceWidth = MediaQuery.of(context).size.width;
    final _contentWidth = _deviceWidth > 450.0 ? 450.0 : _deviceWidth;

    return Column(
      children: <Widget>[
        Card(
          elevation: 8.0,
          child: InkWell(
            onTap: () {
              // Navigator.of(context).pushNamed('/post-details');
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => PostDetailsPage(
              //               postImages: _postImages,
              //             )));
            },
            child: Container(
              width: _contentWidth,
              child: Column(
                children: <Widget>[
                  _buildPostDetails(),
                  _buildPostCardBackgroundImage()
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPostItem();
  }
}
