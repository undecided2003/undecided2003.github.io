import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/profilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Firebase_API.dart';
import 'GroupInfoPage.dart';
import 'RSVP_List.dart';
import 'Share_Screen.dart';
import 'showErrorMessage.dart';
import 'package:intl/intl.dart';
import 'edit_event.dart';
import 'extractTextLinks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maps_launcher/maps_launcher.dart';

class ChatList {
  String? chatName;
  String? chatMessage;
  Timestamp? chatTimestamp;
  String? chatID;

  ChatList(this.chatName, this.chatMessage, this.chatTimestamp, this.chatID);

  @override
  String toString() {
    return '{ ${this.chatName},${this.chatMessage}, ${this.chatTimestamp}, ${this.chatID}}';
  }
}

class eventInfo extends StatefulWidget {
  final String eventID2;
  final String currentUserName;

  eventInfo(this.eventID2, this.currentUserName);

  @override
  State<eventInfo> createState() => _eventInfoState();
}

class _eventInfoState extends State<eventInfo> {
  String _currentUserName = '';
  bool _isRsvp = false;

  // int? markerid;
  String _date = '';
  String _enddate = '';
  String eventID = 'From Events Info';
  String location = '';
  String latlng = '';
  String lat = '';
  String lng = '';
  String eventName = '';
  String description = '';
  bool isOnline = true;
  String link = '';
  String groupID = '';
  var studentNamesList = <String>[];
  var idList = <String>[];
  var adminList = <String>[];
  var chatMessageList = <String>[];
  var chatNameList = <String>[];
  var chatIDList = <String>[];
  var chatTimestampList = <Timestamp>[];
  String time = '';
  String endtime = '';
  String uriStarttime = '';
  String uriendtime = '';

  String groupName = '';
  var chatList = <ChatList>[];
  var _chatList = <ChatList>[];
  String eventImage =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/White.PNG?alt=media&token=5b94cca1-2ad2-4339-a611-0d76b88db3df';
  String dropdownValue = 'Edit';
  TranslationModel _translated = TranslationModel(translatedText: '', detectedSourceLanguage: '');
  final _translation = Translation(
    apiKey: 'AIzaSyATkm_B3odmcZ12hq-AICsLYY0z_UMczBQ',
  );

  getEventID(String _eventID) {
    setState(() {
      eventID = _eventID;
    });
  }

  getUserName() async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    String currentName = widget.currentUserName;

