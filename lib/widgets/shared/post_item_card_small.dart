import 'package:flutter/material.dart';

class PostItemCardSmall extends StatelessWidget {
  final int postIndex;

  const PostItemCardSmall({Key key, @required this.postIndex})
      : super(key: key);

  int get _postIndex => postIndex;

  Widget _buildPostDetailsCard(
      {@required double postContainerHeight,
      @required double postContentContainerWidth,
      @required double deviceWidth}) {
    return Positioned(
      left: 15.0,
      bottom: 0.0,
      height: postContainerHeight,
      width: postContentContainerWidth,
      child: Card(
        child: Container(
          padding: EdgeInsets.only(left: deviceWidth * 0.18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/temp2.jpg'),
                  ),
                  title: Text('John Doe'),
                  subtitle: Text('May 22, 2019'),
                  trailing: IconButton(
                    tooltip: 'Like this post',
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      print('post isFavorite');
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text('Affordable Wears',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc dolor purus, isaculis ac dolor nec, laoreet imperdiet eros.',
                      overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    tooltip: 'Save this post',
                    icon: Icon(
                      Icons.bookmark_border,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      print('post isFavorite');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage(
      {@required double postContainerHeight,
      @required double postImageContainerWidth}) {
    return Positioned(
      top: 0.0,
      left: 0.0,
      height: postContainerHeight,
      width: postImageContainerWidth,
      child: Card(
        elevation: 5.0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/temp$_postIndex.jpg'))),
        ),
      ),
    );
  }

  Widget _buildCardStack(
      {@required double deviceWidth, @required double containerHeight}) {
    final double _postContentContainerWidth =
        deviceWidth * 0.85; // 85% of total device width.
    final double _postImageContainerWidth =
        deviceWidth * 0.25; // 25% of total device width.

    final double _postContainerHeight = containerHeight - 15.0;

    return Stack(
      children: <Widget>[
        _buildPostDetailsCard(
            postContainerHeight: _postContainerHeight,
            postContentContainerWidth: _postContentContainerWidth,
            deviceWidth: deviceWidth),
        _buildPostImage(
            postContainerHeight: _postContainerHeight,
            postImageContainerWidth: _postImageContainerWidth),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = MediaQuery.of(context).size.width;

    final double _containerHeight = 150.0;
    final double _containerWidth = _deviceWidth > 500.0
        ? 500.0
        : _deviceWidth * 0.90; // 90% of total device width.

    return Material(
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (BuildContext context) => PostDetailsPage()));
        },
        child: Container(
          height: _containerHeight,
          width: _containerWidth,
          child: _buildCardStack(
              deviceWidth: _deviceWidth, containerHeight: _containerHeight),
        ),
      ),
    );
  }
}
