import 'package:flex_color_scheme/flex_color_scheme.dart';
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
      apiKey: "AIzaSyD-jYrBTBF1SZNVyqyPX9X1-xOgqdHowvM",
      appId: "1:166255457114:web:8e300d06a2e701cf5cb963",
      messagingSenderId: "166255457114",
      projectId: "drbaapp-d48aa",
      storageBucket: "drbaapp-d48aa.appspot.com",
      authDomain: "drbaapp-d48aa.firebaseapp.com",
    ));
    usePathUrlStrategy();
    runApp(Home());
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp();

    runApp(Home());
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();

  static _HomeState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeState>();
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

          // themeMode: ThemeMode.dark,

          theme: FlexThemeData.light(
            scheme: FlexScheme.greyLaw,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 7,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 10,
              blendOnColors: false,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.secondary,
              bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.secondary,
              bottomNavigationBarSelectedIconSchemeColor: SchemeColor.tertiary,
              bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.secondary,

           //   bottomNavigationBarBackgroundSchemeColor: SchemeColor.background,

              navigationRailUnselectedLabelSchemeColor: SchemeColor.secondary,
              navigationRailUnselectedIconSchemeColor: SchemeColor.secondary,
              navigationRailSelectedIconSchemeColor: SchemeColor.tertiary,
              navigationRailSelectedLabelSchemeColor: SchemeColor.secondary,
              elevatedButtonSchemeColor: SchemeColor.secondary,

              drawerUnselectedItemSchemeColor: SchemeColor.tertiary,
              dropdownMenuTextStyle: TextStyle(inherit: true),

              //   alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            // To use the Playground font, add GoogleFonts package and uncomment
            // fontFamily: GoogleFonts.notoSans().fontFamily,
          ),
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.greyLaw,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 13,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
             // bottomNavigationBarSelectedIconSchemeColor: SchemeColor.tertiary,
              bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
              bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.primary,
              bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.primary,
              bottomNavigationBarBackgroundSchemeColor: SchemeColor.background,

            //  navigationRailSelectedIconSchemeColor: SchemeColor.tertiary,
              navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
              navigationRailUnselectedLabelSchemeColor: SchemeColor.primary,
              navigationRailUnselectedIconSchemeColor: SchemeColor.primary,
              elevatedButtonSchemeColor: SchemeColor.secondary,

              // alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            // To use the Playground font, add GoogleFonts package and uncomment
            // fontFamily: GoogleFonts.notoSans().fontFamily,
          ),


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
