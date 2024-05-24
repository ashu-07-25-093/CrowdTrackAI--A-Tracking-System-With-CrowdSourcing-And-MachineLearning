import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
//
class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({Key? key}) : super(key: key);

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}


int cnt = 0;
int Row = 1;

const credentialz = r'''
{
  "type": "service_account",
  "project_id": "daring-slice-375205",
  "private_key_id": "8414dbbbdf58a905df8602f50e9e74b721f70859",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDspwwoSbqGmot8\nHFqEmTdNVJ8HSB/+cylwKhQ2vjwbJggQsfO/yERj6jlx7HgyLQe2Q4ePlIFL4ret\naAYmZIhbCPQKKogGayoYC6PwLu83o9zGijp8zdT73QhLSz3c0rMj68ZraLcb9wn2\nlhFGd4TcRs02j2XusZejwD+TmTG0rHoDd8ZdbuQb1gu9xkDTUwBCOkKYi2kFtteK\nC197dl5FW5T2Z/3cygdPdAg77oMkZCwEtVbpFKp0xcLxe3CYiNi0DXz4OSFF0c7L\noE5euPwoUBm0yoSKGsOnxhF7ghlmu/tOf7UEgGkfkBNGPlRmvcAFzzrb1RNe4IB0\nsuLDYpvFAgMBAAECggEAMZgTZ+kFljpSg3S0soeia4oRlrbSf6JWO4uR92P4GC9o\n7sjAPn+Dd5XpKnsGOGuv604tHVWfoA3X9NbxPQACBGP0sqG1pnS0WlwsI8ROPRCR\nzqi+t5NyMEMivxa6VOnyAVPinfVQtGNZ2uuZnLUk6n3K+UVldPeSQg6itDWdUVGR\nxpLmRgPNZFUPQXk4OgfaG3Fe/9HIXK37ePRnn0kMRnZmUjFUNBRWBGrnXRVnBHvT\njU4apljha7vuTXYnd6Zq30kXZ4wxNt4i5XRYckV6CQQwVdfP4E7STfvYBSuuSSiK\njVR6s6JaN7y0L+bvXPUh31NvS9kX/THdH+ZHJ3mhYQKBgQD5q1HzOmAkk3Y9rNgZ\nh5iR3k5cJId1PQhPxERSAlCForTW0MrSXR046yEVWE8piLfv/1l2E0dBTkoaQBA5\ncOy2sNrqmAHl8FpO35jm2ApHySGX+/I4DGBt7XK+Q6l0HOd12Q452bfR4YyjCUzi\nC6WMBfNmcE6QWdnuOdhDyycbYQKBgQDypztl8Fe6dKGXbtwpoWJ/JEqLI6QkRn3/\n33cRp33quY5aMNKk3fnxsfH2SVQqZEF2PmSZBcoPWPr0+2P+c8cf4Q9W6vUSDjS7\njYWg5XrZLPoAflshV9Dnvoajvs1T3oe+7nbrKlEKInhnJQfwjoosTVZn3N6s12O3\nYNRF8Une5QKBgF1R29++AhGpzJhg8qUYOb7MCR4HyVnY5jJqed7tXouUtWNVx3m5\ntCKCQGtqBqzPnXDnUNkBe7C9QpVtPKM7wj7G/AyTpKH9pMO2b8BZH/6U/yl/0pmA\nhsqP5kOXps7vvtQdvWOCLWMVmyuVXldfYxFjaAbyE2uBKiQRGvS8CnIBAoGAGMjo\nEkN4Un0zPCqApmfrjZ0BWDDtxR7GI+qJWO5IuD73wVKXUWuy6fMJCeT3idTvssow\nsEidGPA3weojjov43NK6JGCfY5a74CRWb9bAs4oahw5g9Ijpt6IIUpVcl6J1LxVg\nZCjQWj6nGbH4m6OTjW7g0n8G55SghMyJIhPBPdkCgYA8vLYj5+CLD/u0/uZl37DN\nYSRLvJH8YMLtEfrg1+Z/oQYG4yesFDYhI2Oa8BDLlwcqyh8+tmNB208IxlSYypIZ\n+ghp00lDGbFf3/fkReJIMT/O+t+OU3OiHTKDqx45ijyFgV7vYLhjVNbduqxeU+Mq\nD4W4Z32AUu/uAEwLWuMFkQ==\n-----END PRIVATE KEY-----\n",
  "client_email": "googlesheetssecond@daring-slice-375205.iam.gserviceaccount.com",
  "client_id": "103425167353482323938",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/googlesheetssecond%40daring-slice-375205.iam.gserviceaccount.com"
}
''';

const spreadsheetId = '1cH6OK7D3LiD-rMbssTbaHvQFv9UaIQTr5ZnlNVo8avA';

// final gsheets = GSheets(credentialz);

var sh;


TextEditingController nameTextEditingController = TextEditingController();
TextEditingController routeNameTextEditingController = TextEditingController();


class _EarningsTabPageState extends State<EarningsTabPage> {

  void createSheets()
  async {
    final gsheets = GSheets(credentialz);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    var sheet = ss.worksheetByTitle("Sheet1");

    sh = sheet;
    Row = 1;
    cnt = 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [




                TextField(
                  controller: nameTextEditingController,
                  style: const TextStyle(
                      color: Colors.grey
                  ),
                  decoration: const InputDecoration(
                    labelText: "Stop Name",
                    hintText: "Stop Name",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),


                ElevatedButton(
                  onPressed: ()
                  async {

                    createSheets();
                  },

                  child: const Text(
                    "Create Sheet",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                    ),
                  ),
                ),



                ElevatedButton(
                  onPressed: ()
                  async {

                    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                    print(position.longitude); //Output: 80.24599079
                    print(position.latitude);

                    // String tdata = DateFormat("hh:mm:ss a").format(DateTime.now());
                    String tdata = DateFormat("hh:mm a").format(DateTime.now());
                    print(tdata);
                    print("\n\n\n\n\n");

                    await sh?.values.insertValue(cnt, column: 1, row: Row);
                    await sh?.values.insertValue(570, column: 2, row: Row);
                    await sh?.values.insertValue(cnt, column: 3, row: Row);
                    await sh?.values.insertValue(cnt++, column: 4, row: Row);
                    await sh?.values.insertValue(nameTextEditingController.text.toString(), column: 5, row: Row);
                    await sh?.values.insertValue(position.latitude.toString(), column: 6, row: Row);
                    await sh?.values.insertValue(position.longitude.toString(), column: 7, row: Row);
                    await sh?.values.insertValue("IITM Bus", column: 8, row: Row);
                    await sh?.values.insertValue("UP", column: 9, row: Row);
                    await sh?.values.insertValue(tdata, column: 10, row: Row);





                    Row+=1;
                  },

                  child: const Text(
                    "Add Entry",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}






