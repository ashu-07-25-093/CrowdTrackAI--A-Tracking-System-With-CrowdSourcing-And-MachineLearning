


import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/direction_details_info.dart';
import '../models/driver_data.dart';
import '../models/user_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;

User? currentFirebaseUser;

UserModel? userModelCurrentInfo;

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


StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();