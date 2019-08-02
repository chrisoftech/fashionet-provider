import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarkPage extends StatelessWidget {
  Widget _buildSliverList({@required PostBloc postBloc}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext contex, int index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PostItemCardSmall(
                bookmarkPost: postBloc.bookmarkedPosts[index],
              ),
            ],
          );
        },
        childCount: postBloc.bookmarkedPosts.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final PostBloc _postBloc = Provider.of<PostBloc>(context);

    return Scaffold(
      body: Consumer<PostBloc>(
          builder: (BuildContext context, PostBloc postBloc, Widget child) {
        return CustomScrollView(
          slivers: <Widget>[
            postBloc.bookmarkPostState == PostState.Loading
                ? SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 50.0),
                        CircularProgressIndicator(),
                      ],
                    ),
                  )
                : postBloc.bookmarkedPosts.length == 0
                    ? SliverToBoxAdapter(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 50.0),
                            Text('No Post(s) Loaded'),
                          ],
                        ),
                      )
                    : _buildSliverList(postBloc: postBloc),
            SliverToBoxAdapter(
              child: SizedBox(height: 170.0),
            )
          ],
        );
      }),
    );
  }
}
