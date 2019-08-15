import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/modules/modules.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PopupMenu _menu;
  GlobalKey _menuButtonKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final PanelController _panelController = PanelController();

  Color get _primaryColor => Theme.of(context).primaryColor;

  // CategoryBloc _categoryBloc;

  int _activePageIndex = 0;
  final _pageController = PageController(initialPage: 0, keepPage: false);
  PageView _pageView;

  bool _isPined = true;
  bool _isFavorite = false;

  ProfileBloc _profileBloc;
  PostBloc _postBloc;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // initializing menu
    _openCustomMenu();

    _profileBloc = Provider.of<ProfileBloc>(context, listen: false);
    _postBloc = Provider.of<PostBloc>(context, listen: false);

    _onWidgetDidBuild(() {
      _profileBloc.fetchUserProfileSubscriptions();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.orange, Colors.indigo],
  ).createShader(new Rect.fromLTWH(0.0, 0.0, 250.0, 70.0));

  void _openCategoryModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Categories();
        });
  }

  void onClickMenu(MenuItemProvider item) {
    print('Click menu -> ${item.menuTitle}');
    if (item.menuTitle == 'Profile') {
      Navigator.of(context).pushNamed('/user-profile');
    } else if (item.menuTitle == 'Categories') {
      _openCategoryModal();
    }
  }

  void onDismiss() {
    print('Menu is closed');
  }

  void _openCustomMenu() {
    _menu = PopupMenu(
        // backgroundColor: Theme.of(context).primaryColor,
        // lineColor: Theme.of(context).accentColor,
        maxColumn: 1,
        items: [
          MenuItem(
              title: 'Profile',
              image: Icon(
                Icons.person_outline,
                color: Colors.white,
              )),
          MenuItem(
              title: 'Categories',
              image: Icon(
                Icons.category,
                color: Colors.white,
              )),
          MenuItem(
              title: 'Settings',
              image: Icon(
                Icons.settings,
                color: Colors.white,
              )),
          MenuItem(
              title: 'Signout',
              image: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              )),
        ],
        onClickMenu: onClickMenu,
        onDismiss: onDismiss);
    // _menu.show(widgetKey: _menuButtonKey);
  }

  Widget _buildAppbarActionWidgets(
      {@required BuildContext context,
      @required int index,
      @required IconData icon}) {
    return InkWell(
      key: index == 1 ? _menuButtonKey : null,
      onTap: () {
        if (index == 0) {
          Navigator.of(context).pushNamed('/search');
        } else if (index == 1) {
          // _openCustomMenu();
          _menu.show(widgetKey: _menuButtonKey);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Icon(
          icon,
          size: 30.0,
          color: _primaryColor,
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          size: 30.0,
          color: _primaryColor,
        ),
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
      ),
      title: Text(
        'FashionNet',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            foreground: new Paint()..shader = linearGradient),
      ),
      actions: <Widget>[
        _buildAppbarActionWidgets(
            context: context, index: 0, icon: Icons.search),
        _buildAppbarActionWidgets(
            context: context, index: 1, icon: Icons.more_vert),
        SizedBox(width: 10.0)
        // _buildAppBarMenuPopUp(),
      ],
    );
  }

  Container _buildPageBody(double _deviceHeight, double _deviceWidth) {
    return Container(
      height: _deviceHeight,
      width: _deviceWidth,
      child: Column(
        children: <Widget>[
          CategoryNavBar(
            onActiveCategoryChange: (String categoryId) {
              print(categoryId);
            },
          ),
          SizedBox(height: 10.0),
          _isPined
              ? Flexible(child: LatestPosts(isRefreshing: _isRefreshing))
              : Container(),
          Flexible(
            child: SuggestedPosts(
              isPined: _isPined,
              isFavorite: _isFavorite,
              onExpandSuggestedPostsToggle: (bool isPined) {
                setState(() => _isPined = isPined);
              },
              onIsFavoriteToggle: (bool isFavorite) {
                setState(() => _isFavorite = isFavorite);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _floatingCollapsed() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        // color: Colors.blueGrey,
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
        child: PostForm(key: _postBloc.postFormKey, scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Future<bool> _showExitAlertDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Close Application'),
            content: Text('Are you sure of exiting FASHIONet?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                  child: Text('Exit'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double _deviceHeight = MediaQuery.of(context).size.height;
    double _deviceWidth = MediaQuery.of(context).size.width;

    final AuthBloc _authBloc = Provider.of<AuthBloc>(context);
    // PopupMenu.context = context;

    _pageView = PageView(
      controller: _pageController,
      onPageChanged: (int index) async {
        setState(() {
          _activePageIndex = index;

          _isRefreshing = true;
        });

        if (index == 0) {
          await _profileBloc.fetchUserProfileSubscriptions();
        }
        setState(() => _isRefreshing = false);
      },
      children: <Widget>[
        _buildPageBody(_deviceHeight, _deviceWidth),
        FeedPage(),
        BookmarkPage(),
      ],
    );

    return WillPopScope(
      onWillPop: () {
        if (_panelController.isPanelOpen()) {
          _panelController.close();
          _menu.dismiss();
        } else {
          // _menu.dismiss();
          return _showExitAlertDialog();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(context),
        drawer: Drawer(
          child: Center(
            child: RaisedButton(
              child: Text('Logout'),
              onPressed: () => _authBloc.signout(),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          activeIndex: _activePageIndex,
          onActiveIndexChange: (int index) {
            setState(() {
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 500), curve: Curves.ease);
            });
            // setState(() => _pageController.jumpToPage(index));
          },
        ),
        body: Consumer<PostBloc>(
            builder: (BuildContext context, PostBloc postBloc, Widget child) {
          _postBloc = postBloc;
          return RefreshIndicator(
            onRefresh: () async {
              // setState(() => _isRefreshing = true);
              // await postBloc.fetchPosts();
              // await _profileBloc.fetchUserProfileFollowing();
              // setState(() => _isRefreshing = false);
            },
            child: SlidingUpPanel(
              minHeight: 50.0,
              renderPanelSheet: false,
              controller: _panelController,
              panel: _floatingPanel(),
              collapsed: _floatingCollapsed(),
              body: _pageView,
            ),
          );
        }),
      ),
    );
  }
}
