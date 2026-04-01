import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier{
  String _name = "";
  String _CNIC = "";
  String _phoneNumber = "";
  String _email = "";
  String _password = "";
  String get name => _name;
  String get CNIC => _CNIC;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String get password => _password;

  void setName(String name) {
    _name = name;
    notifyListeners(); 
  }
  void setCNIC(String CNIC) {
    _CNIC = CNIC;
    notifyListeners();
  }
  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }
  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  
}