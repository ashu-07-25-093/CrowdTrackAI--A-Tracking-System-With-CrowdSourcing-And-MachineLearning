# CrowdTrackAI--A-Tracking-System-With-CrowdSourcing-And-MachineLearning

This repo is demonstrating the project about bus-arrival time prediction using Crowd-sourcing and Machine Learning approach. There are certain projects which directly predict the bus arrival time using machine learning, but they are using the GPS installed over the buses. But we are following the crowd-sourcing approach which considers multiple user’s locations.

The project is divided mainly into three parts : User Application, Driver’s Application and the Prediction System. 

### Flutter

For Application development purposes, we used Flutter, and for development, we used Android Studio. 

You can use the following document to set up the flutter.

Link : https://drive.google.com/drive/folders/1htW_D1ANxcN2iBZ_oy15-cGKHslZNLG1?usp=sharing

We have two different applications for the user and the driver. The user folder contains the user’s application, and the driver’s folder contains the driver’s application. So, make two different projects in your IDE that correspond to the user and the driver.

Once you successfully set up the user and driver’s application, go to the pubspec.yaml file, the IDE will show the pub get option and click on that. It will download all the required libraries with the specified version. If you want to use any new library, mention it here with its version name and do pub get.

### Firebase

The communication between all three parts of the project is governed by the Firebase real-time database. You have to create the Firebase project and two applications within it. Download the google-services.json file and replace it with the file present at /android/app/google-services.json 

Now go to the project settings of your Firebase project; you will find the web-API key there. 
You have to paste this key to multiple files in the project.

1.	/android/app/src/main/AndroidManifest.xml
2.	/lib/global/map_key.dart

Go to the cloud messaging section in the Firebase project settings and copy the server key token.

Paste this token to the global file at /lib/global/global.dart with the String variable.
cloudMessagingServerToken.

If you haven’t enabled cloud messaging, then enable it in Firebase.

Do the above process for both applications.

In the Authentication section of your Firebase project, keep the sign-in method as Email/password.

Go to the real-time database in your project. Go to the rule section and paste the rules below. 

	{
      "rules": {
        ".read":true,
        ".write": true,
      }
    }   

If all the steps mentioned above are performed successfully, you should be able to see running both of your applications and see the changes happening in Firebase. (Running the applications for the first time will automatically create the tables on Firebase.)


### Prediction System

The prediction system has two servers. One is hosted on port 5000, and another is running on port 8888; you can change the port number in the code files. Whenever a user makes a search query from a particular source to the destination, the corresponding changes will be made over the Firebase database(model data) in our case. Now, one server from our prediction system is sensing these changes continuously, and whenever some change occurs, it will fetch the newer data and give it to server2. Server2 here takes the data, preprocesses it, makes the prediction, prepares the response, and sends it back to server1. Now, server1 pushes the prediction result on the Firebase database(prediction table in our case).

### Data and Code files for Prediction system : 

https://drive.google.com/drive/folders/1ckZSnRy6gBrcnTsVVof5w-ihe41q5ZSR?usp=sharing


### Video Demonstration

https://drive.google.com/drive/folders/1v-WQKNGvGhoUHH9N1sFL5zLmaGHaC1LW?usp=sharing






