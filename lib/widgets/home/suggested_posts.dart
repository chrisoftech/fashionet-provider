import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SuggestedPosts extends StatefulWidget {
  final bool isPined;
  final bool isFavorite;
  final Function(bool) onExpandSuggestedPostsToggle;
  final Function(bool) onIsFavoriteToggle;

  const SuggestedPosts(
      {Key key,
      this.isPined,
      this.isFavorite,
      @required this.onExpandSuggestedPostsToggle,
      @required this.onIsFavoriteToggle})
      : super(key: key);

  @override
  _SuggestedPostsState createState() => _SuggestedPostsState();
}

class _SuggestedPostsState extends State<SuggestedPosts> {
  bool _isPined;
  bool _isFavorite;

  Function(bool) get _onExpandSuggestedPostsToggle =>
      widget.onExpandSuggestedPostsToggle;

  Function(bool) get _onIsFavoriteToggle => widget.onIsFavoriteToggle;

  @override
  void initState() {
    _isPined = widget.isPined;
    _isFavorite = widget.isFavorite;
    super.initState();
  }

  void _togglePinSuggestedPostsView() {
    setState(() {
      _isPined = !_isPined;
      _onExpandSuggestedPostsToggle(_isPined);
    });
  }

  void _toggleIsFavoriteView() {
    setState(() {
      _isFavorite = !_isFavorite;
      _onIsFavoriteToggle(_isFavorite);
    });
  }

  Widget _buildSuggestedPostsTitleRow({@required BuildContext context}) {
    return Row(
      children: <Widget>[
        Text(
          'Suggested',
          style: TextStyle(
            fontSize: 23.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: <Widget>[
              Material(
                color: _isPined ? Colors.black12 : null,
                borderRadius: BorderRadius.circular(20.0),
                child: InkWell(
                  onTap: _togglePinSuggestedPostsView,
                  borderRadius: BorderRadius.circular(20.0),
                  splashColor: Theme.of(context).primaryColor,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(FontAwesomeIcons.thumbtack,
                        size: 20.0, color: Theme.of(context).accentColor),
                  ),
                ),
              ),
              SizedBox(width: 5.0),
              Container(
                height: 30.0,
                width: 2.0,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              Material(
                borderRadius: BorderRadius.circular(20.0),
                child: InkWell(
                  onTap: _toggleIsFavoriteView,
                  borderRadius: BorderRadius.circular(20.0),
                  splashColor: Colors.black38,
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20.0,
                        color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildSuggestedPostsTitleRow(context: context),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 9,
                  padding: EdgeInsets.only(bottom: 170.0),
                  itemBuilder: (BuildContext context, int index) {
                    final int postIndex = index == 0 ? 9 : index;

                    // return PostItemCardSmall(postIndex: postIndex);
                    return Container();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
