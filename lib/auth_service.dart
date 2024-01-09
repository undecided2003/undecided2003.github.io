import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  signInWithGoogle(String language) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final gauthsigin =
        await FirebaseAuth.instance.signInWithCredential(credential);
    // print (gUser.id);
    // print(FirebaseAuth.instance.currentUser!.uid);
    // print(_firebaseAuth.currentUser!.uid);
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((Students) async {
      if (Students.exists) {
//print('exists!');
      } else {
        //print('not exist!');
        bool unread = false;
        bool appAdmin = false;

        await FirebaseFirestore.instance
            .collection("Students")
            .doc(_firebaseAuth.currentUser!.uid)
            .set({
          'Auth Name': gUser.displayName.toString(),
          'Email': gUser.email.toString(),
          'Token': 'abc',
          'Groups': <String>[],
          'Events': <String>[],
          'Past Events': <String>[],
          'imageLink':
              'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..',
          'Chat Rooms': <String>[],
          'Unread Messages': unread,
          'Language': language,
          'App Admin': appAdmin,
          'Name': '',
          'Interest': '',
          'Activities': '',
          'Bio': '',
          'Meditation Goals': <int>[0,0],

        });
        //       }
      }
    //  print(gUser.displayName.toString());
    });
    Future.delayed(Duration(seconds: 1), () async {});

    return gauthsigin;
  }

  // String sha256ofString(String input) {
  //   final bytes = utf8.encode(input);
  //   final digest = sha256.convert(bytes);
  //   return digest.toString();
  // }

  signInWithApple1(String language) async {
    try {
      AppleAuthProvider appleProvider = await AppleAuthProvider();
      await appleProvider.addScope('email');
      await appleProvider.addScope('name');
      UserCredential? credential;
      if (kIsWeb) {
        credential = await FirebaseAuth.instance.signInWithPopup(appleProvider);
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        credential =
            await FirebaseAuth.instance.signInWithProvider(appleProvider);
      }

      // final appleCredential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [
      //     AppleIDAuthorizationScopes.email,
      //     AppleIDAuthorizationScopes.fullName,
      //   ],
      //   nonce: nonce,
      // );

      //   print(appleCredential.authorizationCode);
      //    AppleIdCredential? appleIdCredential = credential1.credential!;
      //    OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      //    OAuthCredential credential2 = oAuthProvider.credential(
      //      idToken: String.fromCharCodes(appleIdCredential.identityToken!),
      //      accessToken:
      //      String.fromCharCodes(appleIdCredential.authorizationCode!),
      //    );
      // Create an `OAuthCredential` from the credential returned by Apple.
      // final oauthCredential = OAuthProvider("apple.com").credential(
      //   idToken: credential.identityToken,
      //   rawNonce: rawNonce,
      // );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      // final authResult =
      // await _firebaseAuth.signInWithCredential(oauthCredential);

      final displayName = '${credential!.user!.displayName}';
      final appleEmail = '${credential!.user!.email}';

      var firebaseUser = credential.user;
      // var firebaseUser = await _firebaseAuth.currentUser;

      if (appleEmail != null) {
        await firebaseUser!.updateEmail(appleEmail);
      }

      if (credential.user?.displayName != null) {
        await firebaseUser!.updateDisplayName(displayName);
      }

      // await firebaseUser!.reload();
      // firebaseUser = await _firebaseAuth.currentUser;

      await FirebaseFirestore.instance
          .collection('Students')
          .doc(_firebaseAuth.currentUser!.uid)
          .get()
          .then((Students) async {
        if (Students.exists) {
//print('exists!');
        } else {
          //print('not exist!');
          bool unread = false;
          bool appAdmin = false;

          await FirebaseFirestore.instance
              .collection("Students")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'Auth Name': _firebaseAuth.currentUser!.displayName,
            'Email': _firebaseAuth.currentUser!.email,
            'Token': 'abc',
            'Groups': <String>[],
            'Events': <String>[],
            'Past Events': <String>[],
            'imageLink':
                'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..',
            'Chat Rooms': <String>[],
            'Unread Messages': unread,
            'Language': language,
            'App Admin': appAdmin,
            'Name': '',
            'Interest': '',
            'Activities': '',
            'Bio': '',
            'Meditation Goals': <int>[0,0],

          });
        }
      });
      Future.delayed(Duration(seconds: 1), () async {});
      return firebaseUser;
    } catch (exception) {
      print(exception);
    }
  }

