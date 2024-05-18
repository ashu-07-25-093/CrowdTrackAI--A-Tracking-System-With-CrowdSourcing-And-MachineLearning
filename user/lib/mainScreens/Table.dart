import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Completer, Future, Timer;
import 'package:flutter/services.dart' show SystemNavigator, rootBundle;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:user/mainScreens/select_nearest_active_driver_screen3.dart';
// import 'package:trial_google_sheets/static_data.dart';
import 'package:user/mainScreens/static_data.dart';

import '../assistants/geofire_assistant.dart';
import '../global/global.dart';
import '../models/active_nearby_available_drivers.dart';
import 'my_dynamic_details.dart';

class TableLayout extends StatefulWidget {
  @override
  _TableLayoutState createState() => _TableLayoutState();
}

String s = "" , source = "" , destination = "" , changingString = " hello";
final TextEditingController _typeAheadController = TextEditingController();
final TextEditingController _typeAheadController2 = TextEditingController();
final TextEditingController mycontroller = TextEditingController();
List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

List<String> allStations = [];


class _TableLayoutState extends State<TableLayout> {
  List<List<dynamic>> data = [];

  String myRoute = "";
  int direction = 1;


  //This function will convert the time in AM - PM to minutes of the day
  //Input = Time format Hr:Min AP/PM
  //Output = Total minutes of the Day
  timeToMin(String s)
  {
    print("string : "+s);
    print(': index'+s.indexOf(':').toString());
    print('space index'+s.indexOf(' ').toString());

    if(s.indexOf(' ')==-1){
      int idx = s.indexOf('M');

      String str = s.substring(0, s.indexOf('M') -  1);

      str += ' ';
      str += s.substring(s.indexOf('M') -  1) ;

      s = str;
    }

    print(s);

    int hr = int.parse(s.substring(0 , s.indexOf(':')));
    int min = int.parse(s.substring(s.indexOf(':') + 1 , s.indexOf(' '))  );

    print(s);
    print("hr" + hr.toString());
    print("min" + min.toString());
    //
    var c = s[s.indexOf(' ') + 1];
    var fir = s[0] , sec = s[1];
    //
    print("Time = " + c.toString());
    print("\n\n\n\n\n\n");

    if(fir.toString() == "1" && sec.toString() == "2")
      {
        if(c.toString() == "P") c = "A";
        else c = "P";
      }

    if(c.toString() == "P")
      {
        hr = hr + 12;

      }
    hr = hr*60;

    // print(s);
    // print("\n\n\n\n\n\n");
    // print(hr+min);
    // print("\n\n\n\n\n\n");

    return hr + min;



  }

  //This function uses Haversine formula to calculate the distance between two different
  //latitude and Longitudes
  distance(lat1, lon1, lat2, lon2) {
    var p = pi/180.0;
    var a = 0.5 - cos((lat2-lat1)*p)/2 + cos(lat1*p) * cos(lat2*p) * (1-cos((lon2-lon1)*p))/2;
    return 12742 * asin(sqrt(a));
  }

  //Used to load the static CSV file that we have
  //Other functions are :- Find the buses in the given source and destination according to the current time
  //And the set them to static and dynamic buses repectively
  loadAsset() async {
    final myData = await rootBundle.loadString("assets/busdata.csv");

    //--------------------------------------------------------------------------------------------
    // final myDataroute = await rootBundle.loadString("assets/route.csv");
    // final myDatastop = await rootBundle.loadString("assets/stop.csv");
    // final myDatarest = await rootBundle.loadString("assets/rest_data.csv");
    //--------------------------------------------------------------------------------------------


    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);

    //--------------------------------------------------------------------------------------------
    // List<List<dynamic>> csvTable1 = CsvToListConverter().convert(myDataroute);
    // List<List<dynamic>> csvTable2 = CsvToListConverter().convert(myDatastop);
    // List<List<dynamic>> csvTable3 = CsvToListConverter().convert(myDatarest);
    // routedata = csvTable1;
    // stopdata = csvTable2;
    // restdata = csvTable3;
    //--------------------------------------------------------------------------------------------




    data = csvTable;

    var cnt = 0;
    var src = false , dest = false;

    onlineNearByAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


