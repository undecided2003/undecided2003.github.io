import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profilePage.dart';
import 'showErrorMessage.dart';
import 'AppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MembersList {
  String? memberName;
  String? _profileImageLink;
  String? memberID;
  MembersList(this.memberName, this._profileImageLink, this.memberID);
  @override
  String toString() {
    return '{ ${this.memberName},${this._profileImageLink},${this.memberID}}';
  }
}

class ShowmembersList extends StatefulWidget {
  final String groupID;
  final String currentUserName;
  final String groupName;
  var adminsList = <String>[];

  ShowmembersList(this.groupID,this.currentUserName,this.groupName,this.adminsList );
  @override
  State<ShowmembersList> createState() => _ShowmembersListState();
}

class _ShowmembersListState extends State<ShowmembersList> {

  var emailList = <String>[];
  final currentUser = FirebaseAuth.instance.currentUser!;
  var membersList = <MembersList>[];

  void _showPopupMenu(context, Offset offset,
      String _receiverName, int _index, String _receiverID) async {

      await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            offset & Size(40, 40), // smaller rect, the touch area
            Offset.zero & Size(1000, 1000) // Bigger rect, the entire screen
        ),
        items: [
          PopupMenuItem(
            value: 0,
            child: Text(AppLocalizations.of(context).viewProfile),
            onTap: () async {
              await FirebaseFirestore.instance
                  .collection('Student')
                  .doc(_receiverID)
                  .get()
                  .then((user) async {
                final navigator = Navigator.of(context);
                await Future.delayed(Duration.zero);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>  profilePage(receiverID:_receiverID )
                )
                );
                // if(_receiverName!=user.get('Name')){
                //   var _memberNames = List.from(user.get('Group Members Names'));
                //   _memberNames[_index] = user.get('Name');
                //   FirebaseFirestore.instance
                //       .collection('Groups')
                //       .doc(widget.groupID)
                //       .update({
                //     'Group Members Names': _memberNames,
                //   });
                // }
              });

            },
          ),
          PopupMenuItem(
            value: 1,
            child: Text(AppLocalizations.of(context).makeGroupAdmin),
            onTap: () async {


              await FirebaseFirestore.instance
                  .collection('Groups')
                  .doc(widget.groupID)
                  .get()
                  .then((Groups) async {
                if (currentUser.uid ==
                    List.from(Groups.get('Group Members ID'))[0] ||
                    widget.adminsList.contains(currentUser.uid)) {
    if (widget.adminsList.contains(_receiverID)) {
    showErrorMessage(
    context,AppLocalizations.of(context).thispersonisalready
    );
    }
    else{
                  setState(() {
                    widget.adminsList.add(_receiverID);
                  });
                  FirebaseFirestore.instance
                      .collection('Groups')
                      .doc(widget.groupID)
                      .update({
                    'Admins': widget.adminsList,
                  });}
                } else {
                  showErrorMessage(
                      context,AppLocalizations.of(context).onlyagroupadmincanmakegroupadmins);
                }

              });

            },
          ),
          PopupMenuItem(
            value: 2,
            child: Text(AppLocalizations.of(context).removeMember),
            onTap: () async {
              await FirebaseFirestore.instance
                  .collection('Groups')
                  .doc(widget.groupID)
                  .get()
                  .then((Groups) async {
               // var groupMembersNamesList =
               // List.from(Groups.get('Group Members Names'));
                var groupMembersIdList =
                List.from(Groups.get('Group Members ID'));

                if (currentUser.uid ==
                    List.from(Groups.get('Group Members ID'))[0] ||
                    widget.adminsList.contains(currentUser.uid)) {
                 // groupMembersNamesList.removeAt(_index);
                  groupMembersIdList.removeAt(_index);
                  widget.adminsList.remove(_receiverID);

                  FirebaseFirestore.instance
                      .collection('Groups')
                      .doc(widget.groupID)
                      .update({
                   // 'Group Members Names': groupMembersNamesList,
                    'Group Members ID': groupMembersIdList,
                    'Admins': widget.adminsList,
                  });
setState(() {

});
                  // getGroupInfo(
                  //     context, widget.groupID, widget.currentUserEmail);
                  var groupsList = <String>[];
                  await FirebaseFirestore.instance
                      .collection("Students")
                      .doc(_receiverID)
                      .get()
                      .then((User) async {
                    groupsList = List.from(User.get('Groups'));
                  });
                  groupsList.remove(widget.groupID);
                  await FirebaseFirestore.instance
                      .collection("Students")
                      .doc(_receiverID)
                      .update({'Groups': groupsList});
                } else {
                  showErrorMessage(
                      context,AppLocalizations.of(context).onlyagroupadmincanremovemembers);
                }
              });
            },
          )
        ],
        elevation: 8.0,
      );

  }
  // final _controller = NativeAdmobController();
  //
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }
  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=935;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBars(widget.groupName+AppLocalizations.of(context).members,'', context),
      body:
      SafeArea(
        child: Center(
        //  scrollDirection: Axis.vertical,
          child: Padding(
          padding: EdgeInsets.only(left: 0, right: 0, top: 0,bottom: 0),
          // child: SizedBox(
          //   height:MediaQuery.of(context).size.height-350,
            child: Column(
              children:// <Widget>
               [
                 SizedBox(
                  height: 10,
                ),
                Text(AppLocalizations.of(context).membersList,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NexaBold')),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  child: Expanded(
                      child: FutureBuilder<List<MembersList>>(
                          future: getMembersList(),
                          builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.connectionState == ConnectionState.done) {
                          return ListView.builder(
                            //    shrinkWrap:true,
                            itemCount: membersList.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  isDesktop(context)
                                      ?
                                  Expanded(child: Container())
                                      :Container(),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(25, 0, 25,0),
                                      child: GestureDetector(
                                        onTapDown: (TapDownDetails details) {
                                          _showPopupMenu(
                                              context,
                                              details.globalPosition,
                                              membersList[index].memberName!,
                                              index,membersList[index].memberID! );
                                        },
                                        child: Container(
                                          //  padding: EdgeInsets.all(24),
                                           decoration: BoxDecoration(
                                               border: Border(bottom: BorderSide())),
                                          child: ListTile(
                                            tileColor:  Colors.grey[100],
                                            leading: CircleAvatar(
                                                 radius: 20,
                                              backgroundColor: Colors.blueGrey,
                                              backgroundImage: CachedNetworkImageProvider(
                                                  membersList[index]
                                                      ._profileImageLink!),
                                            ),
                                            title: Text(
                                              membersList[index].memberName!,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: "NexaBold",
                                                //  fontSize: 15,
                                              ),
                                            ),
                                            subtitle: Text(
                                          index == 0 ||
                                          widget.adminsList.contains(
                                              membersList[index]
                                              .memberID)
                                              ? 'Admin'
                                              : '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontFamily: "NexaBold",
                                            //  fontSize: 15,
                                          ),
                                        ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  isDesktop(context)
                                      ?
                                  Expanded(child: Container())
                                      :Container(),
                                ],
                              );
                            },
                          );
            }
            else {
            return Center(child: CircularProgressIndicator());
            }
                        }
                      ),

                  ),
                ),

              ],
            ),
             //   ),
            ) ),
      ),
    );
  }

  Future<List<MembersList>> getMembersList() async {
    membersList.clear();
 //   var membersNameList = <String>[];
    var membersIDList = <String>[];
    var _adminsList = <String>[];

    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupID)
        .get()
        .then((group) {
  //    membersNameList = List.from(group.get('Group Members Names'));
      membersIDList = List.from(group.get('Group Members ID'));
      _adminsList = List.from(group.get('Admins'));
    });

    for (int i = 0; i < membersIDList.length; i++) {
      membersList.add(
          MembersList( 'Name', 'profileLink', membersIDList[i]));
    }
    //print(membersList);

    for (int i = 0; i < membersIDList.length; i++) {
      final doc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(membersIDList[i])
          .get();
      if (doc.exists) {
        String profileLink = doc.get('imageLink');
        String Name = 'Anonymous';
        try{Name= doc.get('Name');}catch(e){}

        membersList[i] =
            MembersList(Name, profileLink, membersIDList[i]);
      } else {
        _adminsList.remove(membersIDList[i]);
      //  var _membersNameList = membersNameList;
        var _membersIDList = membersIDList;
      //  _membersNameList.removeAt(i);
        _membersIDList.removeAt(i);
        FirebaseFirestore.instance
            .collection('Groups')
            .doc(widget.groupID)
            .update({
       //   'Group Members Names': _membersNameList,
          'Group Members ID': _membersIDList,
          'Admins': _adminsList,
        });
      }
    }
    return membersList;
  }
}



