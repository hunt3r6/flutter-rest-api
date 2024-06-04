import 'package:flutter/material.dart';
import 'package:flutter_pemula/api/repository.dart';
import 'package:flutter_pemula/component/post_view.dart';
import 'package:flutter_pemula/model/post.dart';
import 'package:flutter_pemula/screen/add_edit_post_screen.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({
    super.key,
    required this.title,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  final Repository _apiService = Repository();

  final List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMorePosts();
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.fetchPosts(_currentPage);
      setState(() {
        _currentPage++;
        _posts.addAll(result['posts']);
        _hasMore = result['nextPageUrl'] != null;
      });
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.fetchPosts(_currentPage);
      setState(() {
        _currentPage++;
        _posts.addAll(result['posts']);
        _hasMore = result['nextPageUrl'] != null;
      });
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost(int postId) async {
    try {
      final response = await _apiService.deletePost(postId);
      if (response) {
        setState(() {
          _posts.removeWhere((post) => post.id == postId);
        });
        _loadMorePosts();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _buildPostList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditPostScreen(),
            ),
          );
          if (result == true) {
            _currentPage = 1;
            _posts.clear();
            _hasMore = true;
            _loadPosts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _posts.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final post = _posts[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card.filled(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                // Todo action ke detail post
              },
              child: Stack(
                children: [
                  PostView(post: post),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditPostScreen(post: post),
                          ),
                        );

                        if (result == true) {
                          _currentPage = 1;
                          _posts.clear();
                          _hasMore = true;
                          _loadPosts();
                        }
                      },
                      icon: const Icon(Icons.edit_rounded),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: IconButton(
                      onPressed: () => _deletePost(post.id),
                      icon: const Icon(Icons.delete_rounded),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
