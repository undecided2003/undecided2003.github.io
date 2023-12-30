import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'GroupInfoPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupsList {
  String? groupName;
  String? groupID;
  int? membercount;
  String? groupImageLink;
  String? lastMessage;
  String? lastSender;
  Timestamp? time;

  GroupsList(this.groupName, this.groupID, this.membercount,
      this.groupImageLink, this.lastMessage, this.lastSender, this.time);

  @override
  String toString() {
    return '{ ${this.groupName},${this.groupID}, ${this.membercount},${this.groupImageLink},${this.lastMessage},${this.lastSender},${this.time}}';
  }
}

final currentUser = FirebaseAuth.instance.currentUser!;

// void rebuildAllChildren(BuildContext context) {
//   void rebuild(Element el) {
//     el.markNeedsBuild();
//     el.visitChildren(rebuild);
//   }
//   (context as Element).visitChildren(rebuild);
// }

class GroupsInfo extends StatefulWidget {
  String? _currentUserName;

  // final Function callback;
  // final VoidCallback onTap;

  GroupsInfo(
    this._currentUserName,
  );

  // void callCallaback() { callback(){}; }

  @override
  State<GroupsInfo> createState() => _GroupsInfoState();
}

class _GroupsInfoState extends State<GroupsInfo>
    with SingleTickerProviderStateMixin {
  var groupsList = <GroupsList>[];
  var mygroupsList = <GroupsList>[];
  late Future myGroupFuture=GetMyGroups();
  late Future groupFuture=GetGroups();

  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget Mygroups() {
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
                  future: myGroupFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      mygroupsList
                          .sort((a, b) => a.groupName!.compareTo(b.groupName!));

                      return    mygroupsList.length==0?
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
                            :
                            ListView.builder(
                        //    shrinkWrap:true,
                        addAutomaticKeepAlives: true,
                        itemCount: mygroupsList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      //  padding: EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        border: Border.all(color: Colors.grey),

                                        borderRadius: BorderRadius.circular(12),
                                        // border: Border.all(
                                        //   color: Colors.grey,
                                        // ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => GroupInfoPage(
                                              groupID:
                                                  mygroupsList[index].groupID!,
                                              currentUserName: widget
                                                  ._currentUserName!, //groupImage:  mygroupsList[index].groupImageLink!
                                            ),
                                          ))
                                              .then((value) {
                                            setState(() {
                                              // SchedulerBinding.instance.addPostFrameCallback((_) {
                                              myGroupFuture = GetMyGroups();
                                              //   });
                                              //    groupFuture = GetGroups();
                                            });
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: mygroupsList[index]
                                                  .groupImageLink!,
                                              // width: 90.0,
                                              height: 202.0,

                                              fadeInCurve: Curves.easeIn,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  // borderRadius: BorderRadius.all(
                                                  //     Radius.circular(8.0)),
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.contain),
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () async {
                                                // if (kIsWeb) {
                                                //   GoRouter.of(context).go(
                                                //       '/group${mygroupsList[index].groupID!}');
                                                // } else if (defaultTargetPlatform ==
                                                //         TargetPlatform.iOS ||
                                                //     defaultTargetPlatform ==
                                                //         TargetPlatform.android) {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      GroupInfoPage(
                                                    groupID: mygroupsList[index]
                                                        .groupID!,
                                                    currentUserName: widget
                                                        ._currentUserName!, //groupImage:  mygroupsList[index].groupImageLink!
                                                  ),
                                                ))
                                                    .then((value) {
                                                  setState(() {
                                                    // SchedulerBinding.instance.addPostFrameCallback((_) {
                                                    myGroupFuture =
                                                        GetMyGroups();
                                                    //   });
                                                    //    groupFuture = GetGroups();
                                                  });
                                                });
                                                // }
                                              },
                                              title: Text(
                                                mygroupsList[index].groupName!,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "NexaBold",
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
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
          ],
        ),
      ),
    );
  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 935;

  Widget Groups() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 25, right: 25),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: groupFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      groupsList
                          .sort((a, b) => a.groupName!.compareTo(b.groupName!));

                      return ListView.builder(
                        addAutomaticKeepAlives: true,
                        itemCount: groupsList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              isDesktop(context)
                                  ? Expanded(child: Container())
                                  : Container(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      //  padding: EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        border: Border.all(color: Colors.grey),

                                        borderRadius: BorderRadius.circular(12),
                                        // border: Border.all(
                                        //   color: Colors.grey,
                                        // ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => GroupInfoPage(
                                              groupID:
                                                  groupsList[index].groupID!,
                                              currentUserName: widget
                                                  ._currentUserName!, //groupImage:  groupsList[index].groupImageLink!
                                            ),
                                          ))
                                              .then((value) {
                                            setState(() {
                                              //SchedulerBinding.instance.addPostFrameCallback((_) {
                                              groupFuture = GetGroups();
                                            });
                                          });
                                          //   }
                                        },
                                        child: Column(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: groupsList[index]
                                                  .groupImageLink!,
                                              //     fit: BoxFit.cover,
                                              height: 202.0,

                                              fadeInCurve: Curves.easeIn,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.contain),
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () async {
                                                // if (kIsWeb) {
                                                //   final bool? result = await GoRouter.of(context).push(
                                                //   '/group${groupsList[index].groupID!}');
                                                //
                                                //
                                                //   // .then((value) {
                                                //     setState(() {
                                                //     //  SchedulerBinding.instance.addPostFrameCallback((_) {
                                                //       groupFuture = GetGroups();
                                                //         // });
                                                //       //  myGroupFuture = GetMyGroups();
                                                //     });
                                                //   // });
                                                // } else if (defaultTargetPlatform ==
                                                //         TargetPlatform.iOS ||
                                                //     defaultTargetPlatform ==
                                                //         TargetPlatform.android) {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      GroupInfoPage(
                                                    groupID: groupsList[index]
                                                        .groupID!,
                                                    currentUserName: widget
                                                        ._currentUserName!, //groupImage:  groupsList[index].groupImageLink!
                                                  ),
                                                ))
                                                    .then((value) {
                                                  setState(() {
                                                    //SchedulerBinding.instance.addPostFrameCallback((_) {
                                                    groupFuture = GetGroups();
                                                    //  });
                                                    //  myGroupFuture = GetMyGroups();
                                                  });
                                                });
                                                //   }
                                              },
                                              title: Text(
                                                groupsList[index].groupName!,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "NexaBold",
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
          ],
        ),
      ),
    );
  }

  Future<List<GroupsList>> GetGroups() async {
    //  groupsList = [];

    await FirebaseFirestore.instance
        .collection('Groups')
        .get()
        .then((Groups) async {
      groupsList.clear();
      for (int i = 0; i < Groups.docs.length; i++) {
        if (Groups.docs[i]['Public']) {
          var groupMembersList = List.from(Groups.docs[i]['Group Members ID']);
          var eventsList = <String>[];
          groupsList.add(GroupsList(
            Groups.docs[i]['Group Name'],
            Groups.docs[i].id,
            //  widget.currentUserName,
            groupMembersList.length,
            Groups.docs[i]['groupimageLink'],
            '',
            '',
            Timestamp.now(),
          ));
        }
      }
    });
    return groupsList;
  }

  Future<List<GroupsList>> GetMyGroups() async {
    //  mygroupsList = [];

    await FirebaseFirestore.instance
        .collection('Students')
        .doc(currentUser.uid)
        .get()
        .then((student) async {
      mygroupsList.clear();
      var usergroupsList = <String>[];
      usergroupsList = await List.from(student.get('Groups'));

      for (int i = 0; i < usergroupsList.length; i++) {
        await FirebaseFirestore.instance
            .collection('Groups')
            .doc(usergroupsList[i])
            .get()
            .then((group) async {
          var groupMembersList = List.from(group['Group Members ID']);
          mygroupsList.add(GroupsList(
            group['Group Name'],
            group.id,
            //  widget.currentUserName,
            groupMembersList.length,
            group['groupimageLink'],
            '',
            '',
            Timestamp.now(),
          ));
          //     }
        });
      }
    });

    return mygroupsList;
  }

  void initState() {
    super.initState();


    _tabController.animation?.addListener(() {
      // if (_tabController.animation!.isCompleted!) {
      //   setState(() {
      //     myGroupFuture = GetMyGroups();
      //     groupFuture = GetGroups();
      //    // _tabController.index = (_tabController.animation!.value).round();
      //
      //   });
      // }else{
        setState(() {
        });

   //   }
    });
    // _tabController.addListener(() {
    //       if (_tabController.indexIsChanging ) {
    //     setState(()  {
    //       print('2');
    //       myGroupFuture = GetMyGroups();
    //       groupFuture = GetGroups();
    //     });
    //
    //
    //   }
    //
    //
    // });
  }

  Widget build(BuildContext context) {
    //  _tabController.index =0;
    //   rebuildAllChildren(context);
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        children: [
          TabBar(
              controller: _tabController,
              splashFactory: NoSplash.splashFactory,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
          //isScrollable : true,
         // physics:AlwaysScrollableScrollPhysics(),
              tabs: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: _tabController.index == 0
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Tab(
                      child: Center(
                          child: Text(AppLocalizations.of(context).myGroups,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                //  color: Colors.black,
                                  fontFamily: kIsWeb? "NexaBold"
                                      :"OpenSerif"
                              ))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      color: _tabController.index == 1
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Tab(
                      child: Center(
                          child: Text(AppLocalizations.of(context).dRBAGroups,
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
              Container(
                child: Center(
                  child: Mygroups(),
                ),
                //    child: Groups()
              ),
              Container(
                child: Center(
                  child: Groups(),
                ),
                //    child: Groups()
              ),
              // Container(
              //   child: Center(
              //     child: Container(),
              //   ),
              // ),
            ]),
          ),
        ],
      ),
    );
  }
}
