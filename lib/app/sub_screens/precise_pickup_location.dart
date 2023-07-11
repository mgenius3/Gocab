import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:Gocab/Assistants/assistant_method.dart';
import "package:geocoder2/geocoder2.dart";
import "package:provider/provider.dart";
import '../../model/direction.dart';
import "../../infoHandler/app_info.dart";
import "../../global/map_key.dart";

class PrecisePickUpScreen extends StatefulWidget {
  const PrecisePickUpScreen({super.key});

  @override
  State<PrecisePickUpScreen> createState() => _PrecisePickUpScreenState();
}

class _PrecisePickUpScreenState extends State<PrecisePickUpScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

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

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap, top: 100),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            setState(() {
              bottomPaddingOfMap = 50;
            });
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
              padding: EdgeInsets.only(top: 60, bottom: bottomPaddingOfMap),
              child: Image.asset("images/pick.png", height: 45, width: 45),
            )),
        Positioned(
          top: 40,
          right: 20,
          left: 20,
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 23, 79, 110)),
                  color: Colors.white),
              padding: EdgeInsets.all(20),
              child: Text(
                Provider.of<AppInfo>(context).userPickUpLocation != null
                    ? (Provider.of<AppInfo>(context)
                                .userPickUpLocation!
                                .locationName)!
                            .substring(0, 24) +
                        "..."
                    : "Not getting address",
                overflow: TextOverflow.visible,
                softWrap: true,
              )),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text("Set Current Location"),
            ),
          ),
        )
      ],
    ));
  }
}
