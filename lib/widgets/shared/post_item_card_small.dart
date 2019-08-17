import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostItemCardSmall extends StatefulWidget {
  final Post bookmarkPost;

  const PostItemCardSmall({Key key, @required this.bookmarkPost})
      : super(key: key);

  @override
  _PostItemCardSmallState createState() => _PostItemCardSmallState();
}

class _PostItemCardSmallState extends State<PostItemCardSmall> {
  Post get _bookmarkPost => widget.bookmarkPost;

  void _navigateToPostDetailsPage() {
    Navigator.of(context).pushNamed('/bookmark/${_bookmarkPost.postId}');
  }

  void _navigateToProfilePage() {
    Navigator.of(context).pushNamed(
        '/bookmarked-post-profile/${_bookmarkPost.postId}/${_bookmarkPost.profile.userId}');
  }

  Widget _buildPostPriceTag({@required BuildContext context}) {
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
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0)),
            // borderRadius: BorderRadius.circular(25.0),
          ),
          child: Text(
            'GHC ${_bookmarkPost.price}',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildPostDetailsCard(
      {@required BuildContext context,
      @required double postContainerHeight,
      @required double postContentContainerWidth,
      @required double deviceWidth}) {
    return Positioned(
      left: 15.0,
      bottom: 0.0,
      height: postContainerHeight,
      width: postContentContainerWidth,
      child: Card(
        elevation: 5.0,
        child: Container(
          padding: EdgeInsets.only(left: deviceWidth * 0.18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  isThreeLine: true,
                  title: Text('${_bookmarkPost.title}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${_bookmarkPost.description}',
                      overflow: TextOverflow.ellipsis),
                  trailing: Consumer<PostBloc>(builder:
                      (BuildContext context, PostBloc postBloc, Widget child) {
                    return IconButton(
                      tooltip: 'Save this post',
                      icon: Icon(
                        _bookmarkPost.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        postBloc.toggleBookmarkStatus(post: _bookmarkPost);
                      },
                    );
                  }),
                ),
              ),
              Expanded(
                child: ListTile(
                  onTap: () => _navigateToProfilePage(),
                  title: Text(
                      'by ${_bookmarkPost.profile.firstName} ${_bookmarkPost.profile.lastName}'),
                  subtitle: Text(
                    '${DateFormat.yMMMMEEEEd().format(_bookmarkPost.lastUpdate.toDate())}',
                    style: TextStyle(fontSize: 11.0),
                  ),
                  trailing: _buildPostPriceTag(context: context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage() {
    return Material(
      elevation: 5.0,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: _bookmarkPost != null && _bookmarkPost.imageUrls.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: '${_bookmarkPost.imageUrls[0]}',
                placeholder: (context, imageUrl) =>
                    Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                errorWidget: (context, imageUrl, error) =>
                    Center(child: Icon(Icons.error)),
                imageBuilder: (BuildContext context, ImageProvider image) {
                  return Hero(
                    tag:
                        '${_bookmarkPost.postId}_${_bookmarkPost.imageUrls[0]}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(image: image, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                      image: AssetImage('assets/avatars/bg-avatar.png'),
                      fit: BoxFit.cover),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _bookmarkPost != null &&
              _bookmarkPost.profile.profileImageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: '${_bookmarkPost.profile.profileImageUrl}',
              placeholder: (context, imageUrl) =>
                  Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
              errorWidget: (context, imageUrl, error) =>
                  Center(child: Icon(Icons.error)),
              imageBuilder: (BuildContext context, ImageProvider image) {
                return Hero(
                  tag:
                      '${_bookmarkPost.postId}_${_bookmarkPost.profile.profileImageUrl}',
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25.0),
                    child: InkWell(
                      onTap: () => _navigateToProfilePage(),
                      borderRadius: BorderRadius.circular(25.0),
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                          image:
                              DecorationImage(image: image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
                image: DecorationImage(
                    image: AssetImage('assets/avatars/ps-avatar.png'),
                    fit: BoxFit.cover),
              ),
            ),
    );
  }

  Widget _buildPostImageCount() {
    return widget.bookmarkPost.imageUrls.length == 1
        ? Container()
        : Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 30.0,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0)),
                  ),
                  child: Text(
                    '+ ${widget.bookmarkPost.imageUrls.length - 1}',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildPostImageStack(
      {@required double postContainerHeight,
      @required double postImageContainerWidth}) {
    return Positioned(
      top: 0.0,
      left: 0.0,
      height: postContainerHeight,
      width: postImageContainerWidth,
      child: Stack(
        children: <Widget>[
          _buildPostImage(),
          _buildProfileAvatar(),
          _buildPostImageCount(),
        ],
      ),
    );
  }

  Widget _buildCardStack(
      {@required BuildContext context,
      @required double deviceWidth,
      @required double containerHeight}) {
    final double _postContentContainerWidth =
        deviceWidth * 0.85; // 85% of total device width.
    final double _postImageContainerWidth =
        deviceWidth * 0.25; // 25% of total device width.

    final double _postContainerHeight = containerHeight - 15.0;

    return Stack(
      children: <Widget>[
        _buildPostDetailsCard(
            context: context,
            postContainerHeight: _postContainerHeight,
            postContentContainerWidth: _postContentContainerWidth,
            deviceWidth: deviceWidth),
        _buildPostImageStack(
            postContainerHeight: _postContainerHeight,
            postImageContainerWidth: _postImageContainerWidth),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = MediaQuery.of(context).size.width;

    final double _containerHeight = 150.0;
    final double _containerWidth = _deviceWidth > 500.0
        ? 500.0
        : _deviceWidth * 0.90; // 90% of total device width.

    return Column(
      children: <Widget>[
        Material(
          child: InkWell(
            onTap: () => _navigateToPostDetailsPage(),
            child: Container(
              height: _containerHeight,
              width: _containerWidth,
              child: _buildCardStack(
                  context: context,
                  deviceWidth: _deviceWidth,
                  containerHeight: _containerHeight),
            ),
          ),
        ),
        SizedBox(height: 5.0),
      ],
    );
  }
}
