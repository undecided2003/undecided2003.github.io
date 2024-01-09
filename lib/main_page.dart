import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drbaapp/showErrorMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'Groups.dart';
import 'NavDrawer.dart';
import 'EventsTabs.dart';
import 'ResourcesTabs.dart';
import 'Newsfeed_Info.dart';
import 'add_newsfeed.dart';
import 'appBar.dart';
import 'edit_profile.dart';
import 'package:flutter/foundation.dart';
import 'group_add.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'main.dart';
import 'map.dart';

class News {
  String? newsName;
  Timestamp? date;
  String? newsImage;
  String? newsStory;
  String? addedname;
  String? newsID;
  String? addedID;
  String? currentuserName;
  String? currentuserID;
  String? _profileImageLink;

  News(
      this.newsName,
      this.date,
      this.newsImage,
      this.newsStory,
      this.addedname,
      this.newsID,
      this.addedID,
      this.currentuserName,
      this.currentuserID,
      this._profileImageLink);

  @override
  String toString() {
    return '{ ${this.newsName},${this.date}, ${this.newsImage},${this.newsStory} ,${this.addedname} '
        ' ,${this.newsID},${this.addedID},${this.currentuserName},${this.currentuserID},${this._profileImageLink}}';
  }
}

class Monastery {
  String branch;
  String address;
  String contact;
  String website;
  double lat;
  double long;

  Monastery(this.branch, this.address, this.contact, this.website, this.lat,
      this.long);

