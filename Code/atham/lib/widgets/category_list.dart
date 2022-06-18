import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final followersList;

  final gotUserUid;

  final ValueChanged<String> updateCategory;

  final isMe;

  CategoryList(
      {required this.updateCategory,
      required this.followersList,
      required this.gotUserUid,
      required this.isMe});

  Future<void> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('카테고리 삭제'),
          content: Text('카테고리를 삭제하시겠습니까?(관련 옷이 삭제되지 않습니다.)'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                if (FirebaseAuth.instance.currentUser!.uid == gotUserUid) {
                  await fireStoreMethods().removeCategory(followersList);
                } else {
                  showSnackBar(context, "다른 사람의 카테고리를 삭제하면 안되죠!!!");
                }
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isMe
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                updateCategory(followersList);
              },
              onLongPress: () {
                if (followersList != "ALL") _asyncConfirmDialog(context);
              },
              child: Card(
                color: Colors.pink,
                child: ListTile(
                  title: Text(followersList),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                updateCategory(followersList);
              },
              onLongPress: () {
                if (followersList != "ALL") _asyncConfirmDialog(context);
              },
              child: Card(
                child: ListTile(
                  title: Text(followersList),
                ),
              ),
            ),
          );
  }
}
