import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/models/user.dart';

class AuthProvider with ChangeNotifier{

  User? user;

  void setUser(User user){
    this.user = user;
    notifyListeners();
  }

 
}