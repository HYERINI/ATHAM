import 'package:atham/screens/add_post_screen.dart';
import 'package:atham/screens/another_profile_screen.dart';
import 'package:atham/screens/liked_post_screen.dart';
import 'package:atham/screens/today_post_screen.dart';
import 'package:atham/screens/when_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:atham/screens/profile_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const TodayPostScreen(),
  const WhenPostScreen(),
  const AddPostScreen(),
  const LikedPostScreen(),
  AnotherProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
