import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/profilePage.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:drbaapp/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:intl/intl.dart';
import 'Newfeed_edit.dart';
import 'Share_Screen.dart';
import 'extractTextLinks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatList {
  String? chatID;
  String? chatName;
  String? chatMessage;
  Timestamp? chatTimestamp;

  ChatList(this.chatID, this.chatName, this.chatMessage, this.chatTimestamp);

  @override
  String toString() {
    return '{ ${this.chatID},${this.chatName},${this.chatMessage}, ${this.chatTimestamp}}';
  }
}

class Newsdata {
  String? _newsName;
  String? _studentName;
  String? _newsImage;
  String? _newsStory;
  Timestamp? _newsTime;
  var chatList = <ChatList>[];
  String? _studentID;
  String? _profileImageLink;

  Newsdata(this._newsName, this._studentName, this._newsImage, this._newsStory,
      this._newsTime, this.chatList, this._studentID, this._profileImageLink);
}

class Newsfeed_info extends StatefulWidget {
  // var newslist = <News>[];
  String newsID;
  String currentUserName;

  Newsfeed_info(this.newsID, this.currentUserName);

  @override
  State<Newsfeed_info> createState() => _Newsfeed_infoState();
}

class _Newsfeed_infoState extends State<Newsfeed_info> {
  var chatList = <ChatList>[];
  var chatIDList = <String>[];
  var chatMessageList = <String>[];
  var chatNameList = <String>[];
  var chatTimestampList = <Timestamp>[];
  Newsdata? newsdata;
  bool initPos = true;

  // final animated =AnimatedSwitcher(
  // duration: const Duration(seconds: 1), child: GetNewsDataFromNewsID(widget.newsID)
  // );
  TranslationModel _translated =
      TranslationModel(translatedText: '', detectedSourceLanguage: '');
  final _translation = Translation(
    apiKey: 'AIzaSyATkm_B3odmcZ12hq-AICsLYY0z_UMczBQ',
  );
  late Future getNewsDataFromNewsID = GetNewsDataFromNewsID(widget.newsID);

  GetNewsDataFromNewsID(String newsID) async {
    await FirebaseFirestore.instance
        .collection('Newsfeed')
        .doc(newsID)
        .get()
        .then((news) {
      if (news.exists) {
        //    setState(() {

        chatIDList = List.from(news.get('UserID'));
        chatMessageList = List.from(news.get('commentsMessage'));
        chatNameList = List.from(news.get('commentsName'));
        chatTimestampList = List.from(news.get('commentsTimestamp'));
        chatList = [];
        for (int j = 0; j < chatMessageList.length; j++) {
          chatList.add(ChatList(chatIDList[j], chatNameList[j],
              chatMessageList[j], chatTimestampList[j]));
        }
        ;
        chatList = chatList.reversed.toList();
        newsdata = Newsdata(
            news.get('News Name'),
            news.get('Student Name'),
            news.get('imageLink'),
            news.get('Story'),
            news.get('Time'),
            chatList,
            news.get('Student ID'),
            news.get('Student imageLink'));
        //     });
      } else {
        Navigator.of(context).pop();
        showErrorMessage(
            context, AppLocalizations.of(context).newsupdatenolongerexist);
      }
    });
    return newsdata;
  }

  // shareNews(){
  //   dynamicLinkProvider()
  //       .createLink('news' + widget.newsID.toString())
  //       .then((value) {
  //     final box = context.findRenderObject() as RenderBox?;
  //     Share.share(
  //       newsdata!._studentName! + " posted a news update " +
  //           newsdata!._newsName! +
  //           ' \n \n' +
  //           value,
  //       sharePositionOrigin:
  //       box!.localToGlobal(Offset.zero) & box.size,
  //     );
  //   });
  //
  // }

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
        await FirebaseFirestore.instance
            .collection('Newsfeed')
            .doc(widget.newsID)
            .get()
            .then((news) async {
          if (news['imageLink'] !=
              'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/newsfeed%2Fdharma-news.png?alt=media&token=6d592125-dd0d-4b00-846d-9f019cf6b09b&_gl=1*1r2li0u*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODczNTg3MS41NjMuMS4xNjk4NzM2MjUzLjQyLjAuMA..') {
            FirebaseStorage.instance.refFromURL(news['imageLink']).delete();
          }
        });

        FirebaseFirestore.instance
            .collection('Newsfeed')
            .doc(widget.newsID)
            .delete();

