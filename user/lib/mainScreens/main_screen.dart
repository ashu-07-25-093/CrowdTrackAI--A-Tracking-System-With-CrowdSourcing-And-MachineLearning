import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';
import 'package:simple_kalman/simple_kalman.dart';
import 'package:user/mainScreens/main_screen_Two.dart';
import 'package:user/mainScreens/search_places_screen.dart';
import 'package:user/mainScreens/select_nearest_active_driver_screen.dart';
import 'package:user/mainScreens/select_nearest_active_driver_screen2.dart';
import 'package:user/models/direction_details_info.dart';
import 'package:user/models/directions.dart';
import 'package:intl/intl.dart';
import '../assistants/assistant_methods.dart';
import '../assistants/geofire_assistant.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../main.dart';
import '../models/active_nearby_available_drivers.dart';
import '../widgets/my_drawer.dart';
import '../widgets/progress_dialog.dart';
import 'Table.dart';
import 'my_dynamic_details.dart';
// import 'package:users_app/assistants/assistant_methods.dart';
// import 'package:users_app/authentication/login_screen.dart';
// import 'package:users_app/global/global.dart';
// import 'package:users_app/infoHandler/app_info.dart';
// import 'package:users_app/mainScreens/search_places_screen.dart';
// import 'package:users_app/widgets/my_drawer.dart';


class MainScreen extends StatefulWidget
{
  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen>
{
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;


  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;

  //For showing the current drivers
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;

  double l1 = 0 , l2 = 0 , l3 = 0 , l4 = 0 , l5 = 0;
  double n1 = 0 , n2 = 0 , n3 = 0 , n4 = 0 , n5 = 0;

  bool againState3 = false;

  double nl1 = 0 , nl2 = 0 , nl3 = 0 , nl4 = 0 , nl5 = 0;
  double nn1 = 0 , nn2 = 0 , nn3 = 0 , nn4 = 0 , nn5 = 0;

  int state = 1;

  var selectedDriver = "";

  // Aashay Changes started

  Marker? _userLocationMarker;
  LatLng _currentPosition = LatLng(12.9864308, 80.2385628); // Default position

  // Initialize the Geolocator
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  String driverKey = "";
  double maxiFromList = 0;


  // Aashay Changes ended


  blackThemeGoogleMap()
  {

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

  // LatLon = {'Ganga' : {'lat' : 12.986431, 'lon' : 80.238563}, 'Himalaya' : {'lat' : 12.986355, 'lon' : 80.2350117},
  // 'GymKhana' : {'lat' : 12.9870334, 'lon' : 80.2333308}, 'OAT' : {'lat' : 12.9886095, 'lon' : 80.2326199},
  // 'Hospital' : {'lat' : 12.9904753, 'lon' : 80.2317671}, 'RobertBosch' : {'lat' : 12.9905063, 'lon' : 80.2265638},
  // 'Velachery' : {'lat' : 12.9884243, 'lon' : 80.2231616}, 'Mechanical' : {'lat' : 12.9906251, 'lon' : 80.2310355},
  // 'Gajendra' : {'lat' : 12.9921004, 'lon' : 80.2321797}, 'KV' : {'lat' : 12.9942827, 'lon' : 80.2344724},
  // 'LinkRoad' : {'lat' : 12.9963805, 'lon' : 80.2357008}, 'Vana Vani' : {'lat' : 12.998858, 'lon' : 80.2388567},
  // 'Residential' : {'lat' : 13.0026967, 'lon' : 80.2399064}, 'Main Gate' : {'lat' : 13.0052914, 'lon' : 80.2418989}
  // }

  initializeLatLon()
  {

    stations["ganga"] = [];
    stations["ganga"]?.add(12.9864310);
    stations["ganga"]?.add(80.2385630);

    stations["himalaya"] = [];
    stations["himalaya"]?.add(12.9863550);
    stations["himalaya"]?.add(80.2350117);

    stations["gymkhana"] = [];
    stations["gymkhana"]?.add(12.9870334);
    stations["gymkhana"]?.add(80.2333308);

    stations["oat"] = [];
    stations["oat"]?.add(12.9886095);
    stations["oat"]?.add(80.2326199);

    stations["clt"] = [];
    stations["clt"]?.add(12.9886095);
    stations["clt"]?.add(80.2326199);

    stations["hospital"] = [];
    stations["hospital"]?.add(12.9904753);
    stations["hospital"]?.add(80.2317671);

    stations["humanitiy science block(hsb)"] = [];
    stations["humanitiy science block(hsb)"]?.add(12.9904753);
    stations["humanitiy science block(hsb)"]?.add(80.2317671);

    stations["icsr"] = [];
    stations["icsr"]?.add(12.9904753);
    stations["icsr"]?.add(80.2317671);

    stations["robert bosch"] = [];
    stations["robert bosch"]?.add(12.9905063);
    stations["robert bosch"]?.add(80.2265638);

    stations["velachery"] = [];
    stations["velachery"]?.add(12.9884243);
    stations["velachery"]?.add(80.2231616);

    stations["crc"] = [];
    stations["crc"]?.add(12.9906251);
    stations["crc"]?.add(80.2310355);

    stations["bsb"] = [];
    stations["bsb"]?.add(12.9906251);
    stations["bsb"]?.add(80.2310355);

    stations["engineering design(ed)"] = [];
    stations["engineering design(ed)"]?.add(12.990155548534194);
    stations["engineering design(ed)"]?.add(80.22733041354944);

    stations["ocean engineering"] = [];
    stations["ocean engineering"]?.add(12.990155548534194);
    stations["ocean engineering"]?.add(80.22733041354944);

    stations["gajendra"] = [];
    stations["gajendra"]?.add(12.9921004);
    stations["gajendra"]?.add(80.2321797);

    stations["library"] = [];
    stations["library"]?.add(12.9921004);
    stations["library"]?.add(80.2321797);

    stations["admin bloack"] = [];
    stations["admin bloack"]?.add(12.9921004);
    stations["admin bloack"]?.add(80.2321797);

    stations["kv"] = [];
    stations["kv"]?.add(12.9942827);
    stations["kv"]?.add(80.2344724);

    stations["link road"] = [];
    stations["link road"]?.add(12.9963805);
    stations["link road"]?.add(80.2357008);

    stations["vana vani"] = [];
    stations["vana vani"]?.add(12.9988580);
    stations["vana vani"]?.add(80.2388567);

    stations["residential"] = [];
    stations["residential"]?.add(13.0026967);
    stations["residential"]?.add(80.2399064);

    stations["main gate"] = [];
    stations["main gate"]?.add(13.0052914);
    stations["main gate"]?.add(80.2418989);

    stopRouteDist["ganga"]?["ganga"] = 0;
    stopRouteDist["main gate"]?["main gate"] = 0;
    stopRouteDist["velachery"]?["velachery"] = 0;

    stopRouteDist["ganga"]?["himalaya"] = 384.88;
    stopRouteDist["himalaya"]?["ganga"] = 384.88;

    stopRouteDist["himalaya"]?["gymkhana"] = 197.131;
    stopRouteDist["gymkhana"]?["himalaya"] = 197.131;

    stopRouteDist["gymkhana"]?["oat"] = 191.434;
    stopRouteDist["oat"]?["gymkhana"] = 191.434;

    stopRouteDist["oat"]?["gajendra"] = 260;
    stopRouteDist["gajendra"]?["oat"] = 260;

    stopRouteDist["gajendra"]?["hospital"] = 140;
    stopRouteDist["hospital"]?["gajendra"] = 140;

    stopRouteDist["hospital"]?["crc"] = 220;
    stopRouteDist["crc"]?["hospital"] = 220;

    stopRouteDist["crc"]?["ocean engineering"] = 310;
    stopRouteDist["ocean engineering"]?["crc"] = 310;

    stopRouteDist["ocean engineering"]?["velachery"] = 490;
    stopRouteDist["velachery"]?["ocean engineering"] = 490;

    stopRouteDist["gajendra"]?["kv"] = 347.263;
    stopRouteDist["kv"]?["gajendra"] = 347.263;

    stopRouteDist["kv"]?["link road"] = 268.563;
    stopRouteDist["link road"]?["kv"] = 268.563;

    stopRouteDist["link road"]?["vana vani"] = 439.099;
    stopRouteDist["vana vani"]?["link road"] = 439.099;

    stopRouteDist["vana vani"]?["residential"] = 441.735;
    stopRouteDist["residential"]?["vana vani"] = 441.735;

    stopRouteDist["residential"]?["main gate"] = 360.339;
    stopRouteDist["main gate"]?["residential"] = 360.339;

    print("Ganga : *****");
    print(stations["Ganga"]);
    print("\n");

    print("latlon initialized\n");

  }

  //gps permission
  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
    {
      _locationPermission = await Geolocator.requestPermission();
    }
  }



  locateUserPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();
    initializeLatLon();

  }

