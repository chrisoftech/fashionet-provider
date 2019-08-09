import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscriptionTabPage extends StatelessWidget {
  Widget _buildSliverList({@required ProfileBloc profileBloc}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return ProfileSubscriptionCard(
            profile: profileBloc.profileFollowing[index]);
      }, childCount: profileBloc.profileFollowing.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileBloc>(
        builder: (BuildContext context, ProfileBloc profileBloc, Widget child) {
      return profileBloc.profileFollowingState == ProfileState.Loading
          ? SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50.0),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : profileBloc.profileFollowing.length == 0
              ? SliverToBoxAdapter(
                  child: Column(
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
                      Text('Sorry! You are not subsribed to any page :('),
                    ],
                  ),
                )
              : _buildSliverList(profileBloc: profileBloc);
    });
  }
}
