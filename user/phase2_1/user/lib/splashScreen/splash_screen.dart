import 'dart:async';

// import 'package:driver_app/authentication/signup_screen.dart';
// import 'package:driver_app/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';

import '../assistants/assistant_methods.dart';
import '../authentication/login_screen.dart';
import '../global/global.dart';
import '../mainScreens/main_screen.dart';

// import '../authentication/login_screen.dart';
// import '../global/global.dart';


class MySplashScreen extends StatefulWidget
{
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}



class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer()
  {

    fAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(const Duration(seconds: 3), () async
    {
      if(await fAuth.currentUser != null)
        {
          currentFirebaseUser = fAuth.currentUser;
          Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
        }
      else
        {
          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
        }

      // if(await fAuth.currentUser != null)
      // {
      //   // currentFirebaseUser = fAuth.currentUser;
      //   Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      // }
      // else
      // {
      //   Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      // }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }


  @override
  Widget build(BuildContext context)
  {
    return Material(
      child: Container(
        color: Colors.orangeAccent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset("Images/img_1.png"),

              const SizedBox(height: 10,),

              const Text(
                "Public Transport Tracking App",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}