import 'package:mtag_queue_skipper/models/bike_details.dart';
import 'package:flutter/material.dart';


class BikeDetailsProvider with ChangeNotifier {
  BikeDetails? bikeDetails;

  void setBikeDetails(BikeDetails bikeDetails){
    this.bikeDetails = bikeDetails;
    notifyListeners();

  }
}