import 'dart:async';

import 'package:csv/csv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:user/assistants/assistant_methods.dart';
import 'package:user/mainScreens/my_dynamic_details.dart';
import 'package:user/mainScreens/static_buses_info.dart';

import '../global/global.dart';
// import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
// import 'package:users_app/global/global.dart';


class DynamicBusInfo extends StatefulWidget
{
  @override
  _DynamicBusInfo createState() => _DynamicBusInfo();
}



class _DynamicBusInfo extends State<DynamicBusInfo>
{

  @override
  void initState() {
    super.initState();
    // Example initialization of busStationList
    //busStationList = ['Station 1', 'Station 2', 'Station 3'];
    // Start auto-refresh timer
    startTimer();
  }

  Timer? _timer;

  void startTimer() {
    // Create a timer that runs every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) async {
      // Call a method to fetch or update the bus station list
      await findDynamicDetails();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  //String fareAmount = "99";
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



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: const Text(
          "Buses found are :- ",
          style: TextStyle(
            fontSize: 10,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
              Icons.close, color: Colors.black12
          ),
          onPressed: ()
          {
            //
          },
        ),
      ),
      body: ListView.builder(
        itemCount: busStationList.length,
        itemBuilder: (BuildContext context, int index)
        {
          return GestureDetector(

            onTap: ()
            async {


            },

            child: Card(
              color: Colors.grey,
              //elevation: 1,
              shadowColor: Colors.black,
              //margin: const EdgeInsets.all(8),
              child: ListTile(

                title: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      busStationList[index],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),

                  ],
                ),

              ),
            ),
          );
        },
      ),
    );
  }
}