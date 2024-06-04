// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_pemula/api/repository.dart';
import 'package:flutter_pemula/model/post.dart';

class AddEditPostScreen extends StatefulWidget {
  final Post? post;
  const AddEditPostScreen({
    super.key,
    this.post,
  });

  @override
  State<AddEditPostScreen> createState() => _AddEditPostScreenState();
}

class _AddEditPostScreenState extends State<AddEditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();
  File? _image;
  final picker = ImagePicker();
  final Repository apiService = Repository();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Image Selected')),
        );
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
    }
    super.initState();
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      bool success = false;
      if (widget.post != null) {
        success = await apiService.updatePost(
          _image,
          _titleController.text,
          _contentController.text,
          widget.post!.id,
        );
      } else if (_image != null) {
        success = await apiService.insertPost(
          _image,
          _titleController.text,
          _contentController.text,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please Insert Image'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (!mounted) return;
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to Create Post')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.post == null ? 'Add New Post' : 'Edit Post'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: _image == null
                      ? const Text('No Image Selected')
                      : Image.file(
                          _image!,
                          height: 200,
                          width: 200,
                        ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextButton(
                  onPressed: getImage,
                  child: const Text('Selected Image'),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {},
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Insert Title';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _contentController,
                  focusNode: _contentFocus,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Insert Some Text';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _submitData(),
                    child: Text(widget.post == null ? 'Submit' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
