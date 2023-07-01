import 'package:flutter/cupertino.dart';
import 'package:Gocab/model/direction.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  //List<String> historyTripsKeysList = [];
  // List<TripHistoryModel> allTripHistoryInformationList = [];?

  void updatePickUpLocationAddress(Directions userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
