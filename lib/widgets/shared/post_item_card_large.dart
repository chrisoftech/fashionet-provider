import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostItemCardLarge extends StatefulWidget {
  final int postIndex;
  final BoxConstraints constraints;
  final double deviceWidth;
  final Post post;

  const PostItemCardLarge({
    Key key,
    @required this.postIndex,
    @required this.constraints,
    @required this.deviceWidth,
    @required this.post,
  }) : super(key: key);

  @override
  _PostItemCardLargeState createState() => _PostItemCardLargeState();
}

class _PostItemCardLargeState extends State<PostItemCardLarge> {
  Post get _post => widget.post;

  PostBloc _postBloc;

  Widget _buildPostImage() {
    final double _maxHeight = widget.constraints.maxHeight;

    final double _parentContainerWidth =
        widget.deviceWidth * 0.90; // 80% of device width

    final double _postImageContainerHeight =
        _maxHeight * 0.65; // 65% of constraints maxHeight

    return Positioned(
      top: 0.0,
      height: _postImageContainerHeight,
      width: _parentContainerWidth,
      child: _post != null && _post.imageUrls.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: '${_post.imageUrls[0]}',
              placeholder: (context, imageUrl) =>
                  Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
              errorWidget: (context, imageUrl, error) =>
                  Center(child: Icon(Icons.error)),
              imageBuilder: (BuildContext context, ImageProvider image) {
                return Hero(
                  tag: '${_post.postId}_${_post.imageUrls[0]}',
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
    );
  }

  Widget _buildPostTitle() {
    return Flexible(
      child: ListTile(
        title: Text('${_post.title}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${_post.description}', overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          tooltip: 'Save this post',
          icon: Icon(
            _post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () {
            _postBloc.toggleBookmarkStatus(post: _post);
          },
        ),
      ),
    );
  }

  Widget _buildPostUser() {
    return Flexible(
      child: ListTile(
        leading: Container(
          height: 45.0,
          width: 45.0,
          child: _post != null && _post.profile.profileImageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: '${_post.profile.profileImageUrl}',
                  placeholder: (context, imageUrl) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0)),
                  errorWidget: (context, imageUrl, error) =>
                      Center(child: Icon(Icons.error)),
                  imageBuilder: (BuildContext context, ImageProvider image) {
                    return Hero(
                      tag: '${_post.postId}_${_post.profile.profileImageUrl}',
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image:
                              DecorationImage(image: image, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(22.5),
                  child: Image.asset('assets/avatars/ps-avatar.png',
                      fit: BoxFit.cover),
                ),
        ),
        title: Text('by ${_post.profile.firstName} ${_post.profile.lastName}',
            overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${DateFormat.yMMMMEEEEd().format(_post.lastUpdate.toDate())}',
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildPostContent() {
    final double _maxHeight = widget.constraints.maxHeight;

    final double _parentContainerWidth =
        widget.deviceWidth * 0.90; // 80% of device width

    final double _postContentContainerHeight =
        _maxHeight * 0.50; // 55% of constraints maxHeight

    return Positioned(
      bottom: 20.0,
      height: _postContentContainerHeight,
      width: _parentContainerWidth,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 0.0, right: 10.0, left: 10.0, bottom: 10.0),
        child: Card(
          elevation: 8.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildPostTitle(),
                SizedBox(height: 5.0),
                _buildPostUser(),
                SizedBox(height: 20.0)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyStack() {
    return Stack(
      children: <Widget>[
        _buildPostImage(),
        _buildPostContent(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _parentContainerWidth =
        widget.deviceWidth * 0.90; // 80% of device width

    return Consumer<PostBloc>(
        builder: (BuildContext context, PostBloc postBloc, Widget child) {
      _postBloc = postBloc;
      return Row(
        children: <Widget>[
          Container(
            width: _parentContainerWidth,
            // height:  constraints.maxHeight * .8,
            child: _buildBodyStack(),
          ),
          SizedBox(width: 20.0)
        ],
      );
    });
  }
}
