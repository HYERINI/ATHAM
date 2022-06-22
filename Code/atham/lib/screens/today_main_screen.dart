import 'package:atham/flutter_flow/flutter_flow_theme.dart';
import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/screens/profile_screen.dart';
import 'package:atham/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/widgets/post_card.dart';
import 'package:intl/intl.dart';

class TodayMainScreen extends StatefulWidget {
  const TodayMainScreen({Key? key}) : super(key: key);

  @override
  State<TodayMainScreen> createState() => _TodayMainScreenState();
}

class _TodayMainScreenState extends State<TodayMainScreen> {
  List<String> photoUrlList = [];
  List<String> usersNameList = [];
  List<String> likedTImesList = [];

  List<String> musinsaClothesNameList = [];
  List<String> musinsaPhotoUrlList = [];
  List<String> musinsaUrl = [];

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
      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy("likedTimes", descending: true)
          .limit(3)
          .get();

      for (var i in postSnap.docs) {
        var a = i.data()!;
        photoUrlList.add(a["postUrl"]);
        usersNameList.add(a["username"]);
        likedTImesList.add(a["likedTimes"].toString());
      }

      var rankingSnap = await FirebaseFirestore.instance
          .collection('musinsa')
          .doc("ranking")
          .get();

      var rankingData = rankingSnap.data()!;
      for (int a = 1; a < 4; a++) {
        String nowClothesName = "clothesName" + a.toString();
        musinsaClothesNameList.add(rankingData[nowClothesName]);
        String nowUrlName = "clothesUrl" + a.toString();
        musinsaUrl.add(rankingData[nowUrlName]);
        String nowPhotoName = "clothesPhoto" + a.toString();
        musinsaPhotoUrlList.add(rankingData[nowPhotoName]);
      }

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
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    DateFormat.yMMMd().format(
                      DateTime.now(),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 150,
                    width: width,
                    child: Row(children: [
                      //오늘의 날씨 아이콘
                      Container(),

                      //최고, 현재, 최저 기온
                      Row(children: []),
                    ]),
                  ),
                ),
                //인기 게시물
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "실시간 게시물 랭킹 Top3",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(),
                      Row(children: [
                        //1st
                        Expanded(flex: 1, child: rankingPost(0)),
                        SizedBox(width: 10),
                        //2nd
                        Expanded(flex: 1, child: rankingPost(1)),
                        SizedBox(width: 10),
                        //3rd
                        Expanded(flex: 1, child: rankingPost(2)),
                      ]),
                    ],
                  ),
                ),

                //실시간 인기 상품
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("실시간 인기 Top3 패션",
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(),
                      Row(children: [
                        //1st
                        Expanded(flex: 1, child: rankingClothes(0)),
                        SizedBox(width: 10),
                        //2nd
                        Expanded(flex: 1, child: rankingClothes(1)),
                        SizedBox(width: 10),
                        //3rd
                        Expanded(flex: 1, child: rankingClothes(2)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget rankingPost(int thisIndex) {
    return Column(
      children: [
        Stack(
          children: [
            Image(
              image: NetworkImage(photoUrlList[thisIndex]),
              width: 150,
              fit: BoxFit.fitWidth,
            ),
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text((thisIndex + 1).toString() + "위",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              usersNameList[thisIndex],
              maxLines: 2,
            ),
            Row(
              children: [
                Icon(Icons.heart_broken),
                Text(likedTImesList[thisIndex])
              ],
            )
          ],
        )
      ],
    );
  }

  Widget rankingClothes(int thisIndex) {
    return Column(
      children: [
        Stack(
          children: [
            Image(
              image: NetworkImage(musinsaPhotoUrlList[thisIndex]),
              width: 150,
              fit: BoxFit.fitWidth,
            ),
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text((thisIndex + 1).toString() + "위",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
        Text(
          musinsaClothesNameList[thisIndex],
          maxLines: 3,
        ),
      ],
    );
  }
}
