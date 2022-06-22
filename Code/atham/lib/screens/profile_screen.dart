import 'dart:typed_data';

import 'package:atham/flutter_flow/flutter_flow_theme.dart';
import 'package:atham/screens/add_clothes_screen.dart';
import 'package:atham/screens/add_post_screen.dart';
import 'package:atham/screens/closet_screen.dart';
import 'package:atham/screens/my_post_screen.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/weather/loading_screen.dart';
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
  int closetLen = 0;

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

      var closetSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection("closet")
          .get();
      closetLen = closetSnap.docs.length;

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
                "마이 페이지",
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
                                Column(
                                  children: [
                                    Text(userData['username'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium),
                                    const Divider(),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildStatColumn(postLen, "게시물"),
                                        buildStatColumn(closetLen, "나의 옷"),
                                        //buildStatColumn(following, "좋아요 누른 수"),
                                      ],
                                    ),
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
                          top: 1,
                        ),
                        child: Text(
                          userData['bio'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListView(

                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              shape: BoxShape.rectangle,
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LoadingScreen(
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24, 0, 0, 0),
                                    child: Text(
                                      '날씨',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText1,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional(0.9, 0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFF95A1AC),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              shape: BoxShape.rectangle,
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ClosetScreen(
                                      uid: widget.uid,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24, 0, 0, 0),
                                    child: Text(
                                      '내 옷장',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText1,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional(0.9, 0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFF95A1AC),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 1, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              shape: BoxShape.rectangle,
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MyPostScreen(
                                      uid: widget.uid,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24, 0, 0, 0),
                                    child: Text(
                                      '내 게시물',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText1,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional(0.9, 0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFF95A1AC),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FollowButton(
                      text: '로그아웃',
                      backgroundColor: mobileBackgroundColor,
                      textColor: primaryColor,
                      borderColor: Color.fromARGB(255, 255, 0, 0),
                      function: () async {
                        await AuthMethods().logOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          );
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
