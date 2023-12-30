import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
        apiKey: "AIzaSyD-jYrBTBF1SZNVyqyPX9X1-xOgqdHowvM", appId: "1:166255457114:web:8e300d06a2e701cf5cb963",
        messagingSenderId: "166255457114", projectId: "drbaapp-d48aa",
      storageBucket: "drbaapp-d48aa.appspot.com", authDomain: "drbaapp-d48aa.firebaseapp.com",
    )
    );
    usePathUrlStrategy();
    runApp( Home());
  }
  else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp( );

    runApp(Home());

 }


}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
  static _HomeState? of(BuildContext context) => context.findAncestorStateOfType<_HomeState>();

}

class _HomeState extends State<Home> {
  Map args = {};

  Locale _locale = Locale('en');

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
        create: (_) => AuthService(),
        child: MaterialApp.router(
          routerConfig: router,

          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,

          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          locale: _locale,
          supportedLocales: [
            Locale('en'),
            Locale('zh', 'TW'),
            Locale('vi'),
          ],
          // theme: ThemeData(
          //   textTheme: GoogleFonts.latoTextTheme(
          //     Theme.of(context).textTheme,
          //   ),
         // ),
          // localeResolutionCallback: (_locale, supportedLocales) {
          //   for (var supportedLocale in supportedLocales) {
          //     if (supportedLocale.languageCode == _locale?.languageCode &&
          //         supportedLocale.countryCode == _locale?.countryCode) {
          //       return supportedLocale;
          //     }
          //   }
          // },
         // home: Welcome(),
        ));
  }
}

