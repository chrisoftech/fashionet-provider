import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  bool _isRefreshing = false;

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
            
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _isRefreshing = true);
            await postBloc.fetchBookmarkedPosts();
            setState(() => _isRefreshing = false);
          },
          child: CustomScrollView(
            slivers: <Widget>[
              _isRefreshing
                  ? _buildSliverList(postBloc: postBloc)
                  : postBloc.bookmarkPostState == PostState.Loading
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
                                  FlatButton(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.refresh),
                                        Text('refresh'),
                                      ],
                                    ),
                                    onPressed: () {
                                      postBloc.fetchBookmarkedPosts();
                                    },
                                  ),
                                  Text('No Bookmarked Post(s) Loaded'),
                                ],
                              ),
                            )
                          : _buildSliverList(postBloc: postBloc),
              SliverToBoxAdapter(
                child: SizedBox(height: 170.0),
              )
            ],
          ),
        );
      }),
    );
  }
}
