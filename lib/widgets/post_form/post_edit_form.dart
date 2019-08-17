import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/widgets/widgets.dart';
import 'package:flutter/material.dart';

class PostEditForm extends StatelessWidget {
  final Post post;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  PostEditForm({Key key, @required this.post})
      : _scaffoldKey = GlobalKey<ScaffoldState>(),
        super(key: key);

  Post get _post => post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PostForm(scaffoldKey: _scaffoldKey, post: _post),
    );
  }
}
