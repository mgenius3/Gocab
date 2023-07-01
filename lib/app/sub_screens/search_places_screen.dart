import 'package:flutter/material.dart';
import 'package:Gocab/Assistants/request_assistant.dart';
import 'package:Gocab/model/predicted_places.dart';
import 'package:Gocab/widget/place_prediction.dart';
import '../../global/map_key.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];

  // Your implementation of findPlaceAutoCompleteSearch method
  // You need to implement this method to fetch the list of predicted places
  // based on the inputText. Once you have the list, you can update the
  // placesPredictedList and call setState to rebuild the UI.

  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/api/place/autocomplete/json?input=$inputText&key=$mapkey&components=country:80";

      var responseAutoCompleteSearch =
      await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch["status"] == "Error Occured. Failed. No Response.") {
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList =
        (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.blue,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          title: Text(
            "Search & Set dropoff Location",
            style: TextStyle(
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_sharp,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        onChanged: (value) {
                          findPlaceAutoCompleteSearch(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Search location here...",
                          fillColor: Colors.white,
                          filled: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: 11,
                            top: 8,
                            bottom: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Display place prediction result
            placesPredictedList.length > 0
                ? Expanded(
              child: ListView.separated(
                itemCount: placesPredictedList.length,
                itemBuilder: (context, index) {
                  return PlacePredictionTileDesign(
                    predictedPlaces: placesPredictedList[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 0,
                    color: darkTheme
                        ? Colors.amber.shade400
                        : Colors.blue,
                    thickness: 0,
                  );
                },
                physics: ClampingScrollPhysics(),
              ),
            )
                : Container(), // Add an empty Container if no predictions
          ],
        ),
      ),
    );
  }
}

