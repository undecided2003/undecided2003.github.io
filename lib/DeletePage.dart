import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'showErrorMessage.dart';
import 'auth_service.dart';
import 'square_tile.dart';
import 'AppBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeletePage extends StatefulWidget {
//  final Function()? onTap;
  const DeletePage({Key? key}) : super(key: key);

  @override
  State<DeletePage> createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> with SingleTickerProviderStateMixin {
  String? userID = FirebaseAuth.instance.currentUser!.uid;
  String? profileLink = '';
  var groupList = <String>[];
  int screenState = 0;
  String phoneNumber = '';
  String verID = " ";
  String otpPin = " ";
  String email = '';
  late final tabController = TabController(length: 2, vsync: this);
  double containerHeight =900;
  String _Locale = 'en';

  Future<void> verifyPhone(String number) async {
    showDialog(context: context, builder: (context){
      return    Center(child: CircularProgressIndicator());
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) {
        Navigator.pop(context);

        showErrorMessage(context, AppLocalizations.of(context).authCompleted);
      },
      verificationFailed: (FirebaseAuthException e) {
        Navigator.pop(context);
        showErrorMessage(context, AppLocalizations.of(context).authFailed );
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.pop(context);
        showErrorMessage(context, AppLocalizations.of(context).confirmationCodeSent);
        verID = verificationId;
        setState(() {
          screenState = 1;
          phoneNumber = _phoneController.text;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showErrorMessage(context, AppLocalizations.of(context).timeout);
      },
    );
  }

  Future<void> verifyOTP(String _otpPin) async {
    await FirebaseAuth.instance
        .signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: verID,
        smsCode: _otpPin,
      ),
    )
        .whenComplete(() async {
      bool signinsuccess = true;
      if (signinsuccess) {
        await FirebaseFirestore.instance
            .collection('Students')
            .doc(userID)
            .get()
            .then((Users) async {
          if (Users.exists) {
            if (Users.get('imageLink') !=
                'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..') {
              profileLink = Users.get('imageLink');
              FirebaseStorage.instance.refFromURL(profileLink!).delete();
            }
            try {
              groupList = List.from(Users.get('Groups'));
            } catch (e) {}

            for (int j = 0; j < groupList.length; j++) {
              await FirebaseFirestore.instance
                  .collection("Groups")
                  .doc(groupList[j])
                  .get()
                  .then((Groups) async {
                var IdList = <String>[];
                var adminsList = List.from(Groups.get('Admins'));

                try {
                  IdList = List.from(Groups.get('Group Members ID'));
                } catch (e) {}

                for (int i = 0; i < IdList.length; i++) {
                  if (IdList[i] == userID) {
                    IdList.remove(userID);
                    adminsList.remove(userID);
                  }
                }
                await FirebaseFirestore.instance
                    .collection('Groups')
                    .doc(groupList[j])
                    .update({
                  'Admins': adminsList,
                  'Group Members ID': IdList
                });
              });
            }
          }
        });

        await FirebaseFirestore.instance
            .collection('Students')
            .doc(userID)
            .delete();
        await FirebaseAuth.instance.currentUser!.delete();
        await FirebaseAuth.instance.signOut();
        Navigator.pop(context);
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) => Welcome(),
      } // ));
    });
  }

  bool isOnlyNumber(String str) {
    try {
      var value = int.parse(str);
      return true;
    } on FormatException {
      return false;
    }
  }

  // Future<void> _signInWithApple(BuildContext context) async {
  //   try {
  //     final authService = Provider.of<AuthService>(context, listen: false);
  //     final user = await authService.signInWithApple(context, 'en');
  //   } catch (e) {
  //     // TODO: Show alert here
  //     print(e);
  //   }
  // }

  void initState() {
    super.initState();
    //  _phoneController.text = '+1';
    tabController.addListener(() {
      if(tabController.indexIsChanging) {
        setState(() {});}
    });

  }


  Future<double> Getdata()
  async {
    _emailController.clear();
    _passwordController.clear();
    _phoneController.text = '+1';
    containerHeight =  900;

    if (tabController.index==1&& screenState!=1) {
      screenState =  0;

    } else if (tabController.index==0 ){
      screenState =  2;

    }
    return containerHeight;
  }
  @override
  bool isDesktop(BuildContext context)=>MediaQuery.of(context).size.width>=1025;

  Widget build(BuildContext context) {
    return FutureBuilder<double>(
        future: Getdata(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
    return Scaffold(

      appBar: AppBars(AppLocalizations.of(context).deleteAccount,'', context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [    isDesktop(context)
                ?
            Expanded(child: Container())
                :Container(),
              Expanded(
                child: Container(
                  height: containerHeight,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Image(
                        color: Colors.grey[600],

                        image: AssetImage("assets/logo.png"),
                        height: 140.0,
                        width: 140,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(AppLocalizations.of(context).signinonelasttimeifyouwanttodeleteyouraccount,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontFamily: 'NexaBold')),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          // color: Colors.grey[100],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: TabBar(controller: tabController,
                            dividerColor:Colors.transparent,
                            indicator:  BoxDecoration(
                              border: Border.all(
                                  color:  Colors.black
                              ),
                              color: Colors.grey[400],
                            ),
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey[600],
                            tabs: [
                          Tab(
                            child: Container(
                              child: Center(
                                  child: Text(AppLocalizations.of(context).emailAddress,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                       //   color: Colors.black,
                                          fontFamily: 'NexaBold'))),
                            ),
                          ),
                          Tab(
                            child: Container(
                              child: Center(
                                  child: Text(AppLocalizations.of(context).phoneNumber,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                       //   color: Colors.black,
                                          fontFamily: 'NexaBold'))),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: TabBarView(controller: tabController, children: [
                          SigninWithEmail()
                          ,
                          SigninWithPhoneNumber(),
                        ]),
                      ),
                      // screenState == 0 || screenState == 1
                      //     ? screenState == 0
                      //
                      //         : stateOTP()
                      //     : statePassword(),

                      screenState == 0
                          ? SizedBox(
                        width: 275.0,
                        height: 50.0,
                        child: GestureDetector(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_phoneController.text.isEmpty ||
                                  _phoneController.text == '+1') {
                                showErrorMessage(
                                    context, AppLocalizations.of(context).phoneNumber);
                              } else if (isOnlyNumber(_phoneController.text
                                  .replaceAll('+', ''))) {

                                verifyPhone(_phoneController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10))
                              ),
                              backgroundColor:
                              Colors.grey[100], // Background color
                            ),
                            child: Text(AppLocalizations.of(context).continue1,
                                style: TextStyle(
                                    fontSize: 25,
                                   // color: Colors.grey[800],
                                    fontFamily: 'NexaBold')),
                          ),
                        ),
                      )
                          :screenState == 1 ?
                      SizedBox(
                        width: 275.0,
                        height: 50.0,
                        child: GestureDetector(
                          child: ElevatedButton(
                            onPressed: () {
                              otpPin = _verificationController.text;
                              if (otpPin.length >= 6) {
                                verifyOTP(otpPin);
                              } else {
                                showErrorMessage(
                                    context, AppLocalizations.of(context).entercodecorrectly);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10))
                              ),
                              backgroundColor:
                              Colors.grey[100], // Background color
                            ),
                            child: Text(AppLocalizations.of(context).delete,
                                style: TextStyle(
                                    fontSize: 25,
                                  //  color: Colors.grey[800],
                                    fontFamily: 'NexaBold')),
                          ),
                        ),
                      )
                          : Column(
                        children: [
                          SizedBox(
                            width: 275.0,
                            height: 50.0,
                            child: GestureDetector(
                              child: ElevatedButton(
                                onPressed: () {
                                  signIn();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              10))
                                  ),
                                  backgroundColor:
                                  Colors.grey[100], // Background color
                                ),
                                child: Text(AppLocalizations.of(context).delete,
                                    style: TextStyle(
                                        fontSize: 25,
                                      //  color: Colors.grey[800],
                                        fontFamily: 'NexaBold')),
                              ),
                            ),
                          ),

                              ],
                            ),
                      const SizedBox(
                        height: 50,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              )),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(AppLocalizations.of(context).orsigninwith,
                              //      style: TextStyle(color: Colors.grey[700])
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                thickness: 0.5,
                            color: Colors.grey[400],
                              ))
                            ],
                          )),
                      SizedBox(height: 30),
                      Column(

                        children: [
                          SizedBox(
                            width: 320.0,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(

                                backgroundColor: Colors
                                    .grey[100], // Background color
                              ),
                              onPressed: () async {
                               await AuthService().signInWithGoogle(_Locale);
                                await FirebaseFirestore.instance
                                    .collection('Students')
                                    .doc(userID)
                                    .get()
                                    .then((Users) async {
                                  if (Users.exists) {
                                    if (Users.get('imageLink') !=
                                        'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..')
                                    {
                                      profileLink = Users.get('imageLink');
                                      FirebaseStorage.instance
                                          .refFromURL(profileLink!)
                                          .delete();
                                    }
                                    try {
                                      groupList = List.from(Users.get('Groups'));
                                    } catch (e) {}

                                    for (int j = 0; j < groupList.length; j++) {
                                      await FirebaseFirestore.instance
                                          .collection("Groups")
                                          .doc(groupList[j])
                                          .get()
                                          .then((Groups) async {

                                        var IdList = <String>[];
                                        var adminsList = List.from(Groups.get('Admins'));

                                        try {
                                          IdList =
                                              List.from(Groups.get('Group Members ID'));
                                        } catch (e) {}

                                        for (int i = 0; i < IdList.length; i++) {
                                          if (IdList[i] == userID) {
                                            IdList.remove(userID);
                                            adminsList.remove(userID);
                                          }
                                        }
                                        await FirebaseFirestore.instance
                                            .collection('Groups')
                                            .doc(groupList[j])
                                            .update({
                                          'Admins': adminsList,
                                          'Group Members ID': IdList
                                        });
                                      });
                                    }
                                  }
                                });

                                await FirebaseFirestore.instance
                                    .collection('Students')
                                    .doc(userID)
                                    .delete();
                                await FirebaseAuth.instance.currentUser!.delete();
                                await FirebaseAuth.instance.signOut();
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:  [
                                    Image(
                                      image: AssetImage("assets/google.png"),
                                      height: 18.0,
                                      width: 24,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 24, right: 8),
                                      child: Text(
                                        AppLocalizations.of(context).signinusingGoogle,
                                        style: TextStyle(
                                          fontSize: 18,
                                          // color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          SizedBox(
                            width: 320.0,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .grey[100], // Background color
                              ),
                              onPressed: () async {
                               await AuthService().signInWithApple1(_Locale);
                                await FirebaseFirestore.instance
                                    .collection('Students')
                                    .doc(userID)
                                    .get()
                                    .then((Users) async {
                                  if (Users.exists) {
                                    if (Users.get('imageLink') !=
                                        'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..')
                                    {
                                      profileLink = Users.get('imageLink');
                                      FirebaseStorage.instance
                                          .refFromURL(profileLink!)
                                          .delete();
                                    }

                                    groupList = List.from(Users.get('Groups'));


                                    for (int j = 0; j < groupList.length; j++) {
                                      await FirebaseFirestore.instance
                                          .collection("Groups")
                                          .doc(groupList[j])
                                          .get()
                                          .then((Groups) async {

                                        var IdList = <String>[];
                                        var adminsList = List.from(Groups.get('Admins'));

                                        try {
                                          IdList =
                                              List.from(Groups.get('Group Members ID'));
                                        } catch (e) {}

                                        for (int i = 0; i < IdList.length; i++) {
                                          if (IdList[i] == userID) {
                                            IdList.remove(userID);
                                            adminsList.remove(userID);
                                          }
                                        }
                                        await FirebaseFirestore.instance
                                            .collection('Groups')
                                            .doc(groupList[j])
                                            .update({
                                          'Admins': adminsList,
                                          'Group Members ID': IdList
                                        });
                                      });
                                    }
                                  }
                                });

                                await FirebaseFirestore.instance
                                    .collection('Students')
                                    .doc(userID)
                                    .delete();
                                await FirebaseAuth.instance.currentUser!.delete();
                                await FirebaseAuth.instance.signOut();
                                Navigator.pop(context);
                                // Navigator.of(context).push(MaterialPageRoute(
                                //   builder: (context) => Welcome(),
                                // ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:  [
                                    Image(
                                      image: AssetImage("assets/apple.png"),
                                      height: 18.0,
                                      width: 24,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 24, right: 8),
                                      child: Text(
                                        AppLocalizations.of(context).signinusingApple,
                                        style: TextStyle(
                                          fontSize: 18,
                                          //     color: Colors.black54,
                                          fontWeight: FontWeight.w600,

                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),

                    ],
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
      ),
    );  } else {
  return Center(
  child: CircularProgressIndicator()
  );
  }}
    );
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _verificationController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void signIn() async {
    bool signinsuccess = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
//        Navigator.of(context, rootNavigator: true).pop();
    } on FirebaseAuthException catch (e) {
      signinsuccess = false;
      showErrorMessage(context, e.code);
    }
    if (signinsuccess) {
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(userID)
          .get()
          .then((Users) async {
        if (Users.exists) {
          if (Users.get('imageLink') !=
              'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..')
          {
            profileLink = Users.get('imageLink');
            FirebaseStorage.instance.refFromURL(profileLink!).delete();
          }
          try {
            groupList = List.from(Users.get('Groups'));
          } catch (e) {}

          for (int j = 0; j < groupList.length; j++) {
            await FirebaseFirestore.instance
                .collection("Groups")
                .doc(groupList[j])
                .get()
                .then((Groups) async {
              var IdList = <String>[];
              var adminsList = List.from(Groups.get('Admins'));

              try {
                IdList = List.from(Groups.get('Group Members ID'));
              } catch (e) {}

              for (int i = 0; i < IdList.length; i++) {
                if (IdList[i] == userID) {
                  IdList.remove(userID);
                  adminsList.remove(userID);
                }
              }
              await FirebaseFirestore.instance
                  .collection('Groups')
                  .doc(groupList[j])
                  .update({
                'Admins': adminsList,
                'Group Members ID': IdList
              });
            });
          }
        }
      });

      await FirebaseFirestore.instance
          .collection('Students')
          .doc(userID)
          .delete();
      await FirebaseAuth.instance.currentUser!.delete();
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      // Navigator.of(context).push(MaterialPageRoute(
      //   builder: (context) => Welcome(),
      // ));
    }
  }

  Widget stateOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: AppLocalizations.of(context).wejustsentacodeto,
                style: TextStyle(
                 // color: Colors.black,
                  fontFamily: "NexaBold",
                ),
              ),
              TextSpan(
                text: phoneNumber,
                style: TextStyle(
               //   color: Colors.black,
                  fontFamily: "NexaBold",
                ),
              ),
              TextSpan(
                text: "\n"+AppLocalizations.of(context).enterthecodeheretodelete,
                style: TextStyle(
               //   color: Colors.black,
                  fontFamily: "NexaBold",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: _verificationController,
          // onChanged: (value) {
          //   setState(() {
          //     otpPin = value;
          //   });
          // },
        //  cursorColor: Colors.black,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).enterConfirmationCode,
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
        const SizedBox(
          height: 10,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:AppLocalizations.of(context).didntreceivethecode,
                style: TextStyle(
              //    color: Colors.black,
                  fontFamily: "NexaBold",
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      screenState = 0;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context).goBack,
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontFamily: "NexaBold",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget SigninWithEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context).email,
              style: TextStyle(
             //   color: Colors.black,
                fontFamily: "NexaBold",
              ),
            )),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _emailController,
            autofillHints: [AutofillHints.email],
         //   cursorColor: Colors.black,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).email,

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
        SizedBox(height: 20),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context).password,
              style: TextStyle(
               // color: Colors.black,
                fontFamily: "NexaBold",
              ),
            )),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          autofillHints: [AutofillHints.password],
        //  cursorColor: Colors.black,
          maxLines: 1,
          decoration: InputDecoration(
            hintText:   AppLocalizations.of(context).password,

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
            signIn();
          },
        ),
        const SizedBox(
          height: 10,
        ),



        Text(
          AppLocalizations.of(context).enterthepasswordtodelete,
          style: TextStyle(
         //   color: Colors.black,
            fontFamily: "NexaBold",
          ),
        ),

      ],
    );
  }


  Widget SigninWithPhoneNumber() {
    return
      screenState == 1
          ?  stateOTP()
          :
      Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).phoneNumber,
                style: TextStyle(
              //    color: Colors.black,
                  fontFamily: "NexaBold",
                ),
              )),
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _phoneController,
              autofillHints: [AutofillHints.telephoneNumber],

          //    cursorColor: Colors.black,
              maxLines: 1,
              decoration: InputDecoration(
                hintText:  AppLocalizations.of(context).phoneNumber,

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
          // const SizedBox(
          //   height: 24,
          // ),
          Align(
            alignment: Alignment.centerLeft,
            child:Text(
              AppLocalizations.of(context).enterphonenumberstartingwithcountrycode,
              style: TextStyle(
        //        color: Colors.black,
                fontFamily: "NexaBold",
              ),
            ),),
          //  SizedBox(
          //   height: 20,
          // ),
        ],
      );


  }
}