//   Future<User> signInWithApple(context, String language, {List<Scope> scopes = const []}) async {
//     String displayName = "Need a name";
//     String appleEmail =  "Need an email";
//     // 1. perform the sign-in request
//     final result = await TheAppleSignIn.performRequests(
//         [AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])]);
//     // 2. check the result
//     switch (result.status) {
//       case AuthorizationStatus.authorized:
//         AppleIdCredential? appleIdCredential = result.credential!;
//         OAuthProvider oAuthProvider = OAuthProvider('apple.com');
//         OAuthCredential credential = oAuthProvider.credential(
//           idToken: String.fromCharCodes(appleIdCredential.identityToken!),
//           accessToken:
//           String.fromCharCodes(appleIdCredential.authorizationCode!),
//         );
//
//         final userCredential =
//         await _firebaseAuth.signInWithCredential(credential);
//         final firebaseUser = userCredential.user!;
//
//         final appleEmail = appleIdCredential.email;
//         final fullName = appleIdCredential.fullName;
//         displayName = '${fullName!.givenName} ${fullName!.familyName}';
//
//         if (appleEmail != null) {
//           await firebaseUser.updateEmail(appleEmail);
//         }
//
//         if (fullName!.givenName != null || fullName!.familyName != null) {
//           await firebaseUser.updateDisplayName(displayName);
//         }
//
//
//
//         await FirebaseFirestore.instance
//             .collection('Students')
//             .doc(_firebaseAuth.currentUser!.uid)
//             .get().then((Students)  async {
//
//
//           if (Students.exists) {
// //print('exists!');
//           }
//
//           else   {//print('not exist!');
//             bool unread = false;
//             bool appAdmin = false;
//
//             await FirebaseFirestore.instance.collection("Students").doc(FirebaseAuth.instance.currentUser!.uid)
//                         .set(
//                         {
//                           'Auth Name': _firebaseAuth.currentUser!.displayName,
//                           'Email': _firebaseAuth.currentUser!.email,
//                           'Token': 'abc',
//                           'Groups': <String>[],
//                           'Events':<String>[],
//                           'Past Events': <String>[],
//
//                           'imageLink': 'https://firebasestorage.googleapis.com/v0/b/drbaapp-d48aa.appspot.com/o/profileImage%2Fpersonicon.png?alt=media&token=9cccc6db-20b3-4ba5-b6a3-6dbec5de24d0&_gl=1*fbn2vh*_ga*ODk3NjIyMTUwLjE2ODM0OTgyMzc.*_ga_CW55HF8NVT*MTY5ODA0NTM2OS41NDIuMS4xNjk4MDQ1NzU5LjE0LjAuMA..',
//                           'Chat Rooms': <String>[],
//                           'Unread Messages': unread,
//                           'Language': language,
//                           'App Admin': appAdmin,
//                           'Name': '',
//                           'Interest': '',
//                           'Bio': '',
//
//                         });
//
//
//               }
//             }
//         );
//         Future.delayed(Duration(seconds: 1), () async {
//         }
//         );
//
//         return firebaseUser;
//
//       case AuthorizationStatus.error:
//         throw PlatformException(
//           code: 'ERROR_AUTHORIZATION_DENIED',
//           message: result.error.toString(),
//         );
//
//       case AuthorizationStatus.cancelled:
//         throw PlatformException(
//           code: 'ERROR_ABORTED_BY_USER',
//           message: AppLocalizations.of(context).signinabortedbyuser,
//         );
//       default:
//         throw UnimplementedError();
//     }
//   }
}
