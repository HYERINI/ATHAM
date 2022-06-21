import 'package:atham/methods/storage_methods.dart';
import 'package:atham/models/clothes.dart';
import 'package:atham/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

class fireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPostToday(String talking, Uint8List file, String uid,
      String username, String profImage) async {
    String stateText = "문제가 생긴 것 같습니다ㅠ";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToString('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
          talking: talking,
          uid: uid,
          username: username,
          likes: [],
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          postType: 1);
      _firestore.collection('posts').doc(postId).set(post.toJson());
      stateText = "success";
    } catch (err) {
      stateText = err.toString();
    }
    return stateText;
  }

  Future<String> uploadPostWhen(String talking, Uint8List file, String uid,
      String username, String profImage) async {
    String stateText = "문제가 생긴 것 같습니다ㅠ";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToString('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
          talking: talking,
          uid: uid,
          username: username,
          likes: [],
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          postType: 2);
      _firestore.collection('posts').doc(postId).set(post.toJson());
      stateText = "success";
    } catch (err) {
      stateText = err.toString();
    }
    return stateText;
  }

  Future<String> deletePost(
      String postId, List likedList, String postUrl) async {
    String res = "문제가 생긴 것 같습니다...ㅠ";
    try {
      likedList.forEach((element) {
        _firestore.collection('users').doc(element).update({
          'following': FieldValue.arrayRemove([postId])
        });
      });

      await FirebaseStorage.instance.refFromURL(postUrl).delete();

      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteComment(String postId, String commentId) async {
    String res = "문제가 생긴 것 같습니다...ㅠ";
    try {
      var a = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "좋아요/취소 도중에 문제가 생긴 것 같습니다...ㅠ";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });

        _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([postId])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });

        _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([postId])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followPost(String uid, String postId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(postId)) {
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([postId])
        });
      } else {
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([postId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String stateText = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        stateText = 'success';
      } else {
        stateText = "댓글을 입력하세요";
      }
    } catch (err) {
      stateText = err.toString();
    }
    return stateText;
  }

  //이제는 옷장 관련 기능

  Future<String> uploadClothes(String talking, Uint8List file, String uid,
      String clothesName, String nowCategory, String mainCategory, String subCategory, int maxT, int minT) async {
    String stateText = "문제가 생긴 것 같습니다ㅠ";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToString('clothes', file, true);
      String clothesId = const Uuid().v1(); // creates unique id based on time

      Clothes clothes = Clothes(
          talking: talking,
          uid: uid,
          clothesName: clothesName,
          clothesId: clothesId,
          datePublished: DateTime.now(),
          clothesPhotoUrl: photoUrl,
          nowCategory: nowCategory,
          mainCategory: mainCategory,
          subCategory: subCategory,
          usedTimes: 0,
          maxT: maxT,
          minT: minT);

      _firestore
          .collection('users')
          .doc(uid)
          .collection("closet")
          .doc(clothesId)
          .set(clothes.toJson());
      await addCategory(uid, nowCategory);
      stateText = "success";
    } catch (err) {
      stateText = err.toString();
    }
    return stateText;
  }

  Future<String> deleteClothes(String clothesId, String photoUrl) async {
    String res = "문제가 생긴 것 같습니다...ㅠ";
    try {
      await FirebaseStorage.instance.refFromURL(photoUrl).delete();
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("closet")
          .doc(clothesId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> addCategory(
    String uid,
    String categoryName,
  ) async {
    try {
      if (categoryName != "ALL") {
        DocumentSnapshot snap =
            await _firestore.collection('users').doc(uid).get();
        List followers = (snap.data()! as dynamic)['followers'];

        if (!followers.contains(categoryName)) {
          await _firestore.collection('users').doc(uid).update({
            'followers': FieldValue.arrayUnion([categoryName])
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addusedTimes(
    String clothesUid,
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("closet").doc(clothesUid).get();
      int oldTimes = (snap.data()! as dynamic)['usedTimes'];

      await _firestore
        .collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("closet").doc(clothesUid)
        .update({'usedTimes': oldTimes + 1});
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> removeCategory(
    String categoryName,
  ) async {
    try {
      DocumentSnapshot snap = await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      List followers = (snap.data()! as dynamic)['followers'];

      if (followers.contains(categoryName)) {
        await _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'followers': FieldValue.arrayRemove([categoryName])
        });
        updataNullCategoryClothes(categoryName);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updataNullCategoryClothes(String categoryName) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("closet")
        .where("nowCategory", isEqualTo: categoryName)
        .get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("closet")
          .doc(querySnapshot.docs[i].id)
          .update({'nowCategory': 'ALL'});
    }
  }
}
