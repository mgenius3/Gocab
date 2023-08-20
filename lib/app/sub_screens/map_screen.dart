import 'package:Gocab/Assistants/assistant_method.dart';
import 'package:Gocab/app/sub_screens/search_places_screen.dart';
import 'package:Gocab/widget/progress_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import "package:geocoder2/geocoder2.dart";
import "package:Gocab/global/map_key.dart";
import "package:Gocab/model/user_model.dart";
import "../../global/global.dart";
import '../../model/direction.dart';
import "package:provider/provider.dart";
import "../../infoHandler/app_info.dart";
import "./precise_pickup_location.dart";
import "./drawer_screen.dart";
import "../../utils/helper.dart";
import '../../helper/alertbox.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import '../../model/active_nearby_available_drivers.dart';
import '../../Assistants/geofire_assistant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Gocab/splash.dart';
import '../../widget/pay_fare_amount_dialog.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import './rate_driver.dart';

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw "Could not launch $url";
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;
  String? fareAmount;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationcontaiinerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRidesContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatedList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  bool readCurrentLocation = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;
  DatabaseReference? referenceDriverReceiveRequest;
  String selectedVehicleType = " ";

  String driverRideStatus = "Driver is on his way";

  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  String userRideRequestStatus = "";

  List<ActiveNearByAvailableDrivers> onlineNearByAvailableDriversList = [];

  bool requestPositionInfo = true;
  bool remove_bottomBar = false;

  var get_directionDetailsInfo;

  var logger = Logger();

  locateUserPosition() async {
    try {
      Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      userCurrentPosition = cPosition;

      print("109 $userCurrentPosition");
      LatLng latLngPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 15);

      print("116 $cameraPosition");

      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoordinates(
              userCurrentPosition!, context);

      ///get user from database
      userName = userModelCurrentInfo!.name!;
      userEmail = userModelCurrentInfo!.email!;

      print("131 $userName");

      initializeGeoFireListener();
      AssistantMethods.readTripsKeysForOnlineUser(context);
    } catch (err) {
      print(err);
    }
  }

  initializeGeoFireListener() {
    try {
      Geofire.initialize("activeDrivers");

      Geofire.queryAtLocation(userCurrentPosition!.latitude,
              userCurrentPosition!.longitude, 10)!
          .listen((map) {
        if (map != null) {
          var callBack = map["callBack"];

          switch (callBack) {
            //whenever any driver become active/online
            case Geofire.onKeyEntered:
              GeoFireAssistant.activeNearByAvailableDriversList.clear();
              ActiveNearByAvailableDrivers activeNearByAvailableDrivers =
                  ActiveNearByAvailableDrivers();
              activeNearByAvailableDrivers.locationLatitude = map["latitude"];
              activeNearByAvailableDrivers.locationLongitude = map["longitude"];
              activeNearByAvailableDrivers.driverId = map["key"];

              GeoFireAssistant.activeNearByAvailableDriversList
                  .add(activeNearByAvailableDrivers);

              if (activeNearbyDriverKeysLoaded == true) {
                displayActiveDriversOnUsersMap();
              }

              break;

            //whenever any driver becomes non-active
            case Geofire.onKeyExited:
              GeoFireAssistant.deleteOfflineDriverFromList(map["key"]);
              displayActiveDriversOnUsersMap();
              break;

            //whenever driver moves - update driver location
            case Geofire.onKeyMoved:
              ActiveNearByAvailableDrivers activeNearByAvailableDrivers =
                  ActiveNearByAvailableDrivers();
              activeNearByAvailableDrivers.locationLatitude = map["latitude"];
              activeNearByAvailableDrivers.locationLongitude = map["longitude"];
              activeNearByAvailableDrivers.driverId = map["key"];
              displayActiveDriversOnUsersMap();
              break;

            //display those online active drivers on user's map
            case Geofire.onGeoQueryReady:
              activeNearbyDriverKeysLoaded = true;
              displayActiveDriversOnUsersMap();
              break;
          }
        } else {
          print("185");
          Fluttertoast.showToast(msg: "driver is null");
        }

        // setState(() {});
      });
    } catch (err) {
      print("194 + $err");
    }
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driverMarkerSet = Set<Marker>();

      for (ActiveNearByAvailableDrivers eachDriver
          in GeoFireAssistant.activeNearByAvailableDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driverMarkerSet.add(marker);
      }

      setState(() {
        markerSet = driverMarkerSet;
      });
    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(0.8, 0.8));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car2.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition!.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition!.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    setState(() {
      get_directionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLInePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatedList.clear();

    if (decodePolyLInePointsResultList.isNotEmpty) {
      decodePolyLInePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        // color: darkTheme ? Colors.amberAccent : Colors.blue,
        color: Colors.black,
        polylineId: PolylineId("polylineID"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });
  }

  void showSearchingForDriversContainer() {
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  void showSuggestedRidesContainer() {
    setState(() {
      suggestedRidesContainerHeight = 420;
      bottomPaddingOfMap = 400;
      remove_bottomBar = true;
    });
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: mapkey);

      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;

        //update current address as soon as the user change cursor to new address
        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);
        _address = data.address;
      });
    } catch (e) {}
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  saveRideRequestInformation(String selectedVehicleType) {
    //1. save the rideRequest information

    print("398");

    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      //*key: value*
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString()
    };

    Map destinationLocationMap = {
      //*key: value*
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation!.locationLongitude.toString()
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
      "fareAmount": fareAmount
    };

    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverPhone"] != null) {
        setState(() {
          driverPhone =
              (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverName"] != null) {
        setState(() {
          driverName =
              (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["ratings"] != null) {
        setState(() {
          driverRatings =
              (eventSnap.snapshot.value as Map)["ratings"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        setState(() {
          userRideRequestStatus =
              (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["driverLocation"] != null) {
        double driverCurrentPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["latitude"]);
        double driverCurrentPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)["driverLocation"]["longitude"]);

        LatLng driverCurrentPositionLatLng =
            LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        //status =  accepted
        if (userRideRequestStatus == "accepted") {
          updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
        }
        //status = arrived
        if (userRideRequestStatus == "arrived") {
          setState(() {
            driverRideStatus = "Driver has arrived";
          });
        }

        //status = onTrip
        if (userRideRequestStatus == "ontrip") {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }

        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse(
                (eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
                context: context,
                builder: (BuildContext context) => PayFareAmountDialog(
                      fareAmount: fareAmount,
                    ));

            print(response);
            if (response == "Cash Paid") {
              // user can rate the driver now

              if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
                String assignedDriverId =
                    (eventSnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => RateDriverScreen(
                              assignedDriverId: assignedDriverId,
                            )));

                referenceRideRequest!.onDisconnect();
                tripRidesRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    onlineNearByAvailableDriversList =
        GeoFireAssistant.activeNearByAvailableDriversList;
    searchNearestOnlineDrivers(selectedVehicleType);
  }

  searchNearestOnlineDrivers(String selectedVehicleType) async {
    if (onlineNearByAvailableDriversList.length == 0) {
      //cancel/delete the rideRequest Information
      referenceRideRequest!.remove();

      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinatedList.clear();
        remove_bottomBar = false;
      });

      Fluttertoast.showToast(msg: "No online nearest Driver Available");

      Future.delayed(Duration(milliseconds: 4000), () {
        referenceRideRequest!.remove();
        // Navigator.push(context, MaterialPageRoute(builder: (c) => Splash()));
      });

      return;
    }

    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    for (int i = 0; i < driversList.length; i++) {
      //push notification cloud messaging
      // if (driversList[i]["information"]["offers"] == selectedVehicleType) {
      //   print("545 ${driversList[i]}");
      //   AssistantMethods.sendNotificationToDriverNow(
      //       driversList[i]["token"], referenceRideRequest!.key!, context);
      // }

      //push notification real time database;
      if (driversList[i]["information"]["offers"] == selectedVehicleType) {
        AssistantMethods.sendNotificationToDriverNow(
            driversList[i]["id"], referenceRideRequest!.key!, context);
      }
    }

    Fluttertoast.showToast(msg: "Notification sent successfully");

    showSearchingForDriversContainer();

    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(referenceRideRequest!.key!)
        .child("driverId")
        .onValue
        .listen((eventRideRequestSnapshot) {
      print("EventSnapshot: ${eventRideRequestSnapshot.snapshot.value}");

      if (eventRideRequestSnapshot.snapshot.value != null) {
        if (eventRideRequestSnapshot.snapshot.value != "waiting") {
          showUIForAssignedDriverInfo();
        }
      }
    });
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      LatLng userPickUpPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickUpPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus = "Driver is coming: " +
            directionDetailsInfo.distance_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation!.locationLongitude!);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng, userDestinationPosition);

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() async {
        driverRideStatus = "Going Towards Destination (" +
            directionDetailsInfo.duration_text.toString() +
            ")";
      });

      requestPositionInfo = true;
    }
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationcontaiinerHeight = 0;
      assignedDriverInfoContainerHeight = 200;
      suggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref
          .child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = (dataSnapshot.snapshot.value) as Map;

        driverKeyInfo["id"] = onlineNearestDriversList[i].driverId.toString();

        driversList.add(driverKeyInfo);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    locateUserPosition();

    //----
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    createActiveNearByDriverIconMarker();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: 180, top: 50),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {});
                locateUserPosition();
              },
              onCameraMove: (CameraPosition? position) {
                if (!readCurrentLocation && pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },
              onCameraIdle: () {
                readCurrentLocation == true ? null : getAddressFromLatLng();
              },
            ),
            Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35.0),
                  child: Image.asset("images/pick.png", height: 45, width: 45),
                )),

            //CUSTOM HAMBURGER BUTTON FOR DRAWER
            Positioned(
                top: 50,
                left: 20,
                child: Container(
                    child: GestureDetector(
                  onTap: () {
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                      child: Icon(Icons.menu, color: Colors.white)),
                ))),

            //UI for searching location
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(children: [
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade100,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(Icons.my_location),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Pick Up",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                              Provider.of<AppInfo>(context)
                                                          .userPickUpLocation !=
                                                      null
                                                  ? shortenString(
                                                      Provider.of<AppInfo>(
                                                              context)
                                                          .userPickUpLocation!
                                                          .locationName
                                                          .toString())
                                                  : "Not getting address",
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Divider(
                                    height: 1,
                                    thickness: 2,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                      padding: EdgeInsets.all(5),
                                      child: GestureDetector(
                                        onTap: () async {
                                          //go to search places screen
                                          var responseFromSearchScreen =
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          SearchPlacesScreen()));

                                          if (responseFromSearchScreen ==
                                              "obtainedDropoff") {
                                            setState(() {
                                              openNavigationDrawer = false;
                                            });
                                          }

                                          await drawPolyLineFromOriginToDestination(
                                              darkTheme);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Destination?",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    Provider.of<AppInfo>(
                                                                    context)
                                                                .userDropOffLocation !=
                                                            null
                                                        // ? Provider.of<AppInfo>(
                                                        //         context)
                                                        //     .userDropOffLocation!
                                                        //     .locationName!
                                                        ? shortenString(Provider
                                                                .of<AppInfo>(
                                                                    context)
                                                            .userDropOffLocation!
                                                            .locationName!
                                                            .toString())
                                                        : "Where to?",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              )),
                          SizedBox(height: 5),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     ElevatedButton(
                          //       onPressed: () {
                          //         Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //                 builder: (c) =>
                          //                     PrecisePickUpScreen()));
                          //       },
                          //       child: Text(
                          //         "Change Pick Up",
                          //         style: TextStyle(color: Colors.white),
                          //       ),
                          //       style: ElevatedButton.styleFrom(
                          //         textStyle: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.white,
                          //           fontSize: 16,
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(width: 10),
                          //     ElevatedButton(
                          //       onPressed: () {},
                          //       child: Text(
                          //         "Request a ride",
                          //         style: TextStyle(color: Colors.white),
                          //       ),
                          //       style: ElevatedButton.styleFrom(
                          //         textStyle: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.white,
                          //           fontSize: 16,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // )
                        ]),
                      )
                    ],
                  ),
                )),

            //UI FOR SUGGESTED RIDES
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: suggestedRidesContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20))),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  suggestedRidesContainerHeight = 0;
                                  remove_bottomBar = false;
                                });
                              },
                              icon: Icon(Icons.cancel))),
                      Container(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(Icons.star, color: Colors.white),
                            ),
                            SizedBox(width: 15),
                            Text(Provider.of<AppInfo>(context)
                                        .userPickUpLocation !=
                                    null
                                ? shortenString(Provider.of<AppInfo>(context)
                                    .userPickUpLocation!
                                    .locationName!
                                    .toString())
                                : "Not getting address"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Icon(Icons.star, color: Colors.white),
                            ),
                            SizedBox(width: 15),
                            Text(Provider.of<AppInfo>(context)
                                        .userDropOffLocation !=
                                    null
                                ? shortenString(Provider.of<AppInfo>(context)
                                    .userDropOffLocation!
                                    .locationName!
                                    .toString())
                                : "Not getting address"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("SELECT YOUR RIDES",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVehicleType = "Taxi";
                                fareAmount = ((AssistantMethods
                                            .calculateFareAmountFromOriginToDestination(
                                                get_directionDetailsInfo!) *
                                        2))
                                    .toStringAsFixed(1);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Taxi"
                                    ? Color(0xFF0D0B81)
                                    : Color.fromARGB(255, 19, 14, 14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Column(children: [
                                  Image.asset("images/car2.png", width: 30),
                                  SizedBox(height: 8),
                                  Text("Book a Taxi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text(
                                      // tripDirectionDetailsInfo != null
                                      get_directionDetailsInfo != null
                                          ? "\u20A6 ${((AssistantMethods.calculateFareAmountFromOriginToDestination(get_directionDetailsInfo!) * 2)).toStringAsFixed(1)}"
                                          : "null",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                ]),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVehicleType = "Bike";
                                fareAmount = ((AssistantMethods
                                            .calculateFareAmountFromOriginToDestination(
                                                get_directionDetailsInfo!) *
                                        0.8))
                                    .toStringAsFixed(1);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Bike"
                                    ? Color(0xFF0D0B81)
                                    : Color.fromARGB(255, 19, 14, 14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Column(children: [
                                  Image.asset(
                                    "images/bike.png",
                                    width: 30,
                                  ),
                                  SizedBox(height: 8),
                                  Text("Dispatch Ride",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text(
                                      get_directionDetailsInfo != null
                                          ? "\u20A6 ${((AssistantMethods.calculateFareAmountFromOriginToDestination(get_directionDetailsInfo!) * 0.8)).toStringAsFixed(1)}"
                                          : "null",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                ]),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedVehicleType != "") {
                              setState(() {
                                remove_bottomBar = true;
                                suggestedRidesContainerHeight = 0;
                              });

                              saveRideRequestInformation(selectedVehicleType);
                            } else {
                              AlertBox().showAlertDialog(
                                  context,
                                  "Booking Ride",
                                  "No rider available at the moment");
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Color(0xFF0D0B81),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text("Book Ride",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20))),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            ///Requesting a ride
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: searchingForDriverContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(children: [
                    LinearProgressIndicator(
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        "Searching for a driver....",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        referenceRideRequest!.remove();

                        referenceDriverReceiveRequest =
                            FirebaseDatabase.instance.ref();

                        for (int i = 0;
                            i < onlineNearByAvailableDriversList.length;
                            i++) {
                          await referenceDriverReceiveRequest
                              ?.child('drivers')
                              .child(onlineNearByAvailableDriversList[i]
                                  .driverId
                                  .toString())
                              .child("messages")
                              .remove();
                        }

                        setState(() {
                          referenceRideRequest!.remove();
                          searchingForDriverContainerHeight = 0;
                          suggestedRidesContainerHeight = 0;
                          remove_bottomBar = false;
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            )),
                        child: Icon(Icons.close, size: 30, color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: double.infinity,
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ))
                  ]),
                ),
              ),
            ),

            //UI for displaying assigned driver information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: assignedDriverInfoContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        driverRideStatus,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Divider(
                        thickness: 1,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driverName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Row(children: [
                                    Icon(Icons.star, color: Colors.orange),
                                    SizedBox(width: 5),
                                    Text(driverRatings,
                                        style: TextStyle(color: Colors.grey))
                                  ])
                                ],
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset("images/car2.png", scale: 3),
                              Text(driverCarDetails,
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      ElevatedButton.icon(
                          onPressed: () {
                            _makePhoneCall("tel: $driverPhone");
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.blue),
                          icon: Icon(Icons.phone),
                          label: Text(
                            "Call Driver",
                          ))
                    ],
                  ),
                ),
              ),
            )
            // Positioned(
            //   top: 40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //       decoration: BoxDecoration(
            //           border:
            //               Border.all(color: Color.fromARGB(255, 23, 79, 110)),
            //           color: Colors.white),
            //       padding: EdgeInsets.all(20),
            //       child: Text(
            //         Provider.of<AppInfo>(context).userPickUpLocation != null
            //             ? (Provider.of<AppInfo>(context)
            //                         .userPickUpLocation!
            //                         .locationName)!
            //                     .substring(0, 24) +
            //                 "..."
            //             : "Not getting address",
            //         overflow: TextOverflow.visible,
            //         softWrap: true,
            //       )),
            // )
          ],
        ),
        bottomNavigationBar: remove_bottomBar
            ? null
            : BottomAppBar(
                shape: const CircularNotchedRectangle(),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Color(0xFF0D47A1),
                child: SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => PrecisePickUpScreen()));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 5),
                              Text("Change Pick Up",
                                  style: TextStyle(color: Colors.white))
                            ],
                          )),
                      GestureDetector(
                          onTap: () async {
                            //go to search places screen
                            var responseFromSearchScreen = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => SearchPlacesScreen()));

                            if (responseFromSearchScreen == "obtainedDropoff") {
                              setState(() {
                                openNavigationDrawer = false;
                                //checking if the user has set destination
                                readCurrentLocation = true;
                              });
                            }

                            await drawPolyLineFromOriginToDestination(
                                darkTheme);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions,
                                size: 30.0,
                                color: Colors.white,
                              ),
                              SizedBox(height: 5),
                              Text("Set Destination",
                                  style: TextStyle(color: Colors.white))
                            ],
                          ))
                    ],
                  ),
                ),
              ),
        floatingActionButtonLocation:
            remove_bottomBar ? null : FloatingActionButtonLocation.centerDocked,
        floatingActionButton: remove_bottomBar
            ? null
            : FloatingActionButton(
                backgroundColor: Color(0xFF0D47A1),
                onPressed: (() {
                  if (Provider.of<AppInfo>(context, listen: false)
                          .userDropOffLocation !=
                      null) {
                    showSuggestedRidesContainer();
                  } else {
                    Fluttertoast.showToast(
                        msg: "Please select desination location");
                  }
                  // AlertBox().showAlertDialog(
                  //     context, "Booking Ride", "No rider available at the moment");
                }),
                tooltip: 'Request A Ride',
                shape: const CircleBorder(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon(Icons.directions_bike_sharp, size: 30),
                      Icon(Icons.monetization_on, size: 30),

                      Text(
                        "Fare",
                        style: TextStyle(fontSize: 10),
                      )
                    ]),
              ),
      ),
    );
  }
}
