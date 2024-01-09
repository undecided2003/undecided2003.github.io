import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/picker.dart';
import 'dart:async';
import 'AppBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class TimerHandler {
//   DateTime _endingTime;
//
//   TimerHandler._privateConstructor();
//   TimerHandler();
//
//   static final TimerHandler _instance = new TimerHandler();
//   static TimerHandler get instance => _instance;
//
//   int get remainingSeconds {
//     final DateTime dateTimeNow = new DateTime.now();
//     Duration remainingTime = _endingTime.difference(dateTimeNow);
//     // Return in seconds
//     return remainingTime.inSeconds;
//   }
//
//   void setEndingTime(int durationToEnd) {
//     final DateTime dateTimeNow = new DateTime.now();
//
//     // Ending time is the current time plus the remaining duration.
//     this._endingTime = dateTimeNow.add(
//       Duration(
//         seconds: durationToEnd,
//       ),
//     );
//
//   }
// }

class meditationTimer extends StatefulWidget {
  final List<int> goals;

  meditationTimer(this.goals);

  @override
  State<meditationTimer> createState() => _meditationTimerState();
}

class _meditationTimerState extends State<meditationTimer> {
  Duration timeleft = Duration(hours: 0);
  Duration goal1 = Duration(hours: 0);
  Duration goal2 = Duration(hours: 0);

  bool isTimerStarted = false;
  Timer? _timer;
  bool recordGoal1 = false;
  bool recordGoal2 = false;
  var goalsList = <int>[];
  AudioPlayer player2 = AudioPlayer(playerId: '2');

