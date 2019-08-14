import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final Profile userProfile;

  const ProfilePage({Key key, this.userProfile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentDisplayedPageIndex = 0;
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  Profile get _profile => widget.userProfile;
  bool _isCurrentUserProfile = false;

  PostBloc _postBloc;
  ProfileBloc _profileBloc;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _postBloc = Provider.of<PostBloc>(context, listen: false);
    _profileBloc = Provider.of<ProfileBloc>(context, listen: false);

    if (_profileBloc.userProfile != null) {
      setState(() {
        _profileBloc.userProfile.userId == _profile.userId
            ? _isCurrentUserProfile = true
            : _isCurrentUserProfile = false;
      });
    }

    _onWidgetDidBuild(() {
      _postBloc.fetchProfilePosts(userId: _profile.userId);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      print('sroll next');
      _postBloc.fetchMoreProfilePosts(userId: _profile.userId);
    }
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, double _deviceHeight, double _deviceWidth) {
    return SliverAppBar(
      pinned: true,
      title: Text(
        '${_profile.firstName.trim()} ${_profile.lastName.trim()}',
      ),
      expandedHeight: 360.0,
      actions: <Widget>[
        Icon(Icons.more_vert),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildFlexibleSpace(
            context: context,
            deviceHeight: _deviceHeight,
            deviceWidth: _deviceWidth),
      ),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(5.0),
          child: ProfileNavbar(
            isCurrentUserProfile: _isCurrentUserProfile,
            onActiveIndexChange: (int index) {
              setState(() {
                _currentDisplayedPageIndex = index;
              });

              if (_currentDisplayedPageIndex == 0) {
                _postBloc.fetchProfilePosts(userId: _profile.userId);
              } else if (_currentDisplayedPageIndex == 1) {
                _profileBloc.fetchUserProfileSubscriptions();
              }

              print(_currentDisplayedPageIndex);
            },
          )),
    );
  }

  Widget _buildProfileAvatar() {
    return _profile != null && _profile.profileImageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: '${_profile.profileImageUrl}',
            placeholder: (context, imageUrl) =>
                Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
            errorWidget: (context, imageUrl, error) =>
                Center(child: Icon(Icons.error)),
            imageBuilder: (BuildContext context, ImageProvider image) {
              return Hero(
                tag:
                    // _isUserProfile
                    // ?
                    '${_profile.profileImageUrl}',
                // : '${_post.postId}_${_profile.profileImageUrl}',
                child: Container(
                  height: 120.0,
                  width: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: image, fit: BoxFit.cover),
                    border: Border.all(width: 1.0, color: Colors.white),
                  ),
                ),
              );
            },
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child:
                Image.asset('assets/avatars/ps-avatar.png', fit: BoxFit.cover),
          );
  }

  Widget _buildProfileName() {
    return Text(
      '${_profile.firstName.trim()} ${_profile.lastName.trim()}',
      style: TextStyle(
          color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProfileFollowButton() {
    return Consumer<PostBloc>(
        builder: (BuildContext context, PostBloc postBloc, Widget child) {
      final double _containerHeight = _profile.isFollowing ? 30.0 : 30.0;
      final double _containerWidth =
          _isCurrentUserProfile ? 100.0 : _profile.isFollowing ? 110.0 : 140.0;

      return Material(
        elevation: 10.0,
        type: MaterialType.button,
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          splashColor: Colors.black38,
          borderRadius: BorderRadius.circular(20.0),
          onTap: _isCurrentUserProfile
              ? null
              : () {
                  postBloc.toggleFollowProfilePageStatus(
                      currentPostProfile: _profile);
                },
          child: AnimatedContainer(
            height: _containerHeight,
            width: _containerWidth,
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _isCurrentUserProfile
                    ? Container()
                    : _profile.isFollowing
                        ? Flexible(
                            child: Center(
                              child: Icon(
                                Icons.favorite,
                                size: 20.0,
                                color: Colors.black38,
                                // color: Colors.red,
                              ),
                            ),
                          )
                        : Flexible(
                            child: Text(
                              'Follow',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  // color: Colors.black45,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                _isCurrentUserProfile ? Container() : SizedBox(width: 5.0),
                _isCurrentUserProfile
                    ? Container()
                    : Container(
                        height: 15.0,
                        width: 1.0,
                        decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                _isCurrentUserProfile ? Container() : SizedBox(width: 10.0),
                Text(
                  '${_profile.followersCount} ${_profile.followersCount > 1 ? 'followers' : 'follower'}',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProfileContactButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              shape: BoxShape.circle),
          child: IconButton(
            tooltip:
                'Call ${_profile.firstName.trim()} ${_profile.lastName.trim()}',
            icon: Icon(
              Icons.call,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
        SizedBox(width: 10.0),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              shape: BoxShape.circle),
          child: IconButton(
            tooltip:
                'Chat with ${_profile.firstName.trim()} ${_profile.lastName.trim()}',
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildFlexibleSpace(
      {@required BuildContext context,
      @required double deviceHeight,
      @required double deviceWidth}) {
    return Container(
      height: 200.0,
      width: deviceWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildProfileAvatar(),
          SizedBox(height: 5.0),
          _buildProfileName(),
          SizedBox(height: 5.0),
          _buildProfileFollowButton(),
          SizedBox(height: 10.0),
          _buildProfileContactButtons(),
        ],
      ),
    );
  }

  FloatingActionButton _buildProfileFAB() {
    return FloatingActionButton(
      elevation: 8.0,
      highlightElevation: 10.0,
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(
        Icons.add_a_photo,
        size: 32.0,
        color: Colors.white,
      ),
      onPressed: () => Navigator.of(context).pushNamed('/post-form'),
    );
  }

  Widget _buildDynamicSliverContent() {
    Widget _dynamicSliverContent;

    switch (_currentDisplayedPageIndex) {
      case 0:
        _dynamicSliverContent = TimelineTabPage(
            userId: _profile.userId, isRefreshing: _isRefreshing);
        break;

      case 1:
        _dynamicSliverContent = _isCurrentUserProfile
            ? SubscriptionTabPage(isRefreshing: _isRefreshing)
            : ProfileTabPage(profile: _profile);
        break;

      case 2:
        _dynamicSliverContent = ProfileTabPage(profile: _profile);
        break;

      default:
        _dynamicSliverContent = TimelineTabPage(
            userId: _profile.userId, isRefreshing: _isRefreshing);
        break;
    }

    return _dynamicSliverContent;
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: _buildProfileFAB(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isRefreshing = true);
          if (_currentDisplayedPageIndex == 0) {
            await _postBloc.fetchProfilePosts(userId: _profile.userId);
          } else if (_currentDisplayedPageIndex == 1) {
            await _profileBloc.fetchUserProfileSubscriptions();
          }
          setState(() => _isRefreshing = false);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            _buildSliverAppBar(context, _deviceHeight, _deviceWidth),
            _buildDynamicSliverContent(),
          ],
        ),
      ),
    );
  }
}
