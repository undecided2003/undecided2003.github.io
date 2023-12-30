import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/profilePage.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'AppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RsvpdataList {
  String? _profileImageLink;
  RsvpdataList(this._profileImageLink);

  @override
  String toString() {
    return '{ ${this._profileImageLink}}';
  }
}

class rsvpList extends StatefulWidget {
  var rsvpNamesList = <String>[];
  final String eventName;
  final String currentUserName;
  var rsvpIDList = <String>[];
  var groupAdminList = <String>[];

  rsvpList(this.rsvpNamesList,this.eventName,this.currentUserName,this.rsvpIDList, this.groupAdminList,);
  @override
  State<rsvpList> createState() => _rsvpListState();
}

class _rsvpListState extends State<rsvpList> {

  var emailList = <String>[];
  final currentUser = FirebaseAuth.instance.currentUser!;
 // String currentUserName='';

  var rsvpdataList = <RsvpdataList>[];


  Future<List<RsvpdataList>> getUserData(context) async {
    if (widget.groupAdminList.contains(currentUser.uid)) {
    for (int j = 0; j < widget.rsvpIDList.length; j++) {
      await FirebaseFirestore.instance
          .collection("Students")
          .doc(widget.rsvpIDList[j])
          .get()
          .then((rsvp) async {
          String profileLink = rsvp['imageLink'];
          rsvpdataList.add(RsvpdataList(profileLink));
    });
  }}
    else{
      Navigator.pop(context);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, AppLocalizations.of(context).onlygroupadminscanseeRSVPlist);
      });

    }
    return rsvpdataList;
  }






  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=935;

  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBars(widget.eventName,'', context),
      body:
      SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 0,bottom: 0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Text(AppLocalizations.of(context).rSVPList,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'NexaBold')),
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                        child: FutureBuilder<List<RsvpdataList>>(
                            future: getUserData(context),
                            builder: (context, snapshot) {
            
                            if (snapshot.hasData &&
                                snapshot.connectionState == ConnectionState.done) {
                            return ListView.builder(
                              //    shrinkWrap:true,
                              itemCount: widget.rsvpIDList.length,
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
                                        child: Container(
                                          //  padding: EdgeInsets.all(24),
                                          // decoration: BoxDecoration(
                                          //     border: Border(bottom: BorderSide())),
                                          child: ListTile(
                                            tileColor:  Colors.white10,
                                            onTap: ()    async {
            
                                                Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (context) =>  profilePage(
                                                       receiverID:widget.rsvpIDList[index] )
                                                )
                                                );
                                            },
                                            leading: CircleAvatar(
                                            //  foregroundColor: Colors.blueGrey,
                                              backgroundColor: Colors.blueGrey,
                                              backgroundImage: CachedNetworkImageProvider(
            
                                                  rsvpdataList[index]._profileImageLink!
                                            //      _profileLink!.length > 0 ? _profileLink[index] : ''
                                                  ),
                                            ),
                                            title:
                                            Text(
                                              widget.rsvpNamesList[index],
                                              style: TextStyle(
                                                color: Colors.black,
                                                //   fontFamily: "NexaBold",
                                                fontSize: 15,
                                              ),
            
                                            ),
                                            subtitle:
                                            Text(
                                              index == 0 ? AppLocalizations.of(context).host : ''
                                              ,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: "NexaBold",
                                                //  fontSize: 15,
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
            
                  ],
                ),
              ),
            ),
          ),

    );
  }
}



