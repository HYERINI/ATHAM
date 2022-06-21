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

class ClosetScreen extends StatefulWidget {
  final String uid;
  const ClosetScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ClosetScreenState createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final ScrollController _firstController = ScrollController();

  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isLoading = false;

  String nowMainC = "전체";
  String nowSubC = "전체";

  @override
  void initState() {
    super.initState();
    getData();
  }

  List<String> mainCategoryList = [
    '상의',
    '아우터',
    '원피스/세트',
    '팬츠',
    '스커트',
    '트레이닝',
    '가방',
    '신발',
    '패션소품',
    '홈웨어',
    '주얼리'
  ];
  List<String> subCategoryList = [];
  void chooseSubList(String? nowString) {
    if (nowString == "상의") {
      subCategoryList = [
        "반팔티셔트",
        "블라우스",
        "셔츠",
        "민소매",
        "니트",
        "조끼",
        "긴팔티셔츠",
        "후드",
        "맨투맨"
      ];
    } else if (nowString == "아우터") {
      subCategoryList = ["가디건", "바람막이", "자켓", "집업/점퍼", "야상", "플리스", "코트", "패딩"];
    } else if (nowString == "원피스/세트") {
      subCategoryList = ["미니원피스", "롱원피스", "투피스", "점프수트"];
    } else if (nowString == "팬츠") {
      subCategoryList = ["롱팬츠", "슬랙스", "데님", "숏팬츠"];
    } else if (nowString == "스커트") {
      subCategoryList = ["미니 스커트", "미디/롱스커트"];
    } else if (nowString == "트레이닝") {
      subCategoryList = ["트레이닝 세트", "트레이닝 상의", "트레이닝 하의", "레깅스"];
    } else if (nowString == "가방") {
      subCategoryList = ["그로스백", "숄더백", "토트백", "클러치", "에코백", "백팩", "지갑", "파우치"];
    } else if (nowString == "신발") {
      subCategoryList = [
        "블로퍼/뮬",
        "플랫/로퍼",
        "샌들",
        "스니커즈",
        "슬리퍼/쪼리",
        "힐",
        "위커/부츠"
      ];
    } else if (nowString == "패션소품") {
      subCategoryList = [
        "헤어",
        "모자",
        "마스크",
        "양말/스타킹",
        "벨트",
        "시계",
        "머플러/스카프",
        "아이웨어",
        "장갑",
        "기타"
      ];
    } else if (nowString == "홈웨어") {
      subCategoryList = ["세트", "윈피스", "잠옷바지", "로브/가운"];
    } else if (nowString == "주얼리") {
      subCategoryList = ["귀걸이", "목걸이", "반지", "팔찌", "발찌", "보석함"];
    }
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
                userData['username'] + "의 옷장",
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      //mainCategpry Area
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        spacing: 10,
                        children: [
                          mainCategoryButton('전체', Icons.checkroom),
                          for (String mainName in mainCategoryList)
                            mainCategoryButton(mainName, Icons.checkroom),
                        ],
                      )
                    ],
                  ),
                ),

                //if mainCategory == 전체, Don't show subCategoryList
                if (nowMainC == "전체")
                  Container()
                else
                  //if mainCategory != 전체, show subCategoryList

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        //mainCategpry Area
                        Scrollbar(
                            thumbVisibility: true,
                            controller: _firstController,
                            child: SizedBox(
                              height: 56,
                              child: ListView(
                                controller: _firstController,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: [
                                  subCategoryButton('전체', Icons.checkroom),
                                  for (String subName in subCategoryList)
                                    subCategoryButton(subName, Icons.checkroom),
                                ],
                              ),
                            )

                            // Row(
                            //   children: [
                            //     subCategoryButton('전체', Icons.checkroom),
                            //     for(String subName in subCategoryList)
                            //       subCategoryButton(subName, Icons.checkroom),
                            //   ]
                            // ),

                            )

                        // Wrap(
                        //   direction: Axis.horizontal,
                        //   alignment: WrapAlignment.start,
                        //   spacing: 5,
                        //   children: [
                        //     subCategoryButton('전체', Icons.checkroom),
                        //     for(String subName in subCategoryList)
                        //       subCategoryButton(subName, Icons.checkroom),
                        //   ],
                        // )
                      ],
                    ),
                  ),

                Column(
                  children: [
                    if (nowMainC == "전체")
                      //if Category == 전체
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
                      )
                    else // if Category != 전체
                    if (nowSubC == "전체")
                      // and if subCategory == 전체 and Category != 전체
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection("closet")
                            .where('mainCategory', isEqualTo: nowMainC)
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
                    else
                      // and if subCategory != 전체 and Category != 전체
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection("closet")
                            .where('mainCategory', isEqualTo: nowMainC)
                            .where('subCategory', isEqualTo: nowSubC)
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
          color: nowMainC == name
              ? Color.fromARGB(255, 0, 166, 125)
              : Color.fromARGB(255, 94, 94, 94),
          child: InkWell(
            splashColor: Color.fromARGB(255, 213, 213, 213),
            onTap: () {
              setState(() {
                nowMainC = name;
                nowSubC = "전체";
                chooseSubList(nowMainC);
              });
            },
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

  Widget subCategoryButton(String name, IconData nowIcon) {
    return SizedBox.fromSize(
      size: Size(56, 56),
      child: ClipOval(
        child: Material(
          color: nowSubC == name
              ? Color.fromARGB(255, 136, 0, 166)
              : Color.fromARGB(255, 94, 94, 94),
          child: InkWell(
            splashColor: Color.fromARGB(255, 213, 213, 213),
            onTap: () {
              setState(() {
                nowSubC = name;
              });
            },
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
