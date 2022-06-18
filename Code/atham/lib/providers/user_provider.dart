import 'package:atham/methods/auth_methods.dart';
import 'package:atham/models/user.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> reloadUser() async {
    User user = await _authMethods.getUserInfo();
    _user = user;
    notifyListeners();
  }
}
