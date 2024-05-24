import 'dart:async';
import 'dart:math';
// import 'package:drivers_app/assistants/assistant_methods.dart';
// import 'package:drivers_app/global/global.dart';
// import 'package:drivers_app/main.dart';
// import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../push_notifications/push_notification_system.dart';


class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}



class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  Marker? _driverLocationMarker;
  // Initialize the Geolocator
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  LatLng _currentPosition = LatLng(12.9864308, 80.2385628); // Default position
  Set<Marker> markersSet = {};

  String statusText = "Now Offline";

  Color buttonColor = Colors.grey;
  Color buttonHostel = Colors.transparent;
  Color buttonMainGate = Colors.transparent;

  bool isDriverActive = false;
  double l1 = 0 , l2 = 0 , l3 = 0 , l4 = 0 , l5 = 0;
  double n1 = 0 , n2 = 0 , n3 = 0 , n4 = 0 , n5 = 0;

  String currentStation = "";
  String myRoute = "";
  String prev_stop = "";
  String next_stop = "";
  int index = 0;
  String route = "";
  bool onOff = false;        // so that two buttons will be appear as the driver gets online
  int p = 0;


  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods
        .searchAddressForGeographicCoordinates(driverCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);
  }

  readCurrentDriverInformation() async
  {
    currentFirebaseUser = fAuth.currentUser;

    await FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((DatabaseEvent snap)
    {
      if(snap.snapshot.value != null)
      {
        onlineDriverData!.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriverData.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_number = (snap.snapshot.value as Map)["car_details"]["car_number"];

        print("Car Details :: ");
        print(onlineDriverData.car_color);
        print(onlineDriverData.car_model);
        print(onlineDriverData.car_number);
      }
    });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
    locateDriverPosition();
    readCurrentDriverInformation();
  }

  // Aashay chanegs started

  // Function to update the marker's position
  void updateMarkerPosition(LatLng newPosition) {
    setState(() {
      _driverLocationMarker = Marker(
        markerId: MarkerId("driver_location"),
        position: newPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    driverIsOnlineNow();
    updateDriversLocationAtRealTime();
    print("in marker updation\n");
  }

  // Function to continuously listen for location updates
  void listenToLocationUpdates() async {
    _geolocatorPlatform.getPositionStream(
      // desiredAccuracy: LocationAccuracy.best,
      // distanceFilter: 10, // Minimum distance (in meters) between location updates
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      updateMarkerPosition(newPosition);
      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(
          CameraUpdate.newLatLng(newPosition),
        );
      }
    });
  }

  // Aashay Changes ended

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            //initialCameraPosition: _kGooglePlex,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),

            markers: markersSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              //black theme google map
              blackThemeGoogleMap();
              checkIfLocationPermissionAllowed();
              locateDriverPosition();
            },
          ),




          //ui for online offline driver
          statusText != "Now Online"
              ? Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: Colors.black87,
          )
              : Container(),

          //button for online offline driver
          Positioned(
            top: statusText != "Now Online"
                ? MediaQuery.of(context).size.height * 0.46
                : 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: ()
                  {
                    if(isDriverActive != true) //offline
                        {
                      // driverIsOnlineNow();
                      // listenToLocationUpdates();
                      // updateDriversLocationAtRealTime();

                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        onOff = true;
                        buttonColor = Colors.transparent;
                        buttonHostel = Colors.grey;
                        buttonMainGate = Colors.grey;

                      });

                      // DateTime now = DateTime.now();
                      //
                      // print("current hour is : ");
                      // print(now.hour);
                      // print("\n");

                      //display Toast
                      Fluttertoast.showToast(msg: "you are Online Now");
                    }
                    else //online
                        {
                      driverIsOfflineNow();

                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        onOff = false;
                        buttonColor = Colors.grey;
                        buttonHostel = Colors.transparent;
                        buttonMainGate = Colors.transparent;
                      });

                      //display Toast
                      Fluttertoast.showToast(msg: "you are Offline Now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: statusText != "Now Online"
                      ? Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.phonelink_ring,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: statusText == "Now Online" && (onOff || currentStation=="ganga" || currentStation=="main gate")
                ? MediaQuery.of(context).size.height * 0.46
                :30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: ()
                  async {
                    buttonColor = Colors.transparent;
                    buttonHostel = Colors.transparent;
                    buttonMainGate = Colors.transparent;

                    index = 0;
                    route = "htom";
                    myRoute = "toM";
                    onOff = false;

                    await driverIsOnlineNow();

                    // Position pos = Geolocator.getCurrentPosition(
                    //   desiredAccuracy: LocationAccuracy.high,
                    // ) as Position;
                    //
                    // driverCurrentPosition = pos;
                    //
                    // double dist_to_ganga = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations["ganga"]?[0], stations["ganga"]?[1]);
                    // double dist_to_main_gate = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations["main gate"]?[0], stations["main gate"]?[1]);
                    //
                    // if(dist_to_ganga < 0.05)
                    // {
                    //   currentStation = "ganga";
                    // }
                    // else if(dist_to_main_gate < 0.05)
                    // {
                    //   currentStation = "main gate";
                    // }
                    print("p : ");
                    print(p);

                    if(currentStation=="ganga")
                    {
                      next_stop = "himalaya";
                      prev_stop = "ganga";
                    }
                    else if(currentStation=="main gate")
                    {
                      next_stop = "residential";
                      prev_stop = "main gate";
                    }
                    // else if(currentStation == "velachery")
                    //   {
                    //     next_stop = "ocean engineering";
                    //     prev_stop = "velachery";
                    //   }

                    listenToLocationUpdates();
                    updateDriversLocationAtRealTime();

                    DatabaseReference driversRef1 = FirebaseDatabase.instance.ref().child("activeDrivers");

                    // double dist_1 = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations[next_stop]?[0], stations[next_stop]?[1]);
                    //
                    // Map driverMap_ =
                    // {
                    //
                    //   "0" : driverCurrentPosition!.latitude,
                    //   "1" : driverCurrentPosition!.longitude,
                    //   "route" : myRoute,
                    //   "nextStop" : next_stop,
                    //   "distToNext" : dist_1
                    // };
                    //
                    // driversRef1.child(currentFirebaseUser!.uid).set(driverMap_); //saving the value of map
                    //
                    // print("dist in button1");
                    // print(dist_1);
                    // print("next station : "+next_stop);


                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonHostel,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: statusText == "Now Online" && (onOff || currentStation=="ganga" || currentStation=="main gate")
                      ? Text(
                    "to MainGate",
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    "",
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.transparent,
                    ),
                  )
                ),

                ElevatedButton(
                    onPressed: ()
                    async {
                      buttonColor = Colors.transparent;
                      buttonHostel = Colors.transparent;
                      buttonMainGate = Colors.transparent;

                      index = 0;
                      route = "mtoh";
                      myRoute = "toH";
                      onOff = false;

                      await driverIsOnlineNow();

                      // Position pos = Geolocator.getCurrentPosition(
                      //   desiredAccuracy: LocationAccuracy.high,
                      // ) as Position;
                      //
                      // driverCurrentPosition = pos;
                      //
                      // double dist_to_ganga = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations["ganga"]?[0], stations["ganga"]?[1]);
                      // double dist_to_main_gate = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations["main gate"]?[0], stations["main gate"]?[1]);
                      //
                      //
                      // if(dist_to_ganga < 0.05)
                      // {
                      //   currentStation = "ganga";
                      // }
                      // else if(dist_to_main_gate < 0.05)
                      // {
                      //   currentStation = "main gate";
                      // }

                      print("p : ");
                      print(p);

                      if(currentStation=="ganga")
                      {
                        next_stop = "himalaya";
                        prev_stop = "ganga";
                      }
                      else if(currentStation=="main gate")
                      {
                        next_stop = "residential";
                        prev_stop = "main gate";
                      }
                      // else if(currentStation == "velachery")
                      // {
                      //   next_stop = "ocean engineering";
                      //   prev_stop = "velachery";
                      // }

                      listenToLocationUpdates();
                      updateDriversLocationAtRealTime();

                      // DatabaseReference driversRef2 = FirebaseDatabase.instance.ref().child("activeDrivers");
                      //
                      // double dist_2 = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations[next_stop]?[0], stations[next_stop]?[1]);
                      //
                      // Map driverMap_2 =
                      // {
                      //
                      //   "0" : driverCurrentPosition!.latitude,
                      //   "1" : driverCurrentPosition!.longitude,
                      //   "route" : myRoute,
                      //   "nextStop" : next_stop,
                      //   "distToNext" : dist_2
                      // };
                      //
                      // driversRef2.child(currentFirebaseUser!.uid).set(driverMap_2); //saving the value of map
                      //
                      // print("dist in button2");
                      // print(dist_2);
                      // print("next station : "+next_stop);


                    },
                    style: ElevatedButton.styleFrom(
                      primary: buttonMainGate,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: statusText == "Now Online" && (onOff || currentStation=="ganga" || currentStation=="main gate")
                        ? Text(
                      "to Hostel",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      "",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.transparent,
                      ),
                    )
                ),
              ],
            ),
          ),


        ],
    );
  }

  distance(lat1, lon1, lat2, lon2) {
    var p = pi/180.0;
    var a = 0.5 - cos((lat2-lat1)*p)/2 + cos(lat1*p) * cos(lat2*p) * (1-cos((lon2-lon1)*p))/2;
    return 12742 * asin(sqrt(a)); //In KM
  }

  driverIsOnlineNow() async
  {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");

    // Geofire.setLocation(
    //     currentFirebaseUser!.uid,
    //     driverCurrentPosition!.latitude,
    //     driverCurrentPosition!.longitude
    // );

    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("activeDrivers");

    double dist_to_ganga = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations["ganga"]?[0], stations["ganga"]?[1]);
    double dist_to_main_gate = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations["main gate"]?[0], stations["main gate"]?[1]);
    double dist_to_velachery = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations["velachery"]?[0], stations["velachery"]?[1]);

    if(dist_to_ganga <= 0.1)
      {
        currentStation = "ganga";
      }
    else if(dist_to_main_gate <= 0.1)
      {
        currentStation = "main gate";
      }
    else if(dist_to_velachery <= 0.1)
    {
      currentStation = "velachery";
    }

    if(currentStation=="ganga")
    {
      next_stop = "himalaya";
      prev_stop = "ganga";
    }
    else if(currentStation=="main gate")
    {
      next_stop = "residential";
      prev_stop = "main gate";
    }
    else if(currentStation == "velachery")
    {
      next_stop = "ocean engineering";
      prev_stop = "velachery";
    }


    double dist_ = 0;
    if(next_stop!=null && next_stop!="")
        dist_ = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations[next_stop]?[0], stations[next_stop]?[1]);

    Map driverMap =
    {

      "0" : driverCurrentPosition!.latitude,
      "1" : driverCurrentPosition!.longitude,
      "route" : myRoute,
      "nextStop" : next_stop,
      "distToNext" : dist_
    };

    driversRef.child(currentFirebaseUser!.uid).set(driverMap); //saving the value of map

    print("dist in driver Online");
    print(dist_);
    print("next station : "+next_stop);


    Marker driverMarker = Marker(
      markerId: const MarkerId("driver_location"),
      position: LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(driverMarker);
    });

    p++;

    //
    // Geofire.initialize("activeDrivers1");
    //
    // Geofire.setLocation(
    //     currentFirebaseUser!.uid,
    //     driverCurrentPosition!.latitude- 1,
    //     driverCurrentPosition!.longitude - 1
    // );
    //
    // Geofire.initialize("activeDrivers2");
    //
    // Geofire.setLocation(
    //     currentFirebaseUser!.uid,
    //     driverCurrentPosition!.latitude- 2,
    //     driverCurrentPosition!.longitude - 2
    // );





    // Map driverlastFiveMap =
    // {
    //   "id": currentFirebaseUser!.uid,
    //   "fir":x+1,
    //   "sec": x+2,
    //   "thir": x+3,
    //   "for":x+4,
    //   "fif":x+5
    // };
    // x += 1;
    // //
    // DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("lastfivelatlongdrivers");
    // driversRef.child(currentFirebaseUser!.uid).set(driverlastFiveMap); //saving the value of map
    //
    //
    // //Update New ride status if driver gets new ride
    // DatabaseReference ref = FirebaseDatabase.instance.ref()
    //     .child("drivers")
    //     .child(currentFirebaseUser!.uid)
    //     .child("newRideStatus");
    //
    // ref.set("idle"); //searching for ride request
    // ref.onValue.listen((event) { }); // listen for coming req,(accept or reject)
  }

  updateDriversLocationAtRealTime()
  {
    //get the moving position of Driver in a stream
    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
      driverCurrentPosition = position;

      // Aashay Changes started
      double? ganga_lat = stations["ganga"]?[0];
      double? ganga_lon = stations["ganga"]?[1];
      double? maingate_lat = stations["main gate"]?[0];
      double? maingate_lon = stations["main gate"]?[1];
      double? velachery_lat = stations["velachery"]?[0];
      double? velachery_lon = stations["velachery"]?[1];

      double dist1 = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, ganga_lat, ganga_lon);
      double dist2 = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, maingate_lat, maingate_lon);
      double dist3 = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, velachery_lat, velachery_lon);

      //FirebaseDatabase.instance.ref().child("modelData").child(currentFirebaseUser!.uid).update({"distToNext" : 350});

      double? next_st_lat = stations[routeDetect[route]?[index+1]]?[0];
      double? next_st_lon = stations[routeDetect[route]?[index+1]]?[1];


      double dist_ = 1e9;

      if(next_stop!=null && next_stop!="")
        {
          dist_ = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, next_st_lat, next_st_lon);
          print("index is : ");
          print(index);
          print("next station is : "+next_stop);
          print("now dist to next is : ");
          print(dist_);
        }


      print("dist in updateDriver");
      print(dist_);
      print("next station : "+next_stop);

      if(dist_ <= 0.1)
        {
          prev_stop = next_stop;
          next_stop = routeDetect[route]![index+1];
          index++;
        }

      if(dist1 <= 0.1)
      {
          currentStation = "ganga";
      }
      else if(dist2 <= 0.1)
        {
            currentStation = "main gate";
        }
      else if(dist3 <= 0.1)
        {
          currentStation = "velachery";
        }
      else
        {
          currentStation = "";
        }

      if(statusText=="Now Online" && (currentStation=="ganga" || currentStation=="main gate"))
        {
            buttonColor = Colors.transparent;
            buttonHostel = Colors.grey;
            buttonMainGate = Colors.grey;
        }
      // else if(statusText=="Now Online" && currentStation=="")
      //   {
      //     buttonColor = Colors.transparent;
      //     buttonHostel = Colors.transparent;
      //     buttonMainGate = Colors.transparent;
      //   }

      // Aashay Changes ended

      if(isDriverActive == true)
      {
        // Geofire.setLocation(
        //     currentFirebaseUser!.uid,
        //     driverCurrentPosition!.latitude,
        //     driverCurrentPosition!.longitude
        // );

        // Aashay Changes started
        DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("activeDrivers");

        //double d = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations[next_stop]?[0], stations[next_stop]?[1]);

        Map driverMap =
        {

          "0" : driverCurrentPosition!.latitude,
          "1" : driverCurrentPosition!.longitude,
          "route" : myRoute,
          "nextStop" : next_stop,
          "distToNext" : dist_
        };

        driversRef.child(currentFirebaseUser!.uid).set(driverMap); //saving the value of map

        // Aashay Changes ended

        if(driverCurrentPosition!.latitude != l1 && driverCurrentPosition!.longitude != n1)
          {

            l5 = l4;
            l4 = l3;
            l3 = l2;
            l2 = l1;
            l1 = driverCurrentPosition!.latitude;

            n5 = n4;
            n4 = n3;
            n3 = n2;
            n2 = n1;
            n1 = driverCurrentPosition!.longitude;


            Map driverlastFiveMap =
            {
              //"id": currentFirebaseUser!.uid,
              "latfir":l1,
              "latsec": l2,
              "latthir": l3,
              "latfor":l4,
              "latfif":l5,
              "lonfir":n1,
              "lonsec": n2,
              "lonthir": n3,
              "lonfor":n4,
              "lonfif":n5
            };
            //x += 1;
            //
            DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("lastfivelatlongdrivers");
            driversRef.child(currentFirebaseUser!.uid).set(driverlastFiveMap); //saving the value of map

          }


      }



      // Map driverlastFiveMap =
      // {
      //   "id": currentFirebaseUser!.uid,
      //   "fir":x+1,
      //   "sec": x+2,
      //   "thir": x+3,
      //   "for":x+4,
      //   "fif":x+5
      // };
      // x += 1;
      // //
      // DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("lastfivelatlongdrivers");
      // driversRef.child(currentFirebaseUser!.uid).set(driverlastFiveMap); //saving the value of map


      //Update New ride status if driver gets new ride
      DatabaseReference ref = FirebaseDatabase.instance.ref()
          .child("drivers")
          .child(currentFirebaseUser!.uid)
          .child("newRideStatus");

      ref.set("idle"); //searching for ride request
      ref.onValue.listen((event) { }); // listen for coming req,(accept or reject)



      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }



  driverIsOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), ()
    {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }

}

