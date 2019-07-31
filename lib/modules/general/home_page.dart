import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/modules/modules.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:fashionet_provider/consts/const.dart' as consts;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController _panelController = PanelController();

  Color get _primaryColor => Theme.of(context).primaryColor;

  // CategoryBloc _categoryBloc;

  int _activePageIndex = 0;
  final _pageController = PageController(initialPage: 0, keepPage: false);
  PageView _pageView;

  bool _isPined = true;
  bool _isFavorite = false;

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
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

  Widget _buildAppbarActionWidgets(
      {@required BuildContext context,
      @required int index,
      @required IconData icon}) {
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.of(context).pushNamed('/search');
        } else if (index == 1) {
          Navigator.of(context).pushNamed('/profile');
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

  void _menuChoiceAction(String menuChoice) {
    print(menuChoice);
    if (menuChoice == 'Categories') {
      _openCategoryModal();
      // _navigateToCatgoryPage();
      return;
    }
  }

  Widget _buildAppBarMenuPopUp() {
    return PopupMenuButton<String>(
        onSelected: _menuChoiceAction,
        icon: Icon(Icons.more_vert, size: 30.0, color: _primaryColor),
        itemBuilder: (BuildContext context) {
          return consts.menuOptions.map((MenuOption option) {
            return PopupMenuItem(
              value: option.menuOption,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Icon(option.icon),
                  // SizedBox(width: 10.0),
                  Text(option.menuOption),
                ],
              ),
            );
          }).toList();
        });
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
            context: context, index: 1, icon: Icons.person_outline),
        _buildAppBarMenuPopUp(),
      ],
    );
  }

  Container _buildPageBody(double _deviceHeight, double _deviceWidth) {
    return Container(
      height: _deviceHeight,
      width: _deviceWidth,
      child: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          CategoryNavBar(
            onActiveCategoryChange: (String categoryId) {
              print(categoryId);
            },
          ),
          SizedBox(height: 10.0),
          _isPined ? LatestPosts() : Container(),
          SuggestedPosts(
            isPined: _isPined,
            isFavorite: _isFavorite,
            onExpandSuggestedPostsToggle: (bool isPined) {
              setState(() => _isPined = isPined);
            },
            onIsFavoriteToggle: (bool isFavorite) {
              setState(() => _isFavorite = isFavorite);
            },
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
        child: PostForm(scaffoldKey: _scaffoldKey),
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
    // _categoryBloc = Provider.of<CategoryBloc>(context);

    _pageView = PageView(
      controller: _pageController,
      onPageChanged: (int index) {
        print('page changed to $index');
        setState(() => _activePageIndex = index);
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
        } else {
          _showExitAlertDialog();
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
                  duration: Duration(milliseconds: 1000), curve: Curves.ease);
            });
            // setState(() => _pageController.jumpToPage(index));
          },
        ),
        body: SlidingUpPanel(
          minHeight: 50.0,
          renderPanelSheet: false,
          controller: _panelController,
          panel: _floatingPanel(),
          collapsed: _floatingCollapsed(),
          body: _pageView,
        ),
      ),
    );
  }
}
