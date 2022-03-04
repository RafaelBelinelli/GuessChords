import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';

import 'music.dart';

enum KeyColor { WHITE, BLACK }

typedef void StringCallback(String val);

class PianoKey extends StatefulWidget {
  final KeyColor color;
  final double width;
  final int midiNote;
  final FlutterMidi flutterMidi;
  final Chord chord;
  BoxDecoration boxDecoration = const BoxDecoration();
  bool reset = false;
  bool pressed = false;
  bool text = false;
  final StringCallback callBack;

  PianoKey.white({
    Key? key,
    required this.width,
    required this.midiNote,
    required this.flutterMidi,
    required this.chord,
    required this.callBack,
  })  : color = KeyColor.WHITE,
        reset = false,
        pressed = false,
        super(key: key);

  PianoKey.black({
    Key? key,
    required this.width,
    required this.midiNote,
    required this.flutterMidi,
    required this.chord,
    required this.callBack,
  })  : color = KeyColor.BLACK,
        reset = false,
        pressed = false,
        super(key: key);

  void setPressed(Note key) {
    pressed = true;
    callBack(key.toString().replaceAll("Note.", ""));
  }

  @override
  _PianoKeyState createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  BoxDecoration boxDecoration = const BoxDecoration();
  Note key = Note.C;

  @override
  void initState() {
    boxDecoration = widget.boxDecoration;
    super.initState();
  }

  playNote() async {
    widget.flutterMidi.playMidiNote(midi: widget.midiNote);

    key = Note.values.elementAt(widget.midiNote % 12);

    if (boxDecoration.gradient?.colors != null) {
      if (widget.chord.notes.contains(key)) {
        widget.setPressed(key);
        setState(() {
          boxDecoration = BoxDecoration(
            color: Colors.green,
            border: Border.all(
                color: const Color.fromRGBO(80, 80, 80, 1), width: 2),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(7)),
          );
        });
      } else {
        setState(() {
          boxDecoration = BoxDecoration(
            color: Colors.red,
            border: Border.all(
                color: const Color.fromRGBO(80, 80, 80, 1), width: 2),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(7)),
          );
        });
      }
    }
  }

  stopNote() async {
    widget.flutterMidi.stopMidiNote(midi: widget.midiNote);
    if (boxDecoration.color == Colors.red) {
      setState(() {
        boxDecoration = BoxDecoration(
          gradient: widget.color == KeyColor.WHITE
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(219, 219, 219, 1),
                    Colors.white,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(80, 80, 80, 1),
                    Color.fromRGBO(80, 80, 80, 1)
                  ],
                ),
          border:
              Border.all(color: const Color.fromRGBO(80, 80, 80, 1), width: 2),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.reset) {
      boxDecoration = BoxDecoration(
        gradient: widget.color == KeyColor.WHITE
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(219, 219, 219, 1),
                  Colors.white,
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(80, 80, 80, 1),
                  Color.fromRGBO(80, 80, 80, 1)
                ],
              ),
        border:
            Border.all(color: const Color.fromRGBO(80, 80, 80, 1), width: 2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
      );
      widget.reset = true;
    }

    return GestureDetector(
      onTapDown: (_) => playNote(),
      onTapUp: (_) => stopNote(),
      child: Container(
        width: widget.width,
        decoration: boxDecoration,
      ),
    );
  }
}

class Piano extends StatefulWidget {
  Piano({Key? key, required this.flutterMidi, required this.chord})
      : super(key: key) {
    initCopy();
  }

  final FlutterMidi flutterMidi;
  final Chord chord;
  var notesCopy;

  Iterable gotRightNote() {
    return notesCopy;
  }

  void initCopy() {
    notesCopy = [];
    notesCopy.addAll(chord.notes);
  }

  @override
  _PianoState createState() => _PianoState();
}

class _PianoState extends State<Piano> {
  final octaveNumber = 5;

