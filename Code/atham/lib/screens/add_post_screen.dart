import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atham/providers/user_provider.dart';
import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  final Uint8List file;
  final int postType;
  const AddPostScreen({Key? key, required this.file, required this.postType})
      : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  void postTodayImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await fireStoreMethods().uploadPostToday(
        _descriptionController.text,
        widget.file,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
        clearImage();
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
      clearImage();
    }
  }

  void postWhenImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await fireStoreMethods().uploadPostWhen(
        _descriptionController.text,
        widget.file,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
        clearImage();
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
      clearImage();
    }
  }

  void clearImage() {
    setState(() {
      //file = null;
      //postType = 0;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text(
          '게시물 올리기',
        ),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (widget.postType == 1) {
                postTodayImage(
                  userProvider.getUser.uid,
                  userProvider.getUser.username,
                  userProvider.getUser.photoUrl,
                );
              } else if (widget.postType == 2) {
                postWhenImage(
                  userProvider.getUser.uid,
                  userProvider.getUser.username,
                  userProvider.getUser.photoUrl,
                );
              }
            },
            child: const Text(
              "Post!",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      // POST FORM
      body: Column(
        children: <Widget>[
          isLoading
              ? const LinearProgressIndicator()
              : const Padding(padding: EdgeInsets.only(top: 0.0)),
          const Divider(),
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                height: 300,
                alignment: Alignment.topCenter,
                child: Image.memory(
                  widget.file,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '오늘의 핏을 설명해보세요!...',
                  ),
                  maxLines: 8,
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