    if (currentName == 'from welcome') {
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(currentUser.uid)
          .get()
          .then((student) async {
        if (student.exists) {
          try {
            currentName = await student.get('Name');
          } catch (e) {
            if (await FirebaseAuth.instance.currentUser!.displayName != null) {
              _currentUserName =
                  await FirebaseAuth.instance.currentUser!.displayName!;
            }
            Future.delayed(Duration(seconds: 1), () async {});
            currentName = await student.get('Name');
          }

          setState(() {
            _currentUserName = currentName;
          });
        }
      });
    } else if (currentName.contains('Anonymous') || currentName == '') {
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(currentUser.uid)
          .get()
          .then((student) async {
        if (student.exists) {
          try {
            currentName = await student.get('Name');
          } catch (e) {
            if (FirebaseAuth.instance.currentUser!.displayName != null) {
              _currentUserName =
                  await FirebaseAuth.instance.currentUser!.displayName!;
            }
          }

          setState(() {
            _currentUserName = currentName;
          });
        }
      });
    } else {
      setState(() {
        _currentUserName = currentName;
      });
    }
  }

  getEventDataFromEventID(String EventID, context) async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('Events')
        .doc(EventID)
        .get()
        .then((events) async {
      if (events.exists) {
        String _eventImage = events.get('imageLink');

        String _location = events.get('Location');
        try {
          _location =
              _location.substring(0, events.get('Location').lastIndexOf('('));
          latlng = events.get('Location').substring(
              events.get('Location').lastIndexOf('(') + 1,
              events.get('Location').length - 1);
          lat = latlng!.substring(0, latlng!.lastIndexOf(','));
          lng = latlng!.substring(latlng!.lastIndexOf(',') + 1, latlng!.length);
        } catch (e) {}
        groupID = events.get('Group ID');

        await FirebaseFirestore.instance
            .collection("Groups")
            .doc(groupID)
            .get()
            .then((group) async {
          adminList = List.from(group.get('Admins'));

          groupName = group.get('Group Name');
        });
        setState(() {
          isOnline = events.get('Is online');
          eventImage = _eventImage;
          location = _location;
          link = events.get('Link');
          latlng;
          lat;
          lng;
          eventName = events.get('Event Name');
          description = events.get('Description');
          studentNamesList = List.from(events.get('Student Name'));
          idList = List.from(events.get('UserID'));
          adminList;
          groupID;
          groupName;
          if (idList.contains(currentUser.uid)) {
            _isRsvp = true;
          } else {
            _isRsvp = false;
          }

          ;
          chatMessageList = List.from(events.get('chatMessage'));
          chatNameList = List.from(events.get('chatName'));
          chatTimestampList = List.from(events.get('chatTimestamp'));
          chatIDList = List.from(events.get('chatID'));

          chatList = [];
          for (int j = 0; j < chatMessageList.length; j++) {
            chatList.add(ChatList(chatNameList[j], chatMessageList[j],
                chatTimestampList[j], chatIDList[j]));
          }
          ;
          _chatList = chatList.reversed.toList();
          time = DateFormat('hh:mm aa')
              .format(events.get('Time').toDate())
              .toString();
          _date = DateFormat('EEE, MM/dd/yyyy')
              .format(events.get('Time').toDate())
              .toString();
          endtime = DateFormat('hh:mm aa')
              .format(events.get('End Time').toDate())
              .toString();
          _enddate = DateFormat('EEE, MM/dd/yyyy')
              .format(events.get('End Time').toDate())
              .toString();
          //20231223T230000Z
          uriStarttime = DateFormat('yyyyMMddTHHmmssZ')
              .format(events.get('Time').toDate())
              .toString();
          uriendtime = DateFormat('yyyyMMddTHHmmssZ')
              .format(events.get('End Time').toDate())
              .toString();
        });
      } else {
        Navigator.of(context).pop();
        showErrorMessage(
            context, AppLocalizations.of(context).eventnolongerexist);
      }
    });
  }

  // final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> join() async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    var eventsList = <String>[];
    await getUserName();
    if (idList.contains(currentUser.uid)) {
      showErrorMessage(
          context, AppLocalizations.of(context).youhavealreadysignedup);
    } else {
//         sendEventRSVPPushNotification(
//             id_List, _currentUserName, eventName!, eventID, widget.currentUserEmail);

      studentNamesList.add(_currentUserName);
      idList.add(currentUser.uid);

      FirebaseFirestore.instance
          .collection('Events')
          .doc(eventID)
          .update({'Student Name': studentNamesList, 'UserID': idList});

      await FirebaseFirestore.instance
          .collection("Students")
          .doc(currentUser.uid)
          .get()
          .then((student) async {
        eventsList = List.from(student.get('Events'));
      });
      eventsList.add(eventID);
      await FirebaseFirestore.instance
          .collection("Students")
          .doc(currentUser.uid)
          .update({'Events': eventsList});
    }

    setState(() {
      _isRsvp = true;
    });

    showErrorMessage(context, AppLocalizations.of(context).yousignedup);
  }

  showDeleteAlertDialog(BuildContext context, String _EventID) async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    Widget cancelButton = ElevatedButton(
      child: Text(AppLocalizations.of(context).cancel),
      style: ElevatedButton.styleFrom(
//foregroundColor: Colors.grey,
          //  shadowColor: Colors.black,
          backgroundColor: Colors.grey[300]),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text(AppLocalizations.of(context).continue1),
      style: ElevatedButton.styleFrom(
//foregroundColor: Colors.grey,
          backgroundColor: Colors.grey[300]),
      onPressed: () async {
        if (idList == 0) {
          Navigator.of(context).pop();
          showErrorMessage(context,
              AppLocalizations.of(context).onlytheeventhostcandeletetheevent);
        } else if (currentUser.uid == idList[0]) {
          if (eventImage !=
              'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/events%2Fdharma_event.png?alt=media&token=95d81281-6780-4e68-9b72-64c220a32ef0&_gl=1*19oljci*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5NzQ0Nzc2OS41MTguMS4xNjk3NDUwNTM3LjUzLjAuMA..') {
            await FirebaseStorage.instance.refFromURL(eventImage).delete();
          }

          for (int j = 0; j < idList.length; j++) {
            var eventsList = <String>[];

            await FirebaseFirestore.instance
                .collection("Students")
                .doc(idList[j])
                .get()
                .then((User) async {
              if (User.exists) {
                eventsList = List.from(User.get('Events'));
                eventsList.remove(_EventID);
                await FirebaseFirestore.instance
                    .collection("Students")
                    .doc(idList[j])
                    .update({'Events': eventsList});
              }
            });
          }

          var groupEventsList = <String>[];
          await FirebaseFirestore.instance
              .collection("Groups")
              .doc(groupID)
              .get()
              .then((User) async {
            groupEventsList = List.from(User.get('Group Events'));
          });
          groupEventsList.remove(_EventID);
          await FirebaseFirestore.instance
              .collection("Groups")
              .doc(groupID)
              .update({'Group Events': groupEventsList});

          await FirebaseFirestore.instance
              .collection('Events')
              .doc(_EventID)
              .delete();
          Navigator.of(context).pop();
          Navigator.of(context).pop();

          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => Welcome(),
          // ));
        } else {
          Navigator.of(context).pop();
          showErrorMessage(context,
              AppLocalizations.of(context).onlytheeventhostcandeletetheevent);
        }
      },
    ); // set up the AlertDialog

    AlertDialog alert = AlertDialog(
      // title: Text(""),
      title: Text(AppLocalizations.of(context).doyouwanttodeletetheevent),
      titleTextStyle: TextStyle(color: Colors.black, fontFamily: 'NexaBold'),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> notGoing() async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    var eventsList = <String>[];
    if (idList.length == 0) {
      showErrorMessage(context, AppLocalizations.of(context).noonehasRSVPed);
    }
    for (int j = 0; j < idList.length; j++) {
      if (idList[j] == currentUser.uid) {
        studentNamesList.removeAt(j);
        idList.remove(currentUser.uid);

        FirebaseFirestore.instance
            .collection('Events')
            .doc(eventID)
            .update({'Student Name': studentNamesList, 'UserID': idList});
        await FirebaseFirestore.instance
            .collection("Students")
            .doc(currentUser.uid)
            .get()
            .then((student) async {
          eventsList = List.from(student.get('Events'));
        });

        eventsList.remove(eventID);

        await FirebaseFirestore.instance
            .collection("Students")
            .doc(currentUser.uid)
            .update({'Events': eventsList});
        setState(() {
          _isRsvp = false;
        });

        showErrorMessage(
            context, AppLocalizations.of(context).youarenolongergoing);
      } else if (j == idList.length - 1 && idList[j] != currentUser.uid) {
        showErrorMessage(
            context, AppLocalizations.of(context).youhavenotRSVPed);
      }
    }
  }

  Future<void> postMessage(String eventID, chatNameList, chatMessageList,
      chatTimestampList, chatIDList) async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    chatNameList.add(_currentUserName!);
    chatMessageList.add(textController.text);
    chatIDList.add(currentUser.uid);
    chatTimestampList.add(Timestamp.now());

    if (textController.text.isNotEmpty) {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection("Events").doc(eventID);
      docRef.update({
        'chatID': chatIDList,
        'chatName': chatNameList,
        'chatMessage': chatMessageList,
        'chatTimestamp': chatTimestampList
      });
      sendEventChatPushNotification(idList, textController.text,
          _currentUserName!, eventName!, docRef.id, currentUser.uid);
    }
    setState(() {
      getEventDataFromEventID(eventID, context);
    });
  }

  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () async {
      await getUserName();
    });
  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 935;

  Widget build(BuildContext context) {
    if (idList.length == 0) {
      if (widget.eventID2 != 'From Join or My Matches') {
        getEventID(widget.eventID2);
      }
      getEventDataFromEventID(eventID, context);
    } else {
      Future.delayed(Duration(seconds: 145), () {
        getEventDataFromEventID(eventID, context);
      });
    }

    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
          ),
          SizedBox(
            height: 50.0,
            width: 300.0,
            child: ElevatedButton(
              onPressed: () async {
                final currentUser = await FirebaseAuth.instance.currentUser!;
                if (currentUser.uid != 'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                  _isRsvp! ? notGoing() : join();
                } else {
                  showErrorMessage(
                      context,
                      AppLocalizations.of(context)
                          .pleaseregisteranewaccounttocontinue);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isRsvp! ? Colors.blueGrey[100] : Colors.blueGrey[700],
                  shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),

                      borderRadius: BorderRadius.all(
                          Radius.circular(10))) // Background color
                  ),
              child: _isRsvp!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.exit_to_app_outlined,
                            color: Colors.grey[900]),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context).notgoing,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey[900],
                                fontFamily: 'NexaBold')),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.grey[100]),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context).joinevent,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey[100],
                                fontFamily: 'NexaBold')),
                      ],
                    ),
            ),
          ),
        ],
      ),

      appBar: AppBar(
          //  leading: IconButton(
          //       icon: const BackButtonIcon(),
          // onPressed: () {
          //   GoRouter.of(context).go('/');
          // }
          //     ),
          title: Text('$eventName',
              style: TextStyle(
                  // fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'NexaBold')),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 1.0),
                colors: <Color>[
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 50, 50, 50),
                ],
                stops: <double>[0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.blueGrey[300],
          ),
          backgroundColor: Colors.transparent,
          actions: [
            PopupMenuButton(
                iconColor: Colors.grey[100],
                itemBuilder: (context1) => [
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(AppLocalizations.of(context).share),
                          ],
                        ),
                        onTap: () async {
                          final navigator = Navigator.of(context1);
                          await Future.delayed(Duration.zero);
                          await navigator.push(MaterialPageRoute(
                              builder: (_) => Share_Screen(
                                  '/event' + eventID.toString(),
                                  AppLocalizations.of(context)
                                          .joinmeforaDRBAevent +
                                      " $eventName, $_date, $time\n" +
                                      AppLocalizations.of(context).rSVPhere,
                                  eventName, )));
                        },
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(AppLocalizations.of(context).edit),
                          ],
                        ),
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('Events')
                              .doc(eventID)
                              .get()
                              .then((Events) async {
                            final currentUser =
                                await FirebaseAuth.instance.currentUser!;

                            if (List.from(Events.get('UserID')).length == 0) {
                              showErrorMessage(
                                  context,
                                  AppLocalizations.of(context)
                                      .onlytheeventhostcanedittheevent);
                            } else if (currentUser.uid ==
                                List.from(Events.get('UserID'))[0]) {
                              Navigator.of(context1)
                                  .push(MaterialPageRoute(
                                      builder: (context) => const editEvent(),
                                      settings: RouteSettings(
                                        arguments: eventID,
                                      )))
                                  .then((value) async {
                                setState(() {
                                  getEventDataFromEventID(eventID, context);
                                });
                              });
                            } else {
                              // Navigator.of(context).pop();
                              showErrorMessage(
                                  context,
                                  AppLocalizations.of(context)
                                      .onlytheeventhostcanedittheevent);
                            }
                          });
                        },
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(AppLocalizations.of(context).delete),
                          ],
                        ),
                        onTap: () {
                          showDeleteAlertDialog(context, eventID!);
                        },
                      )
                    ])
          ]),

      // AppBars('$eventName'),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 23, right: 23, top: 20, bottom: 20),
          child: Row(
            children: [
              isDesktop(context) ? Expanded(child: Container()) : Container(),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: eventImage!,
                        width: double.infinity,
                        height: 205,
                        fadeInCurve: Curves.easeIn,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.contain),
                          ),
                        ),
                      ),
        
                      const SizedBox(
                        height: 24,
                      ),
                      // Wrap(
                      //     spacing: 5.0,
                      //     runSpacing: 5.0,
                      //     alignment: WrapAlignment.center,
                      //     // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      // Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       Builder(builder: (BuildContext context) {
                      //         return IconButton(
                      //             onPressed: () {
                      //               Navigator.of(context).push(MaterialPageRoute(
                      //                   builder: (context) => Share_Screen(
                      //                       'event' + eventID.toString(),
                      //                       AppLocalizations.of(context)
                      //                               .joinmeforaDRBAevent +
                      //                           " $eventName, $_date, $time\n" +
                      //                           AppLocalizations.of(context).rSVPhere,
                      //                       eventName)));
                      //             },
                      //             icon: Icon(
                      //               Icons.share_outlined,
                      //               color: Colors.red,
                      //             ));
                      //       }),
                      //       Expanded(
                      //         child: SelectableText(
                      //             AppLocalizations.of(context).join + ' $eventName',
                      //             style: TextStyle(
                      //                 fontSize: 35,
                      //                 fontWeight: FontWeight.bold,
                      //                 color: Colors.black,
                      //                 fontFamily: 'NexaBold')),
                      //       ),
                      //     ]),
        
                      //  ]),
                      SelectableText('$eventName',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'NexaBold')),
        
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          String webString =
                              'https://calendar.google.com/calendar/u/0/r/eventedit?location=$location&sprop=name:$eventName&sprop=website:e:+https://gather.drba.org/event$eventID&details=$description&text=$eventName&dates=$uriStarttime/$uriendtime';
                          await launchUrl(Uri.parse(webString),
                              mode: LaunchMode.externalApplication);
                        },
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 13,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: Icon(
                                size: 30,
                                Icons.access_time_outlined,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                            const SizedBox(
                              width: 13,
                            ),
                            Expanded(
                                child: Text.rich(
                              TextSpan(
                                text: '$_date' + ', $time' + ' -',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: ' $_enddate' + ' $endtime',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: "NexaBold",
                                        fontSize: 20,
                                      )),
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
        
                      const SizedBox(
                        height: 24,
                      ),
                      isOnline
                          ? Row(
                              children: [
                                const SizedBox(
                                  width: 13,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: Icon(
                                    size: 30,
                                    Icons.link_outlined,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                                const SizedBox(
                                  width: 13,
                                ),
                                Expanded(
                                  child: SelectableText.rich(
                                    TextSpan(
                                      children: extractText(link!),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "NexaBold",
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                //   await  MapsLauncher.launchQuery('$location');
                                MapsLauncher.launchCoordinates(double.parse(lat!),
                                    double.parse(lng!), '$location');
                                // final availableMaps =
                                //     await MapLauncher.installedMaps;
                                // await availableMaps.first.showMarker(
                                //   coords: Coords(
                                //       double.parse(lat!), double.parse(lng!)),
                                //   title: '$location',
                                //  );
                              },
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 13,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8.0)),
                                    ),
                                    child: Icon(
                                      size: 30,
                                      Icons.share_location_outlined,
                                      color: Colors.blueGrey[700],
                                    ),
                                  ),
                                  //),
                                  const SizedBox(
                                    width: 13,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$location',
                                      style: TextStyle(
                                        color: Colors.blueGrey[700],
                                        fontFamily: "NexaBold",
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(
                        height: 24,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (kIsWeb) {
                            GoRouter.of(context).go('/group${groupID}');
                          } else if (defaultTargetPlatform ==
                                  TargetPlatform.iOS ||
                              defaultTargetPlatform == TargetPlatform.android) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => GroupInfoPage(
                                  groupID: groupID,
                                  currentUserName: widget.currentUserName),
                            ));
                          }
                        },
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 13,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: Icon(
                                size: 30,
                                Icons.groups_outlined,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                            const SizedBox(
                              width: 13,
                            ),
                            Expanded(
                              child: Text('$groupName',
                                  style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: "NexaBold",
                                    fontSize: 20,
                                  )),
                            ),
                          ],
                        ),
                      ),
        
                      const SizedBox(
                        height: 24,
                      ),
        
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => rsvpList(
                                  studentNamesList,
                                  eventName!,
                                  _currentUserName,
                                  idList,
                                  adminList)));
                        },
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 13,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: Icon(
                                size: 30,
                                Icons.rsvp_outlined,
                                color: Colors.blueGrey[700],
                              ),
                            ),
                            const SizedBox(
                              width: 13,
                            ),
                            Text(
                              // text: AppLocalizations
                              //     .of(context)
                              //     .rSVPNames,
                              // style: TextStyle(
                              //   color: Colors.black,
                              //   fontFamily: "NexaBold",
                              //   fontSize: 25,
                              // ),
                              studentNamesList.length.toString() +
                                  AppLocalizations.of(context).going,
                              style: TextStyle(
                                color: Colors.blueGrey[700],
                                fontFamily: "NexaBold",
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        AppLocalizations.of(context).description,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "NexaBold",
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 13,
                          ),
                          Expanded(
                            child:SelectableText.rich(
                              textAlign: TextAlign.left,
                              TextSpan(
                                children: extractText('$description'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NexaBold",
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 13,
                          ),
                          SizedBox(
                            height: 40.0,
                        //    width: 180,
                            child: ElevatedButton(
                              onPressed: ()  async {
        
                                if (_translated.translatedText=='') {
                                  _translated = await _translation.translate(
                                      text: '$description',
                                      to: Localizations.localeOf(context)
                                          .toString());
                                }else{
                                  _translated = await _translation.translate(
                                      text: '',
                                      to: Localizations.localeOf(context)
                                          .toString());
                                }
                                setState(()  {
                                  _translated ;
        
                                });
        
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  shape: const RoundedRectangleBorder(
                                      side:
                                      BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              10))) // Background color
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.translate_outlined,
                                      color: Colors.black87),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(AppLocalizations.of(context)
                                      .translate,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                          fontFamily: 'NexaBold')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
             Row(
                          children: [
                            const SizedBox(
                              width: 13,
                            ),
                            Expanded(
                              child: SelectableText.rich(
                                textAlign: TextAlign.left,
                                TextSpan(
                                  children: extractText(_translated.translatedText),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "NexaBold",
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
        
        
                      const SizedBox(
                        height: 24,
                      ),
                      const Divider(
                        height: 45,
                        thickness: 1,
                        color: Colors.grey,
                      ),
        
                      Text(AppLocalizations.of(context).discussion,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'NexaBold')),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 13,
                            ),
                            Expanded(
                                child: TextFormField(
                              controller: textController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // filled: true,
                                // fillColor: Colors.grey[800],
                                hintText:
                                    AppLocalizations.of(context).addacomment,
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "NexaBold",
                                ),
                                //   // enabledBorder: const OutlineInputBorder(
                                //   //   borderSide: BorderSide(
                                //   //     color: Colors.black,
                                //   //   ),
                                //   // ),
                                //   focusedBorder: const OutlineInputBorder(
                                //       borderSide: BorderSide(
                                //         color: Colors.black,
                                //       )),
                              ),
                              onFieldSubmitted: (value) async {
                                final currentUser =
                                    await FirebaseAuth.instance.currentUser!;
                                if (currentUser.uid !=
                                    'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                                  await postMessage(
                                      eventID!,
                                      chatNameList,
                                      chatMessageList,
                                      chatTimestampList,
                                      chatIDList);
                                  textController.clear();
                                } else {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .pleaseregisteranewaccounttocontinue);
                                }
                              },
                            )),
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: IconButton(
                                  onPressed: () async {
                                    final currentUser =
                                        await FirebaseAuth.instance.currentUser!;
                                    if (currentUser.uid !=
                                        'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                                      await postMessage(
                                          eventID!,
                                          chatNameList,
                                          chatMessageList,
                                          chatTimestampList,
                                          chatIDList);
                                      textController.clear();
                                    } else {
                                      showErrorMessage(
                                          context,
                                          AppLocalizations.of(context)
                                              .pleaseregisteranewaccounttocontinue);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.send_outlined,
                                    size: 40,
                                    color: Colors.blueGrey,
                                  )),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 400,
                        child: ListView.builder(
        
                          reverse: true,
                          // shrinkWrap: true,
                          itemCount: _chatList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: SelectableText.rich(
                                TextSpan(
                                  text: _chatList[index].chatName!,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => profilePage(
                                                receiverID:
                                                    _chatList[index].chatID!))),
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: "NexaBold",
                                    fontSize: 20,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      children: extractText(
                                          ': ' + _chatList[index].chatMessage!),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "NexaBold",
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('MM/dd/yyyy, hh:mm a')
                                      .format(_chatList[index]
                                          .chatTimestamp!
                                          .toDate())
                                      .toString())
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Padding(
                      //     padding: const EdgeInsets.all(25),
                      //child:
                      const SizedBox(
                        height: 15,
                      ),
        
                      //  ),
                    ]),
              ),
              isDesktop(context) ? Expanded(child: Container()) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
