import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'AppBar.dart';
import 'chat.dart';

class MyMessagesList {
  String? friend;
  String? friendID;
  String? message;
  Timestamp? timestamp;
  String? _currentUserName;
  bool? unreadMessage;
  String? chatImageLink;

  MyMessagesList(this.friend, this.friendID, this.message, this.timestamp,
      this._currentUserName, this.unreadMessage, this.chatImageLink);

  @override
  String toString() {
    return '{ ${this.friend},${this.friendID}, ${this.message}, ${this.timestamp},${this._currentUserName},${this.unreadMessage},${this.chatImageLink}}';
  }
}

class Chat_List extends StatefulWidget {
  String currentUserID;

  Chat_List(this.currentUserID, );
  @override
  State<Chat_List> createState() => _Chat_ListState();
}

class _Chat_ListState extends State<Chat_List> {
  var myMessagesList = <MyMessagesList>[];
  String messagetitleMessage = '';
  Future<List<MyMessagesList>> getMessages() async {

    var userChatRooms =<String>[];
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(widget.currentUserID)
        .get().then((student)  async {
      userChatRooms=List.from(student['Chat Rooms']);
    });
   // print(userChatRooms);


        for (int i = 0; i < userChatRooms.length; i++) {
          bool _unreadMessageList =false;
          String friend = '';
          String friendID = '';
          String _currentUserName = '';

       //   print(i);

          await FirebaseFirestore.instance.collection('chat_rooms').doc(userChatRooms[i]).collection(
              'messages')
              .get().then((messages)  async {
            Timestamp timestamp = messages.docs[0]['timestamp'];
            String message = messages.docs[0]['message'];
            String chatImage = '';
            for (int k = 0; k < messages.docs.length; k++) {
              if (widget.currentUserID ==
                  messages.docs[k]['receiverID']) {
                friend = messages.docs[k]['senderName'];
                friendID = messages.docs[k]['senderID'];
                message = messages.docs[k]['message'];
                timestamp = messages.docs[k]['timestamp'];
                _currentUserName = messages.docs[k]['receiverName'];
              } else if (widget.currentUserID ==
                  messages.docs[k]['senderID']) {
                friend = messages.docs[k]['receiverName'];
                friendID = messages.docs[k]['receiverID'];
                message = 'You: ' + messages.docs[k]['message'];
                timestamp = messages.docs[k]['timestamp'];
                _currentUserName = messages.docs[k]['senderName'];
              } else {
                friend = '';
              }
              //  print(i);

              if (friend != '' && myMessagesList.isEmpty) {
                //   setState(() {
                await FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .doc(userChatRooms[i])
                    .get().then((chats)  async {
                  String myUserID=widget.currentUserID;
                  try{
                    _unreadMessageList=chats['$myUserID unread'];
                    chatImage = chats[friendID];
                  }catch (e){}
                });
                myMessagesList.add(MyMessagesList(
                    friend, friendID, message, timestamp, _currentUserName,
                    _unreadMessageList,chatImage));
                //   });
              }
              for (int j = 0; j < myMessagesList.length; j++) {
                if (myMessagesList[j].friendID == friendID) {
                  friend = '';
                  if (timestamp.millisecondsSinceEpoch >
                      myMessagesList[j].timestamp!.millisecondsSinceEpoch) {
                    //   setState(() {
                    myMessagesList[j].message = message;
                    myMessagesList[j].timestamp = timestamp;
                    //    });
                  }
                }
              }


              if (friend != '') {
                await FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .doc(userChatRooms[i])
                    .get().then((chats)  async {
                  String myUserID=widget.currentUserID;
                  try{
                    _unreadMessageList=chats['$myUserID unread'];
                    chatImage = chats[friendID];
                  }catch (e){}
                });
                //   setState(() {
                myMessagesList.add(MyMessagesList(
                    friend, friendID, message, timestamp, _currentUserName,
                    _unreadMessageList,chatImage));
                //   });
              }
            }
          });
          // print(friend);
          // print(myMessagesList);
          // print(userChatRooms);
        }
   // print(friend);
   //  print(myMessagesList);
    if (myMessagesList.isEmpty) {
      //  setState(() {
      messagetitleMessage = AppLocalizations.of(context).youdonothaveanymessages;
      //    });
    }

    return myMessagesList;
  }


  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=935;

