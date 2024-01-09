import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'DeletePage.dart';
import 'add_inspiration.dart';
import 'chat_list.dart';
import 'edit_profile.dart';
import 'main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'meditation_timer.dart';

class Profiledata {
  String? currentUserName;
  String? cUEmail;
  String? profileLink;
  String? currentUserId;
  bool? unreadMessages;
  String? _Language;
  bool? appAdmin;
  var meditationGoals = <int>[];

  Profiledata(this.currentUserName, this.cUEmail, this.profileLink,
      this.currentUserId, this.unreadMessages, this._Language, this.appAdmin, this.meditationGoals,);
}

class NavDrawer extends StatefulWidget {
  final String currentUserID;

  NavDrawer({super.key, required this.currentUserID});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String? dropdownValue;
  AudioPlayer player = AudioPlayer(playerId: '1');

  Profiledata? profiledata =
      Profiledata('Anonymous', '', '', '', false, 'English', false, []);

  @override
  Future<void> dispose() async {
    super.dispose(); //change here
    await player.stop();
  }

  Future<Profiledata> getProfileData() async {
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(widget.currentUserID)
        .get()
        .then((Users) async {
      String _imageLink = Users.get('imageLink');
      profiledata!.currentUserId = 'currentUser.uid';
      String lang = Users.get('Language');
      try {
        profiledata!.currentUserName = Users.get('Name');
      } catch (e) {}
      //  });
      profiledata!.profileLink = _imageLink;
      profiledata!.unreadMessages = Users.get('Unread Messages');
      profiledata!.appAdmin = Users.get('App Admin');
      profiledata!.meditationGoals = List.from(Users.get('Meditation Goals'));

      if (lang == 'en') {
        profiledata!._Language = 'English';
      } else if (lang == 'zh') {
        profiledata!._Language = '中文';
      } else if (lang == 'vi') {
        profiledata!._Language = 'Tiếng Việt';
      }


    });

    return profiledata!;
  }

