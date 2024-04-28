import 'package:Gocab/Assistants/request_assistant.dart';
import 'package:flutter/material.dart';
import "../../model/predicted_places.dart";
import "package:Gocab/global/map_key.dart";
import "../../widget/place_prediction.dart";

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];
  TextEditingController? searchInput;
  bool searching = false;

  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapkey&components=country:NG";

      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch == "Error Occured: Failed, No response.") {
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        setState(() {
          placesPredictedList = placePredictionList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            // backgroundColor: darkTheme ? Colors.black : Colors.blue,
            appBar: AppBar(
              // backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              title: Text(
                "Search & Set dropoff Location",
                style: TextStyle(color: Colors.white),
              ),
              elevation: 0.0,
            ),
            body: Column(
              children: [
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.white54,
                        blurRadius: 8,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ]),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.adjust_sharp,
                                color: darkTheme ? Colors.black : Colors.white),
                            Expanded(
                                child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextField(
                                        controller: searchInput,
                                        onChanged: (value) {
                                          findPlaceAutoCompleteSearch(value);
                                          setState(() {
                                            searching = true;
                                          });
                                        },
                                        decoration: InputDecoration(
                                            hintText: "Search location here...",
                                            // fillColor: darkTheme
                                            //     ? Colors.blue
                                            //     : Colors.white54,
                                            filled: true,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                              left: 11,
                                              top: 8,
                                              bottom: 8,
                                            )))))
                          ],
                        ),
                        SizedBox(height: 18.0),
                      ],
                    ),
                  ),
                ),

                //diplay place prediction result
                (placesPredictedList.length > 0)
                    ? Expanded(
                        child: ListView.separated(
                        itemBuilder: (context, index) {
                          return PlacePredictionTileDesign(
                            predictedPlaces: placesPredictedList[index],
                          );
                        },
                        itemCount: placesPredictedList.length,
                        physics: ClampingScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            thickness: 0,
                          );
                        },
                      ))
                    : Center(
                        child: Container(
                          child: !searching
                              ? null
                              : const CircularProgressIndicator(),
                        ),
                      ),
              ],
            )));
  }
}