  // Aashay chanegs started

  // Function to update the marker's position
  void updateMarkerPosition(LatLng newPosition) {
    setState(() {
      _userLocationMarker = Marker(
        markerId: MarkerId("user_location"),
        position: newPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    userIsOnlineNow();
    updateUsersLocationAtRealTime();
    print("in marker updation\n");
    print("Ganga : *****");
    print(stations["Ganga"]);
    print("\n");
    for (MapEntry<String, List<double>> item in stations.entries)
    {
      print("in keys\n");
      List<double> ls = item.value;
      // print(newPosition.latitude);
      // print("\n");
      // print(newPosition.longitude);
      // print("\n");
      // print(ls[0]);
      // print("\n");
      // print(ls[1]);
      // print("\n");

       double dist = distance(newPosition.latitude, newPosition.longitude, ls[0], ls[1]);
       print("distance is calculated : ");
       print(dist);
       print("\n");
       if(dist < 0.05)
         {
           print("found nearest\n");
           Fluttertoast.showToast(msg: "Current Station is : "+item.key);
         }
    }
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
  void initState()
  {
    super.initState();

    checkIfLocationPermissionAllowed();

    locateUserPosition();

    userIsOnlineNow();

    listenToLocationUpdates();


  }

  //not used
  // saveRideRequestInformation()
  // {
  //   //1. save the RideRequest Information(by whom given and taken)
  //
  //   referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();//.push make unique ID
  //   //
  //   var originLocation = Provider.of<AppInfo>(context , listen: false).userPickUpLocation;
  //   var destinationLocation = Provider.of<AppInfo>(context , listen: false).userDropOffLocation;
  //
  //   //Key:value Maps
  //   Map originLocationMap =
  //   {
  //     "latitude": originLocation!.locationLatitude.toString(),
  //     "longitude": originLocation!.locationLongitude.toString(),
  //   };
  //
  //   Map destinationLocationMap =
  //   {
  //     "latitude": destinationLocation!.locationLatitude.toString(),
  //     "longitude": destinationLocation!.locationLongitude.toString(),
  //   };
  //
  //   Map userInformationMap =
  //   {
  //     "origin":originLocationMap,
  //     "destination":destinationLocationMap,
  //     "time":DateTime.now().toString(),
  //     "userName":userModelCurrentInfo!.name,
  //     "userPhone":userModelCurrentInfo!.phone,
  //     "originAddress":originLocation.locationName,
  //     "destinationAddress": destinationLocation.locationName,
  //     "driverId":"waiting",
  //   };
  //
  //   referenceRideRequest!.set(userInformationMap);
  //
  //
  //   onlineNearByAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
  //   searchNearestOnlineDrivers();
  // }
  //

  //
  // searchNearestOnlineDrivers() async
  // {
  //   //no active driver available
  //   if(onlineNearByAvailableDriversList.length == 0)
  //   {
  //     //cancel/delete the RideRequest Information
  //
  //     referenceRideRequest!.remove();
  //
  //     setState(() {
  //       polyLineSet.clear();
  //       markersSet.clear();
  //       circlesSet.clear();
  //       pLineCoOrdinatesList.clear();
  //     });
  //
  //     Fluttertoast.showToast(msg: "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");
  //
  //     Future.delayed(const Duration(milliseconds: 4000), ()
  //     {
  //       SystemNavigator.pop();
  //     });
  //
  //     return;
  //   }
  //
  //   sendNotificationToDriverNow(String chosenDriverId)
  //   {
  //     //assign/SET rideRequestId to newRideStatus in
  //     // Drivers Parent node for that specific choosen driver
  //     FirebaseDatabase.instance.ref()
  //         .child("drivers")
  //         .child(chosenDriverId)
  //         .child("newRideStatus")
  //         .set(referenceRideRequest!.key);
  //
  //     //automate the push notification service
  //     FirebaseDatabase.instance.ref()
  //         .child("drivers")
  //         .child(chosenDriverId)
  //         .child("token").once().then((snap)
  //     {
  //       if(snap.snapshot.value != null)
  //       {
  //         String deviceRegistrationToken = snap.snapshot.value.toString();
  //
  //         //send Notification Now
  //         AssistantMethods.sendNotificationToDriverNow(
  //           deviceRegistrationToken,
  //           referenceRideRequest!.key.toString(),
  //           context,
  //         );
  //
  //         Fluttertoast.showToast(msg: "Notification sent Successfully.");
  //       }
  //       else
  //       {
  //         Fluttertoast.showToast(msg: "Please choose another driver.");
  //         return;
  //       }
  //     });
  //   }
  //
  //   //active driver available
  //   await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
  //
  //   print("\n\n\n\n\nFirst Idhr tak aa gya\n\n\n\n\n");
  //
  //   print(dList.length);
  //
  //   var response = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectNearestActiveDriversScreenTwo(referenceRideRequest : referenceRideRequest)));
  //
  //   print("\n\n\n\n\n Second Idhr tak aa gya\n\n\n\n\n");
  //
  //   if(response == "driverChoosed")
  //   {
  //
  //     print("\n\n\n\n\nIdhr tak aa gya\n\n\n\n\n");
  //
  //     FirebaseDatabase.instance.ref()
  //         .child("drivers")
  //         .child(chosenDriverId!)
  //         .once()
  //         .then((snap)
  //     async {
  //
  //       //If choosen driver ID exists
  //       if(snap.snapshot.value != null)
  //       {
  //         //send the notification to driver
  //         // sendNotificationToDriverNow(chosenDriverId!);
  //         var response = await Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreenTwo()));
  //
  //       }
  //       else
  //       {
  //         Fluttertoast.showToast(msg: "This driver do not exist, try again");
  //       }
  //     });
  //   }
  //
  // }


//not used
//   sendNotificationToDriverNow(String chosenDriverId)
//   {
//
//
//
//     //SET ride request ID to newRideStatus for chosen driver
//     FirebaseDatabase.instance.ref()
//         .child("drivers")
//         .child(chosenDriverId!)
//         .child("newRideStatus")
//         .set(referenceRideRequest!.key);
//
//     //automate the push notification
//
//   }

  int findCurrTimeSec()
  {
      DateTime now = DateTime.now();

      int hour = now.hour;
      int minute = now.minute;
      int sec = now.second;

      int totSec = hour*3600 + minute*60 + sec;

      currDay = DateFormat('EEEE').format(now).toString().toLowerCase();

      return totSec;
  }

  bool isRushHour(int sec)
  {
      if((sec>=30300 && sec<=38100) || (sec>=42900 && sec<=45300) || (sec>=50400 && sec<=52500) || (sec>=54000 && sec<=56400) || (sec>=57300 && sec<=59400)
          || (sec>=62700 && sec<=68400))
        return true;

      return false;
  }

  findDirection()
  async {
    
    await FirebaseDatabase.instance
        .ref()
        .child("user_driver_relationship")
        .child(currentFirebaseUser!.uid.toString())
        .once()
        .then((snap) {    

          for(var row in snap.snapshot.children)
            {
                if(row.key == "bus")
                  {
                    driverKey = row.value.toString();
                    break;
                  }
            }
      });

    print("driver key : "+driverKey+"\n");

    await FirebaseDatabase.instance
        .ref()
        .child("activeDrivers")
        .child(driverKey)
        .once()
        .then((snap) {

      for(var row in snap.snapshot.children)
      {
        if(row.key=="route")
        {
          busRoute = row.value.toString();
          break;
        }
      }
    });
    

    // DatabaseReference driversRef = FirebaseDatabase.instance.ref()
    //     .child("user_driver_relationship");
    // //
    // String driverKey = driversRef.child(currentFirebaseUser!.uid).child("bus")
    //
    // print("driver key : "+driverKey);
    //
    // DatabaseReference driver = FirebaseDatabase.instance.ref()
    //     .child("activeDrivers");
    //
    // String route = driver.child(driverKey).child("route").value.toString();

    print("route is : "+busRoute);

    if(busRoute=="toM")
      direction = 1;
    else if(busRoute=="toH")
      direction = 0;
  }

  findScheduledArrivalTime(int totSec, List<double>? allScheduleTimes) async
  {
      int lb = 0, hb = allScheduleTimes!.length;
      int mid;

      double maxi = 0;

      while(lb<=hb)
        {
          mid = ((lb+hb)/2).floor();

          if(allScheduleTimes[mid]==totSec)
          {
            maxi = totSec.toDouble();
            break;
          }

          else if(allScheduleTimes[mid]>totSec)
            hb = mid - 1;
          else
            {
              maxi = max(maxi, allScheduleTimes[mid]);
              lb = mid + 1;
            }
        }

      maxiFromList = maxi;
  }


  userIsOnlineNow() async
  {

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    Geofire.initialize("activeUsers");

    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude
    );

    int totSec = findCurrTimeSec();

    List<double>? allScheduleTimes = scheduledTime[busRoute]?[nextStop];

    rush = isRushHour(totSec);

    findScheduledArrivalTime(totSec, allScheduleTimes);

    scheduledArrivalTime = maxiFromList.toInt();

    if(rush)
      print("yes !! Rush Hour");
    else
      print("Not a rush hour");

    await findDirection();

    print("direction is : ");
    print(direction);


    await findDynamicDetails();

  }



  distance(lat1, lon1, lat2, lon2) {
    var p = pi/180.0;
    var a = 0.5 - cos((lat2-lat1)*p)/2 + cos(lat1*p) * cos(lat2*p) * (1-cos((lon2-lon1)*p))/2;
    return 12742 * asin(sqrt(a));
  }




  updateUsersLocationAtRealTime()
  {
    //get the moving position of Driver in a stream

    if(automatastarted == true) return;
    automatastarted = true;

    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position)
    async {
      driverCurrentPosition = position;

      if(true)
      {

        Geofire.setLocation(
            currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude
        );


        if(againState3 == true)
        {
          againState3 = false;
          l1 = 0 ; l2 = 0 ; l3 = 0 ; l4 = 0 ; l5 = 0;
          n1 = 0 ; n2 = 0 ; n3 = 0 ; n4 = 0 ; n5 = 0;
        }

        if(driverCurrentPosition!.latitude != l1 && driverCurrentPosition!.longitude != n1) {
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


          // print("\n\n\n\n\n");
          //
          // print(l1.toString() + " " + n1.toString());
          // print(l2.toString() + " " + n2.toString());
          // print(l3.toString() + " " + n3.toString());
          // print(l4.toString() + " " + n4.toString());
          // print(l5.toString() + " " + n5.toString());
          //
          // print("\n\n\n\n\n");
          //
          // for(int i = 0 ; i < dList.length ; i++)
          //   {
          //     print(dList[i]);
          //   }
          // print("\n\n\n\n\n");


          List active_List_name = [];

          //Getting the data from the Firebase
          await FirebaseDatabase.instance
              .ref()
              .child("activeDrivers")
              .once()
              .then((snap) {
            //here i iterate and create the list of objects
            // print(snap.snapshot.value);

            for(var row in snap.snapshot.children)
            {

              String ssss = row.child("0").value.toString();
              print("ssss as lat = " + ssss);
              ssss = ssss.substring(0 , ssss.length - 1);

              var latlat = ssss;//.substring(1 , ssss.indexOf(' ') - 1);

              //print(latlat);

              //double lt = double.parse(latlat);

              ssss = row.child("1").value.toString();
              print("ssss as long = " + ssss);

              var lonlon = ssss;//.substring(ssss.indexOf(' ') + 1);

              //print(lonlon);
              //double ln = double.parse(lonlon);


              //print(distance(userCurrentPosition!.latitude , userCurrentPosition!.longitude , lt , ln));

              Marker userMarker = Marker(
              markerId: const MarkerId("user_location"),
              position: LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );

              setState(() {
                markersSet.add(userMarker);
              });

              //Under 50m^2 radius all buses will be taken care of
              if(true) {
                active_List_name.add(row.key.toString());
              }
            }



          });
          print("\n\n\n\n\n");
          // final _data = <int>[127, 0, 133, 136, 139, 256, 145, 148, 151];
          //
          // final kalman = SimpleKalman(errorMeasure: 256, errorEstimate: 150, q: 0.9);
          // for (final value in _data) {
          //   print('Origin: $value Filtered: ${kalman.filtered(value.toDouble())}');
          // }



          double minVal = 9999999;

          var Userbearing = Geolocator.bearingBetween(l1, n1, l5, n5);

          // state = 4;
          // selectedDriver = "GCD10k5vqgWaKMnik823UBQwNnV2";

          if(state == 1)
          {
            //Fluttertoast.showToast(msg: "Hi boy");

            if(againState3 == true)
            {
              againState3 = false;
              l1 = 0 ; l2 = 0 ; l3 = 0 ; l4 = 0 ; l5 = 0;
              n1 = 0 ; n2 = 0 ; n3 = 0 ; n4 = 0 ; n5 = 0;
            }



            print("State 1 kaise ?");

            for (int i = 0; i < active_List_name.length; i++) {
              print("Current check of bus = " + active_List_name[i]);

              await FirebaseDatabase.instance
                  .ref()
                  .child("lastfivelatlongdrivers")
                  .child(active_List_name[i])
              // .child("name")
                  .once()
                  .then((snap) {
                //print(snap.snapshot.value);

                if (snap.snapshot.value != null) {

                  print("\n\n pehla Kux hua kya ?? \n\n");

                  print(snap.snapshot.value);
                  print(snap.snapshot.key);
                  print(snap.snapshot.child('latfir').value);

                  print(snap.snapshot
                      .child('latfir')
                      .value
                      .toString());
                  print("\n\n\n\n\n");

                  nl1 = double.parse(snap.snapshot
                      .child('latfir')
                      .value
                      .toString());
                  nl2 = double.parse(snap.snapshot
                      .child('latsec')
                      .value
                      .toString());
                  nl3 = double.parse(snap.snapshot
                      .child('latthir')
                      .value
                      .toString());
                  nl4 = double.parse(snap.snapshot
                      .child('latfor')
                      .value
                      .toString());
                  nl5 = double.parse(snap.snapshot
                      .child('latfif')
                      .value
                      .toString());

                  nn1 = double.parse(snap.snapshot
                      .child('lonfir')
                      .value
                      .toString());
                  nn2 = double.parse(snap.snapshot
                      .child('lonsec')
                      .value
                      .toString());
                  nn3 = double.parse(snap.snapshot
                      .child('lonthir')
                      .value
                      .toString());
                  nn4 = double.parse(snap.snapshot
                      .child('lonfor')
                      .value
                      .toString());
                  nn5 = double.parse(snap.snapshot
                      .child('lonfif')
                      .value
                      .toString());


                  // print(l1.toString() + " " + l2.toString() + " " +
                  //     l3.toString() + " " + l4.toString() + " " +
                  //     l5.toString());
                  // print(n1.toString() + " " + n2.toString() + " " +
                  //     n3.toString() + " " + n4.toString() + " " +
                  //     n5.toString());
                  //
                  //
                  // print(nl1.toString() + " " + nl2.toString() + " " +
                  //     nl3.toString() + " " + nl4.toString() + " " +
                  //     nl5.toString());
                  // print(nn1.toString() + " " + nn2.toString() + " " +
                  //     nn3.toString() + " " + nn4.toString() + " " +
                  //     nn5.toString());


                  var bearing = Geolocator.bearingBetween(nl1, nn1, nl5, nn5);

                  // print("Bearing is = \n\n");
                  // print(Geolocator.bearingBetween(10.1, 20.1, 50.1, 60.1));
                  // print(Geolocator.bearingBetween(50.1, 60.1, 10.1, 20.1));
                  // print(Geolocator.bearingBetween(10.08, 20.11, 50.07, 60.12));
                  // print("Bearing is = \n\n");

                  print("\n\nWe get = ");
                  print(distance(l1, n1, nl1, nn1));
                  print(distance(l2, n2, nl2, nn2));
                  print(distance(l3, n3, nl3, nn3));
                  print(distance(l4, n4, nl4, nn4));
                  print(distance(l5, n5, nl5, nn5));


                  if (distance(l1, n1, nl1, nn1) < 0.04 &&
                      distance(l2, n2, nl2, nn2) < 0.04 &&
                      distance(l3, n3, nl3, nn3) < 0.04 &&
                      distance(l4, n4, nl4, nn4) < 0.04 &&
                      distance(l5, n5, nl5, nn5) < 0.04
                  // Userbearing - bearing < 45
                  ) {
                    double total = distance(l1, n1, nl1, nn1) +
                        distance(l2, n2, nl2, nn2) +
                        distance(l3, n3, nl3, nn3) +
                        distance(l4, n4, nl4, nn4) + distance(l5, n5, nl5, nn5);





                    print("Total = " + total.toString());
                    if (minVal > total) {
                      minVal = total;
                      selectedDriver = active_List_name[i];
                    }
                  }
                }
              });


              if (selectedDriver.length > 1) {
                print("\nGot state 2\n");
                print("The candidate driver is :- " + selectedDriver);
                state = 2;
              }
            }
          }
          else if( state  == 2)
          {
            print("Finally , The candidate driver is :- " + selectedDriver);

            print("\n\nNow we will check it for 20 sec \n\n");

            for (int i = 0; i < 4; i++) {
              Future.delayed(const Duration(milliseconds: 5000), () {
                //SystemNavigator.pop();


              });



              var bearing = Geolocator.bearingBetween(nl1, nn1, nl5, nn5);

              if (distance(l1, n1, nl1, nn1) < 0.04 &&
                  distance(l2, n2, nl2, nn2) < 0.04 &&
                  distance(l3, n3, nl3, nn3) < 0.04 &&
                  distance(l4, n4, nl4, nn4) < 0.04 &&
                  distance(l5, n5, nl5, nn5) < 0.04
              // Userbearing - bearing < 45
              ) {
                Fluttertoast.showToast(msg: "Once found correct = " + i.toString());
              }
              else {
                //No matching go back to earlier state

                state = 1;
                break;
              }

              print("\n\n\n\n\n");               print("The turn number is = " + i.toString());
              print("\n\n\n\n\n");

            }


            if (currentFirebaseUser != null) {
              Map driverMap =
              {
                "user": currentFirebaseUser!.uid,
                "bus": selectedDriver,

              };
              //

              print("\n\n");
              print("Finally we are able to put in database");
              print(driverMap);
              print("\n\n");

              Geofire.initialize("user_driver_relationship");
              Geofire.initialize("bus_to_manyusers");

              // (1) User to driver relation
              DatabaseReference driversRef = FirebaseDatabase.instance.ref()
                  .child("user_driver_relationship");
              driversRef.child(currentFirebaseUser!.uid).set(driverMap);




              // (2) Driver to user relation
              List ret_list = [];
              DatabaseReference ref = FirebaseDatabase.instance.ref().child("bus_to_manyusers");

              bool isthere = false;       // to check if the user is already present in bus_to_many relationship
              await ref.child(selectedDriver)
                  .once()
                  .then((dataSnapshot)
              {

                if(dataSnapshot.snapshot.exists) {
                  var t = dataSnapshot.snapshot
                      .child("bus")
                      .value as List?;


                  if (t!.isNotEmpty)
                    for (int i = 0; i < t!.length; i++) {
                      ret_list.add(t[i]);
                      if(t[i].toString() == currentFirebaseUser!.uid.toString())
                      {
                        isthere = true;
                      }
                    }
                }
              });


              if(isthere == false)
                ret_list?.add(currentFirebaseUser!.uid);


              Map driverMap2 =
              {
                "bus": ret_list
              };
              //

              print("\n\n");

              print("Many to one Getting the values");

              print("\n\n");

              DatabaseReference driversReferenceabc = FirebaseDatabase.instance.ref()
                  .child("bus_to_manyusers");
              print("\n\n");

              print("Many to one Getting the values");

              print("\n\n");
              driversReferenceabc.child(selectedDriver).set(driverMap2);







              //Change of State

              state = 3;
            }
          }


          else if(state == 3)
          {

            print("\n\n\n\n");
            print("Apun state 3 pe hai !!!");
            print("\n\n\n\n\n");

            int cnt = 0;

            // Timer mytimer = Timer.periodic(Duration(seconds: 5), (timer) {
            //   //code to run on every 5 seconds
            // });
            //
            for (int i = 0; ; i++)
            {



              // Timer.periodic(Duration(seconds: 5), (timer) async{
              //   print("bye");
              // });
              await FirebaseDatabase.instance
                  .ref()
                  .child("lastfivelatlongdrivers")
                  .child(selectedDriver)
              // .child("name")
                  .once()
                  .then((snap) async {
                //print(snap.snapshot.value);

                await Future.delayed(const Duration(milliseconds: 5000), () {
                  //SystemNavigator.pop();

                  // for(int l = 1 ; l <= 80000 ; l++) {
                  //   for (int k = 1; k <= 70000; k++) {
                  //     int a = l+k * l-k;
                  //   }
                  // }
                  print("ABCDHAJDSASKDAKDAKSD");
                });


                print("\ninvalidation being checked\n");

                print("Selected driver is = " + selectedDriver.toString());
                print(snap.snapshot.value);
                print(snap.snapshot.children.last.value);
                print(snap.snapshot.child('latthir').value);
                print(snap.snapshot.child('lonthir').value);
                // print(snap.snapshot.children.last.child('latthir').value);
                print(snap.snapshot.child('latfir').value);
                print(snap.snapshot.child('lonfir').value);
                print(snap.snapshot.child('latsec').value);
                print(snap.snapshot.child('lonsec').value);
                print(snap.snapshot.children);
                if (snap.snapshot.value != null) {

                  nl1 = double.parse(snap.snapshot
                      .child('latfir')
                      .value
                      .toString());
                  // print("VAlue = " + snap.snapshot.children.last
                  //     .child('latfir')
                  //     .value
                  //     .toString());
                  // print("Lat =  " + nl1.toString());
                  nl2 = double.parse(snap.snapshot
                      .child('latsec')
                      .value
                      .toString());
                  nl3 = double.parse(snap.snapshot
                      .child('latthir')
                      .value
                      .toString());
                  nl4 = double.parse(snap.snapshot
                      .child('latfor')
                      .value
                      .toString());
                  nl5 = double.parse(snap.snapshot
                      .child('latfif')
                      .value
                      .toString());

                  nn1 = double.parse(snap.snapshot
                      .child('lonfir')
                      .value
                      .toString());
                  nn2 = double.parse(snap.snapshot
                      .child('lonsec')
                      .value
                      .toString());
                  nn3 = double.parse(snap.snapshot
                      .child('lonthir')
                      .value
                      .toString());
                  nn4 = double.parse(snap.snapshot
                      .child('lonfor')
                      .value
                      .toString());
                  nn5 = double.parse(snap.snapshot
                      .child('lonfif')
                      .value
                      .toString());
                }
              });

              var bearing = Geolocator.bearingBetween(nl1, nn1, nl5, nn5);



              // print();
              print(l1.toString() +  " " + n1.toString() + " " + nl1.toString()  + " " + nn1.toString());
              print(l2.toString() +  " " + n2.toString() + " " + nl2.toString()  + " " + nn2.toString());
              print(l3.toString() +  " " + n3.toString() + " " + nl3.toString()  + " " + nn3.toString());
              print(l4.toString() +  " " + n4.toString() + " " + nl4.toString()  + " " + nn4.toString());
              print(l5.toString() +  " " + n5.toString() + " " + nl5.toString()  + " " + nn5.toString());
              print(distance(l1, n1, nl1, nn1));
              print(distance(l2, n2, nl2, nn2));
              print(distance(l3, n3, nl3, nn3));
              print(distance(l4, n4, nl4, nn4));
              print(distance(l5, n5, nl5, nn5));

              if ( distance(l1, n1, nl1, nn1) < 0.04 &&
                  distance(l2, n2, nl2, nn2) < 0.04 &&
                  distance(l3, n3, nl3, nn3) < 0.04 &&
                  distance(l4, n4, nl4, nn4) < 0.04 &&
                  distance(l5, n5, nl5, nn5) < 0.04
              // Userbearing - bearing < 45
              ) {
                print("No changes done");
                cnt = 0;
              }
              else {
                print("\n\n");
                print("Ek change aa gya");
                print("\n\n");
                cnt ++ ;
              }
              //No matching go back to earlier state


              if(cnt > 3)
              {

                print("\n\nChanges chalu\n\n");
                Fluttertoast.showToast(msg: "changes chaalu");
                if (currentFirebaseUser != null) {

                  print("Yo");

                  Map driverMapp =
                  {
                    "user": currentFirebaseUser!.uid,
                    "bus": "NILL",

                  };
                  //
                  Geofire.initialize("user_driver_relationship");
                  Geofire.initialize("bus_to_manyusers");

                  DatabaseReference dd = FirebaseDatabase.instance.ref()
                      .child("user_driver_relationship");
                  dd.child(currentFirebaseUser!.uid).remove();

                  //
                  //
                  //
                  //
                  //
                  //
                  //
                  // // (1) REMOVING THE CURRENT USER FROM THE LIST OF THIS BUS DRIVER
                  List ret_list = [];
                  DatabaseReference ref = FirebaseDatabase.instance.ref().child("bus_to_manyusers");

                  await ref.child(selectedDriver)
                      .once()
                      .then((dataSnapshot)
                  {
                    var t = dataSnapshot.snapshot.child("bus").value as List?;

                    //print(t);
                    // print(t.isEmpty);

                    if(t!.isNotEmpty)
                      for(int i = 0 ; i < t!.length ; i++)
                      {
                        ret_list.add(t[i]);
                      }

                  });
                  ret_list?.remove(currentFirebaseUser!.uid);
                  Map driverMap2 =
                  {
                    "bus": ret_list
                  };
                  //
                  DatabaseReference driversReference = FirebaseDatabase.instance.ref()
                      .child("bus_to_manyusers");
                  driversReference.child(selectedDriver).set(driverMap2);

                  //selectedStaticBus = "";
                  selectedDriver = "";

                  againState3 = true;
                  state = 1;
                  Timer.periodic(Duration(seconds: 15), (timer) async{
                    print("bye");
                  });
                  break;
                }



              }
            }



          }
          else if(state == 4)
          {
            // Map driverMapp =
            // {
            //   "user": "trialuser",
            //   "bus": "NILL value",
            //
            // };
            // //
            // DatabaseReference dd = FirebaseDatabase.instance.ref()
            //     .child("user_driver_relationship");
            // dd.child(currentFirebaseUser!.uid).remove();
          }


        }



      }


    });
  }


  // void findAssociatedBus()
  // {
  //
  //   // Timer.periodic(Duration(seconds: 5), (timer) {
  //   //   print("\n\n\n\n\nbye\n\n\n\n\n");
  //   // });
  //
  //   // print("\n\n\n\n\nbye\n\n\n\n\n");
  //   // print("\n\n\n\n\nbye\n\n\n\n\n");
  //   // print("\n\n\n\n\nbye\n\n\n\n\n");
  //   // print("\n\n\n\n\nbye\n\n\n\n\n");
  // }


  // showClosestDrivers()
  // async {
  //   await FirebaseDatabase.instance
  //       .ref()
  //       .child("activeDrivers")
  //       .once()
  //       .then((snap) {
  //     //here i iterate and create the list of objects
  //     // print(snap.snapshot.value);
  //
  //     for(var row in snap.snapshot.children)
  //     {
  //       //print("Row = " );
  //       dList.add(row.key.toString());
  //     }
  // }



  // retrieveOnlineDriversInformation(List onlineNearestDriversList) async
  // {
  //   DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
  //   for(int i=0; i<onlineNearestDriversList.length; i++)
  //   {
  //     await ref.child(onlineNearestDriversList[i].driverId.toString())
  //         .once()
  //         .then((dataSnapshot)
  //     {
  //       var driverKeyInfo = dataSnapshot.snapshot.value;
  //       dList.add(driverKeyInfo);
  //     });
  //   }
  // }

  // Marker userLocationMarker() {
  //
  //   return Marker(
  //     markerId: MarkerId("user_location"),
  //     position: LatLng(12.9864308, 80.2385628),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Customize the marker icon
  //   );
  // }

  @override
  Widget build(BuildContext context)
  {

    createActiveNearByDriverIconMarker();

    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 265,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: MyDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            //initialCameraPosition: _kGooglePlex,

            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),

            polylines: polyLineSet,
            //markers: markersSet
            // Aashay Changes.....
            markers: _userLocationMarker != null ? (Set<Marker>.from(markersSet)..add(_userLocationMarker!) ): markersSet,
            circles: circlesSet,

            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              //for black theme google map
              blackThemeGoogleMap();

              setState(() {
                bottomPaddingOfMap = 240;
              });
              checkIfLocationPermissionAllowed();
              locateUserPosition();
              userIsOnlineNow();
              initializeLatLon();

            },

          ),



          //custom hamburger button for drawer
          Positioned(
            top: 30,
            left: 14,
            child: GestureDetector(
              onTap: ()
              {
                if(openNavigationDrawer)
                {
                  sKey.currentState!.openDrawer();
                }
                else
                {
                  //restart-refresh-minimize app progamatically(to refresh states of app)
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  //openNavigation drawer = true means No data till now ,
                  // so show  menu, else means some destination has been choosen,
                  // so show close option to close
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          //ui for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      //from
                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                          const SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your Location",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                Provider.of<AppInfo>(context).userPickUpLocation != null
                                    ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,40) + "..."
                                    : "not getting address",
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      // const Divider(
                      //   height: 1,
                      //   thickness: 1,
                      //   color: Colors.grey,
                      // ),

                      // const SizedBox(height: 16.0),

                      //to
                      // GestureDetector(
                      //   onTap: () async
                      //   {
                      //     //go to search places screen
                      //     var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchPlacesScreen()));
                      //
                      //     if(responseFromSearchScreen == "obtainedDropoff")
                      //     {
                      //
                      //       setState(() {
                      //         NaNavigationDrawer = false;
                      //       });
                      //
                      //       //draw routes - draw polyline
                      //       //await drawPolyLineFromOriginToDestination();
                      //     }
                      //   },
                      //   child: Row(
                      //     children: [
                      //       const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                      //       const SizedBox(width: 12.0,),
                      //       Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           const Text(
                      //             "To",
                      //             style: TextStyle(color: Colors.grey, fontSize: 12),
                      //           ),
                      //           Text(
                      //             Provider.of<AppInfo>(context).userDropOffLocation != null
                      //                 ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                      //                 : "Where to go?",
                      //             style: const TextStyle(color: Colors.grey, fontSize: 14),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      //const SizedBox(height: 10.0),




                      ElevatedButton(
                        child: const Text(
                          "Source & Dest.",
                        ),
                        onPressed: ()
                        async {

                          TimeForstaticBus.clear();
                          TimeFortopThreeDynamicdriversRoutes.clear();
                          staticbusList.clear();
                          BusListFortopThreeDynamicdriversRoutes.clear();
                          BusListFortopThreeDynamicdrivers.clear();
                          print("\n\n\n\n\nhi\n\n\n\n\n");
                          Navigator.push(context, MaterialPageRoute(builder: (c)=> TableLayout()));

                          //findAssociatedBus();


                          // print("\n\ngot put the list value\n\n");
                          //
                          // List lst = ["r123" , "d9d0fs"];
                          //
                          // lst.add("hlo");
                          //
                          // Map driverMap2 =
                          // {
                          //
                          //   "bus": lst
                          //
                          // };
                          // //
                          // DatabaseReference driversRef = FirebaseDatabase.instance.ref()
                          //     .child("user_driver_relationship");
                          // driversRef.child("UK07").set(driverMap2);
                          //
                          //
                          // List ret_list = [];
                          //
                          //
                          // DatabaseReference ref = FirebaseDatabase.instance.ref().child("user_driver_relationship");
                          //
                          //   await ref.child("UK07")
                          //       .once()
                          //       .then((dataSnapshot)
                          //   {
                          //     print("\n\n We got = ");
                          //     print(dataSnapshot.snapshot.child("bus").value);
                          //
                          //     var t = dataSnapshot.snapshot.child("bus").value as List?;
                          //
                          //     for(int i = 0 ; i < t!.length ; i++)
                          //       {
                          //         ret_list.add(t[i]);
                          //       }
                          //
                          //     print("\n\n");
                          //   });
                          //
                          //
                          //   print(ret_list);
                          //
                          //   ret_list?.add("bye");
                          //
                          //   print(ret_list);
                          //
                          //   ret_list?.add("bye");
                          //
                          //   print(ret_list);
                          //
                          //   ret_list?.remove("bye");
                          //
                          //   print(ret_list);


                          userIsOnlineNow();
                          updateUsersLocationAtRealTime();



                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),

                      // ElevatedButton(
                      //   child: const Text(
                      //     "Find Closest Buses !!!",
                      //   ),
                      //   onPressed: ()
                      //   async {
                      //     //this button works only if dropoff location is set
                      //
                      //     // Provider.of<AppInfo>(context).userDropOffLocation ;
                      //
                      //     // saveRideRequestInformation();
                      //
                      //     Provider.of<AppInfo>(context,listen: false).userDropOffLocation = Provider.of<AppInfo>(context,listen: false).userPickUpLocation;
                      //
                      //     // if(Provider.of<AppInfo>(context,listen: false).userDropOffLocation != null)
                      //         {
                      //       // print("\n\n\n\n\n");
                      //       // print(Provider.of<AppInfo>(context,listen: false).userDropOffLocation.toString());
                      //       // print("\n\n\n\n\n");
                      //       saveRideRequestInformation();
                      //     }
                      //     // else
                      //     //   {
                      //     //     Fluttertoast.showToast(msg: "Please select destination location");
                      //     //   }
                      //
                      //
                      //     // showClosestDrivers();
                      //
                      //
                      //     dList.clear();
                      //
                      //
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //       primary: Colors.green,
                      //       textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      //   ),
                      // ),




                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  // Future<void> drawPolyLineFromOriginToDestination() async
  // {
  //   var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
  //   var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
  //
  //   var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
  //   var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
  //   );
  //
  //   var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
  //
  //
  //   setState(() {
  //     tripDirectionDetailsInfo = directionDetailsInfo;
  //   });
  //
  //
  //   Navigator.pop(context);
  //
  //   print("These are points = ");
  //   print(directionDetailsInfo!.e_points);
  //
  //   //Making polyline , using the Encoded points
  //   PolylinePoints pPoints = PolylinePoints();
  //   List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);
  //
  //   pLineCoOrdinatesList.clear();
  //
  //   if(decodedPolyLinePointsResultList.isNotEmpty)
  //   {
  //     //Loop over each point , add its details
  //     decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
  //     {
  //       pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
  //     });
  //   }
  //
  //   polyLineSet.clear();
  //
  //   setState(() {
  //     Polyline polyline = Polyline(
  //       color: Colors.purpleAccent,
  //       polylineId: const PolylineId("PolylineID"),
  //       jointType: JointType.round,
  //       points: pLineCoOrdinatesList,
  //       startCap: Cap.roundCap,
  //       endCap: Cap.roundCap,
  //       geodesic: true,
  //     );
  //
  //     polyLineSet.add(polyline);
  //   });
  //
  //   LatLngBounds boundsLatLng;
  //   //Adjusting the google map zoom to fit both source and destination
  //   if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
  //   {
  //     boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
  //   }
  //   else if(originLatLng.longitude > destinationLatLng.longitude)
  //   {
  //     boundsLatLng = LatLngBounds(
  //       southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
  //       northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
  //     );
  //   }
  //   else if(originLatLng.latitude > destinationLatLng.latitude)
  //   {
  //     boundsLatLng = LatLngBounds(
  //       southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
  //       northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
  //     );
  //   }
  //   else
  //   {
  //     boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
  //   }
  //
  //   newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
  //
  //   Marker userMarker = Marker(
  //     markerId: const MarkerId("user_location"),
  //     position: LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //   );
  //
  //   Marker originMarker = Marker(
  //     markerId: const MarkerId("originID"),
  //     infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
  //     position: originLatLng,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
  //   );
  //
  //   Marker destinationMarker = Marker(
  //     markerId: const MarkerId("destinationID"),
  //     infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
  //     position: destinationLatLng,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
  //   );
  //
  //   setState(() {
  //     markersSet.add(originMarker);
  //     markersSet.add(destinationMarker);
  //     markersSet.add(userMarker);
  //   });
  //
  //   Circle originCircle = Circle(
  //     circleId: const CircleId("originID"),
  //     fillColor: Colors.green,
  //     radius: 12,
  //     strokeWidth: 3,
  //     strokeColor: Colors.white,
  //     center: originLatLng,
  //   );
  //
  //   Circle destinationCircle = Circle(
  //     circleId: const CircleId("destinationID"),
  //     fillColor: Colors.red,
  //     radius: 12,
  //     strokeWidth: 3,
  //     strokeColor: Colors.white,
  //     center: destinationLatLng,
  //   );
  //
  //   setState(() {
  //     circlesSet.add(originCircle);
  //     circlesSet.add(destinationCircle);
  //   });
  // }

  initializeGeoFireListener()
  {
    Geofire.initialize("activeDrivers");
    Geofire.initialize("user_driver_relationship");
    Geofire.initialize("bus_to_manyusers");

    Geofire.queryAtLocation(
      //Third parameter represents , find within 10Km^2 area
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack)
            {
        //onKeyEntered means = what to do whenever any driver become active/online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();

            //Get the longitude and latitude of the active driver
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];

            //Add the driver to the active driver list
            GeoFireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
            if(activeNearbyDriverKeysLoaded == true)
            {
              displayActiveDriversOnUsersMap();
            }
            break;

        //onKeyExited means = what to do whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

        //onKeyMoved means = what to do whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

        //onKeyReady means =  To  display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }


  displayActiveDriversOnUsersMap()
  {
    setState(() {

      //Reset markers to the new position
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      print("\nYou have \n Entered here \n");

      for(ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableDriversList)
      {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        print("Lat lan = "+eachDriverActivePosition.longitude.toString());
        print("Lat lan = "+eachDriverActivePosition.latitude.toString());
        print("\n----------------------------------\n");

        Marker marker = Marker(
          markerId: MarkerId("driver"+eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }
      // Marker userMarker = Marker(
      //   markerId: const MarkerId("user_location"),
      //   position: LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude),
      //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      // );


      setState(() {
        //markersSet = driversMarkerSet;
        //markersSet.add(userMarker);
        markersSet.addAll(driversMarkerSet);
      });
    });
  }

  createActiveNearByDriverIconMarker()
  {

    //Configure the image
    if(activeNearbyIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "Images/car.png").then((value)
      {
        activeNearbyIcon = value;
      });
    }
  }

}





