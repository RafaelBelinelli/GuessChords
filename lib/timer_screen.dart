import 'dart:async';
import 'package:guesschords/playing_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  final int difficulty;

  const TimerPage({Key? key, String? title, required this.difficulty})
      : super(key: key);

  @override
  State<TimerPage> createState() => _TimerState();
}

class _TimerState extends State<TimerPage> {
  int _current = 3;
  bool ready = false;
  var difficultyNames = ['Fácil', 'Médio', 'Díficil', 'Extremo'];
  static AudioCache player = AudioCache();

  count() async {
    for (int x = 3; x > 0; x--) {
      await Future.delayed(const Duration(seconds: 1)).then((_) async {
        if (x != 1) {
          setState(() {
            _current--;
          });
        }
      });
    }

    player.play("metronomeup.wav");

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlayingPage(difficulty: widget.difficulty)));
    dispose();
  }

  @override
  void dispose() {
    player.clearAll();
    super.dispose();
  }

  @override
  void initState() {
    count();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    player.play("metronome.wav");
    return Scaffold(
        body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(236, 236, 234, 1),
                  Color.fromRGBO(212, 212, 210, 1),
                ],
              ),
            ),
            child: Center(
              child: Text(
                '$_current',
                style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(80, 80, 80, 1)),
              ),
            )));
  }
}
