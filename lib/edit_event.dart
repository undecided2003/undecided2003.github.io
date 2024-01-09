import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'location_search_screen.dart';
import 'showErrorMessage.dart';
import 'AppBar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' as i;

class editEvent extends StatefulWidget {
  const editEvent({Key? key}) : super(key: key);

  @override
  State<editEvent> createState() => _editEventState();
}

class _editEventState extends State<editEvent> {
  String? address;
  DateTime dateTime = DateTime.now();
  TimeOfDay _time = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endtime = TimeOfDay.now();
  DateTime enddateTime = DateTime.now();

  String? eventID;
  CroppedFile? _image;
  String _eventImage =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/events%2Fdharma_event.png?alt=media&token=498da7c2-76c9-4ad9-8fde-68959b42d953&_gl=1*1ksuff4*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5NjIyMTE3NS40NzAuMS4xNjk2MjI1NDk1LjQ1LjAuMA..';
  bool isOnline = false;

  void selectImage() async {
    CroppedFile _img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = _img;
    });
  }

  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    final ImageCropper _imageCropper = ImageCropper();

    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {

      CroppedFile? croppedfile= await _imageCropper.cropImage(
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
              rectWidth:320,
              rectX:1000.0,
              rectY:1000.0,
              aspectRatioLockEnabled : true
          ),
          WebUiSettings(
              context: context,
              //presentStyle: CropperPresentStyle.dialog,
              boundary: const CroppieBoundary(
                width: 600,
                height: 335,
              ),
              viewPort:
              const CroppieViewPort(width: 600, height: 335, ),
              enableExif: true,
              enableZoom: true,
              showZoomer: true,
              enforceBoundary: true,
              mouseWheelZoom: true
          ),
        ],

      );
      // Uint8List _img = croppedfile!.readAsBytesSync();

      // var file = await FlutterNativeImage.compressImage(croppedfile!.path,
      //    quality: 100,);
      // Uint8List? file = await FlutterImageCompress.compressWithFile(
      //   croppedfile!.path,
      //   minHeight: 256,
      //   minWidth: 256,
      //   quality: 100,
      // );
      return await croppedfile;
    }
  }

  getEventData() async {
    int hh = 0;
    eventID = await ModalRoute.of(context)!.settings.arguments as String?;
    //  String _imageLink =_eventImage;
    await FirebaseFirestore.instance
        .collection('Events')
        .doc(eventID)
        .get()
        .then((events) {
      // _eventImage=events['imageLink'];

      setState(() {
        eventID = eventID;
        locationController.text = events['Location'];
        linkController.text = events['Link'];
        eventNameController.text = events['Event Name'];
        dateController.text = DateFormat('EEE, MM/dd/yyyy')
            .format(events.get('Time').toDate())
            .toString();
        dateTime = events.get('Time').toDate();
        timeController.text =
            DateFormat('hh:mm aa').format(events['Time'].toDate()).toString();
        enddateController.text = DateFormat('EEE, MM/dd/yyyy')
            .format(events.get('End Time').toDate())
            .toString();
        enddateTime = events.get('End Time').toDate();
        endtimeController.text =
            DateFormat('hh:mm aa').format(events['End Time'].toDate()).toString();
        isOnline = events['Is online'];

        if (DateFormat('hh:mm aa')
            .format(events.get('Time').toDate())
            .toString()
            .endsWith('PM')) {
          hh = 12;
        }

        String time = DateFormat('hh:mm aa')
            .format(events.get('Time').toDate())
            .toString()
            .split(' ')[0];
        _time = TimeOfDay(
          hour: hh + int.parse(time.split(":")[0]) % 24,
          // in case of a bad time format entered manually by the user
          minute: int.parse(time.split(":")[1]) % 60,
        );
        String endtime = DateFormat('hh:mm aa')
            .format(events.get('End Time').toDate())
            .toString()
            .split(' ')[0];
        _endtime = TimeOfDay(
          hour: hh + int.parse(endtime.split(":")[0]) % 24,
          // in case of a bad time format entered manually by the user
          minute: int.parse(endtime.split(":")[1]) % 60,
        );
        descriptionController.text = events['Description'];
        _eventImage = events['imageLink'];
      });
    });
  }

  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getEventData();
    });
  }

  @override
  final eventNameController = TextEditingController();
  final locationController = TextEditingController();
  final linkController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final descriptionController = TextEditingController();
  final enddateController = TextEditingController();
  final endtimeController = TextEditingController();


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

  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> postEvent() async {
    String imageUrl = _eventImage;

    final FirebaseStorage _storage = FirebaseStorage.instance;
    Future<String> uploadImageToStorage(String _eventId, CroppedFile file) async {
      Reference ref = _storage.ref().child('eventImage').child(_eventId);
      PickedFile localFile = PickedFile(file.path);
      Uint8List bytes = await localFile.readAsBytes();
     UploadTask uploadTask = ref.putData(bytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }
    double _lat = .01;
    double _lng = .01;
    if(DateTime(dateTime.year, dateTime.month, dateTime.day, _time!.hour, _time!.minute).isBefore(
        DateTime(enddateTime.year, enddateTime.month, enddateTime.day, _endtime.hour, _endtime.minute))
    ){
    try {
      String latlng = locationController.text;
      latlng =
          latlng.substring(latlng.lastIndexOf('(') + 1, latlng.length - 1);
      String lat = latlng.substring(0, latlng.lastIndexOf(','));
      String lng = latlng.substring(latlng.lastIndexOf(',') + 1, latlng.length);
      _lat = double.parse(lat);
      _lng = double.parse(lng);
    }catch (e) {
      _lat = .01;
      _lng = .01;
    }

    if ((locationController.text.isNotEmpty&& _lat!=0.01 && _lng!=0.01) ||linkController.text.isNotEmpty) {
      if (_image != null) {
        imageUrl = await uploadImageToStorage(eventID!, _image!);
      }
      showDialog(
          context: context,
          builder: (context) {
            return Center(child: CircularProgressIndicator());
          });
      await FirebaseFirestore.instance
          .collection("Events")
          .doc(eventID)
          .update({
        'Location': locationController.text,
        'Link': linkController.text,
        'Event Name': eventNameController.text,
        'Time': DateTime(dateTime.year, dateTime.month, dateTime.day, _time!.hour, _time!.minute),
        'End Time': DateTime(enddateTime.year, enddateTime.month, enddateTime.day, _endtime.hour, _endtime.minute),

        'Description': descriptionController.text,
        'imageLink': imageUrl,
        'Is online': isOnline,

        // 'dateTime': Timestamp.fromDate(dateTime!),
      });
      Navigator.pop(context);
      Navigator.pop(context);

    } else {
      showErrorMessage(context, AppLocalizations.of(context).locationorlinkisinvalid);
    }
    }else{

      showErrorMessage(context, AppLocalizations.of(context).thestarttimecannotbeafterendtime);

    }
  }
  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;

  Widget build(BuildContext context) {
    // address = ModalRoute.of(context)!.settings.arguments as String?;
    // locationController.text = '$address';

    void _showDatePicker() {
      showDatePicker(
              context: context,
              initialDate: dateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2040))
          .then((value) {
        setState(() {
          dateTime =  value!.add(Duration(hours: 12));
        });
      });
    }

    void _showTimePicker() {
      // final format = DateFormat.jm();
      showTimePicker(
        context: context,
        initialTime: _time,
      ).then((value) {
        setState(() {
          _time = value!;
        });
      });
    }

    void _showEndDatePicker() {
      showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2040))
          .then((value) {
        setState(() {
          enddateTime =  value!.add(Duration(hours: 12));
        });
      });
    }

    void _showEndTimePicker() {
      // final format = DateFormat.jm();
      showTimePicker(
        context: context,
        initialTime: _endtime!,
      ).then((value) {
        setState(() {
          _endtime = value!;
        });
      });
    }

      timeController.text = _time.format(context).toString();

      endtimeController.text = _endtime.format(context).toString();

      dateController.text =   DateFormat('EEE, MM/dd/yyyy').format(dateTime).toString();

      enddateController.text =   DateFormat('EEE, MM/dd/yyyy').format(enddateTime).toString();

    return Scaffold(
        appBar: AppBars(AppLocalizations.of(context).editEvent,'', context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(23),
            child: Row(
              children: [ isDesktop(context)
                  ?
              Expanded(child: Container())
                  :Container(),
                Expanded(
                  child: Column(children: [
                    Stack(
                      children: [
                        _image != null
                            ? Container(
                                width: double.infinity,
                                height: 211.0,
                                decoration: BoxDecoration(
                                 // color: Colors.blueGrey,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  image: kIsWeb ? DecorationImage(
                                      image: CachedNetworkImageProvider(_image!.path),
                                      fit: BoxFit.contain
                                  )
                                      :
                                  DecorationImage(
                                      image: FileImage(i.File(_image!.path)),
                                      fit: BoxFit.contain
                                  )
                                ),
                              )
                            :
                        Container(
                                width: double.infinity,
                                height: 211.0,
                                decoration: BoxDecoration(
                                 // color: Colors.blueGrey,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(_eventImage),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                        Positioned(
                          // bottom: -10,
                          //==left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            color: Colors.white70,
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),
                    Text(AppLocalizations.of(context).editEvent,
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
                        Row(children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context).makeeventonline,
                                style: TextStyle(
                           //       color: Colors.black,
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
                        ]),
                        isOnline
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppLocalizations.of(context).uRLLink,
                                  style: TextStyle(
                          //          color: Colors.black,
                                    fontFamily: "NexaBold",
                                  ),
                                ))
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppLocalizations.of(context).location,
                                  style: TextStyle(
                            //        color: Colors.black,
                                    fontFamily: "NexaBold",
                                  ),
                                )),
                        isOnline
                            ? Container(
                                margin: EdgeInsets.only(bottom: 12),
                                child: TextFormField(
                                  controller: linkController,
                             //     cursorColor: Colors.black,
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
                                              SearchLocationScreen('From Edit Event')),
                                    );
                                    locationController.text = locationroute;
                                  },
                                  //  onChanged: (value) {locationController.text = '$address';},
                        //          cursorColor: Colors.black,
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
                      //          color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: eventNameController,
                            textCapitalization: TextCapitalization.words,
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
                      //          color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            onTap: (_showDatePicker),
                            controller: dateController,
                    //        cursorColor: Colors.black,
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
                      //          color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            onTap: (_showTimePicker),
                            controller: timeController,
                      //      cursorColor: Colors.black,
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
                       //         color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            onTap: (_showEndDatePicker),
                            controller: enddateController,
                         //   cursorColor: Colors.black,
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
                        //        color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            onTap: (_showEndTimePicker),
                            controller: endtimeController,
                     //       cursorColor: Colors.black,
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
                     //           color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: descriptionController,
                            textCapitalization: TextCapitalization.sentences,
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

                            //    Navigator.pop(context);
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
                          child: Text( AppLocalizations.of(context).save,
                              style: TextStyle(
                                  fontSize: 25,
                           //       color: Colors.grey[800],
                                  fontFamily: 'NexaBold')),
                        ),
                      ),
                    ),
                  ]),
                ),
            isDesktop(context)
                ?
            Expanded(child: Container())
                :Container(),
              ],
            ),
          ),
        ));
  }
}
