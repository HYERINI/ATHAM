import 'dart:typed_data';
import 'package:atham/methods/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atham/models/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //getUserInfo
  Future<model.User> getUserInfo() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  //signUp
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List? file,
  }) async {
    String stateText = "문제가 좀 생긴 것 같습니다...";
    try {
      if (email.isNotEmpty ||
          (password.isNotEmpty && password.length>=6) ||
          username.isNotEmpty ||
          bio.isNotEmpty
          ) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl;
        if (file == null) {
          photoUrl =
              "https://firebasestorage.googleapis.com/v0/b/smu-clothes-b872b.appspot.com/o/profileImg%2FprofileIcon.jpeg?alt=media&token=7f4aeaa7-7a84-4847-a84f-176100888dd9";
        } else {
          photoUrl = await StorageMethods()
              .uploadImageToString("profileImg", file, false);
        }

        model.User _user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: ["ALL"],
          following: [],
        );

        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(_user.toJson());

        stateText = "success";
      } else {
        stateText = "6자리 이상의 비밀번호를 포함한 모든 정보를 입력하셔야 합니다...!";
      }
    } catch (err) {
      return err.toString();
    }
    return stateText;
  }

  //login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String stateText = "문제가 생긴 것 같습니다....";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        stateText = "success";
      } else {
        stateText = "이메일과 비밀 번호를 모두 입력해야 합니다...!";
      }
    } catch (err) {
      return err.toString();
    }
    return stateText;
  }

  //logout
  Future<void> logOut() async {
    await _auth.signOut();
  }

}
