import 'package:Gocab/model/direction_details_info.dart';
import 'package:Gocab/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

UserModel? userModelCurrentInfo;
String userDropOffAddress = "";

DirectionDetailsInfo? tripDirectionDetailsInfo;
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";

double countRatingStars = 0.0;
String titleStarsRating = "";
