import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/profilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'Firebase_API.dart';
import 'GroupInfoPage.dart';
import 'extractTextLinks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Message {
  String? senderName;
  String? senderEmail;
  String? senderID;
  String? message;
  Timestamp? timestamp;

  Message({
    required this.senderName,
    required this.senderEmail,
    required this.senderID,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderName': senderName,
      'senderEmail': senderEmail,
      'senderID': senderID,
      'message': message,
      'timestamp': timestamp
    };
  }
}

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String groupChatID, String currentUserName,
      String currentUserEmail, String currentUserID, String message) async {
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderName: currentUserName,
        senderEmail: currentUserEmail,
        senderID: currentUserID,
        timestamp: timestamp,
        message: message);

    await _fireStore
        .collection('Groups')
        .doc(groupChatID)
        .collection('group messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String _groupID) {
    return _fireStore
        .collection('Groups')
        .doc(_groupID)
        .collection('group messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

class groupChat extends StatefulWidget {
  final String groupID;
  final String currentUserName;
  final String groupName;

  groupChat({
    super.key,
    required this.groupID,
    required this.currentUserName,
    required this.groupName,
  });

  @override
  State<groupChat> createState() => _groupChatState();
}

class _groupChatState extends State<groupChat> {
  // late String _currentUserName = widget.currentUserName;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

//  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser!.email.toString();
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  String? profileLink =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/groups%2Fgroup.png?alt=media&token=f4b7d47b-df22-4cba-ab4c-e21a282d7b7a&_gl=1*1635uxj*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5NzIyMjU3OS41MDcuMS4xNjk3MjI0NTE5LjQ4LjAuMA..';
  var groupList = <String>[];

  final ScrollController _controller = ScrollController();
  Map args = {};

  Future<String> getGroupData() async {
    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupID)
        .get()
        .then((Groups) {
      //      setState(() {
      profileLink = Groups.get('groupimageLink');
      groupList = List.from(Groups.get('Group Members ID'));

      //   });
    });
    return profileLink!;
  }

  void sendMessage() async {
//    String receiverName;
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.groupID, widget.currentUserName,
          currentUserEmail, currentUserID, _messageController.text);
      _messageController.clear();
    }
  }

  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  // void initState() {
  //   super.initState();
  //
  // }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getGroupData(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title: GestureDetector(
                    onTap: () {
                      if (kIsWeb) {
                        GoRouter.of(context).go('/group${widget.groupID}');
                      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.android) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupInfoPage(
                              groupID: widget.groupID,
                              currentUserName: widget
                                  .currentUserName, // groupImage:  profileLink!
                            ),
                          ),
                        ).then((value) {
                          setState(() {});
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          //  radius: 64,
                          backgroundColor: Colors.white70,
                          backgroundImage:
                              CachedNetworkImageProvider(profileLink!),
                        ),
                        Expanded(
                          child: Container(
                            //  padding: const EdgeInsets.all(8.0),
                            child: Text(' ' + widget.groupName,
                                style: TextStyle(
                                    // fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  //  color: Colors.black,
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
                  iconTheme: IconThemeData(color: Colors.blueGrey[300]),
                  backgroundColor: Colors.transparent,
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(child: _buildMessageList()),
                      _buildMessageInput(),
                    ],
                  ),
                ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(widget.groupID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(AppLocalizations.of(context).loading);
          }
          return Scrollbar(
            controller: _controller,
            child: ListView(
                reverse: true,
                controller: _controller,
                children: snapshot.data!.docs
                    .map((document) => _buildMessageItem(document))
                    .toList()),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderName'] == widget.currentUserName)
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
          crossAxisAlignment: (data['senderName'] == widget.currentUserName)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderName'] == widget.currentUserName)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            // Text(data['senderName'],              style: TextStyle(
            //   color: Colors.black,
            //   fontFamily: "NexaBold",
            //   fontSize: 17,
            // )),
            SelectableText.rich(
              TextSpan(
                text: data['senderName'],
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          profilePage(receiverID: data['senderID']))),
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontFamily: "NexaBold",
                  fontSize: 20,
                ),
              ),
            ),

            Container(
                padding: const EdgeInsets.all(10),
                decoration: (data['senderName'] == widget.currentUserName)
                    ? BoxDecoration(
                        color: Colors.greenAccent[100],
                        borderRadius: BorderRadius.all(Radius.circular(8)))
                    : BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                child: SelectableText.rich(
                  TextSpan(
                      children: extractText(data['message']),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "NexaBold",
                        fontSize: 17,
                      )),
                )),
            Text(
                DateFormat('MM/dd/yyyy, hh:mm a')
                    .format(data['timestamp'].toDate())
                    .toString(),
                style: TextStyle(
                    fontSize: 10, color: Colors.grey, fontFamily: 'NexaBold'))
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.blueGrey),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 13,
            ),
            Expanded(
                child: TextFormField(
              controller: _messageController,
              style: TextStyle(color: Colors.black),
                  textCapitalization: TextCapitalization.sentences,

                  decoration: InputDecoration(
                fillColor: Colors.grey[100],

                border: InputBorder.none,
                hintText:
                    AppLocalizations.of(context).writesomethinginthegroupchat,
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
              onFieldSubmitted: (value) {
                sendMessage();

                sendGroupChatPushNotification(
                    groupList,
                    _messageController.text,
                    widget.currentUserName,
                    widget.groupName,
                    widget.groupID,
                    currentUserID);
              },
            )),
            IconButton(
                onPressed: () {
                  sendMessage();
                  sendGroupChatPushNotification(
                      groupList,
                      _messageController.text,
                      widget.currentUserName,
                      widget.groupName,
                      widget.groupID,
                      currentUserID);
                },
                icon: const Icon(
                  color: Colors.blueGrey,

                  Icons.send_outlined,
                  size: 40,
                )),
          ],
        ),
      ),
    );
  }
}
