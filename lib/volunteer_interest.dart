import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'showErrorMessage.dart';
import 'AppBar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class addVolunteer extends StatefulWidget {

  final String currentUserID;

  var _volunteerIDList = <String>[];
  var _volunteerInterestList = <String>[];
  final String groupID;

  addVolunteer(this.currentUserID,this._volunteerIDList,this._volunteerInterestList,this.groupID);

  @override
  State<addVolunteer> createState() => _addVolunteerState();
}

class _addVolunteerState extends State<addVolunteer> {
  final interestController = TextEditingController();


  @override
  void dispose() {
    interestController.dispose();
    super.dispose();
  }



  Future<void> joinVolunteer() async {

   var volunteersIDList = widget._volunteerIDList;
   var volunteersInterestList = widget._volunteerInterestList;
   volunteersIDList.add(widget.currentUserID);
   volunteersInterestList.add(interestController.text);

    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupID)
        .update({
      'Volunteers': volunteersIDList,
      'Volunteer Interests': volunteersInterestList,
      //    'Group Members Names': membersNameList,
    });


    Navigator.pop(context);
   showErrorMessage(context,
       AppLocalizations.of(context).youjoinedthe + AppLocalizations.of(context).volunteers + '!');  }





  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery
          .of(context)
          .size
          .width >= 1025;
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBars(AppLocalizations.of(context).volunteerss+'!','', context),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              isDesktop(context)
                  ?
              Expanded(child: Container())
                  : Container(),
              Expanded(
                child: Column(children: [
                  const SizedBox(
                    height: 48,
                  ),
                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).whatvolunteeringinterests,
                            style: TextStyle(
                              //color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: interestController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 5,
                          minLines: 5,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                )),
                          ),
                          onFieldSubmitted: (value) async {
                            await joinVolunteer();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  //onTap: signIn,
                  SizedBox(
                    width: 275.0,
                    height: 50.0,
                    child: GestureDetector(
                      child: ElevatedButton(
                        onPressed: () async {
                          await joinVolunteer();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      10))
                          ),
                          backgroundColor: Colors.grey[100], // Background color
                        ),
                        child: Text(AppLocalizations
                            .of(context)
                            .join,
                            style: TextStyle(
                                fontSize: 25,
                                //color: Colors.grey[800],
                                fontFamily: 'NexaBold')),
                      ),
                    ),
                  ),
                ]),
              ),
              isDesktop(context)
                  ?
              Expanded(child: Container())
                  : Container(),
            ],
          ),
        ));
  }
}
