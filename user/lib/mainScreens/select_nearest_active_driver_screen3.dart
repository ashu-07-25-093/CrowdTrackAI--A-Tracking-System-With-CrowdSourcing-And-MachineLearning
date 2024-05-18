import 'package:csv/csv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:user/assistants/assistant_methods.dart';
import 'package:user/mainScreens/dynamic_buses_info.dart';
import 'package:user/mainScreens/static_buses_info.dart';

import '../global/global.dart';
import 'main_screen_Two.dart';
// import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
// import 'package:users_app/global/global.dart';


class SelectNearestActiveDriversScreenThree extends StatefulWidget
{
  DatabaseReference? referenceRideRequest;
  SelectNearestActiveDriversScreenThree({this.referenceRideRequest});

  @override
  _SelectNearestActiveDriversScreenStateThree createState() => _SelectNearestActiveDriversScreenStateThree();
}



class _SelectNearestActiveDriversScreenStateThree extends State<SelectNearestActiveDriversScreenThree>
{



  String fareAmount = "99";
  //
  // getFareAmountAccordingToVehicleType(int index)
  // {
  //   if(tripDirectionDetailsInfo != null)
  //   {
  //     if(dList[index]["car_details"]["type"].toString() == "bike")
  //     {
  //       fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) / 2).toStringAsFixed(2);
  //     }
  //     if(dList[index]["car_details"]["type"].toString() == "uber-x") //means executive type of car - more comfortable pro level
  //         {
  //       fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 2).toStringAsFixed(2);
  //     }
  //     if(dList[index]["car_details"]["type"].toString() == "uber-go") // non - executive car - comfortable
  //         {
  //       fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString();
  //     }
  //   }
  //   return fareAmount;
  // }

//Just to return the bus at which bustop will it reach at what time
  fun(String s , String z)
  {
    int idx = s.indexOf('?');
    int lidx = s.lastIndexOf('?');
    
    return "Bus No := " + s.substring(0,idx) + ":-" + s.substring(lidx+1 , s.length - 2) + " \nWill reach " + z;
  }

//Just to return the bus at which bustop will it reach at what time
  fun2(String y , String s , String z)
  {
    int idx = s.indexOf('?');
    int lidx = s.lastIndexOf('?');
    return "Bus No = " + s.substring(0,idx)  + ":-" + s.substring(lidx+1 , s.length - 2) + " \nWill reach " + z;

  }


  List<List<dynamic>> data = [];


