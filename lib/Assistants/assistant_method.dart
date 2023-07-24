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

        // // Access the data of the matching document
        // Map<String, dynamic> data = documentSnapshot.data()!;

        print(documentSnapshot.get("phone"));
        // print(data);
        userModelCurrentInfo = UserModel.fromSnapshot(documentSnapshot);

        // Extract specific fields from the data
        // String id = data['id'];
        // String name = data['name'];

        print(userModelCurrentInfo);

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
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude}, ${position.longitude}";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occured: Failed, No response.") {
      humanReadableAddress = requestResponse("results")[0]["formatted_address"];
      print(requestResponse);

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
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
    double timeTravelledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;

    print(timeTravelledFareAmountPerMinute);
    double distanceTravelledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;

    //USD
    double totalFareAmount = timeTravelledFareAmountPerMinute +
        distanceTravelledFareAmountPerKilometer;
    print(totalFareAmount);

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }
}
