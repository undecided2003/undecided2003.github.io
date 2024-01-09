import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'AppBar.dart';
import 'showErrorMessage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' as i;

class EditGroup extends StatefulWidget {
  final String _currentUserName;
  final String _currentUserId;
  final String _groupID;

  EditGroup(this._currentUserName,this._currentUserId,this._groupID);

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  bool ispublic = true;
  CroppedFile? _image;
  String _groupLink ='https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/groups%2Fgroup.png?alt=media&token=f4b7d47b-df22-4cba-ab4c-e21a282d7b7a&_gl=1*1635uxj*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5NzIyMjU3OS41MDcuMS4xNjk3MjI0NTE5LjQ4LjAuMA..';
  String groupname='';


  void selectImage() async {
    CroppedFile _img = await pickImage(ImageSource.gallery, context);

    setState(() {
      _image = _img;
    });
  }


  getGroupData() async {
    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget._groupID)
        .get()
        .then((Groups) async {

      setState(() {
        groupname=Groups.get('Group Name');
        _groupLink = Groups.get('groupimageLink');
        groupnameController.text = groupname;
        descriptionController.text = Groups.get('Description');
        volunteerNeedsController.text = Groups.get('Volunteer Needs');

        ispublic= Groups.get('Public');

      });

//print(isMember);
    });
  }

  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getGroupData();
    });
  }



  @override
  final groupnameController = TextEditingController();
  final descriptionController = TextEditingController();
  final volunteerNeedsController = TextEditingController();



  @override
  void dispose() {
    groupnameController.dispose();
    descriptionController.dispose();
    volunteerNeedsController.dispose();

    super.dispose();
  }


  Future<void> addGroup() async {
    bool grouptaken = false;
    await FirebaseFirestore.instance
        .collection('Groups')
        .get()
        .then((groupscheck) async {
      for (int i = 0; i < groupscheck.docs.length; i++) {
        if( groupnameController.text== groupscheck.docs[i]['Group Name']){
          grouptaken = true;
          i=groupscheck.docs.length-1;
        }
      }
    });
    if ((groupnameController.text.isNotEmpty && !grouptaken) ||groupnameController.text==groupname ) {
      String imageUrl = _groupLink;
      final FirebaseStorage _storage = FirebaseStorage.instance;
      Future<String> uploadImageToStorage(String _groupID,
          CroppedFile file) async {
        Reference ref = _storage.ref().child('groups').child(_groupID);
        PickedFile localFile = PickedFile(file.path);
        Uint8List bytes = await localFile.readAsBytes();
        UploadTask uploadTask = ref.putData(bytes);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }


      //    String _currentUserName = widget._currentUserName;
      String currentName = widget._currentUserName;

      if (currentName.contains('Anonymous') || currentName == '') {
        await FirebaseFirestore.instance
            .collection('Students')
            .doc(widget._currentUserId)
            .get()
            .then((Users) async {
          if (Users.exists) {
            try {
              currentName = await Users.get('Name');
            } catch (e) {
              if (await FirebaseAuth.instance.currentUser!.displayName !=
                  null) {
                currentName =
                await FirebaseAuth.instance.currentUser!.displayName!;
              }
            }
          }
        });
      }

      if (_image != null) {
        imageUrl = await uploadImageToStorage(widget._groupID, _image!);
      }
      showDialog(
          context: context,
          builder: (context) {
            return Center(child: CircularProgressIndicator());
          });
      await FirebaseFirestore.instance.collection("Groups").doc(widget._groupID)
          .update({
        'Group Name': groupnameController.text,
        'Description': descriptionController.text,
        'Volunteer Needs': volunteerNeedsController.text,
        'Public': ispublic,
        'groupimageLink': imageUrl,

      });
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      showErrorMessage(context,  AppLocalizations.of(context).groupnamealreadytakenornotentered);
      //  await Future.delayed(Duration(seconds: 1));
    }


  }


  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;

  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBars(AppLocalizations.of(context).editGroup,'', context),
        body: SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  isDesktop(context)
                      ?
                  Expanded(child: Container())
                      :Container(),
                  Expanded(
                    child: Column(children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Text(AppLocalizations.of(context).editGroup+'!',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                          //    color: Colors.black,
                              fontFamily: 'NexaBold')),
                      const SizedBox(
                        height: 24,
                      ),
                      Stack(
                        children: [
                          _image != null
                              ? Container(
                            height: 205,
                            decoration: BoxDecoration(
                                color: Colors.white38,
                                image:kIsWeb ? DecorationImage(
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
                            height: 205,
                            decoration: BoxDecoration(
                                color: Colors.white38,
                                image: DecorationImage(
                                  image:  CachedNetworkImageProvider(_groupLink),
                                    fit: BoxFit.contain
                                )
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: 1,
                            child: IconButton(
                              color: Colors.white70,

                              onPressed: selectImage,
                              icon: const Icon(Icons.add_a_photo),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(
                        height: 24,
                      ),
                      Column(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppLocalizations.of(context).groupName,
                                  style: TextStyle(
                                  //  color: Colors.black,
                                    fontFamily: "NexaBold",
                                  ),
                                )
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: groupnameController,
                                textCapitalization: TextCapitalization.words,

                                //  onChanged: (value) {locationController.text = '$address';},
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
                            const SizedBox(
                              height: 24,
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppLocalizations.of(context).description,
                                  style: TextStyle(
                                   // color: Colors.black,
                                    fontFamily: "NexaBold",
                                  ),
                                )
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: descriptionController,
                                textCapitalization: TextCapitalization.sentences,

                                //  onChanged: (value) {locationController.text = '$address';},
                              //  cursorColor: Colors.black,
                                maxLines: 2,
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

                            const SizedBox(
                              height: 24,
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppLocalizations.of(context).volunteerNeeds,
                                  style: TextStyle(
                                    // color: Colors.black,
                                    fontFamily: "NexaBold",
                                  ),
                                )
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: volunteerNeedsController,
                                textCapitalization: TextCapitalization.sentences,

                                //  onChanged: (value) {locationController.text = '$address';},
                                //  cursorColor: Colors.black,
                                maxLines: 2,
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
                                  await addGroup();
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                              Text(
                                      AppLocalizations.of(context).makeGroupPublic,
                                      style: TextStyle(
                                        fontSize: 16,
                                   //     color: Colors.black,
                                        fontFamily: "NexaBold",
                                      ),
                                    ),

                                const SizedBox(
                                  width: 16,
                                ),
                                SizedBox(
                                  height: 70,
                                  width: 95,
                                  child: FittedBox(
                                    fit: BoxFit.fill,

                                    child: Switch(

                                      value: ispublic,
                                      onChanged: (bool value) {
                                        setState(() {
                                          ispublic=value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: 275.0,
                              height: 50.0,
                              child: GestureDetector(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await addGroup();
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
                                  child: Text(AppLocalizations.of(context).save,
                                      style: TextStyle(
                                          fontSize: 25,
                                        //  color: Colors.grey[800],
                                          fontFamily: 'NexaBold')),
                                ),
                              ),
                            ),
                          ]),
                    ]),
                  ),
                  isDesktop(context)
                      ?
                  Expanded(child: Container())
                      :Container(),
                ],
              )
          ),
        ));
  }
}

pickImage(ImageSource source, context) async{
  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();

  XFile? _file = await _imagePicker.pickImage(source: source);
  if(_file != null){

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

    return await croppedfile;
  }
//  print('No Images Selected');
}

