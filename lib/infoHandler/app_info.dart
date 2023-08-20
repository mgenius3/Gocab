import 'package:flutter/cupertino.dart';
import 'package:Gocab/model/direction.dart';
import '../model/trips_history_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripHistoryInformationList = [];

  void updatePickUpLocationAddress(Directions? userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions? dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory) {
    allTripHistoryInformationList.add(eachTripHistory);
    notifyListeners();
  }
}
