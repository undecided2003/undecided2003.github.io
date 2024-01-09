import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Register.dart';
import 'main.dart';
import 'showErrorMessage.dart';
import 'auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  String verID = " ";
  String otpPin = " ";
  String phoneNumber = '';
  String email = '';
  int screenState = 2;
  late final tabController = TabController(length: 2, vsync: this);
  double containerHeight = 1075;
  String _Language = 'English';
  String _Locale = 'en';

  Future<void> verifyPhone(String number) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });
    // Future.delayed(Duration(seconds: 1), () async {
    //
    // });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) {
        //   Navigator.pop(context);
        //     showErrorMessage(context,AppLocalizations.of(context).authCompleted);
      },
      verificationFailed: (FirebaseAuthException e) {
        Future.delayed(Duration(seconds: 1), () async {
          Navigator.pop(context);
        });
        showErrorMessage(context, AppLocalizations.of(context).authFailed);
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.pop(context);
        showErrorMessage(
            context, AppLocalizations.of(context).confirmationCodeSent);
        verID = verificationId;
        setState(() {
          phoneNumber = _phoneController.text;
          screenState = 1;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        showErrorMessage(context, AppLocalizations.of(context).timeout);
      },
    );
  }

  Future<void> verifyOTP(String _otpPin) async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verID,
          smsCode: _otpPin,
        ),
      )
          .whenComplete(() async {
        final doc = await FirebaseFirestore.instance
            .collection('Students')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        if (doc.exists) {
        } else {
          bool unread = false;
          bool appAdmin = false;

          await FirebaseFirestore.instance
              .collection("Students")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'Auth Name': '',
            'Phone': phoneNumber,
            'Token': 'abc',
            'Groups': <String>[],
            'Events': <String>[],
            'Past Events': <String>[],
            'imageLink':
                'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..',
            'Chat Rooms': <String>[],
            'Unread Messages': unread,
            'Language': _Locale,
            'App Admin': appAdmin,
            'Name': '',
            'Interest': '',
            'Activities': '',
            'Bio': '',
            'Meditation Goals': <int>[0, 0],
          });
        }
      });
    } catch (e) {
      showErrorMessage(
          context, AppLocalizations.of(context).wrongconfirmationcode);
      //    Navigator.of(context, rootNavigator: true).pop();
    }
  }

  bool isOnlyNumber(String str) {
    try {
      var value = int.parse(str);
      return true;
    } on FormatException {
      return false;
    }
  }

  // Future<void> _signInWithApple(BuildContext context, String _language) async {
  //       try {
  //         final authService = Provider.of<AuthService>(context, listen: false);
  //         final student = await authService.signInWithApple(context, _language);
  //         //print('uid: ${student.uid}');
  //       } catch (e) {
  //         // TODO: Show alert here
  //         print(e);
  //       }
  // }

  void initState() {
    super.initState();
    //  _phoneController.text = '+1';
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  Future<double> Getdata() async {
    _emailController.clear();
    _passwordController.clear();
    _phoneController.text = '+1';
    containerHeight = 1075;

    if (tabController.index == 1 && screenState != 1) {
      screenState = 0;
      //  containerHeight = await 1000;
    } else if (tabController.index == 0) {
      screenState = 2;
      //containerHeight = await 1000;
    }
    // else if (tabController.index == 1 && screenState == 1) {
    //  // containerHeight = 1000;
    // }
    return containerHeight;
  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1025;

  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Widget build(BuildContext context) {
    return FutureBuilder<double>(
        future: Getdata(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            // print(phoneNumber);
            return Scaffold(
              //  appBar: AppBars('Pickleball Time Login'),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      isDesktop(context)
                          ? Expanded(child: Container())
                          : Container(),
                      Expanded(
                        child: Container(
                          height: containerHeight,
                          width: double.infinity,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 60,
                              ),
                              Image(
                                color: isDarkMode(context)
                                    ? Colors.grey[100]
                                    : Colors.black87,
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
                                  AppLocalizations.of(context)
                                          .signinorsignupwith +
                                      AppLocalizations.of(context)
                                          .emailorphonenumber,
                                  style: TextStyle(
                                      //    color: Colors.grey[700]
                                      )),

                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  // color: Colors.grey[100],
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: TabBar(
                                    controller: tabController,
                                    dividerColor: Colors.transparent,
                                    indicator: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      color: Colors.grey[400],
                                    ),
                                    labelColor: Colors.black,
                                    unselectedLabelColor: Colors.grey[600],
                                    tabs: [
                                      Tab(
                                        child: Center(
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .emailAddress,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    //color: Colors.black,
                                                    fontFamily: 'NexaBold'))),
                                      ),
                                      Tab(
                                        child: Center(
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .phoneNumber,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    //  color: Colors.black,
                                                    fontFamily: 'NexaBold'))),
                                      ),
                                    ]),
                              ),

                              const SizedBox(
                                height: 8,
                              ),
                              Expanded(
                                child: TabBarView(
                                    controller: tabController,
                                    children: [
                                      SigninWithEmail(),
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
                                      width: 320.0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_phoneController.text.isEmpty ||
                                              _phoneController.text == '+1') {
                                            showErrorMessage(
                                                context,
                                                AppLocalizations.of(context)
                                                    .enterPhoneNumber);
                                          } else if (isOnlyNumber(
                                              _phoneController.text
                                                  .replaceAll('+', ''))) {
                                            verifyPhone(_phoneController.text);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors
                                              .grey[100], // Background color
                                        ),
                                        child: Text(
                                            AppLocalizations.of(context)
                                                .continue1,
                                            style: TextStyle(
                                                fontSize: 22,
                                                //  color: Colors.grey[800],
                                                fontFamily: 'NexaBold')),
                                      ),
                                    )
                                  : screenState == 1
                                      ? SizedBox(
                                          width: 320.0,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              otpPin =
                                                  _verificationController.text;
                                              if (otpPin.length >= 6) {
                                                verifyOTP(otpPin);
                                              } else {
                                                showErrorMessage(
                                                    context,
                                                    AppLocalizations.of(context)
                                                        .entercodecorrectly);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[
                                                  100], // Background color
                                            ),
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .signin,
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    // color: Colors.grey[800],
                                                    fontFamily: 'NexaBold')),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            SizedBox(
                                              width: 320.0,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  signIn();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey[
                                                      100], // Background color
                                                ),
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .signin,
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        //  color: Colors.grey[800],
                                                        fontFamily:
                                                            'NexaBold')),
                                              ),
                                            ),
                                          ],
                                        ),
                              const SizedBox(
                                height: 30,
                              ),
                              // const SizedBox(
                              //   height: 50,
                              // ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Divider(
                                        thickness: 0.5,
                                        color: Colors.grey[400],
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .orsigninwith,
                                          //   style: TextStyle(color: Colors.grey[700])
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
                                      onPressed: () {
                                        AuthService().signInWithGoogle(_Locale);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image(
                                              image: AssetImage(
                                                  "assets/google.png"),
                                              height: 18.0,
                                              width: 24,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 24, right: 8),
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .signinusingGoogle,
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
                                      onPressed: () {
                                        AuthService().signInWithApple1(_Locale);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image(
                                              image: AssetImage(
                                                  "assets/apple.png"),
                                              height: 18.0,
                                              width: 24,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 24, right: 8),
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .signinusingApple,
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
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     SquareTile(
                                  //         onTap: () {
                                  //           AuthService().signInWithGoogle(_Locale);
                                  //         },
                                  //         imagePath: 'assets/google.png'),
                                  //     SizedBox(width: 25),
                                  //     SquareTile(
                                  //         onTap: () {
                                  //           //    if (kIsWeb) {
                                  //           AuthService().signInWithApple1(_Locale);
                                  //           //}
                                  //           //     else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                                  //           //       AuthService().signInWithApple1(_Locale);
                                  //           // //      _signInWithApple(context, _Locale);
                                  //           //     }
                                  //         },
                                  //         imagePath: 'assets/apple.png'),
                                  //   ],
                                  // ),
                                ],
                              ),
                              SizedBox(height: 30),

                              GestureDetector(
                                onTap: () async {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: 'guest3210drbaapp@drba.org',
                                    password: 'abc123',
                                  );
                                },
                                child:
                                    Text(AppLocalizations.of(context).asGuest,
                                        style: TextStyle(
                                          //  color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        )),
                              ),

                              SizedBox(height: 72),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Register(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            language: _Locale),
                                      ));
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: AppLocalizations.of(context)
                                        .donthaveanaccountyet,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: "NexaBold",
                                      color: Colors.grey[600],
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' ' +
                                              AppLocalizations.of(context)
                                                  .register,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontFamily: "NexaBold",
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),

                              Align(
                                alignment: Alignment.bottomCenter,
                                child: DropdownButton<String>(
                                  //  focusColor: Colors.white,
                                  value: _Language,
                                  //elevation: 5,
                                  // style: TextStyle(color: Colors.white),
                                  //  iconEnabledColor: Colors.black,
                                  items: <String>['English', '中文', 'Tiếng Việt']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        //    style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    AppLocalizations.of(context)
                                        .pleasechoosealangauage,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _Language = value!;
                                      if (value == 'English') {
                                        _Locale = 'en';
                                      } else if (value == '中文') {
                                        _Locale = 'zh';
                                      } else if (value == 'Tiếng Việt') {
                                        _Locale = 'vi';
                                      }
                                    });
                                    Home.of(context)?.setLocale(
                                        Locale.fromSubtags(
                                            languageCode: _Locale));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      isDesktop(context)
                          ? Expanded(child: Container())
                          : Container()
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _verificationController.dispose();

    tabController.dispose();
    super.dispose();
  }

  void signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
