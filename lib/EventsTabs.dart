import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/event_info_past.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Eventsdata {
  String? eventName;
  String? location;
  Timestamp? time;
  String? eventImage;
  int? rsvpNumber;
  String? eventID;
  String? link;
  bool? isOnline;

  Eventsdata(this.eventName, this.location, this.time, this.eventImage,
      this.rsvpNumber, this.eventID, this.link, this.isOnline);

  @override
  String toString() {
    return '{ ${this.eventName},${this.location}, ${this.time} ,${this.eventImage}  ,${this.rsvpNumber},${this.eventID},${this.link},${this.isOnline}}';
  }
}

class Eventstabs extends StatefulWidget {
  String? _currentUserName;

  Eventstabs(this._currentUserName);

  @override
  State<Eventstabs> createState() => _EventstabsState();
}

class _EventstabsState extends State<Eventstabs>
    with SingleTickerProviderStateMixin {
  var events = <Eventsdata>[];
  var myevents = <Eventsdata>[];
  var mypastevents = <Eventsdata>[];

  late final _tabController = TabController(length: 3, vsync: this);
  late Future myPastEventsFuture = GetMyPastEvents();
  late Future myEventsFuture = GetMyEvents();
  late Future eventsFuture = GetEvents();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Eventsdata>> GetMyPastEvents() async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    // mypastevents = [];

    await FirebaseFirestore.instance
        .collection('Students')
        .doc(currentUser.uid)
        .get()
        .then((student) async {
      mypastevents.clear();

      var usereventsList = <String>[];
      usereventsList = await List.from(student.get('Past Events'));
      // print(myevents);

      for (int i = 0; i < usereventsList.length; i++) {
        await FirebaseFirestore.instance
            .collection('Past Events')
            .doc(usereventsList[i])
            .get()
            .then((pastevent) async {
          //   var eventMembersList = List.from(event['Group Members ID']);
          String _location = pastevent.get('Location');

          try {
            _location = _location.substring(
                0, pastevent.get('Location').lastIndexOf('('));
          } catch (e) {}

          mypastevents.add(Eventsdata(
              pastevent['Event Name'],
              _location,
              pastevent['Time'],
              pastevent['imageLink'],
              List.from(pastevent['Student Name']).length,
              pastevent.id,
              pastevent['Link'],
              pastevent['Is online']));
          //     }
        });
      }
    });
    return mypastevents;
  }

  Future<List<Eventsdata>> GetMyEvents() async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    // myevents = [];

    await FirebaseFirestore.instance
        .collection('Students')
        .doc(currentUser.uid)
        .get()
        .then((student) async {
      myevents.clear();


      var usereventsList = <String>[];
      usereventsList = await List.from(student.get('Events'));

      for (int i = 0; i < usereventsList.length; i++) {
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(usereventsList[i])
            .get()
            .then((event) async {
          //   var eventMembersList = List.from(event['Group Members ID']);
          String _location = '';

          try {
            _location =
                _location.substring(0, event.get('Location').lastIndexOf('('));
          } catch (e) {}

          myevents.add(Eventsdata(
              event['Event Name'],
              _location,
              event['Time'],
              event['imageLink'],
              List.from(event['Student Name']).length,
              event.id,
              event['Link'],
              event['Is online']));
          //     }
        });

      }
    });

    return myevents;
  }

  Future<List<Eventsdata>> GetEvents() async {
    await FirebaseFirestore.instance
        .collection('Events')
        .get()
        .then((dharmaEvents) async {
      events.clear();
      if (dharmaEvents.docs.isNotEmpty) {
        for (int i = 0; i < dharmaEvents.docs.length; i++) {
          String _location = dharmaEvents.docs[i].get('Location');
          try {
            _location = _location.substring(
                0, dharmaEvents.docs[i].get('Location').lastIndexOf('('));
          } catch (e) {}
          //print(dharmaEvents.docs[i]['End Time']);
          if (DateTime.now().compareTo(dharmaEvents.docs[i]['End Time'].toDate().add(Duration(hours: 12))) >
              0) {
            DocumentReference pastEvent =
            await FirebaseFirestore.instance.collection("Past Events").add({
              'Location': dharmaEvents.docs[i]['Location'],
              'Link': dharmaEvents.docs[i]['Link'],
              'Event Name': dharmaEvents.docs[i]['Event Name'],
              'Time': dharmaEvents.docs[i]['Time'],
              'End Time': dharmaEvents.docs[i]['End Time'],
              'Is online': dharmaEvents.docs[i]['Is online'],
              'Description': dharmaEvents.docs[i]['Description'],
              //      'dateTime': Timestamp.fromDate(dateTime),
              'Student Name': List.from(dharmaEvents.docs[i]['Student Name']),
              'UserID': List.from(dharmaEvents.docs[i]['UserID']),
              'chatName': List.from(dharmaEvents.docs[i]['chatName']),
              'chatMessage': List.from(dharmaEvents.docs[i]['chatMessage']),
              'chatTimestamp': List.from(dharmaEvents.docs[i]['chatTimestamp']),
              'chatID': List.from(dharmaEvents.docs[i]['chatID']),
              'Group ID': dharmaEvents.docs[i]['Group ID'],
              'imageLink': dharmaEvents.docs[i]['imageLink'],
            });

            var userIDList = <String>[];
            userIDList = await List.from(dharmaEvents.docs[i]['UserID']);

            for (int j = 0; j < userIDList.length; j++) {
              var eventsList = <String>[];
              var pastEventsList = <String>[];

              await FirebaseFirestore.instance
                  .collection("Students")
                  .doc(userIDList[j])
                  .get()
                  .then((User) async {
                eventsList = List.from(User.get('Events'));
                eventsList.remove(dharmaEvents.docs[i].id);
                pastEventsList = List.from(User.get('Past Events'));
                pastEventsList.add(pastEvent.id);

                await FirebaseFirestore.instance
                    .collection("Students")
                    .doc(userIDList[j])
                    .update(
                    {'Events': eventsList, 'Past Events': pastEventsList});
              });
            }

            String groupID = dharmaEvents.docs[i]['Group ID'];

            var groupEventsList = <String>[];
            var pastGroupEventsList = <String>[];

            await FirebaseFirestore.instance
                .collection("Groups")
                .doc(groupID)
                .get()
                .then((User) async {
              groupEventsList = List.from(User.get('Group Events'));
              pastGroupEventsList = List.from(User.get('Past Group Events'));
            });
            groupEventsList.remove(dharmaEvents.docs[i].id);
            pastGroupEventsList.add(pastEvent.id);

            await FirebaseFirestore.instance
                .collection("Groups")
                .doc(groupID)
                .update({
              'Group Events': groupEventsList,
              'Past Group Events': pastGroupEventsList
            });
            await FirebaseFirestore.instance
                .collection('Events')
                .doc(dharmaEvents.docs[i].id)
                .delete();

          }

            events.add(Eventsdata(
                dharmaEvents.docs[i]['Event Name'],
                _location,
                dharmaEvents.docs[i]['Time'],
                dharmaEvents.docs[i]['imageLink'],
                List
                    .from(dharmaEvents.docs[i]['Student Name'])
                    .length,
                dharmaEvents.docs[i].id,
                dharmaEvents.docs[i]['Link'],
                dharmaEvents.docs[i]['Is online']));

        }
      }
    });
       // print(events);
    return events;
  }

  Widget MyEvents() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: myEventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      myevents.sort((a, b) => a.time!.compareTo(b.time!));
                      return myevents.length==0?
                      Row(
                        children: [
                          isDesktop(context)
                              ? Expanded(child: Container())
                              : Container(),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Image(
                                    color: Colors.grey,
                                    image: AssetImage("assets/mountain_gate_2k.png"),
                                    // height: 140.0,
                                  
                                    //fit: BoxFit.contain
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
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
                            ),
                          ),
                          isDesktop(context)
                              ? Expanded(child: Container())
                              : Container(),
                        ],
                      )
                          :ListView.builder(
                        addAutomaticKeepAlives: true,

                        //    shrinkWrap:true,
                        itemCount: myevents.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    //  padding: EdgeInsets.all(24),
                                    decoration: DateTime.now().compareTo(    myevents[index]
                                                    .time!.toDate().add( Duration(hours: 12))) <=
                                            0
                                        ? BoxDecoration(
                                            color: Colors.grey[100],
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(12))
                                        : BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                    child: ListTile(
                                      onTap: () async {
                                        //
                                        // if (kIsWeb) {
                                        //   GoRouter.of(context).go('/event${myevents[index].eventID!}');
                                        //   //     .then((value) {
                                        //   //   setState(() {
                                        //   //     //   myevents.clear();
                                        //   //   });
                                        //   // });
                                        //
                                        // }
                                        // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                                        await Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => eventInfo(
                                            myevents[index].eventID!,
                                            widget._currentUserName!,
                                          ),
                                        ))
                                            .then((value) {
                                          setState(() {
                                            myEventsFuture = GetMyEvents();
                                          });
                                        });

                                        // }
                                      },
                                      leading: Transform.translate(
                                        offset: Offset(0, -8),

                                        child: CachedNetworkImage(
                                          imageUrl: myevents[index].eventImage!,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain),
                                            ),
                                          ),
                                          width: 90,
                                          fadeInCurve: Curves.easeIn,
                                        ),

                                        // Container(
                                        //   width: 90,
                                        //   height: 90.0,
                                        //   // padding: EdgeInsets.all(9),
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.all(
                                        //         Radius.circular(8.0)),
                                        //     image: DecorationImage(
                                        //       image: NetworkImage(
                                        //         myevents[index].eventImage!,
                                        //       ),
                                        //       fit: BoxFit.cover,
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat(
                                                    'EEE, MM/dd/yyyy hh:mm aa')
                                                .format(myevents[index]
                                                    .time!
                                                    .toDate())
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "NexaBold",
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            myevents[index].eventName!,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "NexaBold",
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              myevents[index].isOnline!
                                                  ? 'Online'
                                                  : myevents[index].location!,
                                              style: myevents[index].isOnline!
                                                  ? TextStyle(
                                                      color: Colors.deepOrange,
                                                      fontFamily: "NexaBold",
                                                      fontSize: 12,
                                                    )
                                                  : TextStyle(
                                                      color: Colors.lightBlue,
                                                      fontFamily: "NexaBold",
                                                      fontSize: 12,
                                                    )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                            ],
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget dharmaEvents() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: eventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      events.sort((a, b) => a.time!.compareTo(b.time!));
                      return events.length==0?
                      Row(
                        children: [
                          isDesktop(context)
                              ? Expanded(child: Container())
                              : Container(),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Flexible(
                                  child: Image(
                                    color: Colors.grey,
                                    image: AssetImage("assets/mountain_gate_2k.png"),
                                    // height: 140.0,
                                  
                                    //fit: BoxFit.contain
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
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
                            ),
                          ),
                          isDesktop(context)
                              ? Expanded(child: Container())
                              : Container(),
                        ],
                      )
                          :ListView.builder(
                        addAutomaticKeepAlives: true,

                        //    shrinkWrap:true,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    //  padding: EdgeInsets.all(24),
                                    decoration: DateTime.now().compareTo(
                                                events[index]
                                                    .time!
                                                    .toDate()
                                                    .add(
                                                        Duration(hours: 12))) <=
                                            0
                                        ? BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(12))
                                        : BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                    child: ListTile(
                                      onTap: () async {
                                        // if (kIsWeb) {
                                        //   GoRouter.of(context).go('/event${events[index].eventID!}');
                                        //   //     .then((value) {
                                        //   //   setState(() {
                                        //   //     //   myevents.clear();
                                        //   //   });
                                        //   // });
                                        //
                                        // }
                                        // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                                        await Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => eventInfo(
                                            events[index].eventID!,
                                            widget._currentUserName!,
                                          ),
                                        ))
                                            .then((value) {
                                          setState(() {
                                            eventsFuture = GetEvents();
                                          });
                                        });
                                        //  }
                                      },
                                      leading: Transform.translate(
                                        offset: Offset(0, -8),
                                        child: CachedNetworkImage(
                                            imageUrl: events[index].eventImage!,
                                            imageBuilder: (context,
                                                    imageProvider) =>
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                            fadeInCurve: Curves.easeIn,
                                            width: 90),

                                        // Container(
                                        //   alignment: Alignment.topCenter,
                                        //   width: 90,
                                        // //  height: 90.0,
                                        //   // padding: EdgeInsets.all(9),
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.all(
                                        //         Radius.circular(8.0)),
                                        //     image: DecorationImage(
                                        //       image: NetworkImage(
                                        //         events[index].eventImage!,
                                        //       ),
                                        //       fit: BoxFit.cover,
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat(
                                                    'EEE, MM/dd/yyyy hh:mm aa')
                                                .format(events[index]
                                                    .time!
                                                    .toDate())
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "NexaBold",
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            events[index].eventName!,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "NexaBold",
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            events[index].isOnline!
                                                ? 'Online'
                                                : events[index].location!,
                                            style: events[index].isOnline!
                                                ? TextStyle(
                                                    color: Colors.deepOrange,
                                                    fontFamily: "NexaBold",
                                                    fontSize: 12,
                                                  )
                                                : TextStyle(
                                                    color: Colors.lightBlue,
                                                    fontFamily: "NexaBold",
                                                    fontSize: 12,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                            ],
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget MyPastEvents() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: myPastEventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      mypastevents.sort((a, b) => a.time!.compareTo(b.time!));
                      return mypastevents.length==0?
                      Row(
                        children: [
                          isDesktop(context)
                              ? Expanded(child: Container())
                              : Container(),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Flexible(
                                  child: Image(
                                    color: Colors.grey,
                                    image: AssetImage("assets/mountain_gate_2k.png"),
                                    // height: 140.0,
                                  
                                    //fit: BoxFit.contain
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
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
                            ),
                          ),
                          isDesktop(context)
                              ? Expanded(child: Container())
                              : Container(),
                        ],
                      )
                          :ListView.builder(
                        addAutomaticKeepAlives: true,

                        //    shrinkWrap:true,
                        itemCount: mypastevents.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    //  padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.red[100],
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      onTap: () async {
                                        await Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => PasteventInfo(
                                            mypastevents[index].eventID!,
                                            widget._currentUserName!,
                                          ),
                                        ))
                                            .then((value) {
                                          setState(() {
                                            myPastEventsFuture =
                                                GetMyPastEvents();
                                          });
                                        });
                                      },
                                      leading: Transform.translate(
                                        offset: Offset(0, -8),
                                        child: CachedNetworkImage(
                                            imageUrl:
                                                mypastevents[index].eventImage!,
                                            imageBuilder: (context,
                                                    imageProvider) =>
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                            fadeInCurve: Curves.easeIn,
                                            width: 90),
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat(
                                                    'EEE, MM/dd/yyyy hh:mm aa')
                                                .format(mypastevents[index]
                                                    .time!
                                                    .toDate())
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "NexaBold",
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            mypastevents[index].eventName!,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "NexaBold",
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              mypastevents[index].isOnline!
                                                  ? 'Online'
                                                  : mypastevents[index]
                                                      .location!,
                                              style: mypastevents[index]
                                                      .isOnline!
                                                  ? TextStyle(
                                                      color: Colors.deepOrange,
                                                      fontFamily: "NexaBold",
                                                      fontSize: 12,
                                                    )
                                                  : TextStyle(
                                                      color: Colors.lightBlue,
                                                      fontFamily: "NexaBold",
                                                      fontSize: 12,
                                                    )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                            ],
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void initState() {
    super.initState();
    //  _phoneController.text = '+1';
    _tabController.animation?.addListener(() {

     // if (_tabController.animation!.isCompleted!) {
        setState(() {
        });
      // }else{
      //   setState(() {
      //    // _tabController.index = (_tabController.animation!.value).round();
      //   });
      //
      // }
    });
  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 935;

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          TabBar(
              controller: _tabController,
              splashFactory: NoSplash.splashFactory,
              indicatorColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              dividerColor: Colors.transparent,
              tabs: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _tabController.index == 0
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Tab(
                      child: Center(
                          child: Text(AppLocalizations.of(context).going1,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                  fontFamily: kIsWeb? "NexaBold"
                                      :"OpenSerif"
                                //  color: Colors.black,
                              ))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: _tabController.index == 1
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Tab(
                      child: Center(
                          child:
                              Text(AppLocalizations.of(context).upcomingEvents,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                      fontFamily: kIsWeb? "NexaBold"
                                          :"OpenSerif"
                                  ))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: _tabController.index == 2
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Tab(
                      child: Center(
                          child: Text(AppLocalizations.of(context).pastEvents,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                  fontFamily: kIsWeb? "NexaBold"
                                      :"OpenSerif"
                              ))),
                    ),
                  ),
                ),
              ]),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              MyEvents(),
              dharmaEvents(),
              MyPastEvents(),
            ]),
          ),
        ],
      ),
    );
  }
}
