import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'AppBar.dart';
import 'dynamic_link.dart';

// class LinkData {
//   String? link;
//   LinkData (this.link);
// }


class Share_Screen extends StatefulWidget {
  String refLink;
  String messageLink;
  String title;

  Share_Screen(this.refLink,this.messageLink,this.title);

  @override
  State<Share_Screen> createState() => _Share_ScreenState();
}

class _Share_ScreenState extends State<Share_Screen> {
  var linkdata;
 // final _screenshotController = ScreenshotController();
  GlobalKey qrKey = GlobalKey();

GetLinkData() async {
  linkdata = 'gather.drba.org'+widget.refLink;
 // await dynamicLinkProvider()
 //      .createLink(widget.refLink)
 //      .then((value) {
 //   linkdata = value;
 // });
 return linkdata;
     }
  // void initState() {
  //   super.initState();
  //   Future.delayed(Duration(seconds: 0), () async {
  //   dynamicLinkProvider()
  //       .createLink(widget.refLink)
  //       .then((value) {
  //         link = value;
  //   });
  //   });
  // }


  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=935;

Widget build(BuildContext context) {
    return
      FutureBuilder(
          future: GetLinkData(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {

    return Scaffold(
      appBar: AppBars(AppLocalizations.of(context).share,'', context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Row(
            children: [
              isDesktop(context)
                  ?
              Expanded(child: Container())
                  :Container(),
              Expanded(
                child: Center(
                
                
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(widget.title+' '+AppLocalizations.of(context).qRCode,
                            textAlign: TextAlign.center,
                
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "NexaBold",
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                            ),),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        RepaintBoundary(
                          key: qrKey,
                
                          child: QrImageView(
                    data: linkdata!,
                        backgroundColor: Colors.white,
                        version: QrVersions.auto,
                        size: 300.0,
                    ),
                     ),
                        const SizedBox(
                          height: 32,
                        ),
                        SizedBox(
                          width: 270.0,
                          height: 50.0,
                          child: Builder(
                            builder: (BuildContext context) {
                              return ElevatedButton(
                                onPressed: (){
                                  final box = context.findRenderObject() as RenderBox?;
                                  Share.share(
                                    widget.messageLink+
                                        ' \n \n' +
                                        linkdata!,
                                    subject: AppLocalizations.of(context).dRBAAppSharing+widget.title,
                                    sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                
                                  //  padding: EdgeInsets.only(left: 23, right: 23, top: 0,bottom: 0),
                                    backgroundColor: Colors.grey[200],
                                    shape: const RoundedRectangleBorder(
                
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))) // Background color
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.share_outlined, color: Colors.black87),
                                    Text(AppLocalizations.of(context).sharelink,
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.black87,
                                            fontFamily: 'NexaBold')),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        kIsWeb?
                            Container()
                        :
                        SizedBox(
                          width: 270.0,
                          height: 50.0,
                          child: Builder(
                            builder: (BuildContext context) {
                              return ElevatedButton(
                                onPressed: () async {
                                  RenderRepaintBoundary boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
                                  var image = await boundary!.toImage();
                                  ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                                  Uint8List pngBytes = byteData!.buffer.asUint8List();
                                  final tempDir = await getTemporaryDirectory();
                                  final file = await new File('${tempDir?.path}/${widget.title}.png').create();
                                  await file.writeAsBytes(pngBytes);
                                  await Share.shareXFiles([XFile(file!.path)],    sharePositionOrigin:
                                  boundary!.localToGlobal(Offset.zero) & boundary.size, text: widget.title);
                                },
                                style: ElevatedButton.styleFrom(
                                  //  padding: EdgeInsets.only(left: 23, right: 23, top: 0,bottom: 0),
                                    backgroundColor: Colors.grey[200],
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))) // Background color
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_outlined, color: Colors.black87),
                                    Text(' '+AppLocalizations.of(context).share+AppLocalizations.of(context).qRCode,
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.black87,
                                            fontFamily: 'NexaBold')),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),
                ]
                    ),
                    
                ),
              ),
              isDesktop(context)
                  ?
              Expanded(child: Container())
                  :Container(),
            ],
          ),
        ),
      )
    );
  } else {
return Center(child: CircularProgressIndicator());
}
}
);
  }
}
