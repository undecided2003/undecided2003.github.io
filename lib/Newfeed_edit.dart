import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as i;
import 'AppBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditNewsfeed extends StatefulWidget {
  String newsID;

  EditNewsfeed({super.key, required this.newsID});
  @override
  State<EditNewsfeed> createState() => _EditNewsfeedState();
}

class _EditNewsfeedState extends State<EditNewsfeed> {
  final newsNameController = TextEditingController();
  final storyController = TextEditingController();
  CroppedFile? _image;
  String _newsImage =
      'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/newsfeed%2Fdharma-news.png?alt=media&token=6d592125-dd0d-4b00-846d-9f019cf6b09b&_gl=1*1r2li0u*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODczNTg3MS41NjMuMS4xNjk4NzM2MjUzLjQyLjAuMA..';

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
        maxHeight: 250,
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

  @override
  void dispose() {
    newsNameController.dispose();
    storyController.dispose();
    super.dispose();
  }

  TimeOfDay _time = TimeOfDay.now();
  DateTime dateTime = DateTime.now();

  Future<void> PostNews() async {
    String imageUrl = _newsImage;

    final FirebaseStorage _storage = FirebaseStorage.instance;
    Future<String> UploadImageToStorage(String _newsId, CroppedFile file) async {
      Reference ref = _storage.ref().child('newsfeed').child(_newsId);
      PickedFile localFile = PickedFile(file.path);
      Uint8List bytes = await localFile.readAsBytes();
      UploadTask uploadTask = ref.putData(bytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }



        if (_image != null) {
          imageUrl = await UploadImageToStorage(widget.newsID, _image!);
        }
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });
        await FirebaseFirestore.instance.collection("Newsfeed").doc(widget.newsID)
            .update({
          'News Name': newsNameController.text,
          'Story': storyController.text,
          'Time': Timestamp.now(),
          'imageLink': imageUrl,


        });
    Navigator.pop(context);

    Navigator.pop(context);
  }
  getNewsData() async {
    await FirebaseFirestore.instance
        .collection('Newsfeed')
        .doc(widget.newsID)
        .get()
        .then((news) async {
      setState(() {
        _newsImage = news.get('imageLink');
        newsNameController.text = news.get('News Name');
        storyController.text = news.get('Story');

      });

//print(isMember);
    });
  }
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getNewsData();
    });
  }

  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;

  Widget build(BuildContext context) {
    // address = ModalRoute.of(context)!.settings.arguments as String?;
    // locationController.text = '$address';

    void _showDatePicker() {
      showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2040))
          .then((value) {
        setState(() {
          dateTime = value!.add(Duration(hours: 12));
        });
      });
    }

    void _showTimePicker() {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      ).then((value) {
        setState(() {
          _time = value!;
        });
      });
    }

    // dateController.text =
    //     DateFormat('EEE, MM/dd/yyyy').format(dateTime).toString();

    return Scaffold(
        appBar: AppBars(AppLocalizations.of(context).edit,'', context),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: SafeArea(
            child: Row(
              children: [        isDesktop(context)
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
                          height: 210.0,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
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
                            : Container(
                          width: double.infinity,
                          height: 210,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(_newsImage),
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
                    Text(AppLocalizations.of(context).dRBANewsfeed,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                         //  color: Colors.black,
                            fontFamily: 'NexaBold')),
                    const SizedBox(
                      height: 24,
                    ),
            
                    Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).headline,
                              style: TextStyle(
                              //  color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: newsNameController,
                            textCapitalization: TextCapitalization.words ,
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
                              AppLocalizations.of(context).story,
                              style: TextStyle(
                             //   color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: storyController,
                            textCapitalization: TextCapitalization.sentences ,
                            maxLines: 5,
                            minLines: 5,
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
                              await PostNews();
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
                            await PostNews();
            
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
                            //      color: Colors.grey[800],
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