  Future<void> setStaticBusDetails(String s)
  async {
    // final tagName = 'grubs, sheep';
    final split = s.split('?');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++)
        i: split[i]
    };
    print(values); // {0: grubs, 1:  sheep}

    final routeId = values[0];
    final routeName = values[1];
    final startTime = values[2];

    //selectedStaticBus = value1! + " " + value2! + " " + value3!;


    final myData = await rootBundle.loadString("assets/busdata.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);

    data = csvTable;

    var cnt = 0;
    var src = false,
        dest = false;

    var counter = 0;


    for (var i = 0; i < data[0].length - 11; i += 11) {
      // print(data[0][i+5]);
      //if(data[0][i + 4] == 1)

      //print(data[0][i + 1].toString() + " " + data[0][i + 2].toString() + " " + data[0][i + 10].toString() );

      if (data[0][i + 4] == 1) {
        // print(data[0][i + 1].toString() + " " + data[0][i + 2].toString() + " " + data[0][i + 10].toString() );

        if (data[0][i + 1].toString() == routeId.toString() &&
            data[0][i + 2].toString() == routeName.toString() &&
            data[0][i + 10].toString() == startTime.toString()) {
          staticbusList.add(
              data[0][i + 5].toString() +
                  " at time => " + data[0][i + 10].toString());
          print(data[0][i + 5].toString() +
             " at time => " + data[0][i + 10].toString());

          for (var j = i + 11; j < data[0].length - 11; j += 11) {
            // print(data[0][j+4]);
            if (data[0][j + 4] == 1) break;
            staticbusList.add(
                data[0][j + 5].toString() +
                    " at time => " + data[0][j + 10].toString());
            print(data[0][j + 5].toString() +
                " at time => " + data[0][j + 10].toString());
          }

          break;
        }
      }

      //
      // print("\n\n\n\n\n");
      // print(staticbusList.length);
      // print("\n\n\n\n\n");
      // print(staticbusList);
    }
  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: const Text(
          "Buses found are :- ",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
              Icons.close, color: Colors.white
          ),
          onPressed: ()
          {
            //delete/remove the ride request from database
            widget.referenceRideRequest!.remove();

            Fluttertoast.showToast(msg: "you have cancelled the ride request.");

            SystemNavigator.pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15 , vertical: 0.5),
        child: Column(children: [

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
          //
          //       print("khatama bye bye ho gya = " + currentFirebaseUser!.uid.toString());
          //     },
          //   ),
          // ),

          SizedBox(
            height: 15,
          ),

          Text(
            "Dynamic Bus Data :- ",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18
            ),
          ),

          SizedBox(
            height: 3,
          ),


          Expanded(child: Container(child:
          ListView.builder(
            itemCount: myDynamicBusList.length,
            itemBuilder: (BuildContext context, int index)
            {
              String? dKey = indToBus[index];
              return GestureDetector(

                onTap: ()
                async {
                  // setState(() {
                  //   chosenDriverId = BusListFortopThreeDynamicdrivers[index].toString();
                  // });
                  // Navigator.pop(context , "driverChoosed");

                  //setStaticBusDetails(BusListFortopThreeDynamicdrivers[index]);

                  // selectedStaticBus = BusListFortopThreeDynamicdrivers[index];

                  busStationList = myDynamicBusList[index];

                  print("dynamic data holder");

                  await Navigator.push(context, MaterialPageRoute(builder: (c)=> DynamicBusInfo()));


                  // Fluttertoast.showToast(msg: "You selected bus route :- " + BusListFortopThreeDynamicdrivers[index]);

                },

                child: Card(
                  color: Colors.grey,
                  elevation: 3,
                  shadowColor: Colors.green,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Image.asset(
                        "Images/car.png",
                        width: 70,
                      ),
                    ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "bus no : "+index.toString() + ", available seats : "+ availableBusSeats[dKey].toString(),
                          // "hihi",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        // Text(
                        //   "Tata Bus",
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.white54,
                        //   ),
                        // ),
                        SmoothStarRating(
                          rating: 3.5,
                          color: Colors.black,
                          borderColor: Colors.black,
                          allowHalfRating: true,
                          starCount: 5,
                          size: 15,
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   "Rs " + fareAmount,
                        //   style: const TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 2,),
                        Text(
                          tripDirectionDetailsInfo != null
                              ? tripDirectionDetailsInfo!.duration_text!
                              : "" ,

                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 12
                          ),
                        ),

                        const SizedBox(height: 2,),
                        Text(
                          tripDirectionDetailsInfo != null
                              ? tripDirectionDetailsInfo!.distance_text!
                              : "" ,

                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 12
                          ),
                        ),




                      ],
                    ),
                  ),
                ),
              );
            },
          ),

              )
          ),

          Text(
            "Static Bus Data :- ",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18
            ),
          ),

          SizedBox(
            height: 3,
          ),

          Expanded(child: Container(child:
          ListView.builder(
            itemCount: busList.length,
            itemBuilder: (BuildContext context, int index)
            {
              return GestureDetector(

                onTap: ()
                async {
                  // setState(() {
                  //   chosenDriverId = dList[index]["id"].toString();
                  // });
                  // Navigator.pop(context , "driverChoosed");

                  staticbusList.clear();
                  setStaticBusDetails(busList[index]);

                  print("static data holder");

                  // selectedStaticBus = busList[index];

                  await Navigator.push(context, MaterialPageRoute(builder: (c)=> StaticBusInfo()));


                  // Fluttertoast.showToast(msg: "You selected bus route :- " + busList[index]);

                },

                child: Card(
                  color: Colors.grey,
                  elevation: 3,
                  shadowColor: Colors.green,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Image.asset(
                        "Images/car.png",
                        width: 70,
                      ),
                    ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          fun(busList[index] , TimeForstaticBus[index]),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        // Text(
                        //   "Tata Bus",
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.white54,
                        //   ),
                        // ),
                        SmoothStarRating(
                          rating: 3.5,
                          color: Colors.black,
                          borderColor: Colors.black,
                          allowHalfRating: true,
                          starCount: 5,
                          size: 15,
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   "Rs " + fareAmount,
                        //   style: const TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 2,),
                        Text(
                          tripDirectionDetailsInfo != null
                              ? tripDirectionDetailsInfo!.duration_text!
                              : "" ,

                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 12
                          ),
                        ),

                        const SizedBox(height: 2,),

                        //

                        Text(
                          tripDirectionDetailsInfo != null
                              ? tripDirectionDetailsInfo!.distance_text!
                              : "" ,

                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 12
                          ),
                        ),




                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          )
          ),

        ],),
      )










    );
  }
}