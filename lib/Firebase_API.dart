import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:drbaapp/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'GroupInfoPage.dart';
import 'main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// bool isOpening = false;


Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');

}

void handleMessage(RemoteMessage? message) {
  if (message == null) return;

  if (message.data['page']=='pagechat') {
    router.go('/chat${message.data['receiverName']}/${message.data['currentUserName']}/${message.data['receiverID']}');

  }

  if (message.data['page']=='pageevent') {
    router.go('/event${ message.data['eventID']}');

  }
  if (message.data['page']=='pagegroup') {
    router.go('/group${message.data['groupID']}');
  }
  if (message.data['page']=='pagenews') {
    router.go('/news${message.data['newsID']}');

  }
}

// Future initLocalNotifications() async
// {
//   const iOS =IOSInitializationsSettings();
//   const android = AndroidInitializationSettings('pickleicon.png');
//   const settings = InitializationSettings(android: android, iOS:iOS);
//
//   await _localNotifications.initialize(
//     settings,
//     onSelectNotification: (payload){
//       final message = RemoteMessage.fromMap (jsonDecode(payload));
//       handleMessage(message);
//     }
//   );
// final platform = initLocalNotifications().resolvePlatformSpecificImport;
// AndroidFlutterLocalNotificationsPlugin();
// await platform?.createNotificationChennel(_androidChannel);
// }

Future initPushNotifications() async {
  // if (isOpening == false){
  //   isOpening = true;
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );

  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      // await Future.delayed(Duration(seconds: 15));
      // isOpening = false;
 //   }
  // FirebaseMessaging.onMessage.listen((message) {
  //   final notification = message.notification;
  //   if (notification==null) return;
  //   _localNotifications.show(
  //     notification.hashCode,
  //     notification.title,
  //     notification.body,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         _androidChannel.id,
  //         _androidChannel.name,
  //         channelDescription: _androidChannel.description,
  //         icon: 'pickleicon.png',
  //
  //       )
  //     )
  //     payload: jsonEncode(message.toMap()),
  //   );
  // });
}

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // final _androidChannel = const AndroidNotification(
  //   'high_importance_channel',
  //   'High Importance notifications',
  //   description: 'This chennel is used for important notifications',
  //   importance: Importance.defaultImportance,
  // );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {

    // if (isOpening == false){
    //   isOpening = true;

      await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    final currentUser = FirebaseAuth.instance.currentUser!;

    // await FirebaseFirestore.instance
    //     .collection('Users')
    //     .get()
    //     .then((Users) async {
    //   if (Users.docs.isNotEmpty) {
    //     for (int i = 0; i < Users.docs.length; i++) {
    //       String email = Users.docs[i]['Email'];
    //       String UserID = Users.docs[i].id;
    //       if (email == currentUser.email!) {
     //       i = Users.docs.length;

            await FirebaseFirestore.instance
                .collection("Students")
                .doc(currentUser.uid)
                .update({'Token': fCMToken});
      //    }
      //  }
    //  }
    // });

 //   FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

initPushNotifications();

//initLocalNotifications();
  }
  //   await Future.delayed(Duration(seconds: 3));
  //   isOpening = false;
  // }
}



Future<void> sendNewsPushNotification(String postName, String newsID, String newsName,String postID ) async {

    await FirebaseFirestore.instance
        .collection('Students')
        .get()
        .then((Students) async {
      //  if (Users.docs.isNotEmpty) {
      for (int i = 0; i < Students.docs.length; i++) {
        // Builder(
        //     builder: (BuildContext context) async {
        try {
          final body = {
            "to": Students.docs[i]['Token'],
            "notification": {
              "title":
              // Builder(
              //     builder: (BuildContext context)  {
              AppLocalizations.of(scaffoldMessengerKey.currentContext!).dRBANewsfeed+'!', //our name should be send
              "body": postName+AppLocalizations.of(scaffoldMessengerKey.currentContext!).postedanewsfeed+newsName,
              "android_channel_id": "chats"
            },
            "data": {
              "newsID": newsID,
              "receiverName": Students.docs[i]['Name'],
              "postID": postID,
              "page": 'pagenews'
            }

          };
          var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                'key=AAAAJrWY81o:APA91bG5rerbSvSTtSjAIRpV0q58c2cIhV5QeRkZu6qiWMauVmCwZGecR6cYEvuNL6G0unSlHccAqxU61WBBK6axB71i60yz_QprD2a22KY2wCG9xx63B1uVP8GbLHToAYY40SIQFC7G'
              },
              body: jsonEncode(body));
          log('Response status: ${res.statusCode}');
          log('Response body: ${res.body}');
          //     }
          // );
        } catch (e) {
          log('\nsendPushNotificationE: $e');
        }
      }
    });




}



