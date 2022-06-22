import 'dart:typed_data';

import 'package:atham/screens/add_post_screen.dart';
import 'package:atham/screens/profile_screen.dart';
import 'package:atham/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/widgets/post_card.dart';
import 'package:image_picker/image_picker.dart';

class WhenPostScreen extends StatefulWidget {
  const WhenPostScreen({Key? key}) : super(key: key);

  @override
  State<WhenPostScreen> createState() => _WhenPostScreenState();
}

class _WhenPostScreenState extends State<WhenPostScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Image.asset(
                'assets/AthamLogo.png',
                //color: primaryColor,
                height: 80,
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.person,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                            uid: FirebaseAuth.instance.currentUser!.uid),
                      ),
                    );
                  },
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where("postType", isEqualTo: 2)
            .orderBy("datePublished", descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width * 0.3 : 0,
                vertical: width > webScreenSize ? 15 : 0,
              ),
              child: PostCard(
                snap: snapshot.data!.docs[index].data(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _getFAB(),
    );
  }

  _selectImage(BuildContext parentContext) async {
    Uint8List file = await pickImage(ImageSource.gallery, 30);
    //go to add page
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPostScreen(
          file: file,
          postType: 2,
        ),
      ),
    );
  }

  Widget _getFAB() {
    return FloatingActionButton(
      onPressed: () {
        _selectImage(context);
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }
}
