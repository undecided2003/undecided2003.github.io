import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'showErrorMessage.dart';
import 'AppBar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class addInspire extends StatefulWidget {

  addInspire({super.key});

  @override
  State<addInspire> createState() => _addInspireState();
}

class _addInspireState extends State<addInspire> {
  final inspireController = TextEditingController();


  @override
  void dispose() {
    inspireController.dispose();
    super.dispose();
  }



  Future<void> PostInspire() async {
        await FirebaseFirestore.instance.collection("Inspire").add({
          'inspire': inspireController.text,
        });
        Navigator.pop(context);
        showErrorMessage(context, AppLocalizations
            .of(context)
            .youaddedanewinspiration);
      }





  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery
          .of(context)
          .size
          .width >= 935;
@override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBars(AppLocalizations
            .of(context)
            .addInspiration,'', context),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              isDesktop(context)
                  ?
              Expanded(child: Container())
                  : Container(),
              Expanded(
                child: Column(children: [
                  const SizedBox(
                    height: 48,
                  ),
                  Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations
                                .of(context)
                                .enteraninspiration,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "NexaBold",
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: inspireController,
                          cursorColor: Colors.black,
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
                            await PostInspire();
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
                          await PostInspire();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      10))
                          ),
                          backgroundColor: Colors.grey[200], // Background color
                        ),
                        child: Text(AppLocalizations
                            .of(context)
                            .add,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey[800],
                                fontFamily: 'NexaBold')),
                      ),
                    ),
                  ),
                ]),
              ),
              isDesktop(context)
                  ?
              Expanded(child: Container())
                  : Container(),
            ],
          ),
        ));
  }
}