  get octaveStartingNote =>
      (octaveNumber * 12) % 128 +
      (widget.chord.root.toString().contains("b")
          ? widget.chord.root.index - 1
          : widget.chord.root.index);

  get flutterMidi => widget.flutterMidi;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final whiteKeySize = constraints.maxWidth / 14;
        final blackKeySize = whiteKeySize / 2;
        return Stack(
          children: [
            _buildWhiteKeys(whiteKeySize),
            _buildBlackKeys(constraints.maxHeight, blackKeySize, whiteKeySize),
          ],
        );
      },
    );
  }

  _buildWhiteKeys(double whiteKeySize) {
    List<Widget> whiteKeys = [];
    for (int j = 0; j < 24; j++) {
      whiteKeys.add(j % 12 != 0
          ? PianoKey.white(
              width: whiteKeySize,
              midiNote: octaveStartingNote + j,
              flutterMidi: flutterMidi,
              chord: widget.chord,
              callBack: (val) => widget.notesCopy.remove(Note.values.firstWhere(
                  (e) => e.toString().replaceAll("Note.", "") == val)),
            )
          : Stack(children: [
              PianoKey.white(
                width: whiteKeySize,
                midiNote: octaveStartingNote + j,
                flutterMidi: flutterMidi,
                chord: widget.chord,
                callBack: (val) => widget.notesCopy.remove(Note.values
                    .firstWhere(
                        (e) => e.toString().replaceAll("Note.", "") == val)),
              ),
              IgnorePointer(
                  child: Container(
                padding: const EdgeInsets.only(left: 8, top: 100),
                child: Text(
                  widget.chord.root.name.contains("b")
                      ? goDownNotes(widget.chord.root, 1)
                          .toString()
                          .replaceAll("Note.", "")
                      : widget.chord.root.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(80, 80, 80, 1)),
                ),
              ))
            ]));

      if (octaveStartingNote + j != 64 &&
          octaveStartingNote + j != 71 &&
          octaveStartingNote + j != 76 &&
          octaveStartingNote + j != 83 &&
          octaveStartingNote + j != 88 &&
          octaveStartingNote + j != 95 &&
          octaveStartingNote + j != 100) {
        j++;
      }
    }

    return Row(children: whiteKeys);
  }

  _buildBlackKeys(
      double pianoHeight, double blackKeySize, double whiteKeySize) {
    List<Widget> blackKeys = [];
    blackKeys.add(
      SizedBox(
        width: whiteKeySize - blackKeySize / 2,
      ),
    );

    for (int j = 1; j < 22; j += 2) {
      if (octaveStartingNote + j != 65 &&
          octaveStartingNote + j != 72 &&
          octaveStartingNote + j != 77 &&
          octaveStartingNote + j != 84 &&
          octaveStartingNote + j != 89 &&
          octaveStartingNote + j != 96) {
        blackKeys.add(
          PianoKey.black(
            width: blackKeySize,
            midiNote: octaveStartingNote + j,
            flutterMidi: flutterMidi,
            chord: widget.chord,
            callBack: (val) => widget.notesCopy.remove(Note.values.firstWhere(
                (e) => e.toString().replaceAll("Note.", "") == val)),
          ),
        );
      } else {
        j++;
        blackKeys.add(SizedBox(
          width: whiteKeySize - blackKeySize,
        ));
        blackKeys.add(SizedBox(
          width: whiteKeySize - blackKeySize,
        ));
        blackKeys.add(
          PianoKey.black(
            width: blackKeySize,
            midiNote: octaveStartingNote + j,
            flutterMidi: flutterMidi,
            chord: widget.chord,
            callBack: (val) => widget.notesCopy.remove(Note.values.firstWhere(
                (e) => e.toString().replaceAll("Note.", "") == val)),
          ),
        );
      }
      blackKeys.add(SizedBox(
        width: whiteKeySize - blackKeySize,
      ));
    }

    return SizedBox(
      height: pianoHeight * 0.55,
      child: Row(children: blackKeys),
    );
  }
}