    // print("\n\n\n");
    // print("These are the drivers");
    //
    // print(onlineNearByAvailableDriversList.length);
    //
    // for(int i=0; i<onlineNearByAvailableDriversList.length; i++)
    // {
    //   await ref.child(onlineNearByAvailableDriversList[i].driverId.toString())
    //       .once()
    //       .then((snap)
    //   {
    //     print(onlineNearByAvailableDriversList[i]);
    //     var driverInfo = (snap.snapshot.value as Map)["name"];
    //     print(driverInfo);
    //   });
    //
    // }
    // print("\n\n\n");


    // FirebaseDatabase.instance.ref()
    //     .child("activeDrivers")
    //     .child(chosenDriverId!)
    //     .onValue.listen((snap) {
    //
    var bars = FirebaseDatabase.instance.ref("activeDrivers");

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
          //print("Row = " );
          active_List_name.add(row.key.toString());
        }




      //String sss = snap.snapshot.value.toString();


      //active_List_name.add(sss.substring(1 , sss.indexOf(':')));
      //print(sss.substring(1 , sss.indexOf(':')));

      // yearMap.forEach((key, value) {
      //   years.add(Year.fromJson(key, value));
      // });
      //print(Act_Driver);
      // completer.complete(years);
    });

    print("\n\n\n\n\n Size = "  + active_List_name.length.toString());
    print("VAlue = " + active_List_name[0].toString());

    for(int i = 0 ; i < active_List_name.length ; i+=1)
      {
        print(active_List_name[i]);
      }

    print("\n\n\n\n\n");
    List activeRouteNames = [] ;// activeRouteDrivers = [];

   for(int i = 0 ; i < active_List_name.length ; i++)
     {
       await FirebaseDatabase.instance
           .ref()
           .child("drivers")
           .child(active_List_name[i])
           .child("name")
           .once()
           .then((snap) {
         //here i iterate and create the list of objects
         // print("\n\n\n\nWe have shown the name => ");
         // print(snap.snapshot.value);
         activeRouteNames.add(snap.snapshot.value.toString());
         // activeRouteDrivers.add();
         // yearMap.forEach((key, value) {
         //   years.add(Year.fromJson(key, value));
         // });
         //print(Act_Driver);
         // completer.complete(years);
       });


     }






    //This loop iterates over children of user_id
    //childNodes.key is key of the children of userid such as (20170710)
    //childNodes.val().name;
    //childNodes.val().time;
    //childNodes.val().rest_time;
    //childNodes.val().interval_time;


    // });
    // });

    // for (String activeRoutes in activeRouteNames)
    //   {
    //     print("Halo baby = " + activeRoutes);
    //   }

    var counter = 0;

   print(activeRouteNames.length);

   String  CurrentRoutenBusname = "";

   // print("\n\n\n\n\nTime is => ");
   // print(new DateFormat.jm().format(DateTime.now()).toString());
   // print("\n\n\n\n\n");

    String currentTime = new DateFormat.jm().format(DateTime.now()).toString();

    timeToMin(currentTime);

    print("time to min completed");

    // Aashay Changes started for route Detection

      if(source=="hospital" || source=="humanity science block(hsb)" || source=="icsr")
          source = "hospital";
      else if(source=="library" || source=="gajendra" || source=="admin block")
          source = "gajendra";
      else if(source=="engineering design" || source=="ocean engineering")
          source = "ocean engineering";
      else if(source=="crc" || source=="bsb")
          source = "crc";
      else if(source=="oat" || source=="clt")
          source = "oat";

      if(destination=="hospital" || destination=="humanity science block(hsb)" || destination=="icsr")
        destination = "hospital";
      else if(destination=="library" || destination=="gajendra" || destination=="admin block")
        destination = "gajendra";
      else if(destination=="engineering design" || destination=="ocean engineering")
        destination = "ocean engineering";
      else if(destination=="crc" || destination=="bsb")
        destination = "crc";
      else if(destination=="oat" || destination=="clt")
        destination = "oat";

      double? slat = stations[source]?[0];
      double? slon = stations[source]?[1];
      double? dlat = stations[destination]?[0];
      double? dlon = stations[destination]?[1];

      var src_dest = Geolocator.bearingBetween(slat!, slon!, dlat!, dlon!);
      var dest_src = Geolocator.bearingBetween(dlat!, dlon!, slat!, slon!);

      print("source found : "+source);
      print("destination found : "+destination);

      print("gan-him");
      print(Geolocator.bearingBetween(stations["oat"]![0], stations["oat"]![1], stations["gajendra"]![0], stations["gajendra"]![1]));
      print("him-gan");
      print(Geolocator.bearingBetween(stations["gajendra"]![0], stations["gajendra"]![1], stations["oat"]![0], stations["oat"]![1]));

      print(slat);
      print(slon);
      print(dlat);
      print(dlon);
      print(src_dest);
      print(dest_src);

      if(routeDetect["htov"]!.contains(source) && routeDetect["htov"]!.contains(destination))
      {
          if(src_dest < dest_src)
            {
              direction = 1;
              myRoute = "toM";     // "htov"
              actualRoute = "HtoV";
            }
          else if(src_dest > dest_src)
          {
            direction = 0;
            myRoute = "toH";     // "vtoh"
            actualRoute = "VtoH";
          }
      }
      else if(routeDetect["vtom"]!.contains(source) && routeDetect["vtom"]!.contains(destination))
      {
        if(src_dest > dest_src)
        {
          direction = 1;
          myRoute = "toM";        // "vtom"
          actualRoute = "VtoM";
        }
        else if(src_dest < dest_src)
        {
          direction = 0;
          myRoute = "toH";       // "mtov"
          actualRoute = "MtoV";
        }
      }
      else if(routeDetect["htov"]!.contains(source) && !routeDetect["vtom"]!.contains(source) && routeDetect["vtom"]!.contains(destination))
        {
          direction = 1;
          myRoute = "toM";
        }
      else if(routeDetect["mtov"]!.contains(source) && !routeDetect["vtoh"]!.contains(source) && routeDetect["vtoh"]!.contains(destination))
      {
        direction = 0;
        myRoute = "toH";
      }

      searchRoute = myRoute;       // searchRoute is global variable, to know the route from source and destination entered by the user

      print("search route decided : "+searchRoute);

    // Aashay Changes ended for route Detection

    // Aashay Changes started for getting all stations

      await findDynamicDetails();

      // if(searchRoute=="toM")
      //   {
      //
      //     stIdx = routeDetect["htom"]!.indexOf(nextStop);
      //     endIdx = routeDetect["htom"]!.indexOf(destination);
      //
      //     print("stIdx");
      //     print(stIdx);
      //     print("endIdx");
      //     print(endIdx);
      //
      //     r = "htom";
      //   }
      // else if(searchRoute=="toH")
      // {
      //    stIdx = routeDetect["mtoh"]!.indexOf(nextStop);
      //    endIdx = routeDetect["mtoh"]!.indexOf(destination);
      //
      //    print("stIdx");
      //    print(stIdx);
      //    print("endIdx");
      //    print(endIdx);
      //
      //    r = "mtoh";
      // }
      //
      // if(stIdx!=-1)
      // {
      //     for(int i=stIdx;i<=endIdx;i++)
      //     {
      //       allStations.add(routeDetect[r]![i]);
      //     }
      // }

    // Aashay Changes ended for getting all stations

    int current = 0;

    for(var i = 0 ; i < data[0].length - 11 ; i+=11)
      {

        // print(data[0][i+5]);

        if(data[0][i+4] == 1) //Current route first stop
          {
            CurrentRoutenBusname = data[0][i + 1].toString() + "?" + data[0][i+2].toString() + "?" + data[0][i+10].toString();
            current = i;
          }

        //See if the source and destination both gets matched up

        if(data[0][i+4] == 1)
        {
          // print(data[0][i+4]);
          src = false;
          dest = false;
        }

        if(data[0][i + 5] == source)
          {
            // print("Source found \n");
            src = true;
          }
         else if(data[0][i + 5] == destination)
         {
          // print("Destination found \n");
          dest = true;
          // print(src);
          // print(dest);
          if(src == true)
            {
              // print("One path = " + data[0][i + 1].toString() + " <-> " + data[0][i+2].toString() + " <=> " + data[0][i+10].toString());
              changingString = data[0][i + 1].toString() + "?" + data[0][i+2].toString() + "?" + data[0][i+10].toString();

              bool flag = false;

              if(BusListFortopThreeDynamicdrivers.length < 3) {

                var cntr = 0;
                for (String activeRoutes in activeRouteNames) {
                  print(activeRoutes + " --- " + CurrentRoutenBusname);

                  var disttime1 = distance(position.latitude , position.longitude ,data[0][i+6] , data[0][i+7] ) / 5;
                  if (activeRoutes == CurrentRoutenBusname && BusListFortopThreeDynamicdrivers.length <=3 && timeToMin(currentTime) + disttime1 <= timeToMin(data[0][i+10].toString()))
                  {
                    print("Found = " + CurrentRoutenBusname.toString() + " of driver = " + active_List_name[cntr]);
                    BusListFortopThreeDynamicdrivers.add(
                        active_List_name[cntr].toString() );

                    //Adding to the dynamic buses
                    BusListFortopThreeDynamicdriversRoutes.add(CurrentRoutenBusname.toString());

                    bool secondTime = false;

                    print("\n\n\n\n");
                    // print(position.latitude );
                    // print(position.longitude );

                    var minimumDist = 99999.99;
                    String closestStop = "Not Able to Track";

                    for(int j = current ; ; j += 11)
                      {

                        // print(data[0][j+6].toString() + " => " + data[0][j+7].toString() + " " + distance(position.latitude , position.longitude ,data[0][j+6] , data[0][j+7] ).toString() + " Km");

                        var dist = distance(position.latitude , position.longitude ,data[0][j+6] , data[0][j+7] );

                        if(dist < minimumDist)
                          {
                            minimumDist = dist;
                            closestStop = data[0][j+5].toString() + " at " + data[0][j+10];
                          }

                        if(data[0][j+4] == 1)
                          {
                            if(secondTime)
                              {
                                break;
                              }
                            secondTime = true;
                          }
                      }

                    // print("\n\n We found closest stop was => ");
                    // print(closestStop);
                    // print("\n------------------------------------\n");

                    TimeFortopThreeDynamicdriversRoutes.add(closestStop);



                    flag = true;
                    break;
                  }
                  cntr+=1;
                }
              }

              // print(changingString);
              // print(flag);


              // print(timeToMin(currentTime) );
              // print(timeToMin(data[0][i+10].toString()));

              // if(counter <= 3 )//&& flag == false && timeToMin(currentTime) <= timeToMin(data[0][i+10].toString()) )

              // print("counter = " + counter.toString());

              var disttime2 = distance(position.latitude , position.longitude ,data[0][i+6] , data[0][i+7] ) / 5;
              if(counter <= 3 && timeToMin(currentTime) + disttime2 <= timeToMin(data[0][i+10].toString()) )
              {
                // print(currentTime.toString() + "  && "+ timeToMin(currentTime).toString());
                // print(data[0][i+10].toString() + " && " + timeToMin(data[0][i+10].toString()).toString());
                // print("\n\n\n\n\n");
                counter+=1;
                busList.add(CurrentRoutenBusname);
                print("\n\n\n");
                print("Abhi ye mila = " + changingString);
                //print('cccc : '+CurrentRoutenBusname);


                bool secondTime = false;
                var minimumDist = 99999.99;
                String closestStop = "Not Able to Track";

                for(int j = current ; ; j += 11)
                {

                  // print(data[0][j+6].toString() + " => " + data[0][j+7].toString() + " " + distance(position.latitude , position.longitude ,data[0][j+6] , data[0][j+7] ).toString() + " Km");

                  var dist = distance(position.latitude , position.longitude ,data[0][j+6] , data[0][j+7] );

                  if(dist < minimumDist)
                  {
                    minimumDist = dist;
                    closestStop = data[0][j+5].toString() + " at " + data[0][j+10];
                  }

                  if(data[0][j+4] == 1)
                  {
                    if(secondTime)
                    {
                      break;
                    }
                    secondTime = true;
                  }
                }

                // print("\n\n We found closest stop was => ");
                // print(closestStop);
                // print("\n------------------------------------\n");

                TimeForstaticBus.add(closestStop);













                // print("\n\n\n");
              }
            }
        }

        // print(data[0][i+4]);


      }


    //(Normalized Logic)
    /*--------------------------------------------------------------------------------------------

    for(var i = 0 ; i < data[0].length - 7 ; i += 7)
      {

        // print(data[0][i+5]);

        if(data[0][i+2] == 1) //Current route first stop
          {
            CurrentRoutenBusname = data[0][i + 1].toString() + "?" + data[0][i+1].toString() + "?" + data[0][i+6].toString();
            current = i;
          }

        //See if the source and destination both gets matched up

        if(data[0][i+2] == 1)
        {
          // print(data[0][i+4]);
          src = false;
          dest = false;
        }

        if(data[0][i + 3] == source)
          {
            // print("Source found \n");
            src = true;
          }
         else if(data[0][i + 3] == destination)
         {
          // print("Destination found \n");
          dest = true;
          // print(src);
          // print(dest);
          if(src == true)
            {
              // print("One path = " + data[0][i + 1].toString() + " <-> " + data[0][i+2].toString() + " <=> " + data[0][i+10].toString());
              changingString = data[0][i + 1].toString() + "?" + data[0][i+1].toString() + "?" + data[0][i+6].toString();

              bool flag = false;

              if(BusListFortopThreeDynamicdrivers.length < 3) {

                var cntr = 0;
                for (String activeRoutes in activeRouteNames) {
                  print(activeRoutes + " --- " + CurrentRoutenBusname);


                  var llaatt = data[0][i+6];
                  var lloonn = data[0][i+7];

                  for(var j = 0 ; j < stopdata[0].length - 4 ; j += 4)
                  {

                    if(stopdata[j][1] == data[i][3])
                    {
                         llaatt = stopdata[j][2];
                         lloonn = stopdata[j][3];
                         break;
                    }
                  }

                  var disttime1 = distance(position.latitude , position.longitude , llaatt , lloonn ) / 5;
                  if (activeRoutes == CurrentRoutenBusname && BusListFortopThreeDynamicdrivers.length <=3 && timeToMin(currentTime) + disttime1 <= timeToMin(data[0][i+6].toString()))
                  {
                    print("Found = " + CurrentRoutenBusname.toString() + " of driver = " + active_List_name[cntr]);
                    BusListFortopThreeDynamicdrivers.add(
                        active_List_name[cntr].toString() );

                    //Adding to the dynamic buses
                    BusListFortopThreeDynamicdriversRoutes.add(CurrentRoutenBusname.toString());

                    bool secondTime = false;

                    print("\n\n\n\n");
                    // print(position.latitude );
                    // print(position.longitude );

                    var minimumDist = 99999.99;
                    String closestStop = "Not Able to Track";

                    for(int j = current ; ; j += 11)
                      {

                        // print(data[0][j+6].toString() + " => " + data[0][j+7].toString() + " " + distance(position.latitude , position.longitude ,data[0][j+6] , data[0][j+7] ).toString() + " Km");

                            var llaatt = data[0][i+6];
                            var lloonn = data[0][i+7];

                            for(var jjj = 0 ; jjj < stopdata[0].length - 4 ; jjj += 4)
                            {

                              if(stopdata[jjj][1] == data[j][3])
                              {
                                   llaatt = stopdata[jjj][2];
                                   lloonn = stopdata[jjj][3];
                                   break;
                              }
                            }

                        var dist = distance(position.latitude , position.longitude , llaatt , lloonn );

                        if(dist < minimumDist)
                          {
                            minimumDist = dist;
                            closestStop = data[0][j+3].toString() + " at " + data[0][j+6];
                          }

                        if(data[0][j+2] == 1)
                          {
                            if(secondTime)
                              {
                                break;
                              }
                            secondTime = true;
                          }
                      }

                    // print("\n\n We found closest stop was => ");
                    // print(closestStop);
                    // print("\n------------------------------------\n");

                    TimeFortopThreeDynamicdriversRoutes.add(closestStop);



                    flag = true;
                    break;
                  }
                  cntr+=1;
                }
              }


           var llaatt = data[0][i+6];
                  var lloonn = data[0][i+7];

                  for(var j = 0 ; j < stopdata[0].length - 4 ; j += 4)
                  {

                    if(stopdata[j][1] == data[i][3])
                    {
                         llaatt = stopdata[j][2];
                         lloonn = stopdata[j][3];
                         break;
                    }
                  }

              var disttime2 = distance(position.latitude , position.longitude ,llaatt , lloonn ) / 5;
              if(counter <= 3 && timeToMin(currentTime) + disttime2 <= timeToMin(data[0][i+6].toString()) )
              {
                // print(currentTime.toString() + "  && "+ timeToMin(currentTime).toString());
                // print(data[0][i+10].toString() + " && " + timeToMin(data[0][i+10].toString()).toString());
                // print("\n\n\n\n\n");
                counter+=1;
                busList.add(CurrentRoutenBusname);
                // print("\n\n\n");
                // print("Abhi ye mila = " + changingString);


                bool secondTime = false;
                var minimumDist = 99999.99;
                String closestStop = "Not Able to Track";

                for(int j = current ; ; j += 6)
                {

                  // print(data[0][j+6].toString() + " => " + data[0][j+7].toString() + " " + distance(position.latitude , position.longitude ,data[0][j+6] , data[0][j+7] ).toString() + " Km");


                    var llaatt = data[0][i+6];
                  var lloonn = data[0][i+7];

                  for(var jjj = 0 ; jjj < stopdata[0].length - 4 ; jjj += 4)
                  {

                    if(stopdata[jjj][1] == data[j][3])
                    {
                         llaatt = stopdata[jjj][2];
                         lloonn = stopdata[jjj][3];
                         break;
                    }
                  }

                  var dist = distance(position.latitude , position.longitude , llaatt , lloonn );

                  if(dist < minimumDist)
                  {
                    minimumDist = dist;
                    closestStop = data[0][j+3].toString() + " at " + data[0][j+6];
                  }

                  if(data[0][j+2] == 1)
                  {
                    if(secondTime)
                    {
                      break;
                    }
                    secondTime = true;
                  }
                }

                // print("\n\n We found closest stop was => ");
                // print(closestStop);
                // print("\n------------------------------------\n");

                TimeForstaticBus.add(closestStop);













                // print("\n\n\n");
              }
            }
        }

        // print(data[0][i+4]);


      }


    ------------------------------------------------------------------------------------------*/

















    // for(var i in BusListFortopThreeDynamicdrivers)
    //   {
    //     print(i);
    //   }
    // print("\n----------------------");
    // for(var i in busList)
    //   {
    //     print(i);
    //   }

    // print("Cnt came = " + cnt.toString());
    //
    //
    // print(data.length);

  }

  void change()
  {
    // print("\n\n\n\nHello\n\n\n\n");
    // print("new value is = " + s);

    s = source + " " + destination;
    // Fluttertoast.showToast(msg: "new value is = " + s);
  }

  List<String> listOfPlaces = ["abc","acf"];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Public Transport App'),
        ),
        body: Column(
          children: <Widget>[




            // ButtonTheme(
            //   child: FlatButton(
            //     padding: EdgeInsets.all(0),
            //     child: Align(
            //       alignment: Alignment.centerRight,
            //       child: Text(
            //         "X    ",
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
            //             // print(snap.snapshot.key);
            //             selDriver = snap.snapshot.value.toString();
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
            //         //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
            //         SystemNavigator.pop();
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //
            //       //var a = currentFirebaseUser!.uid;
            //       //print("khatama bye bye ho gya = " + currentFirebaseUser!.uid.toString());
            //     },
            //   ),
            // ),


            Padding(
                padding: const EdgeInsets.all(10.0),
                child: TypeAheadField(
                  noItemsFoundBuilder: (context) => const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text('No Item Found'),
                    ),
                  ),
                  suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                      color: Colors.white,
                      elevation: 4.0,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )),
                  debounceDuration: const Duration(milliseconds: 400),
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: _typeAheadController,
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                15.0,
                              )),
                          enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: "Search",
                          contentPadding:
                          const EdgeInsets.only(top: 4, left: 10),
                          hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                          suffixIcon: IconButton(
                              onPressed: () {},
                              icon:
                              const Icon(Icons.search, color: Colors.grey)),
                          fillColor: Colors.white,
                          filled: true)

                  ),
                  suggestionsCallback: (value) {
                    return StateService.getSuggestions(value);
                  },
                  itemBuilder: (context, String suggestion) {
                    return Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),

                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              suggestion,
                              maxLines: 1,
                              // style: TextStyle(color: Colors.red),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  onSuggestionSelected: (String suggestion) {
                    // setState(() {
                    //   userSelected = suggestion;
                    // });

                    source = suggestion;
                    _typeAheadController.text = suggestion;

                  },
                )),















            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TypeAheadField(
                noItemsFoundBuilder: (context) => const SizedBox(
                  height: 7,
                  child: Center(
                    child: Text('No Item Found'),
                  ),
                ),
                suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                    color: Colors.white,
                    elevation: 2.5,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )),
                debounceDuration: const Duration(milliseconds: 400),
                textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController2,
                    decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              15.0,
                            )),
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                            borderSide: BorderSide(color: Colors.black)),
                        hintText: "Search",
                        contentPadding:
                        const EdgeInsets.only(top: 4, left: 10),
                        hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 14),
                        suffixIcon: IconButton(
                            onPressed: () {},
                            icon:
                            const Icon(Icons.search, color: Colors.grey)),
                        fillColor: Colors.white,
                        filled: true)

                ),
                suggestionsCallback: (value) {
                  return StateService.getSuggestions(value);
                },
                itemBuilder: (context, String suggestion) {
                  return Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),

                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            suggestion,
                            maxLines: 1,
                            // style: TextStyle(color: Colors.red),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  );
                },
                onSuggestionSelected: (String suggestion) {
                  // setState(() {
                  //   userSelected = suggestion;
                  // });

                  destination = suggestion;
                  _typeAheadController2.text = suggestion;




                },
              )),




            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () async {
                  print("Your Source & destination = " + source + " " + destination);

                  //changingString = source + " " + destination;


                  TimeForstaticBus.clear();
                  TimeFortopThreeDynamicdriversRoutes.clear();
                  staticbusList.clear();
                  BusListFortopThreeDynamicdriversRoutes.clear();
                  BusListFortopThreeDynamicdrivers.clear();

                  loadAsset();

                  Timer(Duration(seconds: 10), () async {
                    var response = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectNearestActiveDriversScreenThree()));
                  });



                  // print("\n\n\n\n\nYou have printed = " + changingString);
                  // print("\n\n\n\n");
                  //
                  // Fluttertoast.showToast(msg: changingString);

                },
                child: Text('Find Buses !!!'),
              )

            ),







            // Padding(
            //     padding: const EdgeInsets.all(10.0),
            //     child: TextButton(
            //       style: ButtonStyle(
            //         foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            //       ),
            //       onPressed: () async {
            //        // print("Your Source & destination = " + source + " " + destination);
            //
            //         //changingString = source + " " + destination;
            //
            //
            //        // loadAsset();
            //
            //         print("\n\n\n\n\nYou have printed = " + changingString);
            //         print("\n\n\n\n");
            //
            //         Fluttertoast.showToast(msg: changingString);
            //
            //         var response = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectNearestActiveDriversScreenThree()));
            //
            //
            //       },
            //       child: Text('See results'),
            //     )
            //
            // ),


            //
            // ListView.builder(
            //   itemCount: 3,
            //   itemBuilder: (BuildContext context, int index)
            //   {
            //     return GestureDetector(
            //
            //       onTap: ()
            //       {
            //         // setState(() {
            //         //   chosenDriverId = dList[index]["id"].toString();
            //         // });
            //        // Navigator.pop(context , "driverChoosed");
            //       },
            //
            //       child: Card(
            //         color: Colors.grey,
            //         elevation: 3,
            //         shadowColor: Colors.green,
            //         margin: const EdgeInsets.all(8),
            //         child: ListTile(
            //           leading: Padding(
            //             padding: const EdgeInsets.only(top: 2.0),
            //             child: Image.asset(
            //               "Images/car.png",
            //               width: 70,
            //             ),
            //           ),
            //           title: Column(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             children: [
            //               Text(
            //                 "hi",
            //                 style: const TextStyle(
            //                   fontSize: 14,
            //                   color: Colors.black54,
            //                 ),
            //               ),
            //               Text(
            //                 "bi",
            //                 style: const TextStyle(
            //                   fontSize: 12,
            //                   color: Colors.white54,
            //                 ),
            //               ),
            //               SmoothStarRating(
            //                 rating: 3.5,
            //                 color: Colors.black,
            //                 borderColor: Colors.black,
            //                 allowHalfRating: true,
            //                 starCount: 5,
            //                 size: 15,
            //               ),
            //             ],
            //           ),
            //
            //         ),
            //       ),
            //     );
            //   },
            // ),







          ],
        ),
      ),
    );
  }
}