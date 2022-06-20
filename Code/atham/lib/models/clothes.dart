import 'package:cloud_firestore/cloud_firestore.dart';

class Clothes {
  final String talking;
  final String uid;
  final String clothesName;
  final String clothesId;
  final DateTime datePublished;
  final String clothesPhotoUrl;
  final String nowCategory;
  final String mainCategory;
  final int maxT;
  final int minT;

  const Clothes({
    required this.talking,
    required this.uid,
    required this.clothesName,
    required this.clothesId,
    required this.datePublished,
    required this.clothesPhotoUrl,
    required this.nowCategory,
    required this.mainCategory,
    required this.maxT,
    required this.minT,
  });

  static Clothes fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Clothes(
        talking: snapshot["talking"],
        uid: snapshot["uid"],
        clothesName: snapshot["clothesName"],
        clothesId: snapshot["clothesId"],
        datePublished: snapshot["datePublished"],
        clothesPhotoUrl: snapshot['clothesPhotoUrl'],
        nowCategory: snapshot['nowCategory'],
        mainCategory: snapshot['mainCategory'],
        maxT: snapshot['maxT'],
        minT: snapshot['mixT']);
  }

  Map<String, dynamic> toJson() => {
        "talking": talking,
        "uid": uid,
        "clothesName": clothesName,
        "clothesId": clothesId,
        "datePublished": datePublished,
        'clothesPhotoUrl': clothesPhotoUrl,
        'nowCategory': nowCategory,
        'mainCategory': mainCategory,
        'maxT': maxT,
        'minT': minT,
      };
}
