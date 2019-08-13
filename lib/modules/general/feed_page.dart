import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/modules/utilities/utilities.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  PostBloc _postBloc;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      _postBloc.fetchMorePosts();
    }
  }

  Widget _buildSliverList({@required PostBloc postBloc}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return index >= postBloc.posts.length
              ? BottomLoader()
              : PostItemCardDefault(post: postBloc.posts[index]);
        },
        childCount: postBloc.morePostsAvailable
            ? postBloc.posts.length + 1
            : postBloc.posts.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PostBloc>(
          builder: (BuildContext context, PostBloc postBloc, Widget child) {
        _postBloc = postBloc;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _isRefreshing = true);
            await postBloc.fetchPosts();
            setState(() => _isRefreshing = false);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              _isRefreshing
                  ? _buildSliverList(postBloc: postBloc)
                  : postBloc.postState == PostState.Loading
                      ? SliverToBoxAdapter(
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 50.0),
                              _isRefreshing
                                  ? Container()
                                  : CircularProgressIndicator(),
                            ],
                          ),
                        )
                      : postBloc.posts.length == 0
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
                                      postBloc.fetchPosts();
                                    },
                                  ),
                                  Text('No Post(s) Loaded'),
                                ],
                              ),
                            )
                          : _buildSliverList(postBloc: postBloc),
              SliverToBoxAdapter(
                child: SizedBox(height: 160.0),
              )
            ],
          ),
        );
      }),
    );
  }
}
