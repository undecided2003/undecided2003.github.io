import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'showErrorMessage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Register extends StatefulWidget {
  final String email;
  final String password;
  final String language;

  const Register({super.key, required this.email,required this.password,required this.language});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  void initState() {
    super.initState();
    _emailController.text=widget.email;
    _passwordController.text=widget.password;
  }
  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;

  Widget build(BuildContext context) {
    return Scaffold(

    //  appBar: AppBars('Pickleball Time Register'),
      body:   SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child:Row(
          children: [
            isDesktop(context)
              ?
          Expanded(child: Container())
              :Container(),
            Expanded(
        
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Image(
                      color: Colors.grey,

                      image: AssetImage("assets/logo.png"),
                      height: 140.0,
                      width: 140,
                    ),
                    // Text(AppLocalizations.of(context).welcometoDRBA,
                    //     style: TextStyle(
                    //         fontSize: 25,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.black,
                    //         fontFamily: 'NexaBold')),
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                        AppLocalizations.of(context).register,
        
                        style: TextStyle( fontSize: 20,
                            color: Colors.grey[700])),
        
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).name,
                              style: TextStyle(
                             //   color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _nameController,
                            autofillHints: [AutofillHints.name],
                            textCapitalization: TextCapitalization.words ,
                            keyboardType: TextInputType.name,
                            cursorColor: Colors.black,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).name,
                              hintStyle: TextStyle(
                               // color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
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
                              AppLocalizations.of(context).email,
                              style: TextStyle(
                               // color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _emailController,
                            autofillHints: [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Colors.black,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText:  AppLocalizations.of(context).email,
                              hintStyle: TextStyle(
                            //    color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
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
                              AppLocalizations.of(context).password,
                              style: TextStyle(
                            //    color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _passwordController,
                            autofillHints: [AutofillHints.password],
              
                            obscureText: true,
                            cursorColor: Colors.black,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText:  AppLocalizations.of(context).password,
                              hintStyle: TextStyle(
                              //  color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
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
                              AppLocalizations.of(context).confirmpassword,
                              style: TextStyle(
                             //   color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: _confirmpasswordController,
                            autofillHints: [AutofillHints.password],
              
                            obscureText: true,
                            cursorColor: Colors.black,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText:    AppLocalizations.of(context).confirmpassword,
                              hintStyle: TextStyle(
                             //   color: Colors.black,
                                fontFamily: "NexaBold",
                              ),
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
                            onFieldSubmitted: (value){
                              signUp();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    //onTap: signUp,
                    SizedBox(
                      width: 275.0,
                      child: GestureDetector(
                        child: ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100], // Background color
                          ),
                          child: Text(   AppLocalizations.of(context).signup,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.grey[800],
                                  fontFamily: 'NexaBold')),
                        ),
                      ),
                    ),
                    SizedBox(height: 28),
                    GestureDetector(
                        onTap:    () {Navigator.of(context).pop();},
        
                        child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context).alreadyhaveanaccount,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "NexaBold",
                            color: Colors.grey[600],
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: ' '+AppLocalizations.of(context).loginNow,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontFamily: "NexaBold",
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                    ),
        
                  ],
                ),
              ),
        
            isDesktop(context)
                ?
            Expanded(child: Container())
                :Container()
          ],
        ), ),
      ),
    );
  }

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  void signUp() async {
    String name;
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return const Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   },
    // );
    try {
      if (_passwordController.text == _confirmpasswordController.text) {
        if (_passwordController.text.length >= 6) {

          if (_nameController.text.isNotEmpty) {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

            await FirebaseAuth.instance.currentUser!.updateDisplayName(
                _nameController.text);
            Navigator.of(context).pop();

            bool unread = false;
            bool appAdmin = false;

            await FirebaseFirestore.instance.collection("Students").doc(FirebaseAuth.instance.currentUser!.uid)
                .set(
                {
                  'Auth Name': _nameController.text,
                  'Email': _emailController.text.toLowerCase(),
                  'Token': 'abc',
                  'Groups': <String>[],
                  'Events':<String>[],
                  'Past Events': <String>[],
                  'imageLink': 'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..',
                  'Chat Rooms': <String>[],
                  'Unread Messages': unread,
                  'Language': widget.language,
                  'App Admin': appAdmin,
                  'Name': '',
                  'Interest': '',
                  'Activities': '',
                  'Bio': '',
                  'Meditation Goals': <int>[0,0],

                });


          }else{
            showErrorMessage(context,
                AppLocalizations.of(context).namecantbeempty);
          }

        } else {
          //   Navigator.of(context, rootNavigator: true).pop();
          showErrorMessage(context,
              AppLocalizations.of(context).passwordneedstobeatleastsixcharacters);
          //         Navigator.of(context, rootNavigator: true).pop();
        }
      } else {
        showErrorMessage(context, AppLocalizations.of(context).passwordsdontmatch);
        //   Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      showErrorMessage(context,e.code);
      //    Navigator.of(context, rootNavigator: true).pop();
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }
}
