import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/profilePage.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'GroupInfoPage.dart';
import 'RSVP_List.dart';
import 'AppBar.dart';
import 'package:intl/intl.dart';
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

class PasteventInfo extends StatefulWidget {
  final String eventID2;
  final String currentUserName;

  PasteventInfo(this.eventID2, this.currentUserName);

  @override
  State<PasteventInfo> createState() => _PasteventInfoState();
}

class _PasteventInfoState extends State<PasteventInfo> {
  String _currentUserName = '';
  bool _isRsvp = false;
  int? markerid;
  String? _date = '';
  String? _enddate = '';
  String eventID = 'From Events Info';
  String? location = '';
  String? latlng = '';
  String? lat = '';
  String? lng = '';
  String? eventName = '';
  String? description = '';
  bool isOnline = true;
  String? link = '';
  String groupID = '';
  var studentNamesList = <String>[];
  var idList = <String>[];
  var adminList = <String>[];
  var chatMessageList = <String>[];
  var chatNameList = <String>[];
  var chatTimestampList = <Timestamp>[];
  var chatIDList = <String>[];
  String? time = '';
  String? endtime = '';
  String groupName = '';
  String uriStarttime = '';
  String uriendtime = '';

  var chatList = <ChatList>[];
  var _chatList = <ChatList>[];
  String? eventImage =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/White.PNG?alt=media&token=5b94cca1-2ad2-4339-a611-0d76b88db3df';
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
        .collection('Past Events')
        .doc(EventID)
        .get()
        .then((events) async {
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
        groupName = group.get('Group Name');
        adminList = List.from(group.get('Admins'));
      });
      setState(() {
        isOnline = events.get('Is online');
        eventImage = _eventImage;
        location = _location;
        link = events.get('Link');
        latlng;
        lat;
        lng;
        adminList;
        groupID;
        groupName;
        eventName = events.get('Event Name');
        description = events.get('Description');
        studentNamesList = List.from(events.get('Student Name'));
        idList = List.from(events.get('UserID'));
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
        uriStarttime = DateFormat('yyyyMMddTHHmmssZ')
            .format(events.get('Time').toDate())
            .toString();
        uriendtime = DateFormat('yyyyMMddTHHmmssZ')
            .format(events.get('End Time').toDate())
            .toString();
      });
    });
  }

  Future<void> postMessage(String eventID, chatNameList, chatMessageList,
      chatTimestampList, chatIDList) async {
    final currentUser = await FirebaseAuth.instance.currentUser!;

    String studentName = _currentUserName;
    chatNameList.add(studentName!);
    chatMessageList.add(textController.text);
    chatTimestampList.add(Timestamp.now());
    chatIDList.add(currentUser.uid);

    if (textController.text.isNotEmpty) {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection("Past Events")
          .doc(eventID);
      docRef.update({
        'chatID': chatIDList,
        'chatName': chatNameList,
        'chatMessage': chatMessageList,
        'chatTimestamp': chatTimestampList
      });
      // sendEventChatPushNotification(
      //     emailList, textController.text, studentName!, eventName!, docRef.id, widget.currentUserEmail);
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
      MediaQuery.of(context).size.width >= 1025;

  Widget build(BuildContext context) {
    // print('events page');
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
      appBar: AppBars('$eventName', '', context),
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
                        height: 205.0,
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
                      SelectableText('$eventName',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            //  color: Colors.black,
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
                                color: Colors.blueGrey[600],
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
                                //  color: Colors.grey[800],
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: ' $_enddate' + ' $endtime',
                                      style: TextStyle(
                                        color: Colors.redAccent,
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
                                    color: Colors.blueGrey[600],
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
                                      //  color: Colors.black,
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
                                      color: Colors.blueGrey[600],
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
                                        color: Colors.blueGrey,
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
                                color: Colors.blueGrey[600],
                              ),
                            ),
                            const SizedBox(
                              width: 13,
                            ),
                            Text('$groupName',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                )),
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
                                color: Colors.blueGrey[600],
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
                                color: Colors.blueGrey,
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
                        //  color: Colors.black,
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
                               //   color: Colors.black,
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
                      //      width: 180,
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
                                 // color: Colors.black,
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
                       Divider(
                        height: 45,
                        thickness: 1,
                        color: Colors.grey[400],
                      ),
                      Text(AppLocalizations.of(context).discussion,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            //  color: Colors.black,
                              fontFamily: 'NexaBold')),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],

                          border: Border.all(color: Colors.blueGrey),
                          borderRadius:
                          BorderRadius.all(
                              Radius.circular(
                                  8.0)),

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 13,
                            ),
                            Expanded(
                                child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    textCapitalization: TextCapitalization.sentences,

                                    controller: textController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.grey[100],
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    )),
                                hintText: AppLocalizations.of(context).addacomment,
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "NexaBold",
                                ),
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

                                }
                            )),
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: Container(
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
                              ),
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
                            return

                                //  padding: EdgeInsets.all(24),
                                // decoration: BoxDecoration(
                                //     color: Colors.orangeAccent,
                                //     borderRadius:
                                //         BorderRadius.all(Radius.circular(10))),
                                ListTile(
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
                                    fontSize: 16,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      children: extractText(
                                          ': ' + _chatList[index].chatMessage!),
                                      style: Theme.of(context).textTheme.bodyLarge,

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
