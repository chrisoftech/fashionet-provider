import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfilePage extends StatefulWidget {
  final Profile userProfile;

  const ProfilePage({Key key, this.userProfile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PopupMenu _menu;
  GlobalKey _menuButtonKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final PanelController _panelController = PanelController();

  int _currentDisplayedPageIndex = 0;
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  Profile get _profile => widget.userProfile;
  bool _isCurrentUserProfile = false;

  ProfileBloc _profileBloc;
  PostBloc _postBloc;
  // PostEditBloc _postEditBloc;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _profileBloc = Provider.of<ProfileBloc>(context, listen: false);
    _postBloc = Provider.of<PostBloc>(context, listen: false);
    // _postEditBloc = Provider.of<PostEditBloc>(context, listen: false);

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

  void onClickMenu(MenuItemProvider item) {
    print('Click menu -> ${item.menuTitle}');
  }

  void onDismiss() {
    print('Menu is closed');
  }

  void _openCustomMenu() {
    _menu = PopupMenu(
        maxColumn: 1,
        items: [
          MenuItem(
              title: 'Boost Ad',
              image: Icon(
                Icons.poll,
                color: Colors.white,
              )),
          MenuItem(
              title: 'Statistics',
              image: Icon(
                Icons.timeline,
                color: Colors.white,
              )),
        ],
        onClickMenu: onClickMenu,
        onDismiss: onDismiss);
    _menu.show(widgetKey: _menuButtonKey);
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
        IconButton(
            key: _menuButtonKey,
            icon: Icon(Icons.more_vert),
            onPressed: _openCustomMenu),
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
        Icons.call,
        size: 30.0,
        color: Colors.white,
      ),
      onPressed: () {
        print('call ${_profile.firstName}');
        // Navigator.of(context).pushNamed('/post-form');
      },
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

  Widget _floatingCollapsed() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
      ),
      child: Center(
        child: Text(
          'Slide up to post item',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _floatingPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 24.0, right: 24.0, left: 24.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ]),
      child: Container(
        margin: EdgeInsets.only(top: 25.0),
        child: PostForm(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Widget _buildCustomScrollView(
      {@required double deviceHeight, @required deviceWidth}) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        _buildSliverAppBar(context, deviceHeight, deviceWidth),
        _buildDynamicSliverContent(),
      ],
    );
  }

  Widget _buildSlideUpPanel(
      {@required double deviceHeight, @required deviceWidth}) {
    return SlidingUpPanel(
        minHeight: 50.0,
        renderPanelSheet: false,
        controller: _panelController,
        panel: _floatingPanel(),
        collapsed: _floatingCollapsed(),
        body: _buildCustomScrollView(
            deviceHeight: deviceHeight, deviceWidth: deviceWidth));
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        if (_panelController.isPanelOpen()) {
          _panelController.close();
          _menu.dismiss();
        } else {
          // _menu.dismiss();
          return true;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        floatingActionButton:
            _isCurrentUserProfile ? Container() : _buildProfileFAB(),
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
          child: _isCurrentUserProfile
              ? _buildSlideUpPanel(
                  deviceHeight: _deviceHeight, deviceWidth: _deviceWidth)
              : _buildCustomScrollView(
                  deviceHeight: _deviceHeight, deviceWidth: _deviceWidth),
        ),
      ),
    );
  }
}
