
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Firebase_API.dart';
import 'Login.dart';

import 'main_page.dart';
import 'package:flutter/foundation.dart';

class Welcome extends StatefulWidget {
   Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {


  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData){
              print("Logged in");
              FirebaseAPI().initNotifications();
              // if (kIsWeb) {
              //
              //
              // }
              // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
              //     initDynamicLink();
              // }
              return MainPage();
            }else{
              print("Logged out");
              return Login();
            }
          },
        )
    );
  }
}