  @override
  String toString() {
    return '{ ${this.branch},${this.address}, ${this.contact}, ${this.website}, ${this.lat}, ${this.long}}';
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String? currentUserName = 'Anonymous';
  String? currentUserEmail = '';
  String? currentUserID = '';
  final currentUser = FirebaseAuth.instance.currentUser!;
  var news = <News>[];
  Future? newsFuture;
  bool? appAdmin;
  String? profilePic = '';

  // MyStatefulDrawer(context, String ){
  //
  //   return NavDrawer(currentUserID: currentUser.uid);
  // }

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1025;

  bool ishHorizontal(BuildContext context) =>
      MediaQuery.of(context).size.width >= 500;

  void _getUserData() async {
    await FirebaseFirestore.instance
        .collection("Students")
        .doc(currentUser.uid)
        .get()
        .then((Student) async {
          if (Student.exists){
            //  print('lang');
              Home.of(context)?.setLocale(
                  Locale.fromSubtags(languageCode: Student.get('Language')));

              try {
                currentUserName = Student.get('Auth Name');
              } catch (e) {}

              //  if (initiate) {
              try {
                currentUserName = Student.get('Name');

                if (currentUserName == 'Anonymous' || currentUserName == '') {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (_) => editProfile(currentUserID: currentUser.uid)))
                      .then((value) {
                    setState(() {
                      _getUserData();
                    });
                  });
                }
              } catch (e) {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                    builder: (_) => editProfile(currentUserID: currentUser.uid)))
                    .then((value) {
                  setState(() {
                    _getUserData();
                  });
                });
              }

              setState(() {
                //  initiate = false;
                currentUserName = currentUserName;
                currentUserID = currentUser.uid;
                appAdmin = Student.get('App Admin');
                profilePic = Student.get('imageLink');

              });
          }else{
           // Future.delayed(Duration(seconds: 1), () async {
           //  print('lang2');
            _getUserData();

            // });
          }



    });
    await FirebaseFirestore.instance
        .collection("Students")
        .doc(currentUser.uid)
        .update({'Time': Timestamp.now(), 'Name': currentUserName});
  }

  // void rebuildAllChildren(BuildContext context) {
  //   void rebuild(Element el) {
  //     el.markNeedsBuild();
  //     el.visitChildren(rebuild);
  //   }
  //   (context as Element).visitChildren(rebuild);
  // }
  @override
  void initState() {
    super.initState();
    _getUserData();

    newsFuture = GetNews();

   // Future.delayed(Duration(seconds: 1), () async {
   // });
  }

  Widget build(BuildContext context) {
    var northAmerica = <Monastery>[
      Monastery(
          AppLocalizations.of(context).cityofTenThousandBuddhas,
          '4951 Bodhi Way, Ukiah, CA 95482',
          '(707) 462-0939',
          'http://www.cttbusa.org/',
          39.133340685153186,
          -123.16139233068941),
      Monastery(
          AppLocalizations.of(context).goldMountainMonastery,
          '800 Sacramento Street, San Francisco, CA 94108',
          '(415) 421-6117',
          'http://goldmountainmonastery.org/',
          37.79353756666686,
          -122.40646520364906),
      Monastery(
          AppLocalizations.of(context).goldSageMonastery,
          '11455 Clayton Road, San Jose, CA 95127',
          '(408) 923-7243',
          'http://www.drbagsm.org/',
          37.35656568104932,
          -121.78876291901241),
      Monastery(
          AppLocalizations.of(context).theInternationalTranslationInstitute,
          '1777 Murchison Drive, Burlingame, CA 94010-4504',
          '(650) 692-5912',
          '',
          37.594219485190536,
          -122.3876458171516),
      Monastery(
          AppLocalizations.of(context).theCityoftheDharmaRealm,
          '1029 West Capitol Avenue, West Sacramento, CA 95691',
          '(916) 374-8268',
          'http://cityofdharmarealm.org/',
          38.57962186523239,
          -121.52254609459769),
      Monastery(
          AppLocalizations.of(context)
              .instituteforWorldReligionsBerkeleyBuddhistMonastery,
          '2304 McKinley Avenue, Berkeley, CA 94703',
          '(510) 848-3440',
          'http://www.berkeleymonastery.org/',
          37.86668749803473,
          -122.27387230364535),
      Monastery(
          AppLocalizations.of(context).goldWheelMonastery,
          '235 North 58, Los Angeles, CA 90042',
          '(323) 258-6668',
          'http://www.goldwheel.org/',
          34.112110776616305,
          -118.19312230275035),
      Monastery(
          AppLocalizations.of(context).longBeachMonastery,
          '3361 E. Ocean Blvd., Long Beach, CA 90803',
          '(562) 438-8902',
          'http://www.longbeachmonastery.org/',
          33.76131869679501,
          -118.15288091495361),
      Monastery(
          AppLocalizations.of(context).blessingsProsperityLongevityMonastery,
          '4140 Long Beach Blvd., Long Beach, CA 90807',
          '(562) 595-4966',
          'http://www.bplmonastery.org/',
          33.8331572750808,
          -118.18894169922883),
      Monastery(
          AppLocalizations.of(context).goldSummitMonastery,
          '233 1st Avenue W., Seattle, WA 98119',
          '(206) 284-6690',
          'http://www.goldsummitmonastery.org/',
          47.620852667263755,
          -122.35838560168972),
      Monastery(
          AppLocalizations.of(context).avatamsakaVihara,
          '9601 Seven Locks Rd, Bethesda, MD 20817-9997',
          '(301) 469-8300',
          'http://www.avatamsakavihara.org/',
          39.013801703430794,
          -77.15989804713243),
      Monastery(
          AppLocalizations.of(context).snowMountainMonastery,
          '50924 Index-Galena Road, Index, WA 98256-0272',
          '(360) 799-0699',
          'http://smm.drba.org/',
          47.81998874211234,
          -121.54943940139033),
      Monastery(
          AppLocalizations.of(context).goldBuddhaMonastery,
          '248 East 11th Avenue, Vancouver, B.C. V5T 2C3 Canada',
          '(604) 709-0248',
          'http://www.gbm-online.com/',
          49.26097669417499,
          -123.0994715917509),
      Monastery(
          AppLocalizations.of(context).avatamsakaMonastery,
          '1009 - 4th Avenue, S.W. Calgary, AB T2P 0K8 Canada',
          '(403) 234-0644',
          'http://www.avatamsaka.ca/',
          51.04985655048419,
          -114.08423253932354)
    ];
    var asia = <Monastery>[
      Monastery(
          AppLocalizations.of(context).buddhistLectureHall,
          '香港跑馬地黃泥涌道31號12樓, Hong Kong',
          '2572-7644',
          '',
          22.270754006126683,
          114.18497887771372),
      Monastery(
          AppLocalizations.of(context).cixingMonastery,
          'Ling Wui Shan Tsuen, Hong Kong',
          '2985-5159',
          '',
          22.22717575669084,
          113.8682974304003),
      Monastery(
          AppLocalizations.of(context)
              .dharmaRealmBuddhistBooksDistributionAssociation,
          '臺灣省臺北市忠孝東路六段85號11樓, Taipei, Taiwan, R.O.C.',
          '(02) 2786-3022, 2786-2474',
          'http://www.drbataipei.org/',
          25.048248110586933,
          121.58462174888498),
      Monastery(
          AppLocalizations.of(context).dharmaRealmSagelyMonastery,
          '臺灣省高雄市六龜區興龍里東溪山莊20號, Kaohsiung 844, Taiwan, R.O.C.',
          '(07)689-3713',
          'http://www.drsm-tw.org/',
          23.011160681333745,
          120.65549528782103),
      Monastery(
          AppLocalizations.of(context).amitabhaMonastery,
          '臺灣省花蓮縣壽豐鄉池南村富吉街126號, Shou-feng, Hualien County 974, Taiwan, R.O.C.',
          '(03)865-1956',
          'http://www.drbataipei.org/am/index.htm',
          23.894055234048437,
          121.51307885895781),
      Monastery(
          AppLocalizations.of(context).malaysiaDharmaRealmBuddhistAssociation,
          '161, Jalan Ampang, 50450 Kuala Lumpur, Malaysia',
          '6(03) 2164-8055',
          '',
          3.159438864962098,
          101.71595312506865),
      Monastery(
          AppLocalizations.of(context).prajnaGuanyinSagelyMonastery,
          'Batu 5 1/2, Jalan Sungai Besi, Wilayah Persekutuan, 57100 Kuala Lumpur, Malaysia',
          '6(03) 7982-6560',
          '',
          3.124029087096525,
          101.70943019116898),
      Monastery(
          AppLocalizations.of(context).lotusVihara,
          '136, Jalan Sekolah, 45600 Batang Berjuntai, Selangor, Malaysia',
          '6(03) 3271-9439',
          '',
          3.3767090733353298,
          101.4061345222898),
    ];
    var australiaEurope = <Monastery>[
      Monastery(
          AppLocalizations.of(context).goldCoastDharmaRealm,
          '106 Bonogin Road, Mudgeeraba, Queensland 4213 Australia',
          '(07) 5522-8788',
          'http://www.gcdr.org.au/',
          -28.112668604063067,
          153.36883766986526),
      Monastery(
          AppLocalizations.of(context).dRBAFrance,
          '72 Rue Volant, 92000 Nanterre, France',
          '',
          'https://france.drba.org/',
          48.89317896356625,
          2.1967924276329596),
    ];

    var associations = <Monastery>[
      Monastery(
          AppLocalizations.of(context).dharmaRealmBuddhistAssociation,
          AppLocalizations.of(context).mainWebsite,
          '(707) 462-0939',
          'https://www.drba.org/',
          .0001,
          .0001),
      Monastery(
          AppLocalizations.of(context).dharmaRealmBuddhistUniversity,
          AppLocalizations.of(context).buddhistUniversity,
          '(707) 621-7000',
          'https://www.drbu.edu/',
          .0001,
          .0001),
      Monastery(
          AppLocalizations.of(context).sanghaLaityTrainingPrograms,
          AppLocalizations.of(context).monasticTrainingPrograms,
          'sltp@drba.org',
          'https://www.drba.org/monastic-training.html',
          .0001,
          .0001),
      Monastery(
          AppLocalizations.of(context)
              .instillingGoodnessDevelopingVirtueSchools,
          AppLocalizations.of(context).buddhistSchools,
          'Boys’ Division (707) 468-1138, Girls’ Division (707) 468-3847',
          'https://igdvs.org/',
          .0001,
          .0001),
      Monastery(
          AppLocalizations.of(context).buddhistTextTranslationSociety,
          AppLocalizations.of(context).bookstoreandTranslationSociety,
          'info@buddhisttexts.org',
          'https://www.buddhisttexts.org/',
          .0001,
          .0001),
      Monastery(
          AppLocalizations.of(context).dRBAChinese,
          AppLocalizations.of(context).dRBAChineseWebsite,
          '(707) 462-0939',
          'http://www.drbachinese.org',
          .0001,
          .0001),
    ];
    Widget? child1;
    Widget? child2;

    // call() { setState(() {
    //
    // }); }

    Widget AddGroupButton() {
      return Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(
              width: 14,
            ),
            SizedBox(
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  if (appAdmin!) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              newGroup(currentUserName!, currentUser.uid)),
                    ).then((value) {
                      setState(() {
                        _currentIndex = 0;
                      });
                    });
                  } else {
                    showErrorMessage(context,
                        AppLocalizations.of(context).onlyappadminscanaddgroups);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10))) // Background color
                    ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: Colors.grey[100]),
                    Text(' ' + AppLocalizations.of(context).addGroup,
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.grey[100],
                            fontFamily: 'NexaBold')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget AddNewsButton() {
      return Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(
              width: 14,
            ),
            SizedBox(
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  if (appAdmin!) {
                    final navigator = Navigator.of(context);
                    navigator
                        .push(MaterialPageRoute(
                            builder: (_) =>
                                Newsfeed(currentUserID: currentUser.uid)))
                        .then((value) {
                      setState(() {
                        newsFuture = GetNews();
                      });
                    });
                  } else {
                    showErrorMessage(
                        context,
                        AppLocalizations.of(context)
                            .onlyappadminscanaddtonewsfeed);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10))) // Background color
                    ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: Colors.grey[100]),
                    Text(' ' + AppLocalizations.of(context).addNewsfeed,
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.grey[100],
                            fontFamily: 'NexaBold')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    switch (_currentIndex) {
      case 0:
        // getUserData();
        child1 = _NewsFeed();
        child2 = AddNewsButton();

        break;
      case 1:
        child1 = Eventstabs(currentUserName!);
        child2 = Container();

        break;
      case 2:
        //   getMessages();
        child1 = GroupsInfo(
          currentUserName!,
        );
        child2 = AddGroupButton();

        break;
      case 3:
        // getUserList();
        //    FirebaseAuth.instance.signOut();
        //   child1 = _buildUserList();
        child1 =
            Reourcestabs(northAmerica, asia, australiaEurope, associations);
        child2 = mapButton(northAmerica, asia, australiaEurope);

        break;
    }

    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white10,
          appBar:
              AppBars(AppLocalizations.of(context).dRBA, profilePic!, context),
          drawer: Container(
              width: max(288, MediaQuery.of(context).size.width / 5),
              child: NavDrawer(currentUserID: currentUser.uid)),
          onDrawerChanged: (isOpen) {
            if (!isOpen) {
              setState(() {
                newsFuture = GetNews();
              });
            }
          },
          body:
              // SingleChildScrollView(
              //         child:
              Row(
            children: [
              ishHorizontal(context)
                  ? NavigationRail(
                      //  backgroundColor: Colors.grey[100],
                      selectedIndex: _currentIndex,
                      groupAlignment: -1,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      // selectedIconTheme: IconThemeData(
                      //   color: Colors.blue[900],
                      // ),
                      // selectedLabelTextStyle: TextStyle(color: Colors.blue[900],),
                      // unselectedIconTheme: IconThemeData(
                      //   color: Colors.grey[600],
                      // ),
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          icon: FaIcon(FontAwesomeIcons.newspaper),
                          label: Text(AppLocalizations.of(context).news),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.event),
                          label: Text(AppLocalizations.of(context).events),
                        ),
                        NavigationRailDestination(
                            icon: Icon(Icons.group_outlined),
                            label: Text(AppLocalizations.of(context).groups)),
                        NavigationRailDestination(
                          icon: Icon(Icons.library_books_outlined),
                          label: Text(AppLocalizations.of(context).resources),
                        ),
                      ],
                    )
                  : SizedBox(),
              ishHorizontal(context)
                  ? const VerticalDivider(thickness: 1, width: 1)
                  : SizedBox(),
              Expanded(child: Center(child: child1)),
            ],
          ),
          floatingActionButton: child2,
          bottomNavigationBar: ishHorizontal(context)
              ? SizedBox()
              : Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.shade300, width: 1.0))),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    // backgroundColor: Colors.grey[100],
                    type: BottomNavigationBarType.fixed,
                    // fixedColor: Colors.grey[800],
                    // unselectedItemColor: Colors.grey[600],
                    // selectedItemColor: Colors.blue[900],
                    // selectedIconTheme: IconThemeData(
                    //   color: Colors.blue[900],
                    // ),
                    items: [
                      BottomNavigationBarItem(
                        icon: FaIcon(FontAwesomeIcons.newspaper),
                        label: AppLocalizations.of(context).news,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.event),
                        label: AppLocalizations.of(context).events,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.group_outlined),
                        label: AppLocalizations.of(context).groups,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_books_outlined),
                        label: AppLocalizations.of(context).resources,
                      ),
                    ],
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                )),
    );
    //  );
  }

  Future<List<News>> GetNews() async {
    await FirebaseFirestore.instance
        .collection('Newsfeed')
        .get()
        .then((newsfeed) async {
      news.clear();
      if (newsfeed.docs.isNotEmpty) {
        for (int i = 0; i < newsfeed.docs.length; i++) {
          if( newsfeed.docs[i]['Student ID'] ==currentUser.uid && profilePic != newsfeed.docs[i]['Student imageLink'] && profilePic!=''){

            await FirebaseFirestore.instance.collection("Newsfeed").doc( newsfeed.docs[i].id)
                .update({
              'Student imageLink': profilePic,

            });

          }
          news.add(
            News(
              newsfeed.docs[i]['News Name'],
              newsfeed.docs[i]['Time'],
              newsfeed.docs[i]['imageLink'],
              newsfeed.docs[i]['Story'],
              newsfeed.docs[i]['Student Name'],
              newsfeed.docs[i].id,
              newsfeed.docs[i]['UserID'][0],
              currentUserName,
              currentUser.uid,
              newsfeed.docs[i]['Student imageLink'],
            ),
          );
        }
      }
    });
    return news;
  }

  Widget mapButton(
    List<Monastery> _northAmerica,
    List<Monastery> _asia,
    List<Monastery> _australiaEurope,
  ) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 14,
          ),
          SizedBox(
            // width: 227.0,
            height: 50.0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          map(_northAmerica, _asia, _australiaEurope)),
                ).then((value) {
                  setState(() {});
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade600),
                      borderRadius: BorderRadius.all(
                          Radius.circular(10))) // Background color
                  ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FaIcon(FontAwesomeIcons.mapLocationDot,
                      color: Colors.grey[100]),
                  Text(' ' + AppLocalizations.of(context).locateBranches,
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.grey[100],
                          fontFamily: 'NexaBold')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _NewsFeed() {
    return Padding(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(AppLocalizations.of(context).dharmaNewsfeed,
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  // color: Colors.grey[800],
                  fontFamily: 'NexaBold')),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: FutureBuilder(
                future: newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    news.sort((a, b) => b.date!.compareTo(a.date!));

                    return ListView.builder(
                      //   shrinkWrap:true,
                      // physics: const NeverScrollableScrollPhysics(),

                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            isDesktop(context)
                                ? Expanded(child: Container())
                                : Container(),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 14.0),
                                child: Container(
                                  // height: 1100,
                                  width: 550,
                                  //
                                  decoration: BoxDecoration(
                                      //color: Colors.grey[100],
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: GestureDetector(
                                    onTap: () async {
                                      // if (kIsWeb) {
                                      //   GoRouter.of(context).go('/news${news[index].newsID!}');
                                      // }
                                      // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                                      await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => Newsfeed_info(
                                            news[index].newsID!,
                                            currentUserName!),
                                      ))
                                      //     .then((value) {
                                      //   setState(() {
                                      //     SchedulerBinding.instance
                                      //         .addPostFrameCallback((_) {
                                      //       newsFuture == GetNews();
                                      //     });
                                      //   });
                                      // })
                                      ;

                                      // }
                                    },
                                    child: Column(
                                      children: [
                                        // Transform.translate(
                                        //   offset: Offset(0, -8),
                                        //child:
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: CachedNetworkImage(
                                            imageUrl: news[index].newsImage!,
                                            height: 190.0,
                                            fadeInCurve: Curves.easeIn,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15.0)),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //      ),
                                        ListTile(
                                          onTap: () async {
                                            if (currentUserName!
                                                    .contains('Anonymous') ||
                                                currentUserName == '') {
                                              await FirebaseFirestore.instance
                                                  .collection('Students')
                                                  .doc(currentUser.uid)
                                                  .get()
                                                  .then((Students) async {
                                                if (Students.exists) {
                                                  try {
                                                    currentUserName =
                                                        await Students.get(
                                                            'Name');
                                                  } catch (e) {
                                                    if (await FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .displayName !=
                                                        null) {
                                                      currentUserName =
                                                          await FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .displayName!;
                                                    }
                                                  }
                                                }
                                              });
                                            }
                                            // if (kIsWeb) {
                                            //   GoRouter.of(context).go('/news${news[index].newsID!}');
                                            //
                                            // }
                                            // else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                                            await Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  Newsfeed_info(
                                                      news[index].newsID!,
                                                      currentUserName!),
                                            ))
                                                //     .then((value) {
                                                //   //   getNearbyEvents();
                                                //   setState(() {
                                                //   });
                                                // })
                                                ;
                                            //  }
                                          },
                                          title: Text(
                                            news[index].newsName!,
                                            style: TextStyle(
                                              //  color: Colors.black,
                                              fontFamily: "NexaBold",
                                              fontSize: 25,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 17,
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                        backgroundImage:
                                                            CachedNetworkImageProvider(
                                                                news[index]
                                                                    ._profileImageLink!
                                                                //      _profileLink!.length > 0 ? _profileLink[index] : ''
                                                                ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        news[index].addedname!,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.lightBlue,
                                                          fontFamily:
                                                              "NexaBold",
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                            'EEE, MM/dd/yyyy')
                                                        .format(news[index]
                                                            .date!
                                                            .toDate())
                                                        .toString(),
                                                    style: TextStyle(
                                                      //  color: Colors.black,
                                                      fontFamily: "NexaBold",
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(
                                                height: 10,
                                              ),
                                              // Expanded(
                                              //child:
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxHeight: 120.0),
                                                // child:
                                                //     // Scrollbar(
                                                //     //   child:
                                                //     SingleChildScrollView(
                                                //   physics:
                                                //       NeverScrollableScrollPhysics(),
                                                //diables the scrolling

                                                //     scrollDirection: Axis.vertical,

                                                child: Text(
                                                  news[index].newsStory!,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    //   color: Colors.black,
                                                    fontFamily: "NexaBold",
                                                    fontSize: 16,
                                                    // overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),

                                                //     ),
                                              ),
                                              // ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            isDesktop(context)
                                ? Expanded(child: Container())
                                : Container()
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          ),
        ],
      ),
    );
  }
}
