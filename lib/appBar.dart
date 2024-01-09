import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';

var scaffoldKey = GlobalKey<ScaffoldState>();
bool _isSnackbarActive = false;

// TranslationModel _translated = TranslationModel(translatedText: '', detectedSourceLanguage: '');
// final _translation = Translation(
//   apiKey: 'AIzaSyATkm_B3odmcZ12hq-AICsLYY0z_UMczBQ',
// );
class AppBars extends AppBar {

  AppBars(String title, String profileLink, context)
      : super(
            title: Text(title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    //color: Colors.black,
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
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                if (profileLink != '') {
                  scaffoldKey.currentState?.openDrawer();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: profileLink == ''
                  ? Icon(Icons.arrow_back_outlined)
                  : CircleAvatar(
                      //  radius: 64,
                      backgroundColor: Colors.blueGrey,
                      backgroundImage: CachedNetworkImageProvider(profileLink),
                    ),
            ),
            actions: [
              IconButton(
                  icon:  FaIcon(FontAwesomeIcons.solidSun),
                  color: Colors.grey[100],
                  onPressed: () async {

                    QuerySnapshot collection = await FirebaseFirestore.instance
                        .collection("Inspire")
                        .get();

                    var random = Random().nextInt(collection.docs.length);
                    DocumentSnapshot randomDoc = collection.docs[random];
                    String inspire = randomDoc['inspire'];
                   // _translated = await _translation.translate(text: inspire, to: 'en');

                    final snackBar = SnackBar(
                      backgroundColor: Colors.blueGrey[100],
                      duration: Duration(seconds: 15),
                      content: Text(
                        inspire
                            //+'\nGoogle Translate: '+_translated.translatedText
                        ,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width / 5,
                        0.0,
                        MediaQuery.of(context).size.width / 25,
                        MediaQuery.of(context).size.height / 4,
                      ),
                      action: SnackBarAction(
                        label: AppLocalizations.of(context).close,
                        backgroundColor: Colors.grey[400],
                        textColor: Colors.black,
                        onPressed: () {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          _isSnackbarActive = false;

                        },
                      ),
                    );

                    if (_isSnackbarActive)
                    {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      _isSnackbarActive = false;
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      _isSnackbarActive = true;
                    }
                  })
            ]);
}
