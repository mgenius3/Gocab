import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:Gocab/global/map_key.dart';
import 'package:location/location.dart' as locate;
import 'package:permission_handler/permission_handler.dart';
import 'package:Gocab/app/main_screen/widget/book_dispatch_button.dart';
import 'package:Gocab/app/main_screen/widget/book_taxi_button.dart';
import 'package:Gocab/helper/alertbox.dart';
import 'package:Gocab/app/main_screen/side_screen.dart';
import 'helpers/drawer_transition.dart';

class BookingPage extends StatefulWidget {
  final AlertBox alertBox = AlertBox();
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  bool _isDrawerOpen = false;

  final Completer<GoogleMapController> _controller = Completer();
  locate.Location location = locate.Location();
  GoogleMapController? mapController;

  static const LatLng sourceLocation = LatLng(6.4499345, 3.3915123);
  static const LatLng destination = LatLng(6.5774463, 3.4653376);

  List<LatLng> polylineCoordinates = [];
  locate.LocationData? currentLocation;

  Future<locate.LocationData> getCurrentLocation() async {
    try {
      locate.LocationData currentLocation =
          await locate.Location().getLocation();
      return (currentLocation);
    } catch (e) {
      throw e;
    }
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapkey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    print("polypoints");
    if (result.points.isNotEmpty) {
      print("polypoint");
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrentLocation().then((location) {
      currentLocation = location;
      print(currentLocation);
    });

    getPolyPoints();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    // Dispose the AnimationController
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<locate.LocationData>(
        future: getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred while getting location'),
            );
          } else {
            LatLng? targetLocation;
            print("currentlocation $currentLocation");

            if (currentLocation != null) {
              print("currentlocation $currentLocation");
              targetLocation = LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!);
            }

            return Scaffold(
              key: _scaffoldKey,
              drawer: SideDrawer(),
              body: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) {
                      _controller.complete(controller);
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: targetLocation ?? sourceLocation,
                      zoom: 14.6,
                    ),
                    polylines: {
                      Polyline(
                        polylineId: PolylineId("route"),
                        points: polylineCoordinates,
                        color: Colors.blue,
                        width: 16,
                      ),
                    },
                    markers: {
                      if (targetLocation != null)
                        Marker(
                          markerId: MarkerId("currentLocation"),
                          position: targetLocation,
                        ),
                      Marker(
                          markerId: MarkerId("source"),
                          position: sourceLocation),
                      Marker(
                          markerId: MarkerId("destination"),
                          position: destination),
                    },
                  ),
                  Positioned(
                    top: 36, // Adjust the top position as needed
                    left: 16, // Adjust the left position as needed
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                0.2), // Customize the shadow color and opacity
                            blurRadius: 4, // Adjust the blur radius as needed
                            offset: Offset(
                                0, 2), // Adjust the shadow offset as needed
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.blue, // Customize the icon color
                          size: 24, // Customize the icon size
                        ),
                        onPressed: () {
                          print(currentLocation);
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        // padding: EdgeInsets.all(16.0),
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BookTaxiButton(
                              onPressed: () {
                                widget.alertBox.showAlertDialog(
                                    context,
                                    "Booking Taxi",
                                    "No available Taxi currently");
                              },
                            ),
                            // SizedBox(width: 16.0),
                            BookDispatchRiderButton(
                              onPressed: () {
                                widget.alertBox.showAlertDialog(
                                    context,
                                    "Booking Dispatch",
                                    "No available Dispatch currently");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: Container(
                  margin: EdgeInsets.only(bottom: 106.0),
                  width: 58.0,
                  height: 58.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      location.getLocation().then((currentLocation) {
                        if (currentLocation != null && mapController != null) {
                          mapController!.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(
                                currentLocation.latitude!,
                                currentLocation.longitude!,
                              ),
                            ),
                          );
                        }
                      });
                    },
                    child: Icon(Icons.my_location),
                  )),
            );
          }
        });
  }
}
