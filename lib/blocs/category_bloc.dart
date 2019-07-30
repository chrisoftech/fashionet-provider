import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

enum CategoryState { Default, Loading, Success, Failure }
// enum CategoryFetchState { Default, Loaded, Failure }

class CategoryBloc with ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final AuthBloc _authBloc;
  final ImageRepository _imageRepository;

  CategoryState _categoryState = CategoryState.Default;
  // CategoryFetchState _categoryFetchState = CategoryFetchState.Default;

  List<PostCategory> _postCategories = [];
  bool _moreCategoriesAvailable = true;
  bool _fetchingMoreCategories = false;

  CategoryBloc.instance()
      : _categoryRepository = CategoryRepository(),
        _authBloc = AuthBloc.instance(),
        _imageRepository = ImageRepository() {
    fetchCategories();
  }

  // getters
  CategoryState get categoryState => _categoryState;
  List<PostCategory> get postCategories => _postCategories;
  bool get moreCategoriesAvailable => _moreCategoriesAvailable;
  bool get fetchingMoreCategories => _fetchingMoreCategories;

  Future<void> fetchCategories() async {
    try {
      _categoryState = CategoryState.Loading;
      notifyListeners();

      QuerySnapshot _snapshot =
          await _categoryRepository.fetchCategories(lastVisiblePostCategory: null);

      List<PostCategory> _categories = [];

      _snapshot.documents.forEach((DocumentSnapshot document) {
        final String _categoryId = document.documentID;

        final _category = PostCategory(
          userId: document.data['userId'],
          categoryId: _categoryId,
          title: document.data['title'],
          description: document.data['description'],
          imageUrl: document.data['imageUrl'],
          created: document.data['created'],
          lastUpdate: document.data['lastUpdate'],
        );

        _categories.add(_category);
      });

      _postCategories = _categories;

      _categoryState = CategoryState.Success;
      notifyListeners();

      return;
    } catch (e) {
      print(e.toString());

      _categoryState = CategoryState.Failure;
      notifyListeners();
      return;
    }
  }

  Future<void> fetchMoreCategories() async {
    try {
      final List<PostCategory> currentCategories = _postCategories;

      final PostCategory lastVisiblePostCategory =
          currentCategories[currentCategories.length - 1];

      if (_fetchingMoreCategories == true) {
        print('Fetching more categories!');
        return;
      }

      _moreCategoriesAvailable = true;
      _fetchingMoreCategories = true;
      notifyListeners();

      final QuerySnapshot _snapshot = await _categoryRepository.fetchCategories(
          lastVisiblePostCategory: lastVisiblePostCategory);

      if (_snapshot.documents.length < 1) {
        _moreCategoriesAvailable = false;
        _fetchingMoreCategories = false;
        notifyListeners();

        print('No more post category available!');
        return;
      }

      List<PostCategory> _categories = [];

      _snapshot.documents.forEach((DocumentSnapshot document) {
        final String _categoryId = document.documentID;

        final _category = PostCategory(
          userId: document.data['userId'],
          categoryId: _categoryId,
          title: document.data['title'],
          description: document.data['description'],
          imageUrl: document.data['imageUrl'],
          created: document.data['created'],
          lastUpdate: document.data['lastUpdate'],
        );

        _categories.add(_category);
      });

      _categories.isEmpty
          ? _postCategories = currentCategories
          : _postCategories += _categories;

      _fetchingMoreCategories = false;
      notifyListeners();

      return;
    } catch (e) {
      print(e.toString());

      _fetchingMoreCategories = false;
      return;
    }
  }

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