      //  Navigator.of(context).pop();
        Navigator.of(context).pop();
        if (kIsWeb) { Navigator.of(context).pop();}
        context.push('/');
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) => Welcome(),
        // ));
      },
    ); // set up the AlertDialog

    AlertDialog alert = AlertDialog(
      // title: Text(""),
      title: Text(AppLocalizations.of(context).doyouwanttodeletethisnewsupdate),
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

  Future<void> postMessage(
      idList, chatNameList, chatMessageList, chatTimestampList) async {
    final currentUser = await FirebaseAuth.instance.currentUser!;

    String studentName = widget.currentUserName;
    if (studentName == 'from welcome') {
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(currentUser.uid)
          .get()
          .then((Users) async {
        try {
          studentName = Users.get('Name');
        } catch (e) {
          if (await FirebaseAuth.instance.currentUser!.displayName != null) {
            studentName = await FirebaseAuth.instance.currentUser!.displayName!;
          }
          Future.delayed(Duration(seconds: 1), () async {});
          studentName = await Users.get('Name');
        }
      });
    } else if (studentName.contains('Anonymous') || studentName == '') {
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(currentUser.uid)
          .get()
          .then((Users) async {
        if (Users.exists) {
          try {
            studentName = Users.get('Name');
          } catch (e) {
            if (FirebaseAuth.instance.currentUser!.displayName != null) {
              studentName = FirebaseAuth.instance.currentUser!.displayName!;
            }
          }
        }
      });
    }

    idList.add(currentUser.uid);
    chatNameList.add(studentName!);
    chatMessageList.add(textController.text);
    chatTimestampList.add(Timestamp.now());

    if (textController.text.isNotEmpty) {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection("Newsfeed")
          .doc(widget.newsID);
      docRef.update({
        'UserID': idList,
        'commentsName': chatNameList,
        'commentsMessage': chatMessageList,
        'commentsTimestamp': chatTimestampList
      });
      // sendEventChatPushNotification(
      //     emailList, textController.text, studentName!, eventName!, docRef.id, widget.currentUserEmail);
    }

    setState(() {
      getNewsDataFromNewsID = GetNewsDataFromNewsID(widget.newsID);
      initPos = false;
    });
  }

  Future<void> _postInit() async {
    if (initPos) {
    } else {
      //   await Future.delayed(Duration(milliseconds: 100));
      controller.jumpTo(controller.position.maxScrollExtent);
    }
  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1025;

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getNewsDataFromNewsID,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            _postInit();
            return Scaffold(
                appBar: AppBar(
                    title:
                        //  padding: const EdgeInsets.all(8.0),
                        Text(newsdata!._newsName!,
                            style: TextStyle(
                                // fontSize: 10,
                                fontWeight: FontWeight.w600,
                                // color: Colors.black,
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
                                      Text(AppLocalizations.of(context1).share),
                                    ],
                                  ),
                                  onTap: () async {
                                    // final navigator = Navigator.of(context);
                                    // await Future.delayed(Duration.zero);
                                    await Navigator.of(context1).push(
                                        MaterialPageRoute(
                                            builder: (_) => Share_Screen(
                                                '/news' + widget.newsID,
                                                newsdata!._studentName! +
                                                    AppLocalizations.of(context1)
                                                        .postedanewsupdate +
                                                    newsdata!._newsName!,
                                                newsdata!._newsName!)));
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
                                      Text(AppLocalizations.of(context1).edit),
                                    ],
                                  ),
                                  onTap: () async {
                                    final currentUser = await FirebaseAuth
                                        .instance.currentUser!;
                                    if (currentUser.uid ==
                                        newsdata!._studentID!) {
                                      await Navigator.of(context1)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  EditNewsfeed(
                                                      newsID: widget.newsID)))
                                          .then((value) {
                                        setState(() {});
                                      });
                                    } else {
                                      showErrorMessage(
                                          context1,
                                          AppLocalizations.of(context1)
                                              .onlytheauthorcaneditthenewsupdate);
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
                                      Text(AppLocalizations.of(context1).delete),
                                    ],
                                  ),
                                  onTap: () async {
                                    final currentUser = await FirebaseAuth
                                        .instance.currentUser!;
                                    if (currentUser.uid ==
                                        newsdata!._studentID!) {
                                      showDeleteAlertDialog(context1);
                                    } else {
                                      showErrorMessage(
                                          context1,
                                          AppLocalizations.of(context1)
                                              .onlytheauthorcandeletethenewsupdate);
                                    }
                                  },
                                )
                              ])
                    ]),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: 23, right: 23, top: 20, bottom: 20),
                    controller: controller,
                    child: Row(
                      children: [
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                        Expanded(
                          child: Column(
                            children: [
                              CachedNetworkImage(
                                imageUrl: newsdata!._newsImage!,
                                width: double.infinity,
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
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    newsdata!._newsName!,
                                    style: TextStyle(
                                      //  color: Colors.black,
                                      fontFamily: "NexaBold",
                                      fontSize: 28,
                                    ),
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: CachedNetworkImageProvider(
                                            newsdata!._profileImageLink!
                                            //      _profileLink!.length > 0 ? _profileLink[index] : ''
                                            ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      profilePage(
                                                          receiverID: newsdata!
                                                              ._studentID!)));
                                        },
                                        child: Text(
                                          newsdata!._studentName!,
                                          style: TextStyle(
                                            color: Colors.lightBlue,
                                            fontFamily: "NexaBold",
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('EEE, MM/dd/yyyy')
                                        .format(newsdata!._newsTime!.toDate())
                                        .toString(),
                                    style: TextStyle(
                                      //   color: Colors.black,
                                      fontFamily: "NexaBold",
                                      fontSize: 16,
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
                                    width: 14,
                                  ),
                                  Expanded(
                                    child: SelectableText.rich(
                                      textAlign: TextAlign.left,
                                      TextSpan(
                                        children:
                                            extractText(newsdata!._newsStory!),
                                        style: TextStyle(
                                          //       color: Colors.black,
                                          fontFamily: "NexaBold",
                                          fontSize: 20,
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
                                    width: 14,
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                    //   width: 180,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_translated.translatedText == '') {
                                          _translated =
                                              await _translation.translate(
                                                  text: newsdata!._newsStory!,
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
                                          initPos = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[100],
                                          shape: const RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.grey),
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
                                            width: 10,
                                          ),
                                          Text(
                                              AppLocalizations.of(context)
                                                  .translate,
                                              style: TextStyle(
                                                  fontSize: 11,
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
                                    width: 14,
                                  ),
                                  Expanded(
                                    child: SelectableText.rich(
                                      textAlign: TextAlign.left,
                                      TextSpan(
                                        children: extractText(
                                            _translated.translatedText),
                                        style: TextStyle(
                                          //   color: Colors.black,
                                          fontFamily: "NexaBold",
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 24,
                              ),
                              Divider(
                                height: 45,
                                thickness: 1,
                                color: Colors.grey[400],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child:
                                    Text(AppLocalizations.of(context).comments,
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            //  color: Colors.black,
                                            fontFamily: 'NexaBold')),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(color: Colors.blueGrey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 13,
                                    ),
                                    Expanded(
                                        child: TextFormField(
                                          textCapitalization: TextCapitalization.sentences ,

                                          style: TextStyle(color: Colors.black),
                                      controller: textController,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey[100],
                                        border: InputBorder.none,
                                        hintText: AppLocalizations.of(context)
                                            .addacomment,
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontFamily: "NexaBold",
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.transparent,
                                        )),
                                      ),
                                      onFieldSubmitted: (value) async {
                                        final currentUser = await FirebaseAuth
                                            .instance.currentUser!;
                                        if (currentUser.uid !=
                                            'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                                          await postMessage(
                                              chatIDList,
                                              chatNameList,
                                              chatMessageList,
                                              chatTimestampList);
                                          textController.clear();
                                        } else {
                                          showErrorMessage(
                                              context,
                                              AppLocalizations.of(context)
                                                  .pleaseregisteranewaccounttocontinue);
                                        }
                                      },
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 18),
                                      child: Container(
                                        child: IconButton(
                                            onPressed: () async {
                                              final currentUser =
                                                  await FirebaseAuth
                                                      .instance.currentUser!;
                                              if (currentUser.uid !=
                                                  'P1shfIrzeAa68jeQxI3LaLQ3eYb2') {
                                                await postMessage(
                                                    chatIDList,
                                                    chatNameList,
                                                    chatMessageList,
                                                    chatTimestampList);
                                                textController.clear();
                                              } else {
                                                showErrorMessage(
                                                    context,
                                                    AppLocalizations.of(context)
                                                        .pleaseregisteranewaccounttocontinue);
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.send_outlined,
                                              size: 40,
                                              color: Colors.blueGrey,
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // Flexible(
                              //   child:
                              SizedBox(
                                height: 400,
                                // width: 325,
                                child: ListView.builder(
                                  reverse: true,
                                  // shrinkWrap: true,
                                  itemCount: newsdata!.chatList.length,
                                  itemBuilder: (context, index) {
                                    return

                                        //  padding: EdgeInsets.all(24),
                                        // decoration: BoxDecoration(
                                        //     color: Colors.orangeAccent,
                                        //     borderRadius:
                                        //         BorderRadius.all(Radius.circular(10))),
                                        ListTile(
                                      title: SelectableText.rich(
                                        TextSpan(
                                          text: newsdata!
                                              .chatList[index].chatName!,
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => Navigator.of(
                                                    context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        profilePage(
                                                            receiverID:
                                                                newsdata!
                                                                    .chatList[
                                                                        index]
                                                                    .chatID!))),
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontFamily: "NexaBold",
                                            fontSize: 16,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              children: extractText(': ' +
                                                  newsdata!.chatList[index]
                                                      .chatMessage!),
                                              style: Theme.of(context).textTheme.bodyLarge,
                                            ),
                                          ],
                                        ),
                                      ),
                                      //   SelectableText.rich(
                                      //   TextSpan(
                                      //     children: extractText(
                                      //
                                      //             newsdata!.chatList[index].chatMessage!),
                                      //     style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontFamily: "NexaBold",
                                      //       fontSize: 20,
                                      //     ),
                                      //   ),
                                      // ),

                                      // ]
                                      // ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(DateFormat('MM/dd/yyyy, hh:mm a')
                                              .format(newsdata!.chatList[index]
                                                  .chatTimestamp!
                                                  .toDate())
                                              .toString())
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              //    ),
                            ],
                          ),
                        ),
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                      ],
                    ),
                  ),
                ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  final textController = TextEditingController();
  final controller = ScrollController();

  @override
  void dispose() {
    textController.dispose();
    controller.dispose();
    super.dispose();
  }
}
