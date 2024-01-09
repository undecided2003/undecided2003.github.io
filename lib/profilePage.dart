import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'AppBar.dart';
import 'chat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'extractTextLinks.dart';

class Biodata {
  String? profileLink;
  String? Interest;
  String? Bio;
  String? name;
  String? activities;

  bool? appAdmin;

  Biodata(this.profileLink, this.Interest, this.Bio, this.name,this.activities, this.appAdmin);
}

class profilePage extends StatefulWidget {
  final String receiverID;

  profilePage(
      {super.key, required this.receiverID});

  @override
  State<profilePage> createState() => profilePageState();
}

class profilePageState extends State<profilePage> {
  //String cUEmail = '';

  Biodata? biodata = Biodata(
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..',
      '',
      '','','',false);

  Future<Biodata> getProfileData(context) async {
    final userProfile = await FirebaseFirestore.instance
        .collection('Students')
        .doc(widget.receiverID)
        .get();
    if (userProfile.exists) {
      // setState(() {
      biodata!.profileLink = userProfile.get('imageLink');
      biodata!.Interest = userProfile.get('Interest');
      biodata!.Bio = userProfile.get('Bio');
      biodata!.name = userProfile.get('Name');
      biodata!.appAdmin = userProfile.get('App Admin');
      biodata!.activities = userProfile.get('Activities');

      // });
    //  print(widget.receiverID);
    } else {
      Navigator.pop(context);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, AppLocalizations.of(context)
            .thisusernolongerexist);
      });

    }

    return biodata!;
  }

  // initState() {
  //   super.initState();
  //   Future.delayed(Duration.zero, () {
  //     getProfileData();
  //   });
  // }
  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;


  Widget build(BuildContext context) {
    return FutureBuilder<Biodata>(
        future: getProfileData(context),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              //  backgroundColor: Colors.white,
                appBar: AppBars(biodata!.name!,'', context),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(25),
                    child: Builder(builder: (context) {
                      return Row(
                        children: [
                          isDesktop(context)
                              ?
                          Expanded(child: Container())
                              :Container(),
                          Expanded(
                            child: Column(children: [
                              Align(
                                alignment: Alignment.center,
                                child: Column(children: [
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  SelectableText(biodata!.name!,
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                         // color: Colors.black87,
                                          fontFamily: 'NexaBold')),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Container(
                                    color: Colors.blueGrey,
                                    child: CachedNetworkImage(
                  
                                      imageUrl: biodata!.profileLink!,
                                      height: 195,
                                      fadeInCurve : Curves.easeIn,
                                        fit: BoxFit.contain
                                    ),
                                  ),

                  
                                  const SizedBox(
                                    height: 30,
                                  ),

                                ]),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                          .whyareyouinterestedinBuddhism,
                                      style: TextStyle(
                                      //  color: Colors.grey[800],
                                        fontSize: 16,
                                        fontFamily: "NexaBold",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    SelectableText.rich(
                                      textAlign: TextAlign.left,
                                      TextSpan(
                                        children: extractText(
                                          biodata!.Interest!,
                                        ),
                                        style: TextStyle(
                                       //   color: Colors.grey[800],
                                          fontFamily: "NexaBold",
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)
                                          .whatactivitiesandpractices,
                                      style: TextStyle(
                                      //  color: Colors.grey[800],
                                        fontSize: 16,
                                        fontFamily: "NexaBold",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    SelectableText.rich(
                                      textAlign: TextAlign.left,
                                      TextSpan(
                                        children: extractText(
                                          biodata!.activities!,
                                        ),
                                        style: TextStyle(
                                  //        color: Colors.grey[800],
                                          fontFamily: "NexaBold",
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)
                                          .buddhismbackgroundandshortbio,
                                      style: TextStyle(
                                  //      color: Colors.grey[800],
                                        fontSize: 16,
                                        fontFamily: "NexaBold",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    SelectableText.rich(
                                      textAlign: TextAlign.left,
                                      TextSpan(
                                        children: extractText(biodata!.Bio!),
                                        style: TextStyle(
                                   //       color: Colors.grey[800],
                                          fontFamily: "NexaBold",
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 310.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final currentuser =
                                                await FirebaseAuth.instance.currentUser;
                                            if (currentuser!.uid !=
                                                'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                                              if (widget.receiverID !=
                                                  currentuser!.uid) {
                                                String currentUserName = '';
                                                await FirebaseFirestore.instance
                                                    .collection('Students')
                                                    .doc(currentuser!.uid)
                                                    .get()
                                                    .then((student) async {
                                                  currentUserName = student['Name'];
                                                });
                  
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => chatPage(
                                                          receiverName:
                                                          biodata!.name!,
                                                          currentUserName:
                                                              currentUserName,
                                                          receiverID:
                                                              widget.receiverID),
                                                    ));
                                              } else {
                                                showErrorMessage(
                                                    context,
                                                    AppLocalizations.of(context)
                                                        .youcantmessageyourself);
                                              }
                                            } else {
                                              showErrorMessage(
                                                  context,
                                                  AppLocalizations.of(context)
                                                      .pleaseregisteranewaccounttocontinue);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[100],
                                              shape: const RoundedRectangleBorder(
                                                  side: BorderSide(color: Colors.grey),
                  
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(
                                                          10))) // Background color
                                              ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.chat_outlined,
                                             //     color: Colors.black87
                                              ),
                                              Text(AppLocalizations.of(context).message1,
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                    //  color: Colors.black87,
                                                      fontFamily: 'NexaBold')),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 310.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () async {
                  
                                final currentuser =
                                await FirebaseAuth.instance.currentUser;
                                if (currentuser!.uid !=
                                'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                                  bool currentappadmin = false;
                                            await FirebaseFirestore.instance
                                                .collection('Students')
                                                .doc(currentuser!.uid)
                                                .get()
                                                .then((student) async {
                                              currentappadmin = student['App Admin'];
                                            });
                                            if(currentappadmin){
                                            if (biodata!.appAdmin!){
                                              bool appAdmin = false;
                                              await FirebaseFirestore.instance
                                                  .collection("Students")
                                                  .doc(widget.receiverID)
                                                  .update({'App Admin': appAdmin});
                                              showErrorMessage(context,  biodata!.name!+ AppLocalizations.of(context)
                                                  .isnolongeranappadmin);
                                              setState(() {
                  
                                              });
                                            }else{
                                              bool appAdmin = true;
                                              await FirebaseFirestore.instance
                                                  .collection("Students")
                                                  .doc(widget.receiverID)
                                                  .update({'App Admin': appAdmin});
                                              showErrorMessage(context,  biodata!.name!+ AppLocalizations.of(context).isnowanappadmin);
                                              setState(() {
                  
                                              });
                                            }
                  
                  
                                            } else
                                                  {
                                                    showErrorMessage(context,  AppLocalizations.of(context)
                                                        .onlyappadminscanmakeappadmins);
                                                  }
                                } else {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .pleaseregisteranewaccounttocontinue);
                                }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[100],
                                              shape: const RoundedRectangleBorder(
                                                  side: BorderSide(color: Colors.grey),
                  
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(
                                                          10))) // Background color
                                          ),
                                          child:
                                          biodata!.appAdmin!?
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.remove_moderator_outlined,
                                              //    color: Colors.black87
                                              ),
                                              Text(AppLocalizations.of(context)
                                                  .removeappadmin,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                   //   color: Colors.black87,
                                                      fontFamily: 'NexaBold')),
                                            ],
                                          )
                                          :
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_moderator_outlined,
                                        //          color: Colors.black87
                                              ),
                                              Text(AppLocalizations.of(context)
                                                  .makeAppAdmin,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                   //   color: Colors.black87,
                                                      fontFamily: 'NexaBold')),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          isDesktop(context)
                              ?
                          Expanded(child: Container())
                              :Container(),
                        ],
                      );
                    }),
                  ),
                ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
