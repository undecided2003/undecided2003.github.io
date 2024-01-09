import 'dart:io' as i;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'AppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';

class editProfile extends StatefulWidget {
  final String currentUserID;

  editProfile({super.key, required this.currentUserID});

  @override
  State<editProfile> createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {
 // String cUEmail = '';
  CroppedFile? _image;
  String _profileLink =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..';

  void selectImage() async {
    CroppedFile _img = await pickImage(ImageSource.gallery, context);
    // File compressedFile = await FlutterNativeImage.compressImage(img.path,
    //   quality: 5,);
    //  Uint8List _img = img.readAsBytesSync();
    setState(() {
      _image = _img;
    });
  }

  getProfileData() async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    String _imageLink = _profileLink;

    await FirebaseFirestore.instance
        .collection('Students')
        .doc(currentUser.uid)
        .get()
        .then((student) async {
      String name = '';
      String interest = '';
      String bio = '';
      String activities = '';

      try{
        name = student.get('Auth Name');
      } catch (e)
      {

      }
      try{
        interest = student.get('Interest');
        bio =  student.get('Bio');
        _imageLink = student.get('imageLink');
        if(student.get('Name')!=''){ name = student.get('Name'); }

        activities = student.get('Activities');
      } catch (e)
      {

      }
      setState(() {
      //  cUEmail = currentUser.email!;
        nameController.text = name;
        interestedController.text = interest;
        bioController.text =bio;
        activitiesController.text =bio;

        _profileLink = _imageLink;
      });
    });
  }

  @override
  final nameController = TextEditingController();
  final interestedController = TextEditingController();
  final bioController = TextEditingController();
  final activitiesController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    interestedController.dispose();
    bioController.dispose();
    activitiesController.dispose();

    super.dispose();
  }

  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getProfileData();
    });
  }



  Future<void> saveProfile() async {
    String imageUrl = _profileLink;
    final FirebaseStorage _storage = FirebaseStorage.instance;

    Future<String> uploadImageToStorage(String _cUID, CroppedFile file) async {
      Reference ref = _storage.ref().child('profileImage').child(_cUID);
      PickedFile localFile = PickedFile(file.path);
      Uint8List bytes = await localFile.readAsBytes();
      UploadTask uploadTask = ref.putData(bytes!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }

    if (nameController.text.isNotEmpty && nameController.text!='Anonymous') {
      final currentUser = await FirebaseAuth.instance.currentUser!;

      if (_image != null) {
        imageUrl = await uploadImageToStorage(currentUser.uid, _image!);
      }
      await FirebaseFirestore.instance
          .collection("Students")
          .doc(currentUser.uid)
          .update({
        'Name': nameController.text,
        'Interest': interestedController.text,
        'Bio': bioController.text,
        'Activities': activitiesController.text,

        'imageLink': imageUrl,
        // 'file': _image!
      });

      Navigator.pop(context);
    } else {
      showErrorMessage(context, AppLocalizations.of(context).nonameentered);
    }
  }
  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBars(AppLocalizations.of(context).dRBAEditProfile,'', context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [  isDesktop(context)
                ?
            Expanded(child: Container())
                :Container(),
                Expanded(
                  child: Column(children: [
                    const SizedBox(
                      height: 6,
                    ),
                    Text(AppLocalizations.of(context).editProfile,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          //  color: Colors.black,
                            fontFamily: 'NexaBold')),
                    const SizedBox(
                      height: 24,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? Container(
                    height: 210,
                          decoration: BoxDecoration(
                         //  color: Colors.blueGrey,
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
                          height: 210,
                          decoration: BoxDecoration(
                             // color: Colors.blueGrey,
                              image: DecorationImage(
                                  image:  CachedNetworkImageProvider(_profileLink),
                                  fit: BoxFit.contain
                              )
                          ),
                        ),


                        Positioned(
                          bottom: 1,
                          left: 1,
                          child: IconButton(
                            color: Colors.grey,

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
                              AppLocalizations.of(context).name+':',
                              style: TextStyle(
                  //              color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,

                            //  onChanged: (value) {locationController.text = '$address';},
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
                        const SizedBox(
                          height: 20,
                        ),
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: Text(
                        //     'Email: ' + cUEmail,
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.black,
                        //       fontSize: 20,
                        //       fontFamily: "NexaBold",
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).whyareyouinterestedinBuddhism,
                              style: TextStyle(
                       //         color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: interestedController,
                            textCapitalization: TextCapitalization.sentences,
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
                          height: 20,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).whatactivitiesandpractices,
                              style: TextStyle(
                      //          color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: activitiesController,
                            textCapitalization: TextCapitalization.sentences,
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
                          height: 20,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).buddhismbackgroundandshortbio,
                              style: TextStyle(
                       //         color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: bioController,
                            maxLines: 3,
                            minLines: 3,
                            textCapitalization: TextCapitalization.sentences,
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
                              await saveProfile();
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
                            await saveProfile();
                            //    Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        10))
                            ) ,
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

pickImage(ImageSource source, context1) async {
  final ImagePicker _imagePicker = ImagePicker();
  final ImageCropper _imageCropper = ImageCropper();
 double width =MediaQuery.of(context1).size.width;

  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {

   CroppedFile? croppedfile= await _imageCropper.cropImage(
     aspectRatioPresets: [CropAspectRatioPreset.ratio16x9 ],
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
         context: context1,
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
//  print('No Images Selected');
}