  Widget build(BuildContext context) {
    return    Scaffold(
    appBar: AppBars(AppLocalizations.of(context).dRBAMessages,'', context),
    body:SafeArea(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(messagetitleMessage,
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'NexaBold')),

          Expanded(
            child:
            FutureBuilder<List<MyMessagesList>>(
                future: getMessages(),
                builder: (context, snapshot) {
               // print(myMessagesList[index].unreadMessageList!);
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    myMessagesList.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
                    myMessagesList = myMessagesList.reversed.toList();

                    return ListView.builder(
                      //    shrinkWrap:true,

                      itemCount: myMessagesList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 0, left: 10, right: 10, bottom: 0),
                          child: Row(
                            children: [    isDesktop(context)
                                ?
                            Expanded(child: Container())
                                :Container(),
                              Expanded(
                                child: Container(
                                  //  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    // border: Border.all(
                                    //   color: Colors.grey,
                                    // ),
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      //String _receiverID='';
                                      // await FirebaseFirestore.instance.collection('Users').get().then((Users) {
                                      //
                                      //   for (int i = 0; i < Users.docs.length; i++) {
                                      //     if(myMessagesList[index].friendID! ==Users.docs[i]['Email'] ){
                                      //       // String profileLink = Users.docs[i]['imageLink'];
                                      //
                                      //       // setState(() {
                                      //       _receiverID = Users.docs[i].id;
                                      //       // });
                                      //       i = Users.docs.length;
                                      //     }
                                      //
                                      //   }
                                      // });

                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => chatPage(
                                            receiverName: myMessagesList[index].friend!,
                                            currentUserName:
                                            myMessagesList[index]._currentUserName!, receiverID: myMessagesList[index].friendID!),
                                      ))  .then((value) {
                                        setState(() {
                                       //   getMessages();
                                        });
                                      });
                                    },
                                    leading:myMessagesList[index].chatImageLink==''
                                        ?
                                      Icon(
                                        Icons.perm_identity_sharp,
                                        color: Colors.blueAccent,
                                      )
                                        :

                                    CircleAvatar(
                                      //   radius: 64,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: CachedNetworkImageProvider(
                                          myMessagesList[index].chatImageLink!
                                        //      _profileLink!.length > 0 ? _profileLink[index] : ''
                                      ),
                                    ),
                                    title:

                                    Stack(children: <Widget>[
                                      Text(
                                        myMessagesList[index].friend!,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "NexaBold",
                                          fontSize: 20,
                                        ),
                                      ),
                                      myMessagesList[index].unreadMessage!
                                          ?
                                      Positioned(
                                        // draw a red marble
                                        //top: 0.0,
                                        right: 0.0,
                                          child: Icon(Icons.brightness_1,
                                              size: 8.0, color: Colors.redAccent),
                                           )
                                          :Container()
                                    ]),
                                    subtitle: Wrap(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          myMessagesList[index].message!,
                                          style: TextStyle(
                                            color: Colors.lightBlue,
                                            fontFamily: "NexaBold",
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          '  (' +
                                              DateFormat('MM/dd/yyyy, hh:mm a')
                                                  .format(
                                                  myMessagesList[index].timestamp!.toDate())
                                                  .toString() +
                                              ')',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontFamily: "NexaBold",
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              isDesktop(context)
                                  ?
                              Expanded(child: Container())
                                  :Container(),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
            ),
          )
        ],
      ),
    ) );
}
}