//        Navigator.of(context, rootNavigator: true).pop();
    } on FirebaseAuthException catch (e) {
      //  Navigator.of(context, rootNavigator: true).pop();
      showErrorMessage(context, e.code);
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
                  color: Colors.grey[600],
                  fontFamily: "NexaBold",
                ),
              ),
              TextSpan(
                text: phoneNumber,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: "NexaBold",
                ),
              ),
              TextSpan(
                text: "\n" +
                    AppLocalizations.of(context).enterthecodeheretosignin,
                style: TextStyle(
                  color: Colors.grey[600],
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
          cursorColor: Colors.black,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).enterConfirmationCode,
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
          onFieldSubmitted: (value) {
            otpPin = _verificationController.text;
            if (otpPin.length >= 6) {
              verifyOTP(otpPin);
            } else {
              showErrorMessage(
                  context, AppLocalizations.of(context).entercodecorrectly);
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: AppLocalizations.of(context).didntreceivethecode,
                style: TextStyle(
                  color: Colors.grey[600],
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
              hintText: AppLocalizations.of(context).email,
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
        SizedBox(height: 20),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context).password,
              style: TextStyle(
                //   color: Colors.black,
                fontFamily: "NexaBold",
              ),
            )),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          autofillHints: [AutofillHints.password],
          cursorColor: Colors.black,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).password,
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
          onFieldSubmitted: (value) {
            signIn();
          },
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: _emailController.text.trim(),
              );
              showErrorMessage(context, AppLocalizations.of(context).linktoresetyourpassword+_emailController.text.trim());
            } on FirebaseAuthException catch (e) {
              showErrorMessage(context, e.code);
            }
          },
          child: Text(
            AppLocalizations.of(context).forgotyourpassword,
            style: TextStyle(
              fontSize: 14.0,
              fontFamily: "NexaBold",
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget SigninWithPhoneNumber() {
    return screenState == 1
        ? stateOTP()
        : Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).phoneNumber,
                    style: TextStyle(
                      //   color: Colors.black,
                      fontFamily: "NexaBold",
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _phoneController,
                // keyboardType: TextInputType.phone,

                  autofillHints: [AutofillHints.telephoneNumber],
                  cursorColor: Colors.black,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context).phoneNumber + ' (+1)',
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
                  onFieldSubmitted: (value) {
                    if (_phoneController.text.isEmpty ||
                        _phoneController.text == '+1') {
                      showErrorMessage(context,
                          AppLocalizations.of(context).enterPhoneNumber);
                    } else if (isOnlyNumber(
                        _phoneController.text.replaceAll('+', ''))) {
                      verifyPhone(_phoneController.text);
                    }
                  },
                ),
              ),
              // const SizedBox(
              //   height: 24,
              // ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)
                      .enterphonenumberstartingwithcountrycode,
                  style: TextStyle(
                    //  color: Colors.black,
                    fontFamily: "NexaBold",
                  ),
                ),
              ),
              //  SizedBox(
              //   height: 20,
              // ),
            ],
          );
  }
}
