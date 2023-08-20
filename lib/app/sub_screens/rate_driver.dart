import 'package:Gocab/splash.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import '../../global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RateDriverScreen extends StatefulWidget {
  String? assignedDriverId;

  RateDriverScreen({this.assignedDriverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.transparent,
        child: Container(
            margin: EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 22,
                ),
                Text(
                  "Rate Trip Experience",
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                Divider(height: 2, color: Colors.blue),
                SizedBox(height: 20),
                SmoothStarRating(
                  rating: countRatingStars,
                  allowHalfRating: false,
                  starCount: 5,
                  color: Colors.blue,
                  borderColor: Colors.grey,
                  size: 46,
                  onRatingChanged: (valueOfStarsChoosed) {
                    countRatingStars = valueOfStarsChoosed;

                    if (countRatingStars == 1) {
                      setState(() {
                        titleStarsRating = "Very Bad";
                      });
                    }
                    if (countRatingStars == 2) {
                      setState(() {
                        titleStarsRating = "Bad";
                      });
                    }
                    if (countRatingStars == 3) {
                      setState(() {
                        titleStarsRating = "Good";
                      });
                    }
                    if (countRatingStars == 4) {
                      setState(() {
                        titleStarsRating = "Very Good";
                      });
                    }
                    if (countRatingStars == 5) {
                      setState(() {
                        titleStarsRating = "Excellent";
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(titleStarsRating,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.blue)),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      DatabaseReference rateDriverRef = FirebaseDatabase
                          .instance
                          .ref()
                          .child("drivers")
                          .child(widget.assignedDriverId!)
                          .child("ratings");

                      rateDriverRef.once().then((snap) {
                        if (snap.snapshot.value == null) {
                          rateDriverRef.set(countRatingStars.toString());

                          Navigator.pop(context);

                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) => Splash()));
                        } else {
                          double pastRatings =
                              double.parse(snap.snapshot.value.toString());
                          double newAverageRatings =
                              (pastRatings + countRatingStars) / 2;
                          rateDriverRef.set(newAverageRatings.toString());

                          Navigator.pop(context);

                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) => Splash()));
                        }

                        Fluttertoast.showToast(msg: "Restarting the app now");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 70)),
                    child: Text("Submit",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )))
              ],
            )));
  }
}
