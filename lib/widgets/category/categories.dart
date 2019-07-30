import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/modules/utilities/utilities.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:provider/provider.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  CategoryBloc _categoryBloc;

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
      _categoryBloc.fetchMoreCategories();
    }
  }

  void _openCategoryFormDialog() {
    showDialog(
        context: context, builder: (BuildContext context) => CategoryForm());
  }

  Widget _buildCategoryCard({@required PostCategory category}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage('${category.imageUrl}'),
        ),
        title: Text('${category.title}'),
        subtitle: Text(
          '${category.description}',
          textAlign: TextAlign.justify,
        ),
        trailing: Material(
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            onTap: () {
              print('Edited category ${category.title}');
            },
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      title: Text('Categories',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white70,
      actions: <Widget>[
        Material(
          color: Colors.black12,
          child: InkWell(
            onTap: _openCategoryFormDialog,
            radius: 20.0,
            borderRadius: BorderRadius.circular(20.0),
            splashColor: Colors.black38,
            child: Container(
              height: 40.0,
              width: 80.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverList({@required CategoryBloc categoryBloc}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return index >= categoryBloc.postCategories.length
              ? BottomLoader()
              : _buildCategoryCard(
                  category: categoryBloc.postCategories[index]);
        },
        childCount: categoryBloc.moreCategoriesAvailable
            ? categoryBloc.postCategories.length + 1
            : categoryBloc.postCategories.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Consumer<CategoryBloc>(builder:
            (BuildContext context, CategoryBloc categoryBloc, Widget child) {
          _categoryBloc = categoryBloc;

          return CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              _buildSliverAppBar(),
              categoryBloc.categoryState == CategoryState.Loading
                  ? SliverToBoxAdapter(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          CircularProgressIndicator(),
                        ],
                      ),
                    )
                  : categoryBloc.postCategories.length == 0
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Text('No Categories'),
                          ),
                        )
                      : _buildSliverList(categoryBloc: categoryBloc),
            ],
          );
        }),
      ),
    );
  }
}