  @override
  //
  // void initState() {
  //   super.initState();
  //   getProfileData();
  //
  // }

  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Profiledata>(
          future: getProfileData(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    // color: Colors.orangeAccent,
                    child: UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                          color:
              profiledata!.profileLink! !=
                      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..'
                  ?
                  Colors.transparent
                  : Colors.blueGrey
                          ,
                          image: DecorationImage(
                              //     opacity: .9,
                              image: CachedNetworkImageProvider(
                                  profiledata!.profileLink!),
                              fit:
                              // profiledata!.profileLink! !=
                              //         'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..'
                              //     ? BoxFit.fill
                              //     :
                              BoxFit.contain)),
                      accountName: Text(''),
                      accountEmail: Text(profiledata!.currentUserName!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: "NexaBold",
                            fontSize: 25,
                          )),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                   //   color: Colors.grey,
                    ),
                    title: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        //   focusColor: Colors.white,
                        value: profiledata!._Language,
                        //elevation: 5,
                        //  style: TextStyle(color: Colors.white),
                        //  iconEnabledColor: Colors.black,
                        items: <String>['English', '中文', 'Tiếng Việt']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: Theme.of(context).textTheme.bodyMedium,

                            ),
                          );
                        }).toList(),

                        onChanged: (String? value) async {
                          // final provider = Provider.of<LocaleProvider>(context, listen:false);
                          // provider.setLocale(_Language);
                          if (value == 'English') {
                            Home.of(context)?.setLocale(
                                Locale.fromSubtags(languageCode: 'en'));
                            await FirebaseFirestore.instance
                                .collection("Students")
                                .doc(widget.currentUserID)
                                .update({'Language': 'en'});
                          } else if (value == '中文') {
                            //   setState(() {
                            Home.of(context)?.setLocale(
                                Locale.fromSubtags(languageCode: 'zh'));
                            //   });
                            await FirebaseFirestore.instance
                                .collection("Students")
                                .doc(widget.currentUserID)
                                .update({'Language': 'zh'});
                          } else if (value == 'Tiếng Việt') {
                            //   setState(() {
                            Home.of(context)?.setLocale(
                                Locale.fromSubtags(languageCode: 'vi'));
                            //   });
                            await FirebaseFirestore.instance
                                .collection("Students")
                                .doc(widget.currentUserID)
                                .update({'Language': 'vi'});
                          }
                        },
                      ),
                    ),
                  ),
                  widget.currentUserID != 'P1shfIrzeAa68jeQxI3LaLQ3eYb2'
                      ? ListTile(
                          leading: Icon(
                            Icons.edit,
                           // color: Colors.grey,
                          ),
                          title: Text(
                            AppLocalizations.of(context).editprofile,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator
                                .push(
                              MaterialPageRoute(
                                  builder: (_) => editProfile(
                                      currentUserID: widget.currentUserID)),
                            )
                                .then((value) {
                              //    profiledata
                              getProfileData();
                              setState(() {});
                            });
                          },
                        )
                      : Container(),
                  widget.currentUserID != 'P1shfIrzeAa68jeQxI3LaLQ3eYb2'
                      ? ListTile(
                          leading: Icon(
                            Icons.message,
                          //  color: Colors.grey,
                          ),
                          title: Stack(children: <Widget>[
                            Text(
                              AppLocalizations.of(context).messages,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            profiledata!.unreadMessages!
                                ? Positioned(
                                    // draw a red marble
                                    top: 0.0,
                                    right: 0.0,
                                    child: new Icon(Icons.brightness_1,
                                        size: 8.0, color: Colors.redAccent),
                                  )
                                : Container()
                          ]),
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator
                                .push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      Chat_List(widget.currentUserID)),
                            )
                                .then((value) {
                              //    profiledata
                              getProfileData();
                              setState(() {});
                            });
                          },
                        )
                      : Container(),
                  ListTile(
                    leading: Icon(
                      Icons.self_improvement_outlined
                    ),
                    title: Text(AppLocalizations.of(context).meditationTimer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () async {
                        final navigator = Navigator.of(context);
                        navigator.push(
                          MaterialPageRoute(builder: (_) => meditationTimer(profiledata!.meditationGoals)),
                        );
                    },
                  ),
                  ListTile(
                    leading: GestureDetector(
                        onTap: () {
                          player.stop();
                        },
                        child: Icon(
                          Icons.playlist_play_outlined,
                      //    color: Colors.grey,
                        )),
                    title: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        // focusColor: Colors.white,
                        //   value:  AppLocalizations.of(context).amitabha,

                        // profiledata!._Language,
                        //   style: TextStyle(color: Colors.blueGrey),
                        // iconEnabledColor: Colors.black,
                        items: <String>[
                          AppLocalizations.of(context).stop,
                          AppLocalizations.of(context).amitabha,
                          AppLocalizations.of(context).guanYin,
                          AppLocalizations.of(context).medicineMasterBuddha,
                          AppLocalizations.of(context).greatCompassionMantra,
                          AppLocalizations.of(context).shurangamaMantra
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: value == AppLocalizations.of(context).stop
                                  ? TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)
                                  : Theme.of(context).textTheme.bodyMedium
                            ),
                          );
                        }).toList(),
                        hint: Text(
                          AppLocalizations.of(context).recitation,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                ),
                        onChanged: (String? value) async {
                          if (value == AppLocalizations.of(context).stop) {
                            player.stop();
                          } else if (value ==
                              AppLocalizations.of(context).amitabha) {
                            player.play(AssetSource('Amitabha.mp3'));
                            player.setReleaseMode(ReleaseMode.loop);
                          } else if (value ==
                              AppLocalizations.of(context).guanYin) {
                            player.play(AssetSource('gwanyinchant.mp3'));
                            player.setReleaseMode(ReleaseMode.loop);
                          } else if (value ==
                              AppLocalizations.of(context)
                                  .medicineMasterBuddha) {
                            player.play(AssetSource('YaoShiShengHao.mp3'));
                            player.setReleaseMode(ReleaseMode.loop);
                          } else if (value ==
                              AppLocalizations.of(context)
                                  .greatCompassionMantra) {
                            player.play(AssetSource('DaBeiZhou.mp3'));
                            player.setReleaseMode(ReleaseMode.loop);
                          } else if (value ==
                              AppLocalizations.of(context).shurangamaMantra) {
                            player.play(AssetSource('LengYanZhou.mp3'));
                            player.setReleaseMode(ReleaseMode.loop);
                          }
                        },
                      ),
                    ),
                  ),

                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.solidSun),
                    title: Text(
                      AppLocalizations.of(context).addInspiration,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () async {
                      if (profiledata!.appAdmin!) {
                        final navigator = Navigator.of(context);
                        navigator.push(
                          MaterialPageRoute(builder: (_) => addInspire()),
                        );
                      } else {
                        showErrorMessage(
                            context,
                            AppLocalizations.of(context)
                                .onlyappadminscanaddinspiration);
                      }
                    },
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.gifts),
                    title: Text(
                      AppLocalizations.of(context).donate,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () async {
                      await launchUrl(Uri.parse('https://www.drba.org/donate.html'),
                       );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout_rounded,
                  //    color: Colors.grey,
                    ),
                    title: Text(
                      AppLocalizations.of(context).logout,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () async {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                  widget.currentUserID != 'P1shfIrzeAa68jeQxI3LaLQ3eYb2'
                      ? ListTile(
                          leading: Icon(
                            Icons.delete_forever,
                         //   color: Colors.grey,
                          ),
                          title: Text(
                            AppLocalizations.of(context).deleteAccount,
            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator.push(
                              MaterialPageRoute(builder: (_) => DeletePage()),
                            );
                          },
                        )
                      : Container()
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