Future<void> sendPushNotification(
 String msg, String myName, String receiverName, String myID, String receiverID) async {
  String? chatUserToken = '';
  await FirebaseFirestore.instance
      .collection('Students')
      .doc(receiverID)
      .get().then((student) async {

      chatUserToken = student['Token'];
  });
  try {
    final body = {
      "to": chatUserToken,
      "notification": {
        "title": myName, //our name should be send
        "body": msg,
        "android_channel_id": "chats"
      },
    "data": {
      "receiverName": myName,
      "currentUserName": receiverName,
      "receiverID": myID,
      "page": 'pagechat'
    }
    };
    var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAAJrWY81o:APA91bG5rerbSvSTtSjAIRpV0q58c2cIhV5QeRkZu6qiWMauVmCwZGecR6cYEvuNL6G0unSlHccAqxU61WBBK6axB71i60yz_QprD2a22KY2wCG9xx63B1uVP8GbLHToAYY40SIQFC7G'
        },
        body: jsonEncode(body));
    log('Response status: ${res.statusCode}');
    log('Response body: ${res.body}');
  } catch (e) {
    log('\nsendPushNotificationE: $e');
  }

}

Future<void> sendEventPushNotification(String myName, bool _isOnline, String eventID, List<String> groupMembersIDList,String eventName,String groupName,) async {
String online='';
  if (_isOnline){
    online = ' '+AppLocalizations.of(scaffoldMessengerKey.currentContext!).online;

}
  for (int i = 0; i < groupMembersIDList.length; i++) {

    await FirebaseFirestore.instance
        .collection('Students')
        .doc(groupMembersIDList[i])
        .get().then((student) async {
            try {
              final body = {
                "to": student['Token'],
                "notification": {
                  "title": AppLocalizations.of(scaffoldMessengerKey.currentContext!).dRBAGroups+': '+groupName,
                  "body": myName+ AppLocalizations.of(scaffoldMessengerKey.currentContext!).createdanewevent+online+': '+AppLocalizations.of(scaffoldMessengerKey.currentContext!).dRBAGroups+eventName,
                  "android_channel_id": "chats"
                },
                "data": {
                  "eventID": eventID,
                  "currentName": student['Name'],
                  "page": 'pageevent'
                }
              };
              var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: {
                    HttpHeaders.contentTypeHeader: 'application/json',
                    HttpHeaders.authorizationHeader:
                    'key=AAAAJrWY81o:APA91bG5rerbSvSTtSjAIRpV0q58c2cIhV5QeRkZu6qiWMauVmCwZGecR6cYEvuNL6G0unSlHccAqxU61WBBK6axB71i60yz_QprD2a22KY2wCG9xx63B1uVP8GbLHToAYY40SIQFC7G'
                  },
                  body: jsonEncode(body));
              log('Response status: ${res.statusCode}');
              log('Response body: ${res.body}');
            } catch (e) {
              log('\nsendPushNotificationE: $e');
            }
  //  }
  });
  }
}



Future<void> sendEventChatPushNotification(List<String> IDlist, String msg, String myName, String eventName, String eventID,String currentUserID) async {
  IDlist.remove(currentUserID);

  for (int j = 0; j < IDlist.length; j++) {
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(IDlist[j])
        .get().then((student) async {
          try {
            final body = {
              "to": student.get('Token'),
              "notification": {
                "title": eventName+': '+ myName +AppLocalizations.of(scaffoldMessengerKey.currentContext!).postedamessage,
                "body": msg,
                "android_channel_id": "chats"
              },
              "data": {
                "eventID": eventID,
                "currentName": student.get('Name'),
                "page": 'pageevent'
              }
            };
            var res = await post(
                Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: {
                  HttpHeaders.contentTypeHeader: 'application/json',
                  HttpHeaders.authorizationHeader:
                  'key=AAAAJrWY81o:APA91bG5rerbSvSTtSjAIRpV0q58c2cIhV5QeRkZu6qiWMauVmCwZGecR6cYEvuNL6G0unSlHccAqxU61WBBK6axB71i60yz_QprD2a22KY2wCG9xx63B1uVP8GbLHToAYY40SIQFC7G'
                },
                body: jsonEncode(body));
            log('Response status: ${res.statusCode}');
            log('Response body: ${res.body}');
          } catch (e) {
            log('\nsendPushNotificationE: $e');
          }


  });

}}

