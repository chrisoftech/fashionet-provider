import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LatestPosts extends StatelessWidget {
  final bool isRefreshing;

  const LatestPosts({Key key, @required this.isRefreshing}) : super(key: key);

  bool get _isRefreshing => isRefreshing;

  Widget _buildListView(
      {@required ProfileBloc profileBloc, @required double deviceWidth}) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ListView.builder(
        padding: EdgeInsets.only(left: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: ProfileBloc.latestFollowingProfilePost.length,
        // itemCount: profileBloc.latestFollowingProfilePost.length,
        itemBuilder: (BuildContext context, int index) {
          return PostItemCardLarge(
              post: ProfileBloc.latestFollowingProfilePost[index],
              // post: profileBloc.latestFollowingProfilePost[index],
              postIndex: index,
              constraints: constraints,
              deviceWidth: deviceWidth);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double _deviceWidth = MediaQuery.of(context).size.width;

    // print('isLoading $_isRefreshing');

    return Consumer(
      builder: (BuildContext context, ProfileBloc profileBloc, Widget child) {
        // print('isLoading ${profileBloc.latestFollowingProfilePost.length}');
        return _isRefreshing
            ? _buildListView(
                profileBloc: profileBloc, deviceWidth: _deviceWidth)
            : profileBloc.profileFollowingState == ProfileState.Loading
                ? Column(
                    children: <Widget>[
                      SizedBox(height: 50.0),
                      _isRefreshing ? Container() : CircularProgressIndicator(),
                    ],
                  )
                : ProfileBloc.latestFollowingProfilePost.length == 0
                    // : profileBloc.latestFollowingProfilePost.length == 0
                    ? Column(
                        children: <Widget>[
                          SizedBox(height: 50.0),
                          FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.refresh),
                                Text('refresh'),
                              ],
                            ),
                            onPressed: () {
                              profileBloc.fetchUserProfileFollowing();
                            },
                          ),
                          Text('Sorry, you are yet to subscribe to a post :('),
                        ],
                      )
                    : _buildListView(
                        profileBloc: profileBloc, deviceWidth: _deviceWidth);
      },
    );
  }
}
