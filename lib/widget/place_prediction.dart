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

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() =>
      _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {

  getPlacesDirectionDetails(String? placeId, context) async{
    showDialog(context: context,
    builder: (BuildContext context) => ProgressDialog(message:  "Setting up Drop-off. Please wait....",
    ));

    String getPlacesDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";

    var responseApi = await RequestAssistant.receiveRequest(getPlacesDirectionDetailsUrl);

    Navigator.pop(context);

    if(responseApi == "Error Occured: Failed, No response."){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName = responseApi["results"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];

      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });
       Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ElevatedButton(
      onPressed: () {
        getPlacesDirectionDetails(widget.predictedPlaces!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        primary: darkTheme ? Colors.black : Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
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
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    ),
                  ),
                  Text(
                    widget.predictedPlaces?.secondary_text ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
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