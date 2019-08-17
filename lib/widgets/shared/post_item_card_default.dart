import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/consts/const.dart' as consts;
import 'package:fashionet_provider/transitions/transitions.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';

class PostItemCardDefault extends StatefulWidget {
  final Post post;
  final bool isProfilePost;

  const PostItemCardDefault(
      {Key key, @required this.post, this.isProfilePost = false})
      : super(key: key);
  @override
  _PostItemCardDefaultState createState() => _PostItemCardDefaultState();
}

class _PostItemCardDefaultState extends State<PostItemCardDefault> {
  int _currentPostImageIndex = 0;
  bool _isCurrentUserProfile = false;

  Post get _post => widget.post;
  bool get _isProfilePost => widget.isProfilePost;

  PostBloc _postBloc;
  // PostEditBloc _postEditBloc;

  initState() {
    super.initState();

    final ProfileBloc _profileBloc =
        Provider.of<ProfileBloc>(context, listen: false);
    _postBloc = Provider.of<PostBloc>(context, listen: false);
    // _postEditBloc = Provider.of<PostEditBloc>(context, listen: false);

    if (_profileBloc.userProfile != null) {
      setState(() {
        _profileBloc.userProfile.userId == _post.profile.userId
            ? _isCurrentUserProfile = true
            : _isCurrentUserProfile = false;
      });
    }
  }

  void _navigateToPostDetailsPage() {
    if (_isProfilePost) {
      Navigator.of(context).pushNamed('/profile-post/${_post.postId}');
    } else {
      Navigator.of(context).pushNamed('/post/${_post.postId}');
    }
  }

  void _navigateToProfilePage() {
    Navigator.of(context).pushNamed('/post-profile/${_post.postId}').then((_) {
      final _postFormKey = UniqueKey();
      _postBloc.postFormKey = _postFormKey;
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
      bottom: 0.0,
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

  Widget _buildPostPriceTag() {
    return Positioned(
      top: 20.0,
      right: 0.0,
      child: Container(
        height: 30.0,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0)),
          // borderRadius: BorderRadius.circular(25.0),
        ),
        child: Text(
          'GHC ${_post.price}',
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPostCardBackgroundImage() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          child: _post.imageUrls.length > 0
              ? _buildPostImageCarousel()
              : Image.asset('assets/avatars/bg-avatar.png', fit: BoxFit.cover),
        ),
        _buildPostImageSynopsis(),
        _post.imageUrls.length > 1
            ? _buildPostImageCarouselIndicator()
            : Container(),
        _buildPostPriceTag()
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
            postBloc.toggleFollowProfilePageStatus(
                currentPostProfile: _post.profile);
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
      onTap: _isProfilePost ? null : () => _navigateToProfilePage(),
      leading: Container(
        height: 50.0,
        width: 50.0,
        child: _post != null && _post.profile.profileImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: '${_post.profile.profileImageUrl}',
                placeholder: (context, imageUrl) =>
                    Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
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
                        image: DecorationImage(image: image, fit: BoxFit.cover),
                      ),
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
      trailing: _isCurrentUserProfile
          ? null
          : _isProfilePost ? null : _buildFollowTrailingButton(),
    );
  }

  _showMessageSnackBar(
      {@required String content,
      @required IconData icon,
      @required bool isError}) {
    // if (_scaffoldKey.currentState != null) {
    Scaffold.of(context)
      // _scaffoldKey.currentState
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
    // }
  }

  Future<void> _deletePost() async {
    final bool _isDeleted = await _postBloc.deletePost(post: _post);
    if (_isDeleted) {
      // _showMessageSnackBar(
      //     content: '${_post.title} is deleted sucessfully',
      //     icon: Icons.check,
      //     isError: false);
      Navigator.of(context).pop();
    } else {
      _showMessageSnackBar(
          content: 'Sorry! Something went wrong! Try again',
          icon: Icons.error_outline,
          isError: true);
    }
  }

  void _buildDeleteConfirmationDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Post',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Are you sure of deleting ${_post.title}?'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel')),
              Consumer<PostBloc>(builder:
                  (BuildContext context, PostBloc postBloc, Widget child) {
                return RaisedButton(
                    onPressed: () => _deletePost(),
                    child: postBloc.postDeleteState == PostState.Loading
                        ? Center(
                            child: SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)))
                        : Text('Delete'));
              }),
            ],
          );
        });
  }

  void _choiceAction(String action) {
    if (action == consts.EDIT) {
      Navigator.push(context, SlideLeftRoute(page: PostEditForm(post: _post)))
          .then((_) {
        final _postFormKey = UniqueKey();
        _postBloc.postFormKey = _postFormKey;
      });
    } else if (action == consts.DELETE) {
      _buildDeleteConfirmationDialog();
    }
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      onSelected: _choiceAction,
      tooltip: 'Choose an action',
      itemBuilder: (BuildContext context) {
        return consts.menuOptions.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text('$item'),
          );
        }).toList();
      },
    );
  }

  Widget _buildPostListTile() {
    return ListTile(
      title:
          Text('${_post.title}', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${_post.description}', overflow: TextOverflow.ellipsis),
      trailing: Consumer<PostBloc>(
          builder: (BuildContext context, PostBloc postBloc, Widget child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                postBloc.toggleBookmarkStatus(post: _post);
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  _post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            !_isCurrentUserProfile ? Container() : _buildActionMenu()
          ],
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
            onTap: () => _navigateToPostDetailsPage(),
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
