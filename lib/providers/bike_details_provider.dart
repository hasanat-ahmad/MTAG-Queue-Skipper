import 'package:mtag_queue_skipper/models/bike_details.dart';
import 'package:flutter/material.dart';


class BikeDetailsProvider with ChangeNotifier {
  BikeDetails? bikeDetails;
  String? tokenNumber;
  String? tokenStatus;
  String? tokenEstimatedTime;
  String? tokenGeneratedAt;

  void setBikeDetails(BikeDetails bikeDetails){
    this.bikeDetails = bikeDetails;
    notifyListeners();

  }

  void setTokenData({
    required String tokenNumber,
    required String tokenStatus,
    required String tokenEstimatedTime,
    required String tokenGeneratedAt,
  }) {
    this.tokenNumber = tokenNumber;
    this.tokenStatus = tokenStatus;
    this.tokenEstimatedTime = tokenEstimatedTime;
    this.tokenGeneratedAt = tokenGeneratedAt;
    notifyListeners();
  }

  bool get hasToken => tokenNumber != null && tokenNumber!.isNotEmpty;
}