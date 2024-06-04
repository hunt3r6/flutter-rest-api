import 'package:flutter/material.dart';
import 'package:flutter_pemula/model/post.dart';

class PostView extends StatelessWidget {
  final Post post;

  const PostView({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.network(
          post.image,
          height: 150,
          width: 150,
          fit: BoxFit.cover,
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(post.content),
            ],
          ),
        )
      ],
    );
  }
}
