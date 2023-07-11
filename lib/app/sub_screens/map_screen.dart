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

  BitmapDescriptor? activeNearbyIcon;

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

    print("This is our address = " + humanReadableAddress);

    ///get user from database
    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    // initializeGeoFireListener();

    //AssistantMethods.readTripKeysForOnlineUser(context);
  }

  Future<void> drawPolyLineFromOriginToDestination(darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    print("---------------polyline--------------------");
    print(originPosition);
    print(destinationPosition);

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

  getAddressFromLatLng() async {
    try {
      print(pickLocation!.latitude);
      print(pickLocation!.longitude);
      print("mapkey ${mapkey}");

      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: mapkey);

      print("108 ${data}");

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

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
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
        key: _scaffoldState,
        drawer: DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: 180, top: 50),
              mapType: MapType.normal,
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
                if (pickLocation != position!.target) {
                  setState(() {
                    pickLocation = position.target;
                  });
                }
              },
              onCameraIdle: () {
                getAddressFromLatLng();
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
                                        Icon(Icons.location_on_outlined),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("From",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                Provider.of<AppInfo>(context)
                                                            .userPickUpLocation !=
                                                        null
                                                    ? (Provider.of<AppInfo>(
                                                                    context)
                                                                .userPickUpLocation!
                                                                .locationName)!
                                                            .substring(0, 40) +
                                                        "..."
                                                    : "Not getting address",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14))
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
                                            Icon(Icons.location_on_outlined),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("To?",
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
                                                        ? Provider.of<AppInfo>(
                                                                    context)
                                                                .userDropOffLocation!
                                                                .locationName!
                                                                .substring(
                                                                    0, 40) +
                                                            "..."
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) =>
                                              PrecisePickUpScreen()));
                                },
                                child: Text(
                                  "Change Pick Up",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text(
                                  "Request a ride",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ]),
                      )
                    ],
                  ),
                )),
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
      ),
    );
  }
}
