import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openCategoryFormDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CategoryForm(scaffoldKey: _scaffoldKey);
      },
    );
  }

  Widget _buildCategoryCard({@required int index}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/temp$index.jpg'),
        ),
        title: Text('Category name $index'),
        subtitle: Text(
          'Laboris reprehenderit velit excepteur excepteur cupidatat aliquip ex esse dolore id dolore. Ut do quis magna labore magna pariatur aliquip veniam nisi dolore culpa reprehenderit minim. Ipsum proident nisi consequat magna nostrud consectetur. Do irure consequat mollit nulla magna eiusmod occaecat.',
          textAlign: TextAlign.justify,
        ),
        trailing: Material(
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            onTap: () {
              print('Edited category $index');
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

  Widget _buildSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _buildCategoryCard(index: index);
        },
        childCount: 9,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            title: Text('Categories',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold)),
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
          ),
          _buildSliverList(),
        ],
      ),
    );
  }
}
