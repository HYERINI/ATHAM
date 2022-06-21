import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/utils/utils.dart';
import 'package:atham/widgets/marquee_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';

class ClothesCard extends StatelessWidget {
  final snap;
  final uid;
  const ClothesCard({Key? key, required this.snap, required this.uid})
      : super(key: key);

  deleteClothes(String clothesId, String photoUrl) async {
    try {
      await fireStoreMethods().deleteClothes(clothesId, photoUrl);
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> _addClothesUsedTime(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('입은 횟수 추가'),
          content: Text('이 옷의 입은 횟수를 +1하시겠습니까?.)'),
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
                if (snap.data()["usedTimes"] != null) {
                  await fireStoreMethods()
                      .addusedTimes(snap.data()["clothesId"]);
                } else {
                  showSnackBar(context, "해당 옷은 구 버전이므로 입은 횟수를 추가할 수 없습니다.");
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Image(
            image: NetworkImage(
              snap.data()['clothesPhotoUrl'],
            ),
            width: 150,
            fit: BoxFit.fitWidth,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '옷 이름: ',
                        ),
                        TextSpan(
                            text: snap.data()['clothesName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '옷 메인카테고리: ',
                        ),
                        TextSpan(
                            text: snap.data()['mainCategory'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '옷 하위카테고리: ',
                        ),
                        TextSpan(
                            text: snap.data()['subCategory'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '옷 설명: ',
                        ),
                        TextSpan(
                            text: snap.data()['talking'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '입은 횟수: ',
                        ),
                        TextSpan(
                            text: snap.data()['usedTimes'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        snap.data()['datePublished'].toDate(),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (FirebaseAuth.instance.currentUser!.uid == uid)
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    _addClothesUsedTime(context);
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      useRootNavigator: false,
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              children: [
                                'Delete',
                              ]
                                  .map(
                                    (e) => InkWell(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(e),
                                        ),
                                        onTap: () {
                                          deleteClothes(
                                              snap
                                                  .data()['clothesId']
                                                  .toString(),
                                              snap.data()['clothesPhotoUrl']);
                                          // remove the dialog box
                                          Navigator.of(context).pop();
                                        }),
                                  )
                                  .toList()),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            )
        ],
      ),
    );
  }
}
