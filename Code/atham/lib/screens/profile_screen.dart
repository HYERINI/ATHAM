import 'dart:typed_data';

import 'package:atham/screens/add_clothes_screen.dart';
import 'package:atham/screens/add_post_screen.dart';
import 'package:atham/screens/my_post_screen.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/widgets/category_list.dart';
import 'package:atham/widgets/clothes_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:atham/methods/auth_methods.dart';
import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/screens/login_screen.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/utils.dart';
import 'package:atham/widgets/follow_button.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
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
    try {
      // get User
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  toAddClothes() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddClothesScreen(),
    ));
  }

  String _usingCategory = "ALL";

  void _updateCategory(String nowCategory) {
    if (nowCategory == _usingCategory) {
      setState(() {
        _usingCategory = "ALL";
      });
    } else {
      setState(() {
        _usingCategory = nowCategory;
      });
    }
    print(_usingCategory);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              userData["photoUrl"],
                            ),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildTouchColumn(postLen, "posts"),
                                    buildStatColumn(followers, "카테고리 수"),
                                    buildStatColumn(following, "좋아요 누른 수"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            text: 'Sign Out',
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await AuthMethods().logOut();
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen(),
                                                ),
                                              );
                                            },
                                          )
                                        : Text(
                                            "===")
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      //mainCategpry Area
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        children: [
                          mainCategoryButton("상의", Icons.checkroom),
                          mainCategoryButton("하의", Icons.checkroom),
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (_usingCategory != "ALL")
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection("closet")
                            .where('nowCategory', isEqualTo: _usingCategory)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return snapshot.data!.docs.isEmpty
                              ? Text("it's empty...")
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (ctx, index) {
                                    return ClothesCard(
                                        snap: snapshot.data!.docs[index],
                                        uid: widget.uid);
                                  },
                                );
                        },
                      )
                    else // and if Category == ALL
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection("closet")
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return snapshot.data!.docs.isEmpty
                              ? Text("it's empty...")
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (ctx, index) {
                                    return ClothesCard(
                                        snap: snapshot.data!.docs[index],
                                        uid: widget.uid);
                                  },
                                );
                        },
                      ),
                  ],
                ),
              ],
            ),
            floatingActionButton: _getFAB(),
          );
  }

  Widget _getFAB() {
    if (FirebaseAuth.instance.currentUser!.uid == widget.uid) {
      return FloatingActionButton(
        onPressed: toAddClothes,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      );
    } else {
      return Container();
    }
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  InkWell buildTouchColumn(int num, String label) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MyPostScreen(
            uid: widget.uid,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              num.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainCategoryButton(String name, IconData nowIcon) {
    return SizedBox.fromSize(
      size: Size(56, 56),
      child: ClipOval(
        child: Material(
          color: Color.fromARGB(255, 94, 94, 94),
          child: InkWell(
            splashColor: Color.fromARGB(255, 213, 213, 213),
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(nowIcon), // <-- Icon
                Text(name), // <-- Text
              ],
            ),
          ),
        ),
      ),
    );
  }
}
