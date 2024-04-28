import 'dart:convert';
import 'package:Gocab/global/map_key.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Gocab/model/user_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'request_assistant.dart';
import '../model/direction.dart';
import '../model/direction_details_info.dart';
import '../global/global.dart';
import "package:provider/provider.dart";
import "../infoHandler/app_info.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../global/map_key.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../model/trips_history_model.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // var userRef =
    //     FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    // var snapshot = await userRef.once();

    // userRef.once().then((snap) {
    //   if (snap.snapshot.value != null) {
    //     userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);

    //     return userModelCurrentInfo;
    //   }
    // });
// Reference the "users" collection
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');

    // Query the documents in the "users" collection based on ID
    QuerySnapshot<Object?> snapshot =
        await usersRef.where('id', isEqualTo: currentUser!.uid).get();

    // Check if there is a matching document
    if (snapshot.docs.isNotEmpty) {
      try {
        // Access the first matching document
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            snapshot.docs[0] as DocumentSnapshot<Map<String, dynamic>>;

        userModelCurrentInfo = UserModel.fromSnapshot(documentSnapshot);

        // Perform further operations with the data
      } catch (err) {
        print(err.toString());
      }
    } else {
      print('No matching document found');
    }
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude}, ${position.longitude}&key=$mapkey";
    String humanReadableAddress = "";
    try {
      var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

      if (requestResponse != "Error Occured: Failed, No response.") {
        humanReadableAddress =
            requestResponse["results"][0]["formatted_address"];

        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = position.latitude;
        userPickUpAddress.locationLongitude = position.longitude;
        userPickUpAddress.locationName = humanReadableAddress;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);
      }
    } catch (err) {
      // print(err);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOrigintoDestinationDirectionDetails =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapkey';
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOrigintoDestinationDirectionDetails);

    // if(responseDirectionApi == "Error Occured: Failed, No response."){
    //   return null;
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    print(directionDetailsInfo);
    double timeTravelledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;

    double distanceTravelledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;

    //USD
    double totalFareAmount = timeTravelledFareAmountPerMinute +
        distanceTravelledFareAmountPerKilometer;

    //--
    double localCurrencyTotalFare = totalFareAmount * 500;

    return localCurrencyTotalFare.truncate().toDouble();

    // return double.parse(totalFareAmount.toStringAsFixed(1));
  }

//push notification cloud messaging
//   static sendNotificationToDriverNow(String deviceRegisterationToken,
//       String userRideRequestId, context) async {
//     String destinationAddress = userDropOffAddress;

//     // Get the FCM token
//     String? fcmToken = await FirebaseMessaging.instance.getToken();

//     Map<String, String> headerNotification = {
//       'Content-Type': 'application/json',
//       'Authorization': 'key=$fcmToken',
//     };

//     Map bodyNotification = {
//       "body": "Destination Address: \n$destinationAddress.",
//       "title": "New Trip Request"
//     };

//     Map dataMap = {
//       "click_action": "FLUTTER_NOTIFICATION_CLICK",
//       "id": "1",
//       "status": "done",
//       "rideRequest": userRideRequestId,
//     };

//     Map officialNotificationFormat = {
//       "notification": bodyNotification,
//       "data": dataMap,
//       "priority": "high",
//       "to": deviceRegisterationToken,
//     };

//     var responseNotification = await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: headerNotification,
//         body: jsonEncode(officialNotificationFormat));
//   }
// }

//push notification for real time database
  static sendNotificationToDriverNow(
      String driverId, String userRideRequestId, context) async {
    String destinationAddress = userDropOffAddress;

    Map dataMap = {
      // "title": "NEW TRIP REQUEST",
      "rideRequest": userRideRequestId,
      // "user_destination": "Destination Address: \n$destinationAddress.",
    };

    DatabaseReference nofificationRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverId)
        .child("messages");

    await nofificationRef.set(dataMap);
  }

  // retrieve the trips for online user
  // trip key = ride request key
  static void readTripsKeysForOnlineUser(context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number of trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });

        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripsAllKeys =
        Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if ((snap.snapshot.value as Map)["status"] == "ended") {
          //update or add each history to OverAllTrips History data list
          Provider.of<AppInfo>(context, listen: false)
              .updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }
}
