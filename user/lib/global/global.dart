


import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/direction_details_info.dart';
import '../models/driver_data.dart';
import '../models/user_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;

User? currentFirebaseUser;

UserModel? userModelCurrentInfo;

bool automatastarted = false;

List dList = [];//Drivers key info list

List busList = [];

List staticbusList = [];

List dynamicbusList = [];

List BusListFortopThreeDynamicdrivers = [];

List BusListFortopThreeDynamicdriversRoutes = [];

List TimeFortopThreeDynamicdriversRoutes = [];

List TimeForstaticBus = [];

String? selectedStaticBus = "";

DirectionDetailsInfo? tripDirectionDetailsInfo;

String? chosenDriverId = "";

String cloudMessagingServerToken =  "key=AAAA_f5hqvg:APA91bHkW75vcnQtV1bRd3bAFTKE3lUdnKZG65-nRJjgO83RDWIJCp7q1HxvY1lxEjzIkNVCY92amkCR2tIWTSDXGpKLCoLBsgUrV0s7MqrP6yqd9bNNPwPaYWDNh9IrE3wzIXmKLs5r";

String userDropOffAddress = "";

HashMap<String, List<double>> stations = new HashMap<String, List<double>>();
HashMap<String, List<String>> routeDetect = new HashMap<String, List<String>>();
HashMap<String, HashMap<String, List<double>>> scheduledTime = new HashMap<String, HashMap<String, List<double>>>();

HashMap<String, HashMap<String, double>> stopRouteDist = new HashMap<String, HashMap<String, double>>();

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();

int direction = 1;

bool rush = false;

String busRoute = "";
String searchRoute = "";
String nextStop = "";
int scheduledArrivalTime = 0;

double distToNext = 0;

String currDay = "";
String actualRoute = "";

List<String> myDynamicTime = [];

List<List<String>> myDynamicBusList = [];

List<String> busStationList = [];

HashMap<String, int> availableBusSeats = new HashMap<String, int>();
HashMap<int, String> indToBus = new HashMap<int, String>();