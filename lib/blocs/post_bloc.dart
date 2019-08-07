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
  final ProfileRepository _profileRepository;

  PostState _postState = PostState.Default;
  PostState _bookmarkPostState = PostState.Default;

  List<Post> _posts = [];
  List<Post> _bookmarkedPosts = [];
  bool _morePostsAvailable = true;
  bool _fetchingMorePosts = false;

  PostBloc.instance()
      : _postRepository = PostRepository(),
        _authBloc = AuthBloc.instance(),
        _imageRepository = ImageRepository(),
        _profileBloc = ProfileBloc.instance(),
        _profileRepository = ProfileRepository() {
    fetchPosts();
    fetchBookmarkedPosts();
  }

  // getters
  PostState get postState => _postState;
  PostState get bookmarkPostState => _bookmarkPostState;
  List<Post> get posts => _posts;
  List<Post> get bookmarkedPosts =>
      _bookmarkedPosts.where((Post post) => post.isBookmarked == true).toList();
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

  Future<Post> _getBookmarkPost({String postId}) async {
    final String _currentUserId = await _authBloc.getUser; // get current-user

    DocumentSnapshot _document = await _postRepository.getPost(postId: postId);

    print('Get bookmarkPost');

    final String _postId = _document.documentID;
    final String _userId = _document.data['userId'];

    await _profileBloc.fetchProfile(userId: _userId);

    final Profile _profile =
        _profileBloc.postProfile; // fetch user for current post

    final _post = Post(
      userId: _userId,
      postId: _postId,
      title: _document.data['title'],
      description: _document.data['description'],
      price: _document.data['price'],
      isAvailable: _document.data['isAvailable'],
      imageUrls: _document.data['imageUrls'],
      categories: _document.data['categories'],
      created: _document.data['created'],
      lastUpdate: _document.data['lastUpdate'],
      profile: _profile,
    );

    // get post bookmark status for current user
    final bool _isBookmarked = await _postRepository.isBookmarked(
        postId: _postId, userId: _currentUserId);

    // get post user following status for current user
    final bool _isFollowing = await _profileRepository.isFollowing(
        postUserId: _userId, userId: _currentUserId);

    // print('isBookmarked: ${document.documentID} $_isBookmarked');
    // print('isFollowing: ${document.documentID} $_isFollowing');

    return _post.copyWith(
        isBookmarked: _isBookmarked,
        profile: _profile.copyWith(isFollowing: _isFollowing));
  }

  Future<Post> _getPost({DocumentSnapshot document}) async {
    final String _currentUserId = await _authBloc.getUser; // get current-user

    DocumentSnapshot _document = document;

    print('Get post');

    final String _postId = _document.documentID;
    final String _userId = _document.data['userId'];

    await _profileBloc.fetchProfile(
        userId: _userId); // fetch user for current post

    final Profile _profile = _profileBloc.postProfile;

    final _post = Post(
      userId: _userId,
      postId: _postId,
      title: _document.data['title'],
      description: _document.data['description'],
      price: _document.data['price'],
      isAvailable: _document.data['isAvailable'],
      imageUrls: _document.data['imageUrls'],
      categories: _document.data['categories'],
      created: _document.data['created'],
      lastUpdate: _document.data['lastUpdate'],
      profile: _profile,
    );

    // get post bookmark status for current user
    final bool _isBookmarked = await _postRepository.isBookmarked(
        postId: _postId, userId: _currentUserId);

    // get post user following status for current user
    final bool _isFollowing = await _profileRepository.isFollowing(
        postUserId: _userId, userId: _currentUserId);

    return _post.copyWith(
        isBookmarked: _isBookmarked,
        profile: _profile.copyWith(isFollowing: _isFollowing));
  }

  Future<void> toggleBookmarkStatus({@required Post post}) async {
    final Post _recievedPost = post;

    final bool _bookmarkStatus = _recievedPost.isBookmarked;
    final bool _newBookmarkStatus = !_bookmarkStatus;

    final String _userId = await _authBloc.getUser;
    final String _postId = _recievedPost.postId;

    final Post _updatedPost = _recievedPost.copyWith(
        isBookmarked: _newBookmarkStatus); // update bookmark status

    final int _postIndex =
        _posts.indexWhere((Post post) => post.postId == _postId);

    _posts[_postIndex] =
        _updatedPost; // update post in List<post> (optimistic update) in _posts

    // update post in List<post> (optimistic update) in _bookmarkedPosts
    if (_newBookmarkStatus) {
      _bookmarkedPosts.insert(0, _updatedPost);
    } else {
      _bookmarkedPosts.removeWhere(
          (Post bookmarkedPost) => bookmarkedPost.postId == _postId);
    }
    notifyListeners();

    try {
      if (_newBookmarkStatus) {
        await _postRepository.addToBookmark(postId: _postId, userId: _userId);
      } else {
        await _postRepository.removeFromBookmark(
            postId: _postId, userId: _userId);
      }

      // set post bookmark in user collection
      await _profileBloc.togglePostBookmarkStatus(post: post, userId: _userId);

      return;
    } catch (e) {
      print(e.toString());

      final Post _updatedPost =
          _recievedPost.copyWith(isBookmarked: !_newBookmarkStatus);

      _posts[_postIndex] = _updatedPost;

      if (_newBookmarkStatus) {
        _bookmarkedPosts.removeWhere(
            (Post bookmarkedPost) => bookmarkedPost.postId == _postId);
      } else {
        _bookmarkedPosts.insert(0, _updatedPost);
      }
      notifyListeners();
    }
  }

  Future<void> toggleFollowProfilePageStatus(
      {@required Profile currentPostProfile}) async {
    final Profile _profile = currentPostProfile;
    final String _currentUserId = await _authBloc.getUser;

    final bool _followingStatus = _profile.isFollowing;
    final bool _newFollowingStatus = !_followingStatus;

    final Profile _updatedProfile =
        _profile.copyWith(isFollowing: _newFollowingStatus);

    final List<Post> _userPosts = _posts
        .where((Post post) => post.userId == currentPostProfile.userId)
        .toList(); // get all posts with current post userId

    _userPosts.forEach((Post post) {
      final String _postId = post.postId;
      final Post _updatedPost = post.copyWith(profile: _updatedProfile);

      final int _postIndex =
          _posts.indexWhere((Post post) => post.postId == _postId);

      _posts[_postIndex] = _updatedPost;
      notifyListeners();
    });

    try {
      if (_newFollowingStatus) {
        await _profileRepository.addToFollowers(
            postUserId: currentPostProfile.userId, userId: _currentUserId);
      } else {
        await _profileRepository.removeFromFollowers(
            postUserId: currentPostProfile.userId, userId: _currentUserId);
      }

      // set user following in user collection
      await _profileBloc.toggleFollowProfilePageStatus(
          profile: currentPostProfile);

      return;
    } catch (e) {
      print(e.toString());

      final Profile _updatedProfile =
          _profile.copyWith(isFollowing: !_newFollowingStatus);

      final List<Post> _userPosts = _posts
          .where((Post post) => post.userId == currentPostProfile.userId)
          .toList(); // get all posts with current post userId

      _userPosts.forEach((Post post) {
        final String _postId = post.postId;
        final Post _updatedPost = post.copyWith(profile: _updatedProfile);

        final int _postIndex =
            _posts.indexWhere((Post post) => post.postId == _postId);

        _posts[_postIndex] = _updatedPost;
        notifyListeners();
      });
    }
  }

  Future<void> fetchBookmarkedPosts() async {
    try {
      _bookmarkPostState = PostState.Loading;
      notifyListeners();

      final String _currentUserId = await _authBloc.getUser;
      QuerySnapshot _snapshot =
          await _profileRepository.fetchBookmarkedPosts(userId: _currentUserId);

      List<Post> posts = [];

      for (int i = 0; i < _snapshot.documents.length; i++) {
        final DocumentSnapshot document = _snapshot.documents[i];
        final String _postId = document.documentID;
        final Post _post = await _getBookmarkPost(postId: _postId);

        posts.add(_post);
      }

      _bookmarkedPosts = posts;

      _bookmarkPostState = PostState.Success;
      notifyListeners();
      return;
    } catch (e) {
      print(e.toString());

      _bookmarkPostState = PostState.Failure;
      notifyListeners();
    }
  }

  Future<void> fetchPosts() async {
    try {
      _postState = PostState.Loading;
      notifyListeners();

      QuerySnapshot _snapshot =
          await _postRepository.fetchPosts(lastVisiblePost: null);

      List<Post> posts = [];

      for (int i = 0; i < _snapshot.documents.length; i++) {
        print('post snapshot legth: ${_snapshot.documents.length}');
        final DocumentSnapshot document = _snapshot.documents[i];
        final Post _post = await _getPost(document: document);

        print('post $i: ${_post != null ? 'Exists' : 'Not Exist'}');

        posts.add(_post);
      }
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

      for (int i = 0; i < _snapshot.documents.length; i++) {
        final DocumentSnapshot document = _snapshot.documents[i];
        final Post _post = await _getPost(document: document);

        posts.add(_post);
      }

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

      await _postRepository.createPost(
        imageUrls: _imageUrls,
        userId: userId,
        title: title,
        description: description,
        price: price,
        isAvailable: isAvailable,
        categories: categories,
      );

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
