import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Firebase_API.dart';
import 'profilePage.dart';
import 'extractTextLinks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class Message {
  String? senderName;
  String? senderID;
  String? receiverName;
  String? receiverID;
  String? message;
  Timestamp? timestamp;

  Message({
    required this.senderName,
    required this.senderID,
    required this.receiverName,
    required this.receiverID,
    required this.timestamp,
    required this.message,

  });

  Map<String, dynamic> toMap() {
    return {
      'senderName': senderName,
      'senderID': senderID,
      'receiverName': receiverName,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp
    };
  }
}



class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage( String receiverName, String currentUserName,
      String message, String _receiverID, String _senderID, List<String> unreadMessagesSender,String receiverImage ) async {

    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderName: currentUserName,
        senderID: _senderID,
        receiverName: receiverName,
        receiverID: _receiverID,
        timestamp: timestamp,
        message:message
    );
    List<String> Names = [_senderID, _receiverID];
    Names.sort();
    String chatRoomID = Names.join("_");

    var receiverChatRooms = <String>[];
    var senderChatRooms = <String>[];

    await _fireStore.collection('chat_rooms').doc(chatRoomID).collection(
        'messages').add(newMessage.toMap());

    // await FirebaseFirestore.instance
    //     .collection('chat_rooms')
    //     .doc(chatRoomID)
    //     .get().then((chat)  async {
    //       unreadMessagesSender= await List.from(chat['Unread Messages From']);
    //   unreadMessagesSender.add(await _senderID);
    //
    // });


    await FirebaseFirestore.instance
        .collection('Students')
        .doc(_receiverID)
        .get().then((receiver)  async {
      receiverChatRooms=List.from(receiver['Chat Rooms']);

    }
    );
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(_senderID)
        .get().then((sender)  async {
      senderChatRooms=List.from(sender['Chat Rooms']);

    }

    );

    bool unreadMessage = true;
    bool _unreadMessage = false;

    await FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .set({
      '$_receiverID unread': unreadMessage,
      '$_senderID unread': _unreadMessage,
      '$_receiverID': receiverImage,

    });

//print(chatRoomID);

    if (receiverChatRooms.contains(chatRoomID)){

      await FirebaseFirestore.instance
          .collection("Students")
          .doc(_receiverID)
          .update({
        'Unread Messages': unreadMessage
      });

    }else {
      receiverChatRooms.add(chatRoomID);
      await FirebaseFirestore.instance
          .collection("Students")
          .doc(_receiverID)
          .update({
        'Chat Rooms': receiverChatRooms,
        'Unread Messages': unreadMessage
      });
    }
    if (senderChatRooms.contains(chatRoomID)){}else {
      senderChatRooms.add(chatRoomID);
      await FirebaseFirestore.instance
          .collection("Students")
          .doc(_senderID)
          .update({
        'Chat Rooms': senderChatRooms,

      });
    }
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    String friendID = userID;
    List<String> Names = [userID, otherUserID];
    Names.sort();
    String chatRoomID = Names.join("_");

    bool unread = false;

    try{
      _fireStore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .update({
        '$otherUserID unread': unread,
      });}catch(e){}


    _fireStore
        .collection("Students")
        .doc(otherUserID)
        .update({
      'Unread Messages': unread
    });

    return _fireStore.collection('chat_rooms').doc(chatRoomID).collection(
        'messages').orderBy('timestamp', descending: true)
    .snapshots();



  }

}


class chatPage extends StatefulWidget {
  final String receiverName;
  final String currentUserName;
  final String receiverID;

  chatPage(
      {super.key,required this.receiverName, required this.currentUserName, required this.receiverID});

  @override
  State<chatPage> createState() => _chatPageState();
}


class _chatPageState extends State<chatPage> {
  late String _currentUserName = widget.currentUserName;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  //final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid!;
  String? profileLink='';
  var unreadMessagesSender =<String>[];

  final ScrollController _controller = ScrollController();
  Map args = {};

  Future<String> getProfileData() async {
    final receiver = await FirebaseFirestore.instance
        .collection('Students')
        .doc(widget.receiverID)
        .get();
    if (receiver.exists) {
    String _imageLink=receiver['imageLink'];
    profileLink= _imageLink;
    } else {
   profileLink= 'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..';


    }    return profileLink!;

  }

