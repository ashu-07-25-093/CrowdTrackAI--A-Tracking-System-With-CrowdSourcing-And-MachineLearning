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

distance(lat1, lon1, lat2, lon2) {
  var p = pi/180.0;
  var a = 0.5 - cos((lat2-lat1)*p)/2 + cos(lat1*p) * cos(lat2*p) * (1-cos((lon2-lon1)*p))/2;
  return 12742 * asin(sqrt(a));
}

bool crowdSourcing(String driverKey)
{
      List usersList = [];
      DatabaseReference ref = FirebaseDatabase.instance.ref().child("bus_to_manyusers");

       ref.child(driverKey)
          .once()
          .then((dataSnapshot)
      {
        var t = dataSnapshot.snapshot.child("bus").value as List?;

        //print(t);
        // print(t.isEmpty);

        if(t!.isNotEmpty)
          {
            for(int i = 0 ; i < t.length ; i++)
            {
              usersList.add(t[i]);
            }

            if(t.length >= 25)
              availableBusSeats[driverKey] = 0;
            else
              availableBusSeats[driverKey] = 25 - t.length;
          }

      });

      //HashMap<String, List<double>> userCurLoc = new HashMap<String, List<double>>();

      List<List<double>> userCurLoc = [];

      for(String userKey in usersList)
        {
          double lat = 0.0, lon = 0.0;
          FirebaseDatabase.instance.ref().child("activeUsers").child(userKey).child("l").once().then((mysnapshot)
              {
                for(var r in mysnapshot.snapshot.children)
                {
                      if(r.key.toString()=="0")
                        lat = double.parse(r.value.toString());
                      else
                        lon = double.parse(r.value.toString());
                  }
              });

          userCurLoc.add([lat, lon]);
        }

      int count = 0;

      List<List<double>> correct_userLoc = [];

      for(int i=0;i<userCurLoc.length;i++)
        {
            if(userCurLoc[i][0]>=12.5 && userCurLoc[i][1]<=13.2)
              {
                correct_userLoc.add(userCurLoc[i]);
                count++;
              }
            if(count==1)
              break;
        }

      int cnt = 0;

      for(int i=0;i<correct_userLoc.length-1;i++)
        {
          double d = distance(correct_userLoc[i][0], correct_userLoc[i][1], correct_userLoc[i+1][0], correct_userLoc[i+1][1]);

          if(d < 0.05)
            cnt++;
        }

      if(count==0)
        return true;

      if(cnt==count-1)
        return true;

      return false;
}
findDynamicDetails()
{
  Geofire.initialize("modelData");

  // searchRoute == busRoute, loop here and so, distToNext is also fetched here

  myDynamicBusList.clear();    // clearing the dynamic bus list
  int busIdx = 0;

  FirebaseDatabase.instance
      .ref()
      .child("activeDrivers")
      .once()
      .then((snap1) async {



    DatabaseReference driversRef1 = FirebaseDatabase.instance.ref().child("modelData");

    for(var row in snap1.snapshot.children)
    {
      print("row.child.toString : "+row.child("route").value.toString());
      print("searchRoute : "+searchRoute);

      String dKey = row.key.toString();

      if(row.child("route").value.toString()==searchRoute && crowdSourcing(dKey))
      {
        nextStop = row.child("nextStop").value.toString();

        int stIdx = -1, endIdx = -1;
        String r = "";

        if(searchRoute=="toM")
        {
          stIdx = routeDetect["htom"]!.indexOf(nextStop);
          endIdx = routeDetect["htom"]!.indexOf(destination);

          r = "htom";
        }
        else if(searchRoute=="toH")
        {
          stIdx = routeDetect["mtoh"]!.indexOf(nextStop);
          endIdx = routeDetect["mtoh"]!.indexOf(destination);

          r = "mtoh";
        }

        if(stIdx!=-1)
        {
          for(int i=stIdx;i<=endIdx;i++)
          {
            allStations.add(routeDetect[r]![i]);
          }
        }

        distToNext = double.parse(row.child("distToNext").value.toString());
        //distToNext = 325;

        // now in the new table in firebase, pass all the data from here only for this driver by driverKey
        // we may not need currStation, and lat, long bcz from activeDrivers table we are already fetching the nextStop and distTonext
        // so, might needed the new training of the model
        // also think about the stopNo

        Map dataMap = {

          "route" : searchRoute,
          "direction" : direction,
          "rushHour" : rush,
          "allStations" : allStations,        // change to allStations here, and distToNext at line 877 and in driverApp
          "actualRoute" : actualRoute,
          "distToNext" : distToNext*1000,      // converting distance to meter
          "scheduledTime" : scheduledArrivalTime,
          "dayOfWeek" : currDay
        };

        //double d = distance(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude, stations[next_stop]?[0], stations[next_stop]?[1]);
        driversRef1.child(row.key.toString()).set(dataMap); //saving the value of map

        print("driversRef1 : "+driversRef1.toString());
        print("row.key : "+row.key.toString());

        await FirebaseDatabase.instance
            .ref()
            .child("predictions")
            .child(row.key.toString())
            .once()
            .then((snap2) {

              print("inside predictions");

          HashMap<String, int> station_time = new HashMap<String, int>();

          for(var row2 in snap2.snapshot.children)
          {
            double d = double.parse(row2.value.toString());
            print(row2.key.toString());

            // int sec = d.toInt();
            // int hours = (sec/3600).toInt();

            station_time[row2.key.toString()] = d.toInt();
          }

          myDynamicTime.clear();

          for(int it=0;it<allStations.length;it++)
          {
            int? sec = station_time[allStations[it]];
            if(sec!<=2000)
              continue;
            int? hours = (sec! / 3600).toInt();
            double d1 = ((sec % 3600)/60);
            int min =  d1.toInt();

            String am_pm = "am";

            if(hours >= 12)
              am_pm = "pm";

            if(hours > 12)
              hours -= 12;
            else if(hours == 0)
              hours = 12;
            //
             String str = "Bus will reach to the station " + allStations[it] + " at " + hours.toString() + " : " + min.toString() + am_pm;
            //String str = "Bus will reach to the station " + allStations[it] + " at " + station_time[allStations[it]].toString();

            myDynamicTime.add(str);
          }


          print("myDynamicTime length : ");
          print(myDynamicTime.length);
          myDynamicBusList.add(myDynamicTime);
          indToBus[busIdx] = dKey;
          busIdx++;

          print("bus added to myDynamicBusList");
          // now call here screen for dynamic data

        });

        allStations = [];
      }
    }
  });

  myDynamicBusList.clear();
  indToBus.clear();
  busIdx = 0;

}