import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashionet_provider/blocs/blocs.dart';
import 'package:fashionet_provider/models/models.dart';
import 'package:fashionet_provider/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

enum PostState { Default, Loading, Success, Failure }

class PostBloc with ChangeNotifier {
  final PostRepository _postRepository;
  final AuthBloc _authBloc;
  final ImageRepository _imageRepository;
  final ProfileBloc _profileBloc;

  PostState _postState = PostState.Default;

  List<Post> _posts = [];
  bool _morePostsAvailable = true;
  bool _fetchingMorePosts = false;

  PostBloc.instance()
      : _postRepository = PostRepository(),
        _authBloc = AuthBloc.instance(),
        _imageRepository = ImageRepository(),
        _profileBloc = ProfileBloc.instance() {
    fetchPosts();
  }

  // getters
  PostState get postState => _postState;
  List<Post> get posts => _posts;
  bool get morePostsAvailable => _morePostsAvailable;
  bool get fetchingMorePosts => _fetchingMorePosts;

  // methods
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

  Future<void> fetchPosts() async {
    try {
      _postState = PostState.Loading;
      notifyListeners();

      QuerySnapshot _snapshot =
          await _postRepository.fetchPosts(lastVisiblePost: null);

      List<Post> posts = [];

      _snapshot.documents.forEach((DocumentSnapshot document) async {
        final String _postId = document.documentID;
        final String _userId = document.data['userId'];

        // fetch user for current post
        final Profile _profile =
            await _profileBloc.fetchProfile(userId: _userId);

        // print(_profile.firstName);

        final _post = Post(
            userId: _userId,
            postId: _postId,
            title: document.data['title'],
            description: document.data['description'],
            price: document.data['price'],
            isAvailable: document.data['isAvailable'],
            imageUrls: document.data['imageUrls'],
            categories: document.data['categories'],
            created: document.data['created'],
            lastUpdate: document.data['lastUpdate'],
            profile: _profile);

        posts.add(_post);
      });

      _posts = posts;

      _postState = PostState.Success;
      notifyListeners();

      return;
    } catch (e) {
      print(e.toString());

      _postState = PostState.Failure;
      notifyListeners();
      return;
    }
  }

  Future<void> fetchMorePosts() async {
    try {
      final List<Post> currentPosts = _posts;

      final Post lastVisiblePost = currentPosts[currentPosts.length - 1];

      if (_fetchingMorePosts == true) {
        print('Fetching more categories!');
        return;
      }

      _morePostsAvailable = true;
      _fetchingMorePosts = true;
      notifyListeners();

      final QuerySnapshot _snapshot =
          await _postRepository.fetchPosts(lastVisiblePost: lastVisiblePost);

      if (_snapshot.documents.length < 1) {
        _morePostsAvailable = false;
        _fetchingMorePosts = false;
        notifyListeners();

        print('No more post available!');
        return;
      }

      List<Post> posts = [];

      _snapshot.documents.forEach((DocumentSnapshot document) async {
        final String _postId = document.documentID;
        final String _userId = document.data['userId'];

        // fetch user for current post
        final Profile _profile =
            await _profileBloc.fetchProfile(userId: _userId);

        // print(_profile.firstName);

        final _post = Post(
          userId: _userId,
          postId: _postId,
          title: document.data['title'],
          description: document.data['description'],
          price: document.data['price'],
          isAvailable: document.data['isAvailable'],
          imageUrls: document.data['imageUrls'],
          categories: document.data['categories'],
          created: document.data['created'],
          lastUpdate: document.data['lastUpdate'],
          profile: _profile,
        );

        posts.add(_post);
      });

      posts.isEmpty ? _posts = currentPosts : _posts += posts;

      _fetchingMorePosts = false;
      notifyListeners();

      return;
    } catch (e) {
      print(e.toString());

      _fetchingMorePosts = false;
      return;
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
