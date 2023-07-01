import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Gocab/model/user_model.dart';
import 'package:geolocator/geolocator.dart';
import 'request_assistant.dart';
import '../model/direction.dart';
import '../global/global.dart';
import "package:provider/provider.dart";
import "../infoHandler/app_info.dart";

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude}, ${position.longitude}";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    print(
        "--------------------------------------------------------------------");
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
}
