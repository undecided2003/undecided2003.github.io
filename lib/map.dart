import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:map_launcher/map_launcher.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'AppBar.dart';
import 'main_page.dart';
import 'package:maps_launcher/maps_launcher.dart';


class map extends StatefulWidget {
  List<Monastery> nAmerica;
  List<Monastery> asia;
  List<Monastery> aussieEurope;

  map(this.nAmerica,this.asia,this.aussieEurope );
  @override
  State<map> createState() => _mapState();
}



class _mapState extends State<map> {

  late GoogleMapController myController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    var position = await GeolocatorPlatform.instance.getCurrentPosition();
    myController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(position.latitude, position.longitude),
        zoom: 11.5,
      ),
    ));

  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  getMarkerData() async {
    var mona;
    if (kIsWeb) {
     await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: const Size.square(60)), 'assets/monastery.png')
          .then((value) => mona = value);
    }
    else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
      mona = await getBytesFromAsset('assets/monastery.png', 110);
    }
        for (int i = 0; i < widget.nAmerica.length; i++) {
            Marker marker;
            MarkerId markerId1 = MarkerId('NA'+i.toString());

            marker = await Marker(
                markerId: markerId1,
                position: LatLng(widget.nAmerica[i].lat, widget.nAmerica[i].long),
                infoWindow: InfoWindow(title:widget.nAmerica[i].branch,
                  snippet: widget.nAmerica[i].address,
                    onTap: ()  {
                  //    if (kIsWeb) {
                     // await MapsLauncher.launchQuery( widget.nAmerica[i].branch);
                       MapsLauncher.launchCoordinates( widget.nAmerica[i].lat, widget.nAmerica[i].long, widget.nAmerica[i].branch);
                      // }
                      // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                      //   final availableMaps =
                      //   await MapLauncher.installedMaps;
                      //   await availableMaps.first.showMarker(
                      //     coords: Coords(
                      //         widget.nAmerica[i].lat, widget.nAmerica[i].long),
                      //     title: widget.nAmerica[i].branch,
                      //   );
                      // }
                    }
                ),
               icon:kIsWeb? mona:
               BitmapDescriptor.fromBytes(mona),
                onTap: ()  {
                  _showModal(context,<Monastery> [widget.nAmerica[i] ]);

                }
                );
            setState(() {
              markers[markerId1] = marker;
            });
        }
    for (int j = 0; j < widget.asia.length; j++) {
      Marker marker;
      MarkerId markerId2 = MarkerId('Asia'+j.toString());

      marker = await Marker(
        markerId: markerId2,
        position: LatLng(widget.asia[j].lat, widget.asia[j].long),
        infoWindow: InfoWindow(title:widget.asia[j].branch,
            snippet: widget.asia[j].address,
            onTap: ()  {

            //  if (kIsWeb) {
                MapsLauncher.launchCoordinates(  widget.asia[j].lat, widget.asia[j].long, widget.asia[j].branch,);
              // }
              // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
              //   final availableMaps =
              //   await MapLauncher.installedMaps;
              //   await availableMaps.first.showMarker(
              //     coords: Coords(
              //         widget.asia[j].lat, widget.asia[j].long),
              //     title: widget.asia[j].branch,
              //   );
              // }

              }
        ),
          icon:kIsWeb? mona:
          BitmapDescriptor.fromBytes(mona),
          onTap: ()  {
            _showModal(context,<Monastery> [widget.asia[j] ]);

          }
      );
      setState(() {
        markers[markerId2] = marker;
      });
    }
    for (int k = 0; k < widget.aussieEurope.length; k++) {
      Marker marker;
      MarkerId markerId3 = MarkerId('AusEu'+k.toString());

      marker = await Marker(
        markerId: markerId3,
        position: LatLng(widget.aussieEurope[k].lat, widget.aussieEurope[k].long),
        infoWindow: InfoWindow(title:widget.aussieEurope[k].branch,
            snippet: widget.aussieEurope[k].address,
            onTap: ()  {
           //   if (kIsWeb) {
                MapsLauncher.launchCoordinates( widget.aussieEurope[k].lat, widget.aussieEurope[k].long, widget.aussieEurope[k].branch,);
              // }
              // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
              //   final availableMaps =
              //   await MapLauncher.installedMaps;
              //   await availableMaps.first.showMarker(
              //     coords: Coords(
              //         widget.aussieEurope[k].lat, widget.aussieEurope[k].long),
              //     title: widget.aussieEurope[k].branch,
              //   );
              // }

        }
        ),
          icon:kIsWeb? mona:
          BitmapDescriptor.fromBytes(mona),
          onTap: ()  {
            _showModal(context,<Monastery> [widget.aussieEurope[k] ]);

          }
      );
      setState(() {
        markers[markerId3] = marker;
      });
    }
  }

  void _showModal(BuildContext context, List<Monastery> monastery) {
    showModalBottomSheet(
      context: context,
      //   isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return
          DraggableScrollableSheet( builder: (context, scrollController) {

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              child:Column(
                //    controller: scrollController,
                children: <Widget>[

                  Expanded(
                    child: Builder(
                        builder: (context) {
                          return ListView.builder(
                            shrinkWrap: true,
                            controller: scrollController,
                            itemCount: monastery.length,
                            itemBuilder: (_, index) {
                              return ListTile(
                                onTap: () async {
                                  if (monastery[index].website == '') {
                                    showErrorMessage(context,AppLocalizations.of(context).nowebsiteavailable);
                                  } else {
                                    await launchUrl(
                                        Uri.parse(monastery[index].website));
                                  }
                                },
                                leading: Container(padding: EdgeInsets.all(9),
                                    child: Image(image: AssetImage('assets/monastery.png'))),
                                title: Text(
                                    monastery[index].branch
                                    ,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "NexaBold",
                                    )),
                              );

                            },

                          );
                        }
                    ),
                  ),

                  Container(
                    color: Colors.grey[50],
                    child: ListTile(

                        minLeadingWidth: 50,
                        leading: Container(
                          //     color: Colors.red,
                            padding: EdgeInsets.all(15),
                            child: Icon(Icons.close,
                              color: Colors.black87,
                            )

                        ),
                        title: Text("Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: "NexaBold",
                            )
                        ),
                        onTap: () {Navigator.pop(context);}
                    ),
                  ),
                ],
              ),
            );
          });
      },
    );
//    future.then((void value) => _closeModal(value));
  }
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void initState() {
    _getUserLocation();
    getMarkerData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBars(AppLocalizations.of(context).locateBranches,'', context),
      body: SafeArea(
        child: Stack(children: <Widget>[
          GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(39.13294323200566, -123.16131907533915),
            zoom: 11.5,
          ),
          onMapCreated: (GoogleMapController controller) {
            myController = controller;
          },
          markers: Set<Marker>.of(markers.values),
        ),
        Container(
          margin: EdgeInsets.only(top: 15, left: 15),
          child: FloatingActionButton.extended(
            heroTag: "btn1",
            onPressed: _getUserLocation,
            label: Text(AppLocalizations.of(context).myLocation),
            icon: Icon(Icons.location_on),
          ),
        ),
        
        ]),
      ),
    );
  }
}
