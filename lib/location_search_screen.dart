import 'dart:convert';
import 'package:drbaapp/showErrorMessage.dart';

import 'AppBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';

class SearchLocationScreen extends StatefulWidget {
  final String key1;
  SearchLocationScreen(this.key1);
  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  List<AutocompletePrediction> placePredictions = [];
  String? _lat;
  String? _long;
  String apiKey = 'AIzaSyATkm_B3odmcZ12hq-AICsLYY0z_UMczBQ';

  void placeAutocomplete(String query) async {
    String _sessionToken = '122344';

    var response;
    if (kIsWeb) {
      String baseURL = 'https://corsproxy.io/?' +
      Uri.encodeComponent('https://maps.googleapis.com/maps/api/place/autocomplete/json');
      String request =
          '$baseURL?input=$query&key=$apiKey&sessiontoken=$_sessionToken';
      response = await http.get(Uri.parse(request), headers: {
        "x-requested-with" : "XMLHttpRequest",
        "Access-Control-Allow-Origin": "*"
      });
    }
    else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {

      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$query&key=$apiKey&sessiontoken=$_sessionToken';
       response = await http.get(Uri.parse(request));

    }

    if (response.statusCode == 200) {
  //    print('search:' + response.body.toString());
    } else {
      showErrorMessage(context,AppLocalizations.of(context).notabletoconnect);
      //   print('did not connect:');
      throw Exception('Failed to load data');

    }
    if (response.body != null) {
      PlaceAutocompleteResponse result =
      PlaceAutocompleteResponse.parseAutocompleteResult(response.body);
      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  @override

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyATkm_B3odmcZ12hq-AICsLYY0z_UMczBQ",
//     baseUrl: kIsWeb
//         ? 'https://corsproxy.io/?' +
//         Uri.encodeComponent('https://maps.googleapis.com/maps/api')
//         : null,
// apiHeaders: {
//   "x-requested-with" : "XMLHttpRequest",
//   "Access-Control-Allow-Origin": "*"
// }
  );

  Future<Null> displayPrediction(String placePredictionsID) async {
    if (kIsWeb) {
      String baseURL = 'https://corsproxy.io/?' +
          Uri.encodeComponent('https://maps.googleapis.com/maps/api/place/details/json');
      String request =
          '$baseURL?placeid=$placePredictionsID&key=$apiKey';
      var response = await http.get(Uri.parse(request), headers: {
        "x-requested-with" : "XMLHttpRequest"
      });
      Map<String, dynamic> data = json.decode(response.body);
    //  PlacesDetailsResponse detail = await response.getDetailsByPlaceId(placePredictionsID);


      var location =
     data['result']['geometry']['location'];
      setState(() {
        _lat = location['lat'].toString();
        _long= location['lng'].toString();
      });

    }
    else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {

      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placePredictionsID);

       setState(() {
         _lat = detail.result.geometry!.location.lat.toString();
         _long= detail.result.geometry!.location.lng.toString();
       });

   }

    //  print(detail);

  }

  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBars(AppLocalizations.of(context).searchlocation,'', context),
      body: SafeArea(
        child: Row(
          children: [
            isDesktop(context)
                ?
            Expanded(child: Container())
                :Container(),
            Expanded(
              child: Column(
                children: [
                  Form(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        onChanged: (value) {
                          placeAutocomplete(value);
                        },
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText:AppLocalizations.of(context).searcheventlocation,
                          hintStyle: TextStyle(
                           // color: Colors.black,
                            fontFamily: "NexaBold",
                          ),
                          prefixIcon: (Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Icon(
                                Icons.pin_drop_outlined,
                              //  color: Color(0xFF585858),
                              ))),
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    height: 4,
                    thickness: 4,
                    color: Color(0xFFF8F8F8),
                  ),
                  Expanded(
                      child: ListView.builder(
                        itemCount: placePredictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () async {

                              String placePredictionsID = placePredictions[index].placeID!;
                              await displayPrediction(placePredictionsID);
                              Navigator.pop(context, placePredictions[index].description!+' ('+_lat!+','+_long!+')');
                            },
                            leading: Icon(
                              Icons.pin_drop_outlined,
                            //  color: Color(0xFF585858),
                            ),
                            title: Text(placePredictions[index].description!,
                                style: TextStyle(
                                //  color: Colors.black,
                                  fontFamily: "NexaBold",
                                )),
                          );
                        },
                      )
                  )
                ],
              ),
            ),
            isDesktop(context)
                ?
            Expanded(child: Container())
                :Container(),
          ],
        ),
      ),
    );
  }
}

class PlaceAutocompleteResponse {
  final String? status;
  final List<AutocompletePrediction>? predictions;

  PlaceAutocompleteResponse({this.status, this.predictions});

  factory PlaceAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteResponse(
      status: json['status'] as String?,
      predictions: json['predictions'] != null
          ? json['predictions']
          .map<AutocompletePrediction>(
              (json) => AutocompletePrediction.fromJson(json))
          .toList()
          : null,
    );
  }

  static PlaceAutocompleteResponse parseAutocompleteResult(
      String responseBody) {
    final parsed = json.decode(responseBody).cast<String, dynamic>();
    return PlaceAutocompleteResponse.fromJson(parsed);
  }
}

class AutocompletePrediction {
  final String? description;
  final StructuredFormatting? structuredFormatting;
  final String? placeID;
  final String? reference;
  final String? lat;
  final String? long;
  AutocompletePrediction({
    this.description,
    this.structuredFormatting,
    this.placeID,
    this.reference,
    this.lat,
    this.long,
  });

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json['description'] as String?,
      placeID: json['place_id'] as String?,
      reference: json['refernce'] as String?,
      lat: json['lat'] as String?,
      long: json['long'] as String?,
      structuredFormatting: json['structured_formatting'] != null
          ? StructuredFormatting.fromJson(json['structured_formatting'])
          : null,
    );
  }
}

class StructuredFormatting {
  /// [mainText] contains the main text of a prediction, usually the name of the place.
  final String? mainText;
  /// [secondaryText] contains the secondary text of a prediction, usually the location of the place.
  final String? secondaryText;
  StructuredFormatting({this.mainText, this.secondaryText});
  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
    );
  }
}

class Place {
  String? lat;
  String? lng;


  Place({
    this.lat,
    this.lng,
  });

  // Place.fromJson(Map<String, dynamic> json) {
  //   for (var component in json['geometry']) {
  //     var componentType = component["types"][0];
  //     switch (componentType) {
  //       case "street_number":
  //         lat = component['long_name'];
  //         break;
  //       case "route":
  //         lat = component['long_name'];
  //         break;
  //
  //     }
  //   }
  // }
}


