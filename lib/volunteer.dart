import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/profilePage.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:drbaapp/volunteer_interest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'AppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'extractTextLinks.dart';
import 'group_edit.dart';

class VolunteersList {
  String? memberName;
  String? _profileImageLink;
  String? memberID;
  String? interest;

  VolunteersList(
      this.memberName, this._profileImageLink, this.memberID, this.interest);

  @override
  String toString() {
    return '{ ${this.memberName},${this._profileImageLink},${this.memberID},${this.interest}}';
  }
}

class volunteerList extends StatefulWidget {
  final String groupID;
  final String currentUserName;
  final String groupName;
  final bool isMember;
  final bool isVolunteer;
  final String volunteerNeeds;

  var adminsList = <String>[];

  volunteerList(this.groupID, this.currentUserName, this.groupName,
      this.adminsList, this.isMember, this.isVolunteer, this.volunteerNeeds);

  @override
  State<volunteerList> createState() => _volunteerListState();
}

class _volunteerListState extends State<volunteerList> {
  var emailList = <String>[];
  final currentUser = FirebaseAuth.instance.currentUser!;
  var volunteersList = <VolunteersList>[];
  var volunteersIDList = <String>[];
  var interestList = <String>[];
  bool isVolunteerInternal = false;
  String currentUserID = '';
  late Future getMembersList = GetMembersList();
  String volunteerNeeds = '';

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1025;

