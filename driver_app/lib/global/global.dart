


import 'dart:async';
import 'dart:collection';

import 'package:driver_app/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;

User? currentFirebaseUser;
UserModel? userModelCurrentInfo;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();

HashMap<String, List<double>> stations = new HashMap<String, List<double>>();
HashMap<String, List<String>> routeDetect = new HashMap<String, List<String>>();

HashMap<String, HashMap<String, List<double>>> scheduledTime = new HashMap<String, HashMap<String, List<double>>>();
