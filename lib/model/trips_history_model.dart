import "package:firebase_database/firebase_database.dart";

class TripsHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? driverName;
  String? ratings;

  TripsHistoryModel(
      {this.time,
      this.originAddress,
      this.destinationAddress,
      this.status,
      this.fareAmount,
      this.car_details,
      this.driverName,
      this.ratings});

  TripsHistoryModel.fromSnapshot(DataSnapshot datasnapshot) {
    time = (datasnapshot.value as Map)["time"];
    originAddress = (datasnapshot.value as Map)["originAddress"];
    destinationAddress = (datasnapshot.value as Map)["destinationAddress"];
    status = (datasnapshot.value as Map)["status"];
    fareAmount = (datasnapshot.value as Map)["fareAmount"];
    car_details = (datasnapshot.value as Map)["car_details"];
    driverName = (datasnapshot.value as Map)["driverName"];
    ratings = (datasnapshot.value as Map)["ratings"];
  }
}
