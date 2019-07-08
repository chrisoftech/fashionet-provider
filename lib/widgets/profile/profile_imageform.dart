import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:flutter/services.dart';

class ProfileImageForm extends StatefulWidget {
  @override
  _ProfileImageFormState createState() => _ProfileImageFormState();
}

class _ProfileImageFormState extends State<ProfileImageForm> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  Future<void> deleteAssets() async {
    await MultiImagePicker.deleteImages(assets: images);
    setState(() {
      images = List<Asset>();
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 1,
          enableCamera: true,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#abcdef",
            actionBarTitle: "FashioNet",
            allViewTitle: "All Photos",
            selectCircleStrokeColor: "#000000",
          ));
    } on PlatformException catch (e) {
      error = e.message;
      print(e.message);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      // if (images.isNotEmpty) _onUploadProfileImage(images[0]);
      _error = error;
    });
  }

  Widget _buildDisplayedImage() {
    if (images.isEmpty) {
      return Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Image.asset('assets/avatars/ps-avatar.png', fit: BoxFit.cover),
        ),
      );
    } else {
      Asset asset = images[0];
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        ),
      );
    }
  }

  Widget _buildStackOverlayIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          images.isEmpty ? Icons.camera_alt : Icons.refresh,
          color: Colors.white24,
          size: 70.0,
        ),
      ),
    );
  }

  Widget _buildImageContainer() {
    return InkWell(
      splashColor: Colors.yellow,
      borderRadius: BorderRadius.circular(100.0),
      onTap: loadAssets,
      child: Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(width: 2.0, color: Colors.white70),
        ),
        child: Stack(
          children: <Widget>[
            _buildDisplayedImage(),
            _buildStackOverlayIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage({@required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.info,
          color: Theme.of(context).accentColor,
        ),
        SizedBox(width: 5.0),
        Text(
          'Select a profile avatar',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          height: 250.0,
          width: 400.0,
          child: Column(
            children: <Widget>[
              _buildImageContainer(),
              SizedBox(height: 20.0),
              _buildImageMessage(context: context),
            ],
          ),
        ),
      ),
    );
  }
}
