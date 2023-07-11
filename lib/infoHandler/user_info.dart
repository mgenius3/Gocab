import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  String? displayName;
  String? email;
  bool emailVerified = false;
  bool isAnonymous = false;
  DateTime? creationTime;
  DateTime? lastSignInTime;
  String? phoneNumber;
  String? photoURL;
  List<UserInfo> providerData = [];
  String? refreshToken;
  String? tenantId;
  String uid = "";

  void setUser(User? user) {
    if (user != null) {
      displayName = user.displayName;
      email = user.email;
      emailVerified = user.emailVerified;
      isAnonymous = user.isAnonymous;
      creationTime = user.metadata.creationTime;
      lastSignInTime = user.metadata.lastSignInTime;
      phoneNumber = user.phoneNumber;
      photoURL = user.photoURL;
      providerData = user.providerData;
      refreshToken = user.refreshToken;
      tenantId = user.tenantId;
      uid = user.uid;
    } else {
      // Reset the values if the user is null
      displayName = null;
      email = null;
      emailVerified = false;
      isAnonymous = false;
      creationTime = null;
      lastSignInTime = null;
      phoneNumber = null;
      photoURL = null;
      providerData = [];
      refreshToken = null;
      tenantId = null;
      uid = "";
    }

    notifyListeners();
  }
}
