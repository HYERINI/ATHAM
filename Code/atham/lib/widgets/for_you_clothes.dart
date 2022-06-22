import 'package:atham/utils/colors.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/utils/utils.dart';
import 'package:atham/widgets/clothes_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForYouCLothes extends StatefulWidget {
  final int MaxT;
  final int MinT;
  const ForYouCLothes({Key? key, required this.MaxT, required this.MinT})
      : super(key: key);

  @override
  State<ForYouCLothes> createState() => _ForYouCLothesState();
}

class _ForYouCLothesState extends State<ForYouCLothes> {
  bool isLoading = false;
  List snapList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClothes();
  }

  getClothes() async {
    setState(() {
      isLoading = true;
    });
    try {
      // get User
      var tempSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('closet')
          .where("maxT", isGreaterThanOrEqualTo: widget.MaxT)
          .get();
      for (var i in tempSnap.docs) {
        var a = i.data()!;
        if (a["minT"] <= widget.MinT) {
          snapList.add(i);
          print(a);
        }
      }

      setState(() {});
    } catch (e) {
      print(e.toString());
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
                    title: Row(
                children: [
                  Image.asset(
                    'assets/AthamLogo.png',
                    //color: primaryColor,
                    height: 80,
                  ),
                  const VerticalDivider(),
                  Text(
                    "옷 추천 해줍니다!",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
                  ),
            body: ListView(
              children: [
                if (snapList.length == 0)
                  Text("NO")
                else
                  for (var t in snapList) ClothesCard(snap: t, uid: "0")
              ],
            ));
  }
}
