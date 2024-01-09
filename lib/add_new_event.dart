import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'Firebase_API.dart';
import 'location_search_screen.dart';
import 'showErrorMessage.dart';
import 'AppBar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' as i;

class newEvent extends StatefulWidget {
  final String groupID;

  newEvent(
    this.groupID,
  );

  @override
  State<newEvent> createState() => _newEventState();
}

class _newEventState extends State<newEvent> {
  String? address;
  @override
  final eventNameController = TextEditingController();
  final locationController = TextEditingController();
  final linkController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final enddateController = TextEditingController();
  final endtimeController = TextEditingController();
  final descriptionController = TextEditingController();

  var _image;
  String _eventImage =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/events%2Fdharma_event.png?alt=media&token=95d81281-6780-4e68-9b72-64c220a32ef0&_gl=1*19oljci*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5NzQ0Nzc2OS41MTguMS4xNjk3NDUwNTM3LjUzLjAuMA..';
  bool isOnline = false;

  void selectImage() async {
    var _img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = _img;
    });
  }

  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    final ImageCropper _imageCropper = ImageCropper();

    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      CroppedFile? croppedfile = await _imageCropper.cropImage(
        aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
        maxWidth: 600,
        maxHeight: 335,
        sourcePath: _file!.path,
        compressQuality: 100,
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          // AndroidUiSettings(
          //     toolbarTitle: 'Cropper',
          //     toolbarColor: Colors.deepOrange,
          //     toolbarWidgetColor: Colors.white,
          //     initAspectRatio: CropAspectRatioPreset.original,
          //     lockAspectRatio: false),
          IOSUiSettings(
              rectHeight: 180,
              rectWidth: 320,
              rectX: 1000.0,
              rectY: 1000.0,
              aspectRatioLockEnabled: true),
          WebUiSettings(
              context: context,
              //presentStyle: CropperPresentStyle.dialog,
              boundary: const CroppieBoundary(
                width: 600,
                height: 335,
              ),
              viewPort: const CroppieViewPort(
                width: 600,
                height: 335,
              ),
              enableExif: true,
              enableZoom: true,
              showZoomer: true,
              enforceBoundary: true,
              mouseWheelZoom: true),
        ],
      );
      return await croppedfile;
    }
  }

  @override
  void dispose() {
    eventNameController.dispose();
    locationController.dispose();
    linkController.dispose();
    dateController.dispose();
    timeController.dispose();
    enddateController.dispose();
    endtimeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  TimeOfDay _time = TimeOfDay.now();
  DateTime dateTime = DateTime.now();
  TimeOfDay _endtime = TimeOfDay.now();
  DateTime enddateTime = DateTime.now();

  Future<void> postEvent() async {
    String imageUrl = _eventImage;
    final _username = <String>[];
    final _email = <String>[];
    final _id = <String>[];
    final chatIDList = <String>[];
    final chatNameList = <String>[];
    final chatMessageList = <String>[];
    final chatTimestampList = <Timestamp>[];
    // int? xweekly;
//    int j =0;

    final FirebaseStorage _storage = FirebaseStorage.instance;
    Future<String> uploadImageToStorage(
        String _eventId, CroppedFile file) async {
      Reference ref = _storage.ref().child('eventImage').child(_eventId);
      PickedFile localFile = PickedFile(file.path);
      Uint8List bytes = await localFile.readAsBytes();
      UploadTask uploadTask = ref.putData(bytes!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }

    if (DateTime(dateTime.year, dateTime.month, dateTime.day, _time.hour,
            _time.minute)
        .isBefore(DateTime(enddateTime.year, enddateTime.month, enddateTime.day,
            _endtime.hour, _endtime.minute))) {
      double _lat = .01;
      double _lng = .01;
      try {
        String latlng = locationController.text;
        latlng =
            latlng.substring(latlng.lastIndexOf('(') + 1, latlng.length - 1);
        String lat = latlng.substring(0, latlng.lastIndexOf(','));
        String lng =
            latlng.substring(latlng.lastIndexOf(',') + 1, latlng.length);
        _lat = double.parse(lat);
        _lng = double.parse(lng);
      } catch (e) {
        _lat = .01;
        _lng = .01;
      }

      if ((locationController.text.isNotEmpty &&
              _lat != 0.01 &&
              _lng != 0.01) ||
          linkController.text.isNotEmpty) {
        final currentUser = await FirebaseAuth.instance.currentUser!;
        await FirebaseFirestore.instance
            .collection('Students')
            .doc(currentUser.uid)
            .get()
            .then((Users) async {
          if (Users.exists) {
            _username.add(Users.get('Name'));
            _email.add(currentUser.email!);
            _id.add(currentUser.uid!);
            chatIDList.add(currentUser.uid);
            chatNameList.add(Users.get('Name'));
            chatMessageList.add(AppLocalizations.of(context)
                .pleaseaskquestionsorsharecommentshere);
            chatTimestampList.add(Timestamp.now());

            showDialog(
                context: context,
                builder: (context) {
                  return Center(child: CircularProgressIndicator());
                });
            DocumentReference docRef =
                await FirebaseFirestore.instance.collection("Events").add({
              'Location': locationController.text,
              'Link': linkController.text,
              'Event Name': eventNameController.text,
              'Time': DateTime(dateTime.year, dateTime.month, dateTime.day,
                  _time.hour, _time.minute),
              'End Time': DateTime(enddateTime.year, enddateTime.month,
                  enddateTime.day, _endtime.hour, _endtime.minute),

              'Is online': isOnline,
              'Description': descriptionController.text,
              //      'dateTime': Timestamp.fromDate(dateTime),
              'Student Name': _username,
              'UserID': _id,
              'chatID': chatIDList,
              'chatName': chatNameList,
              'chatMessage': chatMessageList,
              'chatTimestamp': chatTimestampList,
              'Group ID': widget.groupID,
            });
            if (_image != null) {
              imageUrl = await uploadImageToStorage(docRef.id, _image!);
            }
            await FirebaseFirestore.instance
                .collection("Events")
                .doc(docRef.id)
                .update({
              'imageLink': imageUrl,
            });

            var eventsList = <String>[];
            eventsList = List.from(Users.get('Events'));
            eventsList.add(docRef.id);

            await FirebaseFirestore.instance
                .collection("Students")
                .doc(currentUser.uid)
                .update({'Events': eventsList});
            var groupMembersIDList = <String>[];
            String groupName = '';
            if (widget.groupID != '') {
              await FirebaseFirestore.instance
                  .collection('Groups')
                  .doc(widget.groupID)
                  .get()
                  .then((Groups) async {
                //   print(widget.groupID);
                var groupEventsList = <String>[];
                groupEventsList = List.from(Groups.get('Group Events'));
                groupEventsList.add(docRef.id);
                groupMembersIDList = List.from(Groups.get('Group Members ID'));
                groupName = Groups.get('Group Name');
                await FirebaseFirestore.instance
                    .collection("Groups")
                    .doc(widget.groupID)
                    .update({'Group Events': groupEventsList});
              });
            }
            Navigator.pop(context);

            Navigator.pop(context);

            sendEventPushNotification(Users.get('Name'), isOnline, docRef.id,
                groupMembersIDList, eventNameController.text, groupName);
            showErrorMessage(context,
                AppLocalizations.of(context).youaddedanevent + docRef.id);
          }
        });
      } else {
        showErrorMessage(
            context, AppLocalizations.of(context).locationorlinkisinvalid);
      }
    } else {
      showErrorMessage(context,
          AppLocalizations.of(context).thestarttimecannotbeafterendtime);
    }
    //  dateTime=dateTime.add(const Duration(days: 7));
    //   j++;
    // }
  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1025;

  void updateTime() {}

  Widget build(BuildContext context) {
    // address = ModalRoute.of(context)!.settings.arguments as String?;
    // locationController.text = '$address';

    void _showDatePicker() {
      showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2040))
          .then((dynamic? value) {
        //print(value);

        setState(() {
          dateTime = value!.add(Duration(hours: 12));
        });
      });
    }

    void _showTimePicker() {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((dynamic? value) {
        //    print(value);
        setState(() {
          _time = value!;
        });
      });
    }

    void _showendDatePicker() {
      showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2040))
          .then((dynamic? value) {
        //print(value);

        setState(() {
          enddateTime = value!.add(Duration(hours: 12));
        });
      });
    }

    void _showendTimePicker() {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((dynamic? value) {
        //    print(value);
        setState(() {
          _endtime = value!;
        });
      });
    }

    timeController.text = _time.format(context).toString();

    endtimeController.text = _endtime.format(context).toString();

    dateController.text =
        DateFormat('EEE, MM/dd/yyyy').format(dateTime).toString();

    enddateController.text =
        DateFormat('EEE, MM/dd/yyyy').format(enddateTime).toString();

    return Scaffold(
        appBar: AppBars(
            AppLocalizations.of(context).createaDharmaEvent, '', context),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              isDesktop(context) ? Expanded(child: Container()) : Container(),
              Expanded(
                child: Column(children: [
                  Stack(
                    children: [
                      _image != null
                          ? Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                  //color: Colors.blueGrey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  image: kIsWeb
                                      ? DecorationImage(
                                          image: NetworkImage(_image!.path),
                                          fit: BoxFit.contain)
                                      : DecorationImage(
                                          image:
                                              FileImage(i.File(_image!.path)),
                                          fit: BoxFit.contain)),
                            )
                          : Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                //color: Colors.blueGrey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                image: DecorationImage(
                                  image: NetworkImage(_eventImage),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                      Positioned(
                        // bottom: -10,
                        //==left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          color: Colors.grey[300],
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),
                  Text(AppLocalizations.of(context).dRBANewEvent,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          //   color: Colors.black,
                          fontFamily: 'NexaBold')),
                  const SizedBox(
                    height: 24,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context).makeeventonline,
                                style: TextStyle(
                                  // color: Colors.black,
                                  fontFamily: "NexaBold",
                                ),
                              )),
                          SizedBox(
                            height: 55,
                            width: 65,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(
                                value: isOnline,
                                onChanged: (bool value) {
                                  setState(() {
                                    locationController.text = '';
                                    linkController.text = '';
                                    isOnline = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      isOnline
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context).uRLLink,
                                style: TextStyle(
                                  //  color: Colors.black,
                                  fontFamily: "NexaBold",
                                ),
                              ))
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context).location,
                                style: TextStyle(
                                  //  color: Colors.black,
                                  fontFamily: "NexaBold",
                                ),
                              )),
                      isOnline
                          ? Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: linkController,
                                //  cursorColor: Colors.black,
                                maxLines: 1,
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
                              ))
                          : Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: locationController,
                                onTap: () async {
                                  String locationroute = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SearchLocationScreen(
                                                'From New Event')),
                                  );
                                  locationController.text = locationroute;
                                },
                                // cursorColor: Colors.black,
                                maxLines: 1,
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
                              ),
                            ),
                    ],
                  ),
                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).eventName,
                            style: TextStyle(
                              // color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,

                          controller: eventNameController,
                          //  cursorColor: Colors.black,
                          maxLines: 1,
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
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).date,
                            style: TextStyle(
                              //    color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          onTap: (_showDatePicker),
                          controller: dateController,
                          // cursorColor: Colors.black,
                          maxLines: 1,
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
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).time,
                            style: TextStyle(
                              //   color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          onTap: (_showTimePicker),
                          controller: timeController,
                          //    cursorColor: Colors.black,
                          maxLines: 1,
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
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).enddate,
                            style: TextStyle(
                              //   color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          onTap: (_showendDatePicker),
                          controller: enddateController,
                          // cursorColor: Colors.black,
                          maxLines: 1,
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
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).endtime,
                            style: TextStyle(
                              //     color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          onTap: (_showendTimePicker),
                          controller: endtimeController,
                          //  cursorColor: Colors.black,
                          maxLines: 1,
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
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).description,
                            style: TextStyle(
                              //      color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,

                          controller: descriptionController,
                          //   cursorColor: Colors.black,
                          maxLines: 2,
                          minLines: 2,
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
                            await postEvent();
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
                          await postEvent();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          backgroundColor: Colors.grey[100], // Background color
                        ),
                        child: Text(AppLocalizations.of(context).add,
                            style: TextStyle(
                                fontSize: 25,
                                //  color: Colors.grey[800],
                                fontFamily: 'NexaBold')),
                      ),
                    ),
                  ),
                ]),
              ),
              isDesktop(context) ? Expanded(child: Container()) : Container(),
            ],
          ),
        ));
  }
}
