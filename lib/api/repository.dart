import 'dart:convert';
import 'dart:io';
import 'package:flutter_pemula/model/post.dart';
import 'package:http/http.dart' as http;

class Repository {
  final baseUrl = 'http://192.168.1.6:8080/api';

  //get data with metode async
  Future<Map<String, dynamic>> fetchPosts(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/posts?page=$page'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Post> posts = (data['data']['data'] as List)
          .map((postJson) => Post.fromJson(postJson))
          .toList();
      return {
        'posts': posts,
        'nextPageUrl': data['data']['next_page_url'],
      };
    } else {
      throw Exception('Failed to load data');
    }
  }

  //insert posts
  Future<bool> insertPost(File? image, String title, String content) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image!.path,
      ),
    );
    final response = await request.send();
    if (response.statusCode == 201) {
      return true;
    } else {
      throw false;
    }
  }

  //update post
  Future<bool> updatePost(
      File? image, String title, String content, int id) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/posts/$id'));
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['_method'] = 'PUT';
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw false;
    }
  }

  // delete post
  Future<bool> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw false;
    }
  }
}
