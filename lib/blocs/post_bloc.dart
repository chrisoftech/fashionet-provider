import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

enum PostState { Default, Loading, Success, Failure }

class PostBloc with ChangeNotifier {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final ImageRepository _imageRepository;

  PostState _postState = PostState.Default;

  PostBloc.instance()
      : _postRepository = PostRepository(),
        _authBloc = AuthBloc.instance(),
        _imageRepository = ImageRepository();

  PostState get postState => _postState;

  Future<List<String>> _uploadPostImage(
      {@required String userId, @required List<Asset> assets}) async {
    try {
      final String fileLocation = '$userId/posts';

      final List<String> imageUrls = await _imageRepository.uploadPostImages(
          fileLocation: fileLocation, assets: assets);

      print('Image uploaded ${imageUrls.toList()}');
      return imageUrls;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> createPost(
      {@required List<Asset> assets,
      @required String title,
      @required String description,
      @required double price,
      @required bool isAvailable,
      @required List<String> categories}) async {
    try {
      _postState = PostState.Loading;
      notifyListeners();

      final String userId = await _authBloc.getUser;

      final List<String> _imageUrls =
          await _uploadPostImage(userId: userId, assets: assets);

      final DocumentReference _reference = await _postRepository.createPost(
        imageUrls: _imageUrls,
        userId: userId,
        title: title,
        description: description,
        price: price,
        isAvailable: isAvailable,
        categories: categories,
      );

      print(_reference.documentID);

      // await Future.delayed(Duration(seconds: 5));

      _postState = PostState.Success;
      notifyListeners();

      return true;
    } catch (e) {
      print(e.toString());
      _postState = PostState.Failure;
      notifyListeners();

      return false;
    }
  }
}
