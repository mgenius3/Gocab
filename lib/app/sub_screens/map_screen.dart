import 'package:Gocab/Assistants/assistant_method.dart';
import 'package:Gocab/app/sub_screens/search_places_screen.dart';
import 'package:Gocab/widget/progress_dialog.dart';
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

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

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
  bool setDestinationActive = false;

  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;
  String selectedVehicleType = " ";

  String driverRideStatus = "Driver is on his way";

  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  bool remove_bottomBar = false;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);

    ///get user from database
    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();

    //AssistantMethods.readTripKeysForOnlineUser(context);
  }

  initializeGeoFireListener() {
    Geofire.initialize("activedDrivers");

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map["callBack"];

        switch (callBack) {
          //whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearByAvailableDrivers activeNearByAvailableDrivers =
                ActiveNearByAvailableDrivers();
            activeNearByAvailableDrivers.locationLatitude = map["latitude"];
            activeNearByAvailableDrivers.locationLatitude = map["longitude"];
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
            activeNearByAvailableDrivers.locationLatitude = map["longitude"];
            activeNearByAvailableDrivers.driverId = map["key"];
            displayActiveDriversOnUsersMap();
            break;

          //display those online active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
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
          createLocalImageConfiguration(context, size: Size(0.2, 0.2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
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
    setState(() {});

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

  void showSuggestedRidesContainer() {
    setState(() {
      suggestedRidesContainerHeight = 400;
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
    } catch (e) {
      print("122 error ${e}");
    }
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  saveRideRequestInformation(String selectedVehicleType) {
    //1. save the rideRequest information

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
      "destinationAddress": destinationLocation.locationName
    };

    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      if ((eventSnap.snapshot.value as Map)["information"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["information"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["information"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["information"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["information"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["information"].toString();
        });
      }
      if ((eventSnap.snapshot.value as Map)["information"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["information"].toString();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
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
                if (!setDestinationActive && pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },
              onCameraIdle: () {
                setDestinationActive == true ? null : getAddressFromLatLng();
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
                                              overflow: TextOverflow.fade,
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
                                selectedVehicleType = "Car";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Car"
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
                                      tripDirectionDetailsInfo != null
                                          ? "t ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 2) * 107).toStringAsFixed(1)}"
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
                                      tripDirectionDetailsInfo != null
                                          ? "t ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 2) * 107).toStringAsFixed(1)}"
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
                                  saveRideRequestInformation(
                                      selectedVehicleType);

                                  AlertBox().showAlertDialog(
                                      context,
                                      "Booking Ride",
                                      "No rider available at the moment");
                                }
                                setState(() {
                                  remove_bottomBar = false;
                                  suggestedRidesContainerHeight = 0;
                                });
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
                                              fontSize: 20))))))
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
                                setDestinationActive = true;
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