// Future<void> sendEventRSVPPushNotification( List<String> _uidlist, String myName, String eventName, String eventID, String currentEmail) async {
//
//       for (int j = 0; j < _uidlist.length; j++) {
//         await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(_uidlist[j])
//             .get().then((user) async {
//
//         try {
//           final body = {
//             "to": user.get('Token'),
//             "notification": {
//               "title": myName + ' RSVPed to '+eventName,
//               "body": myName + ' RSVPed to '+eventName,
//               "android_channel_id": "chats"
//             },
//             "data": {
//               "eventID": eventID,
//               "currentName": user.get('Name'),
//               "currentEmail": user.get('Email'),
//               "page": 'pageevent'
//             }
//           };
//           var res = await post(
//               Uri.parse('https://fcm.googleapis.com/fcm/send'),
//               headers: {
//                 HttpHeaders.contentTypeHeader: 'application/json',
//                 HttpHeaders.authorizationHeader:
//                 'key=AAAAJrWY81o:APA91bG5rerbSvSTtSjAIRpV0q58c2cIhV5QeRkZu6qiWMauVmCwZGecR6cYEvuNL6G0unSlHccAqxU61WBBK6axB71i60yz_QprD2a22KY2wCG9xx63B1uVP8GbLHToAYY40SIQFC7G'
//               },
//               body: jsonEncode(body));
//           log('Response status: ${res.statusCode}');
//           log('Response body: ${res.body}');
//         } catch (e) {
//           log('\nsendPushNotificationE: $e');
//         }
//
//       });
//       }
//
// }

Future<void> sendGroupChatPushNotification(List<String> _IDlist, String msg, String myName, String groupName, String groupID, String currentUserID) async {
  _IDlist.remove(currentUserID);

  for (int j = 0; j < _IDlist.length; j++) {
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(_IDlist[j])
        .get().then((students) async {
           String receiverName= students.get('Name');
           try {
              final body = {
                "to": students.get('Token'),
                "notification": {
                  "title": myName +AppLocalizations.of(scaffoldMessengerKey.currentContext!).postedamessagein+groupName,
                  "body": msg,
                  "android_channel_id": "chats"
                },
                "data": {
                  "groupID": groupID,
                  "currentUserName": receiverName,
                  "groupName": groupName,
                  "page": 'pagegroup'
                }
              };
              var res = await post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: {
                    HttpHeaders.contentTypeHeader: 'application/json',
                    HttpHeaders.authorizationHeader:
                    'key=AAAAJrWY81o:APA91bG5rerbSvSTtSjAIRpV0q58c2cIhV5QeRkZu6qiWMauVmCwZGecR6cYEvuNL6G0unSlHccAqxU61WBBK6axB71i60yz_QprD2a22KY2wCG9xx63B1uVP8GbLHToAYY40SIQFC7G'
                  },
                  body: jsonEncode(body));
              log('Response status: ${res.statusCode}');
              log('Response body: ${res.body}');
            } catch (e) {
              log('\nsendPushNotificationE: $e');
            }
  });

}}


// Future<void> sendGroupRSVPPushNotification( List<String> _IDlist, String myName, String groupName, String groupID, String currentEmail, String currentUserID) async {
//   _IDlist.remove(currentUserID);
//
//   for (int j = 0; j < _IDlist.length; j++) {
//   await FirebaseFirestore.instance
//       .collection('Users')
//       .doc(_IDlist[j])
//       .get().then((user) async {
//             String receiverName= user.get('Name');
//             String receiverEmail= user.get('Email');
//
//             try {
//               final body = {
//                 "to": user.get('Token'),
//                 "notification": {
//                   "title": myName + ' Joined the group '+groupName,
//                   "body": myName + ' Joined the group '+groupName,
//                   "android_channel_id": "chats"
//                 },
//                 "data": {
//                   "groupID": groupID,
//                   "currentUserName": receiverName,
//                   "groupName": groupName,
//                   "currentUserEmail": receiverEmail,
//                   "page": 'pagegroupjoin'
//                 }
//               };
//               var res = await post(
//                   Uri.parse('https://fcm.googleapis.com/fcm/send'),
//                   headers: {
//                     HttpHeaders.contentTypeHeader: 'application/json',
//                     HttpHeaders.authorizationHeader:
//                     'key=AAAAJrWY81o:APA91bG5rerbSvSTtSjAIRpV0q58c2cIhV5QeRkZu6qiWMauVmCwZGecR6cYEvuNL6G0unSlHccAqxU61WBBK6axB71i60yz_QprD2a22KY2wCG9xx63B1uVP8GbLHToAYY40SIQFC7G'
//                   },
//                   body: jsonEncode(body));
//               log('Response status: ${res.statusCode}');
//               log('Response body: ${res.body}');
//             } catch (e) {
//               log('\nsendPushNotificationE: $e');
//             }
//
//
//
//   });}
//
// }