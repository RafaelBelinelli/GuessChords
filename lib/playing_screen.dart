import 'dart:async';
import 'dart:math';
import 'package:guesschords/piano.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'music.dart';

class PlayingPage extends StatefulWidget {
  final int difficulty;

  const PlayingPage({Key? key, String? title, this.difficulty = 1})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayingState();
}

class _PlayingState extends State<PlayingPage> {
  final _currentTime = ValueNotifier<int>(-1);
  final _currentChord = ValueNotifier<String>('');
  final _score = ValueNotifier<int>(0);
  var _piano;

  var difficultyNames = ['Fácil', 'Médio', 'Difícil', 'Extremo'];
  static AudioCache player = AudioCache();
  FlutterMidi flutterMidi = FlutterMidi();

  count() async {
    for (int x = 60; x > 0; x--) {
      await Future.delayed(const Duration(seconds: 1)).then((_) async {
        _currentTime.value--;
      });

      if (_piano.value.gotRightNote().isEmpty) {
        _currentChord.value = setChords();
        _piano.value = Piano(
          flutterMidi: flutterMidi,
          chord: Chord(_currentChord.value),
        );
        player.play("metronomeup.wav");
        _score.value += 100;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? best = prefs.getInt("highscore");
    if (best != null) {
      if (_score.value > best) {
        prefs.setInt("highscore", _score.value);
      }
    } else {
      prefs.setInt("highscore", _score.value);
    }
    dispose();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'GuessChords')),
        (route) => false);
  }

  String setChords() {
    var baseChords = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    var chordsCopy = [];

    int difficulty = widget.difficulty.round();

    if (difficulty >= 2) {
      baseChords.addAll(['Db', 'Eb', 'Gb', 'Ab', 'Bb']);
    }

    if (difficulty >= 3) {
      chordsCopy.addAll(baseChords);

      for (String chord in chordsCopy) {
        baseChords.addAll([
          chord + 'm',
          chord + '7',
          chord + 'm7',
          chord + 'maj7',
          chord + '△7',
          chord + 'mM7',
          chord + '6',
          chord + 'm6',
          chord + '°',
          chord + '°7'
        ]);
      }
    }

    if (difficulty == 4) {
      for (String chord in chordsCopy) {
        baseChords.addAll([
          chord + '6/9',
          chord + '5',
          chord + '9',
          chord + 'm9',
          chord + 'maj9',
          chord + '11',
          chord + 'm11',
          chord + '13',
          chord + 'm13',
          chord + 'maj13',
          chord + 'add9',
          chord + 'add2',
          chord + '7-5',
          chord + '7+5',
          chord + 'sus4',
          chord + 'sus2',
          chord + 'dim',
          chord + 'dim7',
          chord + 'm7b5',
          chord + 'aug',
          chord + 'aug7'
        ]);
      }
    }

    return getRandomChord(baseChords);
  }

  String getRandomChord(Iterable chords) {
    int avoid = -1;
    int randomElement = -1;
    Random random = Random();

    while (avoid == randomElement) {
      randomElement = random.nextInt(chords.length);
    }

    avoid = randomElement;

    return chords.elementAt(randomElement);
  }

  Future<void> setupMIDIPlugin() async {
    flutterMidi.unmute();
    await rootBundle
        .load("assets/piano.sf2")
        .then((sf2) => flutterMidi.prepare(sf2: sf2, name: "piano.sf2"));
  }

  @override
  void dispose() {
    player.clearAll();
    _currentChord.dispose();
    _currentTime.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _currentTime.value = 60;
    _currentChord.value = setChords();
    _score.value = 0;
    setupMIDIPlugin();
    _piano = ValueNotifier(
        Piano(flutterMidi: flutterMidi, chord: Chord(_currentChord.value)));
    count();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
              toolbarHeight: 65,
              backgroundColor: const Color.fromRGBO(80, 80, 80, 1)),
          body: Container(
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
              child: Column(
                children: [
                  ValueListenableBuilder(
                      valueListenable: _currentTime,
                      builder: (_, value, __) => Container(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text('$value',
                              style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(80, 80, 80, 1))))),
                  Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width - 60,
                      child: ValueListenableBuilder(
                        valueListenable: _currentChord,
                        builder: (_, value, __) => Text(
                          _currentChord.value,
                          style: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(80, 80, 80, 1)),
                        ),
                      )),
                  Expanded(child: Container()),
                  Container(
                      padding: const EdgeInsets.only(bottom: 30),
                      height: 160,
                      child: ValueListenableBuilder(
                          valueListenable: _piano,
                          builder: (_, value, __) => _piano.value)),
                  Container(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 100, right: 100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(difficultyNames[widget.difficulty.round() - 1],
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  color: Color.fromRGBO(150, 150, 161, 1),
                                  fontWeight: FontWeight.bold)),
                          ValueListenableBuilder(
                            valueListenable: _score,
                            builder: (_, value, __) => Text('Score: $value',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Color.fromRGBO(150, 150, 161, 1),
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ))
                ],
              )),
        ),
        onWillPop: () async {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
          dispose();
          return false;
        });
  }
}
