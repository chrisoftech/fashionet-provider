import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/modules/modules.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';

import 'widgets/widgets.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthBloc>.value(value: AuthBloc.instance()),
        ChangeNotifierProvider<ProfileBloc>.value(
            value: ProfileBloc.instance()),
        ChangeNotifierProvider<PostBloc>.value(value: PostBloc.instance()),
        ChangeNotifierProvider<CategoryBloc>.value(
            value: CategoryBloc.instance()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FashioNet',
        theme: ThemeData(
          fontFamily: 'QuickSand',
          primarySwatch: Colors.indigo,
          accentColor: Colors.orange,
        ),
        home: new DynamicInitialPage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomePage(),
          '/category-form': (BuildContext context) => CategoryForm(),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');

          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'post') {
            final String _postId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<PostBloc>(
                builder:
                    (BuildContext context, PostBloc postBloc, Widget child) {
                  final Post _post = postBloc.posts
                      .firstWhere((Post post) => post.postId == _postId);

                  return PostDetails(post: _post);
                },
              );
            });
          }

          if (pathElements[1] == 'bookmark') {
            final String _postId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<PostBloc>(
                builder:
                    (BuildContext context, PostBloc postBloc, Widget child) {
                  final Post _bookmarkedpost = postBloc.bookmarkedPosts
                      .firstWhere((Post post) => post.postId == _postId);

                  return PostDetails(post: _bookmarkedpost);
                },
              );
            });
          }

          // get the details of selected profile post in profile posts
          if (pathElements[1] == 'profile-post') {
            final String _postId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<PostBloc>(
                builder:
                    (BuildContext context, PostBloc postBloc, Widget child) {
                  final Post _post = postBloc.profilePosts
                      .firstWhere((Post post) => post.postId == _postId);

                  return PostDetails(post: _post);
                },
              );
            });
          }

          // get details of subscribed post from subscribedPosts
          if (pathElements[1] == 'subscribed-post') {
            final String _postId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<ProfileBloc>(
                builder: (BuildContext context, ProfileBloc profileBloc,
                    Widget child) {
                  final Post _post = ProfileBloc.latestProfileSubscriptionPosts
                      .firstWhere((Post post) => post.postId == _postId);

                  return PostDetails(post: _post);
                },
              );
            });
          }

          // get the profile of selected post in feed
          if (pathElements[1] == 'post-profile') {
            final String _postId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<PostBloc>(
                builder:
                    (BuildContext context, PostBloc postBloc, Widget child) {
                  final Post _post = postBloc.posts
                      .firstWhere((Post post) => post.postId == _postId);

                  return ProfilePage(userProfile: _post.profile);
                  // return ProfilePage(post: _post);
                },
              );
            });
          }

          // get the profile of selected post in bookmarked posts
          if (pathElements[1] == 'bookmarked-post-profile') {
            final String _postId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<PostBloc>(
                builder:
                    (BuildContext context, PostBloc postBloc, Widget child) {
                  final Post _post = postBloc.bookmarkedPosts
                      .firstWhere((Post post) => post.postId == _postId);

                  return ProfilePage(userProfile: _post.profile);
                },
              );
            });
          }

          // get the profile of selected post in subscribed posts
          if (pathElements[1] == 'subscribed-post-profile') {
            final String _postId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<ProfileBloc>(
                builder: (BuildContext context, ProfileBloc profileBloc,
                    Widget child) {
                  final Post _post = ProfileBloc.latestProfileSubscriptionPosts
                      .firstWhere((Post post) => post.postId == _postId);

                  return ProfilePage(userProfile: _post.profile);
                },
              );
            });
          }

          // get the profile of selected subscription in user profile
          if (pathElements[1] == 'subscribed-profile') {
            final String _profileId = pathElements[2];

            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<ProfileBloc>(
                builder: (BuildContext context, ProfileBloc profileBloc,
                    Widget child) {
                  final Profile _userProfile = profileBloc.profileSubscriptions
                      .firstWhere(
                          (Profile profile) => profile.userId == _profileId);

                  return ProfilePage(userProfile: _userProfile);
                },
              );
            });
          }

          // get the profile of current user
          if (pathElements[1] == 'user-profile') {
            return MaterialPageRoute(builder: (BuildContext context) {
              return Consumer<ProfileBloc>(
                builder: (BuildContext context, ProfileBloc profileBloc,
                    Widget child) {
                  final Profile _userProfile = profileBloc.userProfile;

                  return ProfilePage(userProfile: _userProfile);
                },
              );
            });
          }

          return null;
        },
      ),
    );
  }
}

class DynamicInitialPage extends StatefulWidget {
  @override
  _DynamicInitialPageState createState() => _DynamicInitialPageState();
}

class _DynamicInitialPageState extends State<DynamicInitialPage> {
  bool _hasProfile;

  Future<void> _getHasProfile({@required ProfileBloc profileBloc}) async {
    final bool hasProfile = await profileBloc.hasProfile;
    setState(() {
      _hasProfile = hasProfile;
    });
  }

  Widget _displayedAuthenticatedPage({@required ProfileBloc profileBloc}) {
    if (_hasProfile) {
      profileBloc.fetchUserProfile(); // fetch user profile
      return HomePage();
    } else {
      return ProfileForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    final ProfileBloc _profileBloc = Provider.of<ProfileBloc>(context);

    return Consumer<AuthBloc>(
      builder: (BuildContext context, AuthBloc authBloc, Widget child) {
        switch (authBloc.authState) {
          case AuthState.Uninitialized:
            return SplashPage();
          case AuthState.Authenticating:
          case AuthState.Authenticated:
            _getHasProfile(profileBloc: _profileBloc);
            // _loadFollowingProfileLatestPosts();

            return _hasProfile != null
                ? _displayedAuthenticatedPage(profileBloc: _profileBloc)
                : Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(child: CircularProgressIndicator()));

          case AuthState.Unauthenticated:
            return AuthPage();
          // return IntroPage();
        }
      },
    );
  }
}
