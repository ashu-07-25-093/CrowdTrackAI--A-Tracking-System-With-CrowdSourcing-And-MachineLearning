import 'dart:async';

// import 'package:drivers_app/global/global.dart';
// import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_methods.dart';
// import '../assistants/black_theme_google_map.dart';
import '../global/global.dart';
// import '../models/user_ride_request_information.dart';
import '../widgets/progress_dialog.dart';
import 'Table.dart';
import 'main_screen_three_crowdsource.dart';


class MainScreenTwo extends StatefulWidget
{
  // UserRideRequestInformation? userRideRequestDetails;

  // NewTripScreen({
  //   this.userRideRequestDetails,
  // });

  @override
  State<MainScreenTwo> createState() => _MainScreenTwoState();
}




class _MainScreenTwoState extends State<MainScreenTwo>
{
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.9516235531604, 80.1405615858957),
    zoom: 14.4746,
  );

  String? buttonTitle = "Start Tracking(click)";
  Color? buttonColor = Colors.green;
  // String? statusBtn = "accepted";

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  final _controller = TextEditingController();

  // BitmapDescriptor customIcon;

// make sure to initialize before map loading
//   BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
//   "Images/car.png")
//       .then((d) {
//   customIcon = d;
//   });



  //Step 1:: when driver accepts the user ride request
  // originLatLng = driverCurrent Location
  // destinationLatLng = user PickUp Location

  //Step 2:: driver already picked up the user in his/her car
  // originLatLng = user PickUp Location => driver current Location
  // destinationLatLng = user DropOff Location

  var lati = 12.9516235531605 , longi = 80.1405615858956;

  Future<void> trial_fun()
  async {

    if(iconAnimatedMarker == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "Images/car.png").then((value)
      {
        iconAnimatedMarker = value;
      });
    }

    // var isDriverDAta = true;
    //
    // var llaatt = 0 , lloonn = 0;
    // await FirebaseDatabase.instance.ref()
    //     .child("activeDrivers")
    //     .child(chosenDriverId!)
    //     .once()
    //     .then((snap) {
    //   // var snap = event.snapshot;
    //
    //
    //   if(snap.snapshot.exists)
    //     {
    //       ;
    //     }
    //   else
    //     {
    //       isDriverDAta = false;
    //     }
    //
    // });




      FirebaseDatabase.instance
          .ref()
          .child("activeDrivers")
          .child(chosenDriverId!)
          .onValue
          .listen((snap) {
        // var snap = event.snapshot;
        
        if(!snap.snapshot.exists)
          {
            print("\n\nStoped\n\n");
            // Navigator.push(context, route)

            Fluttertoast.showToast(msg: "Not Receving Bus Data , doing alternate Solution !!!");

            Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreenThree()));

            // Navigator.pop(context);
          }


        lati = (snap.snapshot.value as Map)["l"][0];
        longi = (snap.snapshot.value as Map)["l"][1];
        print('Value is :\n\n\n\n\\n');
        print(lati);
        print(longi);

        // Timer(Duration(milliseconds: 500), () async {
        //   print("\nHello\n");
        //             fun();
        // });

        print("\nHello\n");
        fun();

        LatLng originLatLan = LatLng(lati, longi);

        Marker originMarker = Marker(
          markerId: const MarkerId("origin"),
          infoWindow: InfoWindow(title: "origin", snippet: "Origin"),
          position: originLatLan,
          // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
          icon: iconAnimatedMarker!,
        );

        setState(() {
          print("Hello");
          CameraPosition cameraPosition = CameraPosition(
              target: originLatLan, zoom: 16);
          newTripGoogleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(cameraPosition));

          setOfMarkers.add(originMarker);
          // markersSet.add(destinationMarker);
        });
        //
        // print(lati);
        // print(longi);
        //
        // print("\n\n\n\n\n");

      });






    print('Value that u got is :\n\n\n\n\\n');

    print(lati);
    print(longi);

    print("\n\n\n\n\n");

    print("TextEditng controller vlue = " + _controller.text);

    fun();

    //
    //
    // Marker originMarker = Marker(
    //   markerId: const MarkerId("origin"),
    //   infoWindow: InfoWindow(title: "origin", snippet: "Origin"),
    //   position: originLatLan,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    // );
    //
    // setState(() {
    //   setOfMarkers.add(originMarker);
    //   // markersSet.add(destinationMarker);
    // });

   // print("Did it come out ??");



  }

  //
  // fun()
  // async {
  //
  //   // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   // var _distanceInMeters = await Geolocator.distanceBetween(
  //   //   driverCurrentPosition!.latitude,
  //   //   driverCurrentPosition!.longitude,
  //   //   position.latitude,
  //   //   position.longitude,
  //   // );
  //
  //   // print("\n\n\n\n");
  //   // print(_distanceInMeters);
  //   // print(driverCurrentPosition!.speed);
  //   // print("\n\n\n\n");
  //   //
  //   return "hello";
  //
  // }

  // var i = 1;

  String time_Left = "Click To see Time...";

  fun()
   async {


     var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

     print("\n\n Ye tu print kra hai");


     // print(driverCurrentPosition!.latitude);
     // print(driverCurrentPosition!.longitude);
     // print("\n\n Ye tu print kra hai");

     var dlat , dlong;

     await FirebaseDatabase.instance.ref()
         .child("activeDrivers")
         .child(chosenDriverId!)
         .once()
         .then((snap) {
       // var snap = event.snapshot;



       dlat = (snap.snapshot.value as Map)["l"][0];
       dlong = (snap.snapshot.value as Map)["l"][1];
       // print(lati);
       // print(longi);


     });

     print('New time is  :\n\n\n\n\\n');
     print(position.longitude); //Output: 80.24599079
     print(position.latitude);
     print(dlat);
     print(dlong);

     var ret = await AssistantMethods.obtainOriginToDestinationDirectionDetails(LatLng(position.latitude , position.longitude) , LatLng(dlat, dlong));






     setState(() {
       // _controller.text = time_Left;
       time_Left = ret!.duration_text.toString();

     });

     print(time_Left);
     print("\n\n\n\n\n");
    return "hihi";
  }



  @override
  Widget build(BuildContext context)
  {
    // createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [

          //google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

            },
          ),


          // ButtonTheme(
          //   child: FlatButton(
          //     padding: EdgeInsets.all(0),
          //     child: Align(
          //       alignment: Alignment.centerLeft,
          //       child: Text(
          //         "(Press Exit)    ",
          //         style: TextStyle(
          //           color: Colors.red,
          //           fontWeight: FontWeight.normal,
          //         ),
          //         textAlign: TextAlign.left,
          //       ),
          //     ),
          //     onPressed: ()
          //     async {
          //
          //       String selDriver = "";
          //       await FirebaseDatabase.instance
          //           .ref()
          //           .child("user_driver_relationship")
          //           .child(currentFirebaseUser!.uid)
          //           .child("bus")
          //           .once()
          //           .then((snap) {
          //
          //         // print(snap.snapshot.key);
          //         selDriver = snap.snapshot.value.toString();
          //
          //       });
          //
          //       print(selDriver);
          //
          //       //(1) delete relation
          //       DatabaseReference dd = FirebaseDatabase.instance.ref()
          //           .child("user_driver_relationship");
          //       dd.child(currentFirebaseUser!.uid).remove();
          //
          //       //(2) delete from bus
          //
          //       if(selDriver != "") {
          //         List ret_list = [];
          //         DatabaseReference ref = FirebaseDatabase.instance.ref()
          //             .child("bus_to_manyusers");
          //
          //         await ref.child(selDriver)
          //             .once()
          //             .then((dataSnapshot) {
          //           var t = dataSnapshot.snapshot
          //               .child("bus")
          //               .value as List?;
          //
          //           //print(t);
          //           // print(t.isEmpty);
          //
          //           if (t != null && t!.isNotEmpty)
          //             for (int i = 0; i < t!.length; i++) {
          //               ret_list.add(t[i]);
          //             }
          //         });
          //         ret_list?.remove(currentFirebaseUser!.uid);
          //         Map driverMap2 =
          //         {
          //           "bus": ret_list
          //         };
          //         //
          //         DatabaseReference driversReference = FirebaseDatabase
          //             .instance.ref()
          //             .child("bus_to_manyusers");
          //         driversReference.child(selDriver).set(driverMap2);
          //       }
          //       //(3) remove from active Users
          //
          //
          //
          //       DatabaseReference dd4 = FirebaseDatabase.instance.ref()
          //           .child("activeDrivers");
          //       dd4.child(currentFirebaseUser!.uid).remove();
          //
          //       DatabaseReference dd3 = FirebaseDatabase.instance.ref()
          //           .child("activeUsers");
          //       dd3.child(currentFirebaseUser!.uid).remove();
          //
          //
          //       //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
          //       SystemNavigator.pop();
          //
          //
          //
          //
          //
          //
          //
          //       print("khatama bye bye ho gya = " + currentFirebaseUser!.uid.toString());
          //     },
          //   ),
          // ),


          //ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                ),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(0.6, 0.6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [

                    //duration
                    Text(
                      durationFromOriginToDestination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),

                    const SizedBox(height: 18,),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 8,),

                    //user name - icon
                    Row(
                      children: [
                        Text(
                          time_Left,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),


                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 10.0),

                    ElevatedButton.icon(
                      onPressed: ()
                      async {

                       // Fluttertoast.showToast(msg: "Pressed the button");
                        //fun();
                        trial_fun();

                      },
                      style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


}