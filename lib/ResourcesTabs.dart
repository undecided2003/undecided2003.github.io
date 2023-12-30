import 'package:drbaapp/showErrorMessage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main_page.dart';

class _Media {
  String title;
  String subtitle;
  String website;

  _Media(this.title, this.subtitle, this.website);

  @override
  String toString() {
    return '{ ${this.title},${this.subtitle}, ${this.website} }';
  }
}

class Reourcestabs extends StatefulWidget {
  List<Monastery> nAmerica;
  List<Monastery> _asia;
  List<Monastery> aussieEurope;
  List<Monastery> _associations;

  Reourcestabs(
      this.nAmerica, this._asia, this.aussieEurope, this._associations);

  @override
  State<Reourcestabs> createState() => _ReourcestabsState();
}

class _ReourcestabsState extends State<Reourcestabs>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 3, vsync: this);
  final scrollcontroller = ScrollController();

  void dispose() {
    _tabController.dispose();
    scrollcontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //  _phoneController.text = '+1';
    _tabController.animation?.addListener(() {
      // if (_tabController.animation!.isCompleted!) {
        setState(() {});
      // }else{
    //     setState(() {
    //     });
    //  // }
     });
  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 935;

  Widget build(BuildContext context) {
    var videos = <_Media>[
      _Media(
          AppLocalizations.of(context).cityofTenThousandBuddhasLive,
          AppLocalizations.of(context).videos,
          'https://www.youtube.com/@CTTBLive'),
      _Media(
          AppLocalizations.of(context).dharmaRealmLive,
          AppLocalizations.of(context).videos,
          'https://www.youtube.com/@DharmaRealmLive'),
      _Media(
          AppLocalizations.of(context).cTTBBuddhadharma,
          AppLocalizations.of(context).collectionofDharma,
          'http://www.cttbusa.org/buddhadharma_tableofcontents.asp.html'),
    ];

    var print = <_Media>[
      _Media(
          AppLocalizations.of(context).buddhistTextTranslationSociety,
          AppLocalizations.of(context).bookstoreandTranslationSociety,
          'https://www.buddhisttexts.org/'),
      _Media(
          AppLocalizations.of(context).buddhismForKids,
          AppLocalizations.of(context).childrenBooks,
          'http://buddhismforkids.net/'),
      _Media(
          AppLocalizations.of(context).cTTBChinese,
          AppLocalizations.of(context).chineseMedia,
          'http://www.cttbchinese.org/'),
      _Media(
          AppLocalizations.of(context).cTTBBuddhadharma,
          AppLocalizations.of(context).collectionofDharma,
          'http://www.cttbusa.org/buddhadharma_tableofcontents.asp.html'),
    ];

    Widget Associations() {
      return SingleChildScrollView(
        controller: scrollcontroller,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 20),
            child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Text(AppLocalizations.of(context).associations,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NexaBold')),
                const SizedBox(
                  height: 24,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget._associations.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                              onTap: () async {
                                if (widget._associations[index].website == '') {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .nowebsiteavailable);
                                } else {
                                  await launchUrl(Uri.parse(
                                      widget._associations[index].website));
                                }
                              },
                              title: Text(
                                widget._associations[index].branch,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    widget._associations[index].address + ' ',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: "NexaBold",
                                      color: Colors.deepPurpleAccent[700],
                                    ),
                                  ),
                                  Text(
                                    widget._associations[index].contact,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "NexaBold",
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget Monasteries() {
      return SingleChildScrollView(
        controller: scrollcontroller,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 24,
                ),
                Text(AppLocalizations.of(context).northAmericaBranches,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NexaBold')),
                const SizedBox(
                  height: 24,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.nAmerica.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                              onTap: () async {
                                if (widget.nAmerica[index].website == '') {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .nowebsiteavailable);
                                } else {
                                  await launchUrl(Uri.parse(
                                    widget.nAmerica[index].website,
                                  ));
                                }
                              },
                              title: Text(
                                widget.nAmerica[index].branch,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(widget.nAmerica[index].address + ' ',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "NexaBold",
                                        color: Colors.deepPurpleAccent[700],
                                      )),
                                  Text(widget.nAmerica[index].contact,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "NexaBold",
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(AppLocalizations.of(context).asiaBranches,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NexaBold')),
                const SizedBox(
                  height: 24,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget._asia.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                              onTap: () async {
                                if (widget._asia[index].website == '') {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .nowebsiteavailable);
                                } else {
                                  await launchUrl(
                                      Uri.parse(widget._asia[index].website));
                                }
                              },
                              title: Text(
                                widget._asia[index].branch,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(widget._asia[index].address + ' ',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "NexaBold",
                                        color: Colors.deepPurpleAccent[700],
                                      )),
                                  Text(
                                    widget._asia[index].contact,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "NexaBold",
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(AppLocalizations.of(context).australiaandEurope,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NexaBold')),
                const SizedBox(
                  height: 24,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.aussieEurope.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                              onTap: () async {
                                if (widget.aussieEurope[index].website == '') {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .nowebsiteavailable);
                                } else {
                                  await launchUrl(Uri.parse(
                                      widget.aussieEurope[index].website));
                                }
                              },
                              title: Text(
                                widget.aussieEurope[index].branch,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(widget.aussieEurope[index].address + ' ',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "NexaBold",
                                        color: Colors.deepPurpleAccent[700],
                                      )),
                                  Text(
                                    widget.aussieEurope[index].contact,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "NexaBold",
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget Media() {
      return SingleChildScrollView(
        controller: scrollcontroller,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 24,
                ),
                Text(AppLocalizations.of(context).video,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NexaBold')),
                const SizedBox(
                  height: 24,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                              onTap: () async {
                                if (videos[index].website == '') {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .nolinkavailable);
                                } else {
                                  await launchUrl(
                                      Uri.parse(videos[index].website));
                                }
                              },
                              title: Text(
                                videos[index].title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(videos[index].subtitle + ' ',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "NexaBold",
                                        color: Colors.red[800],
                                      )),
                                  Text(videos[index].website,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: "NexaBold",
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(AppLocalizations.of(context).print,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'NexaBold')),
                const SizedBox(
                  height: 24,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: print.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                              onTap: () async {
                                if (print[index].website == '') {
                                  showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)
                                          .nolinkavailable);
                                } else {
                                  await launchUrl(
                                      Uri.parse(print[index].website));
                                }
                              },
                              title: Text(
                                print[index].title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "NexaBold",
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(print[index].subtitle + ' ',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "NexaBold",
                                        color: Colors.red[800],
                                      )),
                                  Text(print[index].website,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: "NexaBold",
                                        fontSize: 15,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isDesktop(context)
                            ? Expanded(child: Container())
                            : Container(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Column(

        children: [
          TabBar(
              controller: _tabController,
              splashFactory: NoSplash.splashFactory,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              tabs: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _tabController.index == 0
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Tab(
                      child: Center(
                          child: Text(AppLocalizations.of(context).associations,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                  fontFamily: kIsWeb? "NexaBold"
                                      :"OpenSerif"
                              ))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _tabController.index == 1
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Tab(
                      child: Center(
                          child: Text(
                              AppLocalizations.of(context)
                                  .associationsbranchesandMonasteries,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                  fontFamily: kIsWeb? "NexaBold"
                                      :"OpenSerif"
                              ))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _tabController.index == 2
                          ? Colors.grey[400]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Tab(
                      child: Center(
                        child: Text(AppLocalizations.of(context).media,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                                fontFamily: kIsWeb? "NexaBold"
                                    :"OpenSerif"
                            )),
                      ),
                    ),
                  ),
                )
              ]),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              Center(
                child: Associations(),
              ),
              Center(
                child: Monasteries(),
              ),
              Center(
                child: Media(),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