  volunteerExit(String userID) async {
    if (isVolunteerInternal) {
      for (int i = 0; i < volunteersIDList.length; i++) {
        if (volunteersIDList[i] == userID) {
          interestList.removeAt(i);
          volunteersIDList.remove(userID);
        }
      }

      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(widget.groupID)
          .update({
        'Volunteers': volunteersIDList,
        'Volunteer Interests': interestList,
        //    'Group Members Names': membersNameList,
      });
      setState(() {
         isVolunteerInternal = false;
        getMembersList = GetMembersList();
     //   print(isVolunteerInternal);
      });
      showErrorMessage(
          context,
          AppLocalizations.of(context).youleftthe +
              AppLocalizations.of(context).volunteers +
              '!');
    } else {
      if (volunteersIDList.contains(userID)) {
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => addVolunteer(
                    userID, volunteersIDList, interestList, widget.groupID)))
            .then((value) async {
          setState(() {
            isVolunteerInternal = true;
            getMembersList = GetMembersList();
          });
          //   await FirebaseFirestore.instance
          //       .collection('Groups')
          //       .doc(widget.groupID)
          //       .get()
          //       .then((group) async {
          //     if (List.from(group.get('Volunteers')).contains(currentUser.uid)) {
          //       isVolunteerInternal = true;
          //     }
          //     setState(() {
          //       isVolunteerInternal;
          //       getMembersList =  GetMembersList();
          //     });
          // });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isVolunteerInternal = widget.isVolunteer;
    volunteerNeeds = widget.volunteerNeeds;
  }

  Widget build(BuildContext context) {
    print(isVolunteerInternal);

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBars(
          widget.groupName + AppLocalizations.of(context).volunteerss,
          '',
          context),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
          ),
          SizedBox(
            //   height: 50.0,
            width: 300.0,
            child: ElevatedButton(
              onPressed: () async {
                final currentUser = await FirebaseAuth.instance.currentUser;

                if (currentUser!.uid != 'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                  if (widget.isMember) {
                    volunteerExit(currentUser.uid!);
                  } else {
                    showErrorMessage(
                        context,
                        AppLocalizations.of(context)
                            .onlygroupmemberscanvolunteer);
                  }
                } else {
                  showErrorMessage(
                      context,
                      AppLocalizations.of(context)
                          .pleaseregisteranewaccounttocontinue);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: isVolunteerInternal
                      ? Colors.blueGrey[100]
                      : Colors.blueGrey[700],
                  shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(
                          Radius.circular(10))) // Background color
                  ),
              child: isVolunteerInternal
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.personCircleMinus,
                            color: Colors.grey[900]),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                              AppLocalizations.of(context).leaveVolunteers,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.grey[900],
                                  fontFamily: 'NexaBold')),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.personCirclePlus,
                            color: Colors.grey[100]),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                              AppLocalizations.of(context).joinVolunteers,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.grey[100],
                                  fontFamily: 'NexaBold')),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),

          child: Column(
            children: // <Widget>
                [
              Row(
                children: [
                  isDesktop(context)
                      ? Expanded(child: Container())
                      : Container(),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).volunteerNeeds,
                              style: TextStyle(
                                //  color: Colors.black,
                                fontFamily: "NexaBold",
                                fontSize: 20,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final currentUser =
                                    await FirebaseAuth.instance.currentUser!;

                               if (
                                    widget.adminsList.contains(currentUser.uid)) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (context) => EditGroup(
                                          widget.currentUserName,
                                          currentUser.uid,
                                          widget.groupID)))
                                      .then((value) {
                                    setState(() {
                                      getMembersList = GetMembersList();

                                    });
                                  });
                                } else {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .onlyagroupadmincaneditgroup);
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_outlined,
                                    //size: 40,
                                    //    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    AppLocalizations.of(context).edit,
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
                                  children: extractText(volunteerNeeds),
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
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(AppLocalizations.of(context).volunteerss,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        //  color: Colors.black,
                                        fontFamily: 'NexaBold')),
                              ],
                            ),
                            Row(
                              children: [
                                Text(AppLocalizations.of(context).interests,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        //  color: Colors.black,
                                        fontFamily: 'NexaBold')),
                                const SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                  isDesktop(context)
                      ? Expanded(child: Container())
                      : Container(),
                ],
              ),
              FutureBuilder(
                  future: getMembersList,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      return volunteersList.length==0?
                      Row(
                        children: [
                          isDesktop(context)
                              ? Expanded(child: Container())
                              : Container(),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                    color: Colors.grey,
                                    image: AssetImage("assets/mountain_gate_2k.png"),
                                    // height: 140.0,

                                    //fit: BoxFit.contain
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
                          : ListView.builder(
                        // itemExtent: 225.0,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: volunteersList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => profilePage(
                                                receiverID:
                                                    volunteersList[index]
                                                        .memberID!)));
                                  },
                                  child: Container(
                                    //  padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade400))),
                                    child: ListTile(
                                      // tileColor:  Colors.grey[100],
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.blueGrey,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                volunteersList[index]
                                                    ._profileImageLink!),
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                volunteersList[index]
                                                    .memberName!,
                                                style: TextStyle(
                                                  // color: Colors.black,
                                                  fontFamily: "NexaBold",
                                                  //  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Text(
                                              volunteersList[index].interest!,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                // color: Colors.black,
                                                fontFamily: "NexaBold",
                                                fontSize: 12,
                                              ),
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
            ],
          ),
          //   ),
        )),
      ),
    );
  }

  Future<List<VolunteersList>> GetMembersList() async {
    volunteersList.clear();
    final currentUser = FirebaseAuth.instance.currentUser!;
    currentUserID = currentUser.uid;
    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupID)
        .get()
        .then((group) {
      //    membersNameList = List.from(group.get('Group Members Names'));
      volunteersIDList = List.from(group.get('Volunteers'));
      interestList = List.from(group.get('Volunteer Interests'));
      volunteerNeeds = group.get('Volunteer Needs');
    });
    SchedulerBinding.instance
        .addPostFrameCallback((_) {
    if (volunteersIDList.contains(currentUserID)) {
      isVolunteerInternal = true;
    } else {
      isVolunteerInternal = false;
    }});

    for (int i = 0; i < volunteersIDList.length; i++) {
      volunteersList.add(VolunteersList(
          'Name', 'profileLink', volunteersIDList[i], interestList[i]));
    }

    for (int i = 0; i < volunteersIDList.length; i++) {
      final doc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(volunteersIDList[i])
          .get();
      if (doc.exists) {
        String profileLink = doc.get('imageLink');
        String Name = 'Anonymous';

        try {
          Name = doc.get('Name');
        } catch (e) {}
        volunteersList[i] = VolunteersList(
            Name, profileLink, volunteersIDList[i], interestList[i]);
      }
    }
    return volunteersList;
  }
}
