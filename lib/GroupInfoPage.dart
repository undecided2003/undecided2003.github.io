import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:drbaapp/volunteer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:intl/intl.dart';
import 'Share_Screen.dart';
import 'add_new_event.dart';
import 'event_info.dart';
import 'event_info_past.dart';
import 'extractTextLinks.dart';
import 'group_chat.dart';
import 'group_edit.dart';
import 'group_members_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

class MyEvents {
  String? eventName;
  String? location;
  Timestamp? time;
  String? eventID;
  double? _distance;
  String? eventImage;
  int? rsvpNumber;
  String? link;
  bool isOnline;

  MyEvents(
      this.eventName,
      this.location,
      this.time,
      this.eventID,
      this._distance,
      this.eventImage,
      this.rsvpNumber,
      this.link,
      this.isOnline);

  @override
  String toString() {
    return '{ ${this.eventName},${this.location},${this.time},${this.eventID},${this._distance} '
        ',${this.eventImage}  ,${this.rsvpNumber},${this.link},${this.isOnline}}';
  }
}

Size _textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), //maxLines: 1,
      textDirection: ui.TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: 350);
  return textPainter.size;
}

class GroupInfoPage extends StatefulWidget {
  final String groupID;
  final String currentUserName;

  // final String groupImage;

  GroupInfoPage({
    super.key,
    required this.groupID,
    required this.currentUserName,
    //required this.groupImage,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage>
    with SingleTickerProviderStateMixin {
  var groupEvents = <MyEvents>[];
  var groupEventsList = <String>[];
  var pastGroupEvents = <MyEvents>[];
  var pastGroupEventsList = <String>[];
  String _groupLink =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/White.PNG?alt=media&token=5b94cca1-2ad2-4339-a611-0d76b88db3df';
  var adminsList = <String>[];
  var membersIDList = <String>[];
  var volunteersIDList = <String>[];

  String currentName = '';
  String groupName = '';
  bool _ispublic = true;
  bool _isMember = false;
  bool _isVolunteer = false;
  String volunteerNeeds = '';

  String groupDescription = '';
  late final _tabController = TabController(length: 2, vsync: this);
  late Future getGroupFuture = getGroupEvents();
  late Future getPastGroupFuture = getPastGroupEvents();
  TranslationModel _translated =
      TranslationModel(translatedText: '', detectedSourceLanguage: '');
  final _translation = Translation(
    apiKey: 'AIzaSyATkm_B3odmcZ12hq-AICsLYY0z_UMczBQ',
  );

  Size descriptiontxtSize = _textSize(
      '',
      TextStyle(
        fontSize: 16,
      ));

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  joinExit(String userID) async {
    //   final currentUser = await FirebaseAuth.instance.currentUser;
    var groupList = <String>[];
    // getGroupInfo(context, widget.groupID, widget.currentUserEmail);

    // await FirebaseFirestore.instance
    //     .collection('Groups')
    //     .doc(widget.groupID)
    //     .get()
    //     .then((Groups) async {
    //   membersIDList = List.from(Groups.get('Group Members ID'));
    //   var nameList = List.from(Groups.get('Group Members Names'));

    await FirebaseFirestore.instance
        .collection("Students")
        .doc(userID)
        .get()
        .then((User) async {
      try {
        groupList = List.from(User.get('Groups'));
      } catch (e) {}
    });

    if (_isMember!) {
      for (int i = 0; i < membersIDList.length; i++) {
        if (membersIDList[i] == userID) {
          //     membersNameList.removeAt(i);
          membersIDList.remove(userID);
          groupList.remove(widget.groupID);
          adminsList.remove(userID);
        }
      }
      _isMember = false;
      showErrorMessage(
          context, AppLocalizations.of(context).youleftthe + groupName + '!');
    } else {
      if (membersIDList.contains(userID)) {
      } else {
        //      membersNameList.add(currentName);
        membersIDList.add(userID);
        //    print(IdList);
        _isMember = true;
        groupList.add(widget.groupID);
        showErrorMessage(context,
            AppLocalizations.of(context).youjoinedthe + groupName + '!');
      }
    }

    setState(() {});
    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupID)
        .update({
      'Group Members ID': membersIDList,
      'Admins': adminsList,
      //    'Group Members Names': membersNameList,
    });
    await FirebaseFirestore.instance
        .collection("Students")
        .doc(userID)
        .update({'Groups': groupList});

    // if (_isMember!) {
    //   sendGroupRSVPPushNotification(IdList, _currentUserName, widget.groupName,
    //       widget.groupID, widget.currentUserEmail, currentUser.uid);
    // }
    //   });
  }

  getGroupInfo(
    context,
    String _groupID,
  ) async {
    currentName = widget.currentUserName;
    // groupEvents.clear();
    // pastGroupEvents.clear();
    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(_groupID)
        .get()
        .then((Groups) async {
      if (Groups.exists) {
        final currentUser = await FirebaseAuth.instance.currentUser!;

        if (currentName == 'from welcome') {
          await FirebaseFirestore.instance
              .collection('Students')
              .doc(currentUser.uid)
              .get()
              .then((Users) async {
            try {
              currentName = Users.get('Name');
            } catch (e) {
              if (await FirebaseAuth.instance.currentUser!.displayName !=
                  null) {
                currentName =
                    await FirebaseAuth.instance.currentUser!.displayName!;
              }
              Future.delayed(Duration(seconds: 1), () async {});
              currentName = await Users.get('Name');
            }
          });
        } else if (currentName.contains('Anonymous') || currentName == '') {
          await FirebaseFirestore.instance
              .collection('Students')
              .doc(currentUser.uid)
              .get()
              .then((Users) async {
            if (Users.exists) {
              try {
                currentName = Users.get('Name');
              } catch (e) {
                if (FirebaseAuth.instance.currentUser!.displayName != null) {
                  currentName = FirebaseAuth.instance.currentUser!.displayName!;
                }
              }
            }
          });
        }
        setState(() {
          adminsList = List.from(Groups.get('Admins'));
          membersIDList = List.from(Groups.get('Group Members ID'));
          volunteersIDList = List.from(Groups.get('Volunteers'));
          _groupLink = Groups.get('groupimageLink');
          groupName = Groups.get('Group Name');
          groupDescription = Groups.get('Description');
          volunteerNeeds = Groups.get('Volunteer Needs');
          descriptiontxtSize = _textSize(
            groupDescription,
            TextStyle(
             // color: Colors.black,
              fontFamily: "NexaBold",
              fontSize: 16,
            ),
          );
          print(descriptiontxtSize.height);
          groupEventsList = List.from(Groups.get('Group Events'));
          pastGroupEventsList = List.from(Groups.get('Past Group Events'));
          //    membersNameList = List.from(Groups.get('Group Members Names'));
          if (membersIDList.contains(currentUser.uid)) {
            _isMember = true;
          }else{
            _isMember = false;
          }

          if (volunteersIDList.contains(currentUser.uid)) {
            _isVolunteer = true;
          }else{
            _isVolunteer=false;
          }
          //print(_isVolunteer);
          if (Groups.get('Public')) {
            _ispublic = true;
          } else {
            _ispublic = false;
          }

          _ispublic;
          _isMember;
          _isVolunteer;
        });
      } else {
        Navigator.of(context).pop();
        showErrorMessage(
            context, AppLocalizations.of(context).groupnolongerexist);
      }
    });
  }

  Future<List<MyEvents>> getGroupEvents() async {
    // groupEvents = [];
    await getGroupInfo(context, widget.groupID);
    //  print(groupEventsList);

    for (int j = 0; j < groupEventsList.length; j++) {
      await FirebaseFirestore.instance
          .collection("Events")
          .doc(groupEventsList[j])
          .get()
          .then((event) async {
        groupEvents.clear();
        // if (DateTime.now()
        //         .compareTo(event.get('Date').toDate().add(Duration(days: 1))) <=
        //     0) {
        String _location = event.get('Location');

        try {
          _location =
              _location.substring(0, event.get('Location').lastIndexOf('('));
        } catch (e) {}
        groupEvents.add(MyEvents(
            event.get('Event Name'),
            _location,
            event.get('Time'),
            groupEventsList[j],
            99.9,
            event.get('imageLink'),
            List.from(event.get('Student Name')).length,
            event.get('Link'),
            event.get('Is online')));
        //   }
      });
    }
    // print(groupEvents);
    return groupEvents;
  }

  Future<List<MyEvents>> getPastGroupEvents() async {
    // pastGroupEvents = [];
    // print(pastGroupEventsList);
    await getGroupInfo(context, widget.groupID);

    for (int j = 0; j < pastGroupEventsList.length; j++) {
      await FirebaseFirestore.instance
          .collection("Past Events")
          .doc(pastGroupEventsList[j])
          .get()
          .then((_event) async {
        pastGroupEvents.clear();
        // if (DateTime.now()
        //         .compareTo(event.get('Date').toDate().add(Duration(days: 1))) <=
        //     0) {
        String _location = _event.get('Location');
        try {
          _location =
              _location.substring(0, _event.get('Location').lastIndexOf('('));
        } catch (e) {}
        pastGroupEvents.add(MyEvents(
            _event.get('Event Name'),
            _location,
            _event.get('Time'),
            pastGroupEventsList[j],
            99.9,
            _event.get('imageLink'),
            List.from(_event.get('Student Name')).length,
            _event.get('Link'),
            _event.get('Is online')));
        //   }
      });
    }
    return pastGroupEvents;
  }

  initState() {
    super.initState();
    // getGroupFuture = getGroupEvents();
    //   getGroupInfo(context, widget.groupID);
    // });
    _tabController.animation?.addListener(() {
      // if (_tabController.animation!.isCompleted!) {
      //   setState(() {
      //     getGroupFuture = getGroupEvents();
      //     getPastGroupFuture = getPastGroupEvents();
      //   });
      // }else{
      setState(() {
        // _tabController.index = (_tabController.animation!.value).round();
      });
      //   }
    });
  }

  showDeleteAlertDialog(BuildContext context) async {
    Widget cancelButton = ElevatedButton(
      child: Text(
        AppLocalizations.of(context).cancel,
      ),
      style: ElevatedButton.styleFrom(
//foregroundColor: Colors.grey,
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
        if (_groupLink !=
            'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/groups%2Fgroup.png?alt=media&token=f4b7d47b-df22-4cba-ab4c-e21a282d7b7a&_gl=1*1635uxj*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5NzIyMjU3OS41MDcuMS4xNjk3MjI0NTE5LjQ4LjAuMA..') {
          FirebaseStorage.instance.refFromURL(_groupLink).delete();
        }
        var snapshots = await FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.groupID)
            .collection('group messages')
            .get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }

        var groupsList = <String>[];
        var studentEventsList = <String>[];
        var studentPastEventsList = <String>[];

        for (int j = 0; j < membersIDList.length; j++) {
          await FirebaseFirestore.instance
              .collection("Students")
              .doc(membersIDList[j])
              .get()
              .then((User) async {
            groupsList = List.from(User.get('Groups'));
            studentEventsList = List.from(User.get('Events'));
            studentPastEventsList = List.from(User.get('Past Events'));
          });

          for (int j = 0; j < groupEventsList.length; j++) {
            studentEventsList.remove(groupEventsList[j]);
            FirebaseFirestore.instance
                .collection('Events')
                .doc(groupEventsList[j])
                .delete();
          }

          for (int j = 0; j < pastGroupEventsList.length; j++) {
            studentPastEventsList.remove(pastGroupEventsList[j]);

            FirebaseFirestore.instance
                .collection('Past Events')
                .doc(pastGroupEventsList[j])
                .delete();
          }

          groupsList.remove(widget.groupID);
          await FirebaseFirestore.instance
              .collection("Students")
              .doc(membersIDList[j])
              .update({
            'Groups': groupsList,
            'Events': studentEventsList,
            'Past Events': studentPastEventsList
          });
        }

        FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.groupID)
            .delete();
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) => Welcome(),
        // ));
      },
    ); // set up the AlertDialog

    AlertDialog alert = AlertDialog(
      // title: Text(""),
      title: Text(AppLocalizations.of(context).doyouwanttodeletethegroup),
      titleTextStyle: Theme.of(context).textTheme.bodyLarge,
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


  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1025;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

            title: Text(groupName,
                style: TextStyle(
                    // fontSize: 10,
                    fontWeight: FontWeight.w600,
                  //  color: Colors.black,
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
                color: Colors.black
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
                                    '/group' + widget.groupID.toString(),
                                    AppLocalizations.of(context)
                                            .youareinvitedtojoinmyDRBAgroup +
                                        groupName,
                                    groupName)));
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
                            final currentUser =
                                await FirebaseAuth.instance.currentUser!;
                            if (membersIDList.length == 0) {
                              showErrorMessage(
                                  context,
                                  AppLocalizations.of(context)
                                      .onlyagroupadmincaneditgroup);
                            } else if (currentUser.uid == membersIDList[0] ||
                                adminsList.contains(currentUser.uid)) {
                              Navigator.of(context1)
                                  .push(MaterialPageRoute(
                                      builder: (context) => EditGroup(
                                          currentName,
                                          currentUser.uid,
                                          widget.groupID)))
                                  .then((value) {
                                setState(() {
                                  groupEvents.clear();
                                  pastGroupEvents.clear();
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((_) {
                                    getGroupInfo(context, widget.groupID);
                                  });
                                });
                              });
                            } else {
                              showErrorMessage(
                                  context,
                                  AppLocalizations.of(context)
                                      .onlyagroupadmincaneditgroup);
                            }
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
                          onTap: () async {
                            final currentUser =
                                await FirebaseAuth.instance.currentUser!;
                            if (membersIDList.length == 0) {
                              showErrorMessage(
                                  context,
                                  AppLocalizations.of(context)
                                      .onlyagroupadmincandeletegroup);
                            } else if (currentUser.uid == membersIDList[0] ||
                                adminsList.contains(currentUser.uid)) {
                              showDeleteAlertDialog(context);
                            } else {
                              showErrorMessage(
                                  context,
                                  AppLocalizations.of(context)
                                      .onlyagroupadmincandeletegroup);
                            }
                          },
                        )
                      ])
            ]),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
            ),
            SizedBox(
              height: 50.0,
              width: 300.0,
              child: ElevatedButton(
                onPressed: () async {
                  final currentUser = await FirebaseAuth.instance.currentUser;

                  if (currentUser!.uid != 'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                    joinExit(currentUser!.uid!);
                  } else {
                    showErrorMessage(
                        context,
                        AppLocalizations.of(context)
                            .pleaseregisteranewaccounttocontinue);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: _isMember!
                        ? Colors.blueGrey[100]
                        : Colors.blueGrey[700],
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10))) // Background color
                    ),
                child: _isMember!
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_remove_outlined,
                              color: Colors.grey[900]),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(AppLocalizations.of(context).leaveGroup,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.grey[900],
                                  fontFamily: 'NexaBold')),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_add_outlined,
                              color: Colors.grey[100]),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(AppLocalizations.of(context).joinGroup,
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
        body: SafeArea(
          child: SingleChildScrollView(
              padding:
                  EdgeInsets.only(left: 23, right: 23, top: 20, bottom: 20),
              child: Row(
                children: [
                  isDesktop(context)
                      ? Expanded(child: Container())
                      : Container(),
                  Expanded(
                    child: Container(
                      //  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      height: 1100 + 2 * descriptiontxtSize!.height,
                      // width: double.infinity,

                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: _groupLink,
                              //width: double.infinity,
                              height: 205.0,
                              fadeInCurve: Curves.easeIn,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context).description,
                                  style: TextStyle(
                                  //  color: Colors.black,
                                    fontFamily: "NexaBold",
                                    fontSize: 20,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShowmembersList(
                                                    widget.groupID,
                                                    currentName,
                                                    groupName,
                                                    adminsList)));
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.groups_outlined,
                                        //size: 40,
                                        color: Colors.deepOrange,
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        membersIDList.length.toString() +
                                            AppLocalizations.of(context)
                                                .members,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontFamily: "NexaBold",
                                          fontSize: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                             Divider(
                              height: 30,
                              thickness: 1,
                              color: Colors.grey[400],
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
                                      children:
                                          extractText('$groupDescription'),
                                      style: TextStyle(
                                    //    color: Colors.black,
                                        fontFamily: "NexaBold",
                                        fontSize: 16,
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
                                //  height: 40.0,
                                  // width: 180,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_translated.translatedText == '') {
                                        _translated =
                                            await _translation.translate(
                                                text: '$groupDescription',
                                                to: Localizations.localeOf(
                                                        context)
                                                    .toString());
                                      } else {
                                        _translated =
                                            await _translation.translate(
                                                text: '',
                                                to: Localizations.localeOf(
                                                        context)
                                                    .toString());
                                      }

                                      setState(() {
                                        _translated;
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
                                          width: 5,
                                        ),
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black87,
                                                fontFamily: 'NexaBold')),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                SizedBox(
                                 // height: 40.0,
                                  // width: 180,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_isMember) {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => groupChat(
                                            groupID: widget.groupID,
                                            currentUserName: currentName,
                                            groupName: groupName,
                                          ),
                                        ));
                                      } else {
                                        showErrorMessage(
                                            context,
                                            AppLocalizations.of(context)
                                                .onlygroupmemberscanmessageingroup);
                                      }

                                      //  Navigator.pop(context);
                                      //    Navigator.pop(context);
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
                                        Icon(Icons.message,
                                            color: Colors.black87),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            ' ' +
                                                AppLocalizations.of(context)
                                                    .groupMessages,
                                            style: TextStyle(
                                                fontSize: 10,
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
                                SizedBox(
                                  //  height: 40.0,
                                  // width: 180,
                                  child: ElevatedButton(
                                    onPressed: () async {

                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    volunteerList(
                                                        widget.groupID,
                                                        currentName,
                                                        groupName,
                                                        adminsList,_isMember,_isVolunteer,volunteerNeeds))).then((value) {
                                          setState(() {
                                            groupEvents.clear();
                                            pastGroupEvents.clear();
                                            SchedulerBinding.instance
                                                .addPostFrameCallback((_) {
                                              getGroupInfo(context, widget.groupID);
                                            });
                                          });
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
                                        Icon(Icons.volunteer_activism_outlined,
                                            color: Colors.black87),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            AppLocalizations.of(context).volunteer,
                                            style: TextStyle(
                                                fontSize: 10,
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
                                      children: extractText(
                                          _translated.translatedText),
                                      style: TextStyle(
                                        fontFamily: "NexaBold",
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Text(AppLocalizations.of(context).events,
                                style: TextStyle(
                              //    color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: "NexaBold",
                                )),
                             Divider(
                              height: 30,
                              thickness: 1,
                              color: Colors.grey[400],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 200,
                                  height: 40,
                                  child: TabBar(
                                      controller: _tabController,
                                      splashFactory: NoSplash.splashFactory,
                                      indicatorColor: Colors.transparent,
                                      labelColor: Colors.black,
                                    //  unselectedLabelColor: Colors.grey[600],
                                      dividerColor: Colors.transparent,
                                      tabs: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _tabController.index == 0
                                                ? Colors.grey[300]
                                                :Colors.transparent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12.0)),
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: Tab(
                                            child: Center(
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .upcomingEvents,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      //  color: Colors.black,
                                                        fontFamily: kIsWeb
                                                            ? "NexaBold"
                                                            : "OpenSerif"))),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _tabController.index == 1
                                                ? Colors.grey[300]
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: Tab(
                                            child: Center(
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .pastEvents,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                     //   color: Colors.black,
                                                        fontFamily: kIsWeb
                                                            ? "NexaBold"
                                                            : "OpenSerif"))),
                                          ),
                                        ),
                                      ]),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final currentUser = await FirebaseAuth
                                        .instance.currentUser!;
                                    if (membersIDList.length == 0) {
                                      showErrorMessage(
                                          context,
                                          AppLocalizations.of(context)
                                              .onlyagroupadmincancreateanevent);
                                    } else if (currentUser.uid ==
                                            membersIDList[0] ||
                                        adminsList.contains(currentUser.uid)) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  newEvent(widget.groupID)))
                                          .then((value) {
                                        setState(() {
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) {
                                            getGroupFuture = getGroupEvents();
                                          });
                                          // await getGroupInfo(context, widget.groupID);
                                          // groupEvents.clear();
                                          // pastGroupEvents.clear();
                                          // Future.delayed(Duration(seconds: 0), () async {
                                          // });
                                        });
                                      });
                                    } else {
                                      showErrorMessage(
                                          context,
                                          AppLocalizations.of(context)
                                              .onlyagroupadmincancreateanevent);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                   minimumSize: Size.square(40),
                                      backgroundColor: Colors.grey[100],
                                      shape: const RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))
                                      // Background color
                                      ),
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    GroupEvents(),
                                    PastGroupEvents(),
                                  ]),
                            ),
                          ]),
                    ),
                  ),
                  isDesktop(context)
                      ? Expanded(child: Container())
                      : Container(),
                ],
              )),
        ));
  }

  Widget GroupEvents() {
    return Container(
      //height: 270,
      // decoration: BoxDecoration(
      // //  color: Colors.white,
      // ),
      child: FutureBuilder(
          future: getGroupFuture,
          builder: (context, snapshot) {
            if ( //snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              groupEvents.sort((a, b) => a.time!.compareTo(b.time!));
              return groupEvents.length == 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Image(
                            color: Colors.grey,
                            image: AssetImage("assets/mountain_gate_2k.png"),
                            // height: 140.0,
                            //width: 140,
                            //fit: BoxFit.contain
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context).nothingtoseehere,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "NexaBold",
                            fontSize: 20,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      //    shrinkWrap:true,
                      itemCount: groupEvents.length,
                      itemBuilder: (context, index) {
                        return  Padding(
                            padding: const EdgeInsets.only(bottom: 4,left: 1,right: 1),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Container(
                                decoration: DateTime.now().compareTo(
                                            groupEvents[index]
                                                .time!
                                                .toDate()
                                                .add(Duration(hours: 12))) <=
                                        0
                                    ? BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(11))
                                    : BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(11)),
                                child: GestureDetector(
                                  onTap: () {
                                    // if (kIsWeb) {
                                    //   GoRouter.of(context).go('/event${groupEvents[index].eventID!}');
                                    // }
                                    // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => eventInfo(
                                        groupEvents[index].eventID!,
                                        currentName,
                                      ),
                                    ))
                                        .then((value) {
                                      setState(() {
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) {
                                          getGroupFuture = getGroupEvents();
                                        });
                                      });
                                    });
                                    //   }
                                  },
                                  child: Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: groupEvents[index].eventImage!,
                                        height: 195.0,
                                        fadeInCurve: Curves.easeIn,
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.contain),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        dense: true,
                                        // visualDensity: VisualDensity(horizontal: -2),
                                        contentPadding:
                                            EdgeInsets.only(left: 6, right: 6),

                                        onTap: () {
                                          // if (kIsWeb) {
                                          //   GoRouter.of(context).go('/event${groupEvents[index].eventID!}');
                                          // }
                                          // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => eventInfo(
                                              groupEvents[index].eventID!,
                                              currentName,
                                            ),
                                          ))
                                              .then((value) {
                                            setState(() {
                                              SchedulerBinding.instance
                                                  .addPostFrameCallback((_) {
                                                getGroupFuture = getGroupEvents();
                                              });
                                            });
                                          });
                                          //   }
                                        },
                                        // leading:
                                        title: Text(
                                          groupEvents[index].eventName!,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "NexaBold",
                                            fontSize: 17,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  size: 20,
                                                  Icons.access_time_outlined,
                                                  color: Colors.blueGrey[700],
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    text: DateFormat(
                                                            'MM/dd/yyyy, EEE hh:mm aa')
                                                        .format(groupEvents[index]
                                                            .time!
                                                            .toDate())
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontFamily: "NexaBold",
                                                      color: Colors.grey[800],
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: ' (' +
                                                              groupEvents[index]
                                                                  .rsvpNumber
                                                                  .toString() +
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .going +
                                                              ')',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontFamily:
                                                                "NexaBold",
                                                            fontSize: 14,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            groupEvents[index].isOnline
                                                ? Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      '(online)',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontFamily: "NexaBold",
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                        );
                      },
                    );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget PastGroupEvents() {
    return Container(
      //height: 270,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      // ),

      child: FutureBuilder(
          future: getPastGroupFuture,
          builder: (context, snapshot) {
            if ( //snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              pastGroupEvents.sort((a, b) => b.time!.compareTo(a.time!));

              return pastGroupEvents.length == 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Image(
                            color: Colors.grey,
                            image: AssetImage("assets/mountain_gate_2k.png"),
                            // height: 140.0,
                            //width: 140,
                            //fit: BoxFit.contain
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context).nothingtoseehere,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "NexaBold",
                            fontSize: 20,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      //    shrinkWrap:true,
                      itemCount: pastGroupEvents.length,
                      itemBuilder: (context, index) {
                        return  Padding(
                            padding: const EdgeInsets.only(bottom: 4,left: 1,right: 1),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(11)),
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => PasteventInfo(
                                        pastGroupEvents[index].eventID!,
                                        currentName,
                                      ),
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            pastGroupEvents[index].eventImage!,
                                        height: 195.0,
                                        fadeInCurve: Curves.easeIn,
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.contain),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        dense: true,
                                        // visualDensity: VisualDensity(horizontal: -2),
                                        contentPadding:
                                            EdgeInsets.only(left: 6, right: 6),
                                        onTap: () async {
                                          await Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => PasteventInfo(
                                              pastGroupEvents[index].eventID!,
                                              currentName,
                                            ),
                                          ));
                                        },
                          
                                        title: Text(
                                          pastGroupEvents[index].eventName!,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "NexaBold",
                                            fontSize: 17,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    size: 20,
                                                    Icons.access_time_outlined,
                                                    color: Colors.blueGrey[700],
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: DateFormat(
                                                              'MM/dd/yyyy, EEE hh:mm aa')
                                                          .format(pastGroupEvents[
                                                                  index]
                                                              .time!
                                                              .toDate())
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontFamily: "NexaBold",
                                                        color: Colors.grey[800],
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: ' (' +
                                                                pastGroupEvents[
                                                                        index]
                                                                    .rsvpNumber
                                                                    .toString() +
                                                                AppLocalizations.of(
                                                                        context)
                                                                    .going +
                                                                ')',
                                                            style: TextStyle(
                                                              color: Colors.blue,
                                                              fontFamily:
                                                                  "NexaBold",
                                                              fontSize: 14,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              pastGroupEvents[index].isOnline
                                                  ? Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        '(online)',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontFamily: "NexaBold",
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                        );
                      },
                    );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
