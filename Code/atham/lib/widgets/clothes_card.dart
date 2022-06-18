import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClothesCard extends StatelessWidget {
  final snap;
  final uid;
  const ClothesCard({Key? key, required this.snap, required this.uid}) : super(key: key);

  deleteClothes(String clothesId, String photoUrl) async {
    try {
      await fireStoreMethods().deleteClothes(clothesId, photoUrl);
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              snap.data()['clothesPhotoUrl'],
            ),
            radius: 30,
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
                          text: '옷 카테고리: ',
                        ),
                        TextSpan(
                            text: snap.data()['nowCategory'],
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
          if(FirebaseAuth.instance.currentUser!.uid == uid)
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
                                        snap.data()['clothesId'].toString(),
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
          )
        ],
      ),
    );
  }
}