  @override
  Future<void> dispose() async {
    super.dispose();
    await player2.stop();
  }
  @override
  void countDown(Duration initialTimeLeft) {
    bool isStart = true;

    //DateTime _endingTime = DateTime.now().add(initialTimeLeft);
    // Duration timeleft = _endingTime.difference( DateTime.now());

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //   print(_endingTime);

      if (timeleft == initialTimeLeft - Duration(seconds: 33) &&
          timeleft > Duration(seconds: 1)) {
        player2.play(AssetSource('silence.mp3'));
        player2.setReleaseMode(ReleaseMode.loop);
      }
      if (timeleft == Duration(seconds: 1)) {
        player2.play(AssetSource('2 bell 3 fish best.mp3'));
      }
      if (timeleft > Duration.zero) {
        if (isStart) {
          player2.play(AssetSource('1+3 fish.mp3'));
          isStart = false;
        }
        setState(() {
          timeleft = timeleft - Duration(seconds: 1);
          isTimerStarted = true;
        });

        if (recordGoal1) {
          setState(() {
            goal1 = goal1 + Duration(seconds: 1);
          });
        }

        if (recordGoal2) {
          setState(() {
            goal2 = goal2 + Duration(seconds: 1);
          });
        }
      } else {
        timer.cancel();
        setState(() {
          timeleft = Duration(hours: 0);
          isTimerStarted = false;
        });
      }
    });
  }

  cancelTimer() {
    _timer!.cancel();
    setState(() {
      isTimerStarted = false;
    });
  }

  resetTimer() {
    setState(() async {
      timeleft = Duration(hours: 0);
      isTimerStarted = false;
      await player2.stop();

    });
    _timer!.cancel();

  }

  @override
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1025;

  Widget build(BuildContext context) {
    int hours = timeleft.inHours;
    int minutes = timeleft.inMinutes % 60;
    int seconds = timeleft.inSeconds % 60;
    String _minutes = minutes.toString().padLeft(2, '0');
    String _seconds = seconds.toString().padLeft(2, '0');

    int goal1hours = goal1.inHours;
    int goal1minutes = goal1.inMinutes % 60;
    int goal1seconds = goal1.inSeconds % 60;
    String _goal1minutes = goal1minutes.toString().padLeft(2, '0');
    String _goal1seconds = goal1seconds.toString().padLeft(2, '0');

    int goal2hours = goal2.inHours;
    int goal2minutes = goal2.inMinutes % 60;
    int goal2seconds = goal2.inSeconds % 60;
    String _goal2minutes = goal2minutes.toString().padLeft(2, '0');
    String _goal2seconds = goal2seconds.toString().padLeft(2, '0');

    return Scaffold(
        appBar:
            AppBars(AppLocalizations.of(context).meditationTimer, '', context),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Row(
          children: [
            isDesktop(context) ? Expanded(child: Container()) : Container(),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!isTimerStarted) {
                          countDown(timeleft);
                        } else {
                          cancelTimer();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueGrey.shade400,
                            width: 2.0,
                          ),
                        ),
                        child: Text('$hours:$_minutes:$_seconds',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !isTimerStarted
                            ? SizedBox(
                                height: 67,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!isTimerStarted) {
                                      await player2.stop();
                                      countDown(timeleft);
                                    } else {
                                      cancelTimer();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[100],
                                      shape: const RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  10))) // Background color
                                      ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(AppLocalizations.of(context).start),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 67,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!isTimerStarted) {
                                      await player2.stop();
                                      countDown(timeleft);
                                    } else {
                                      cancelTimer();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[100],
                                      shape: const RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  10))) // Background color
                                      ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.pause,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        AppLocalizations.of(context).pause,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Picker(
                              adapter: NumberPickerAdapter(
                                  data: <NumberPickerColumn>[
                                    NumberPickerColumn(
                                        begin: 0,
                                        end: 999,
                                        suffix: Text(' ' +
                                            AppLocalizations.of(context)
                                                .hours)),
                                    NumberPickerColumn(
                                        begin: 0,
                                        end: 60,
                                        suffix: Text(' ' +
                                            AppLocalizations.of(context)
                                                .minutes)),
                                  ]),
                              delimiter: <PickerDelimiter>[
                                PickerDelimiter(
                                  child: Container(
                                    width: 30.0,
                                    alignment: Alignment.center,
                                    child: Icon(Icons.more_vert),
                                  ),
                                )
                              ],
                              hideHeader: true,
                              confirmText: 'OK',
                              cancelText: AppLocalizations.of(context).cancel,
                              //confirmTextStyle: TextStyle(inherit: false, color: Colors.red, fontSize: 22),
                              title: Text(
                                  AppLocalizations.of(context).selectduration),
                              selectedTextStyle: TextStyle(color: Colors.blue),
                              onConfirm: (Picker picker, List<int> value) {
                                setState(() {
                                  timeleft = Duration(
                                      hours: picker.getSelectedValues()[0],
                                      minutes: picker.getSelectedValues()[1]);
                                });
                              },
                            ).showDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10))) // Background color
                              ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(AppLocalizations.of(context).setTimer),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            resetTimer();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10))) // Background color
                              ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.change_circle_outlined,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(AppLocalizations.of(context).reset),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CheckboxListTile(
                      title:
                          Text(AppLocalizations.of(context).recordGoal + " 1"),
                      value: recordGoal1,
                      onChanged: (newValue) {
                        setState(() {
                          recordGoal1 = newValue!;
                          goal1 = Duration(seconds: widget.goals[0]);
                          goalsList = widget.goals;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    ),
                    recordGoal1
                        ? Column(
                            children: [
                              Text('$goal1hours:$_goal1minutes:$_goal1seconds',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      goalsList[0] = goal1.inSeconds;
                                      final currentUser = await FirebaseAuth
                                          .instance.currentUser!;
                                      await FirebaseFirestore.instance
                                          .collection("Students")
                                          .doc(currentUser.uid)
                                          .update({
                                        'Meditation Goals': goalsList,
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[100],
                                        shape: const RoundedRectangleBorder(
                                            side:
                                                BorderSide(color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10))) // Background color
                                        ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.save,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(AppLocalizations.of(context).save),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        goal1 = Duration(hours: 0);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[100],
                                        shape: const RoundedRectangleBorder(
                                            side:
                                                BorderSide(color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10))) // Background color
                                        ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.change_circle_outlined,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            AppLocalizations.of(context).reset),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        : Container(),
                    CheckboxListTile(
                      title:
                          Text(AppLocalizations.of(context).recordGoal + " 2"),
                      value: recordGoal2,
                      onChanged: (newValue) {
                        setState(() {
                          recordGoal2 = newValue!;
                          goal2 = Duration(seconds: widget.goals[1]);
                          goalsList = widget.goals;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
                    ),
                    recordGoal2
                        ? Column(
                            children: [
                              Text('$goal2hours:$_goal2minutes:$_goal2seconds',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(
                                height: 24,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      goalsList[1] = goal2.inSeconds;
                                      final currentUser = await FirebaseAuth
                                          .instance.currentUser!;

                                      await FirebaseFirestore.instance
                                          .collection("Students")
                                          .doc(currentUser.uid)
                                          .update({
                                        'Meditation Goals': goalsList,
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[100],
                                        shape: const RoundedRectangleBorder(
                                            side:
                                                BorderSide(color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10))) // Background color
                                        ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.save,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(AppLocalizations.of(context).save),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        goal2 = Duration(hours: 0);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[100],
                                        shape: const RoundedRectangleBorder(
                                            side:
                                                BorderSide(color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10))) // Background color
                                        ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.change_circle_outlined,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            AppLocalizations.of(context).reset),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        : Container()
                  ],
                ),
              ),
            ),
            isDesktop(context) ? Expanded(child: Container()) : Container(),
          ],
        ))));
  }
}
