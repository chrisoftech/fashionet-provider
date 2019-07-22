import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

enum CategoryState { Default, Loading, Success, Failure }

class CategoryBloc with ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final AuthBloc _authBloc;
  final ImageRepository _imageRepository;

  CategoryState _categoryState = CategoryState.Default;

  CategoryBloc.instance()
      : _categoryRepository = CategoryRepository(),
        _authBloc = AuthBloc.instance(),
        _imageRepository = ImageRepository();

  // getters
  CategoryState get categoryState => _categoryState;

  Future<bool> createCategory(
      {@required String title,
      @required String description,
      @required Asset asset}) async {
    try {
      _categoryState = CategoryState.Loading;
      notifyListeners();

      final String userId = await _authBloc.getUser;

      final String _imageUrl =
          await _imageRepository.uploadCategoryImage(asset: asset);

      await _categoryRepository.createCategory(
          imageUrl: _imageUrl,
          userId: userId,
          title: title,
          description: description);

      // print('_reference.documentID');

      // await Future.delayed(Duration(seconds: 5));

      _categoryState = CategoryState.Success;
      notifyListeners();

      return true;
    } catch (e) {
      print(e.toString);

      _categoryState = CategoryState.Failure;
      notifyListeners();

      return false;
    }
  }
}
