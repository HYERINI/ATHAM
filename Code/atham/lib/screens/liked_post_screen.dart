import 'package:atham/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/widgets/post_card.dart';

class LikedPostScreen extends StatefulWidget {
  const LikedPostScreen({Key? key}) : super(key: key);

  @override
  State<LikedPostScreen> createState() => _LikedPostScreenState();
}

class _LikedPostScreenState extends State<LikedPostScreen> {
  //var userLikedPost = [];
  var userdata = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    userdata = userSnap.data()!;
    print(userdata["following"]);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: width > webScreenSize
                ? webBackgroundColor
                : mobileBackgroundColor,
            appBar: width > webScreenSize
                ? null
                : AppBar(
                    backgroundColor: mobileBackgroundColor,
                    centerTitle: false,
                    title: Row(
                children: [
                  Image.asset(
                    'assets/AthamLogo.png',
                    //color: primaryColor,
                    height: 80,
                  ),
                  const VerticalDivider(),
                  Text(
                    "좋아요를 누른 게시물",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
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
            body: userdata["following"].isEmpty
                ? const Text("Empty")
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('postId', whereIn: userdata["following"])
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
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
          );
  }
}
