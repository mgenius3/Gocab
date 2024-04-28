import 'package:Gocab/model/direction_details_info.dart';
import 'package:Gocab/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

UserModel? userModelCurrentInfo;
String userDropOffAddress = "";

String cloudMessagingServerToken = "key=";
List driversList = [];
DirectionDetailsInfo? tripDirectionDetailsInfo;
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
String driverRatings = "";
String? driverProfileUrl;

double countRatingStars = 0.0;
String titleStarsRating = "";
