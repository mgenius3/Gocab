import 'package:Gocab/Assistants/request_assistant.dart';
import 'package:Gocab/infoHandler/app_info.dart';
import 'package:Gocab/model/direction.dart';
import 'package:flutter/material.dart';
import 'package:Gocab/model/user_model.dart';
import 'package:Gocab/model/predicted_places.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import './progress_dialog.dart';
import 'package:Gocab/global/map_key.dart';
import 'dart:developer';
import '../app/sub_screens/map_screen.dart';

class PlacePredictionTileDesignPickUp extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesignPickUp({required this.predictedPlaces});

  @override
  State<PlacePredictionTileDesignPickUp> createState() =>
      _PlacePredictionTileDesignPickUpState();
}

class _PlacePredictionTileDesignPickUpState
    extends State<PlacePredictionTileDesignPickUp> {
  getPlacesDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Setting up Pick-up..",
            ));

    String getPlacesDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";

    var responseApi =
        await RequestAssistant.receiveRequest(getPlacesDirectionDetailsUrl);

    Navigator.pop(context);

    if (responseApi == "Error Occured: Failed, No response.") {
      return;
    }

    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      print("$responseApi");
      // directions.locationName = responseApi["result"]["long_name"];
      directions.locationName = responseApi["result"]["formatted_address"];

      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];

      directions.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });
      // Navigator.push(context, MaterialPageRoute(builder: (c) => MapScreen()));
      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        getPlacesDirectionDetails(widget.predictedPlaces!.place_id, context);
      },
      child: Padding(
        padding: EdgeInsets.all(18.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.predictedPlaces?.main_text ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.predictedPlaces?.secondary_text ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