  void sendMessage(String receiverProfileLink) async {

    String receiverName;
    if (_messageController.text.isNotEmpty) {

      if (widget.receiverName== widget.currentUserName)
      {
        setState(() {
          _currentUserName =' '+widget.currentUserName;
        });

    //  receiverName=widget.receiverName+' ';
      }else {

        setState(() {
          _currentUserName =widget.currentUserName;
        });    //  receiverName =widget.currentUserName;
      }
      await _chatService.sendMessage(
         widget.receiverName, _currentUserName, _messageController.text, widget.receiverID, currentUserID, unreadMessagesSender,receiverProfileLink);
      _messageController.clear();
    }
  }
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {


    return
      FutureBuilder<String>(
          future: getProfileData(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
        return Scaffold(
            appBar: AppBar(
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  profilePage(
                               receiverID: widget.receiverID)
                      ),
                    );
                  },
                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [

                      CircleAvatar(
                      //  radius: 64,
                        backgroundColor: Colors.white38,
                        backgroundImage: CachedNetworkImageProvider(profileLink!),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        child: Container(
                        //  padding: const EdgeInsets.all(8.0),
                          child: Text( ' '+widget.receiverName,
                          style: TextStyle(
                             // fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: 'NexaBold')),
                        ),
                      ),
                    ],
                  ),
                ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.0),
                  colors: <Color>[
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 0, 0, 0),
                  ],
                  stops: <double>[0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
            ),
            iconTheme:  IconThemeData(
              color: Colors.blueGrey[300]
            ),
            backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: _buildMessageList()),
                  _buildMessageInput(profileLink!),
                ],
              ),
            )


        );
    } else {
    return Center(child: CircularProgressIndicator());
    }
      }
    );
  }

  Widget _buildMessageList() {

    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverID, currentUserID),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Text(AppLocalizations.of(context).loading);
          }
          return Scrollbar(
            controller: _controller,
            child: ListView(
                reverse: true,
                controller: _controller,
                children: snapshot.data!.docs.map((document) =>
                    _buildMessageItem(document)).toList()),
          );
        }
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {


    Map<String, dynamic> data = document.data() as Map<String, dynamic>;


    var alignment = (data['senderID'] ==currentUserID)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return
      // Row(
      // children: [
 Container(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: (data['senderID'] ==currentUserID)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
                mainAxisAlignment: (data['senderID'] ==currentUserID)
                ? MainAxisAlignment.end
                    : MainAxisAlignment.start
                ,

                children: [
                  Text(data['senderName'],              style: TextStyle(
                    color: Colors.black,
                    fontFamily: "NexaBold",
                    fontSize: 17,
                  )),
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: (data['senderID'] ==currentUserID)

                      ? BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.all(Radius.circular(8)))
                      : BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(8))),

                      child: SelectableText.rich(
                  TextSpan(
                  children: extractText(data['message']),
                        style: TextStyle(
                      color: Colors.black,
                      fontFamily: "NexaBold",
                      fontSize: 17,)
                  ),
          )

                      //Text.rich(TextSpan(children: linkify(data['message'])))

                      // LinkWell(data['message'],
                      //     style: TextStyle(
                      //   color: Colors.black,
                      //   fontFamily: "NexaBold",
                      //   fontSize: 17,
                      // ))


                  ),
                  Text(DateFormat('MM/dd/yyyy, hh:mm a').format(data['timestamp'].toDate()).toString(),
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontFamily: 'NexaBold')
                  )

                ],
              ),
            ),
          )
        ;
        // isDesktop(context)
        //     ?
        // Expanded(child: Container())
        //     :Container(),
    //   ],
    // );
  }

  Widget _buildMessageInput(String _receiverProfileLink) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],

          border: Border.all(color: Colors.blueGrey),
          borderRadius:
          BorderRadius.all(
              Radius.circular(
                  8.0)),

        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const SizedBox(
              width: 13,
            ),
            Expanded(child: TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppLocalizations.of(context).writesomethinginthechat,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: "NexaBold",
                ),
                // enabledBorder: const OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: Colors.black,
                //   ),
                // ),
                // focusedBorder: const OutlineInputBorder(
                //     borderSide: BorderSide(
                //       color: Colors.black,
                //     )),
              ),
              onFieldSubmitted: (value){
                sendMessage(_receiverProfileLink);
                sendPushNotification(_messageController.text, widget.currentUserName, widget.receiverName,
                    currentUserID,widget.receiverID
                );
                _controller.jumpTo(_controller.position.minScrollExtent);
              },
            )

            ),
            IconButton(
                onPressed: () {
                    sendMessage(_receiverProfileLink);
                    sendPushNotification(_messageController.text, widget.currentUserName, widget.receiverName,
                        currentUserID,widget.receiverID
                    );
                    _controller.jumpTo(_controller.position.minScrollExtent);
                },
                icon: const Icon(Icons.send_outlined, size: 40
                  ,
                )
            ),
          ],
        ),
      ),
    );
  }

}

