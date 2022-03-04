enum Note { C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B }

Note goUpNotes(Note startingNote, int amount) {
  int result = startingNote.index + amount;

  while (result >= 12) {
    result = result - 12;
  }

  return Note.values.elementAt(result);
}

Note goDownNotes(Note startingNote, int amount) {
  int result = startingNote.index - amount;

  while (result < 0) {
    result = result + 12;
  }

  return Note.values.elementAt(result);
}

class Chord {
  String name = "";
  Note root = Note.C;
  var notes = [];

  Chord(this.name) {
    setupNotes();
  }

  void setupNotes() {
    int startingNote = 0;
    String rest = "";
    root = Note.values.firstWhere((e) => e.toString() == 'Note.' + name[0]);

    if (name.length > 1) {
      if (name[1] == 'b') {
        // Get Flat chords
        root = goDownNotes(root, 1);
        startingNote++;
      } else if (name[1] == '#') {
        // Get Sharp chords
        root = goUpNotes(root, 1);
        startingNote++;
      }
    }

    rest = name.substring(startingNote + 1);

    notes.add(root);

    if (rest.isEmpty) {
      notes.add(goUpNotes(root, 4));
      notes.add(goUpNotes(root, 7));
      return;
    }

    if (rest[0] == "5" && rest.length == 1) {
      // Get "C5"
      notes.add(goUpNotes(root, 7));
      return;
    }

    if ((rest.contains("m") && !rest.contains("maj")) || rest.contains("dim")) {
      // Get minor chords
      notes.add(goUpNotes(root, 3));
    } else {
      // major third
      notes.add(goUpNotes(root, 4));
    }

    if (rest.contains("-5") || rest.contains("b5") || rest.contains("dim")) {
      // flatened fifth
      notes.add(goUpNotes(root, 6));
    } else if (rest.contains("+5") ||
        rest.contains("#5") ||
        rest.contains("aug")) {
      // sharp fifth / augmented
      notes.add(goUpNotes(root, 8));
    } else {
      // perfect fifth
      notes.add(goUpNotes(root, 7));
    }

    if (rest.contains("maj") || rest.contains("M")) {
      // major seventh
      notes.add(goUpNotes(root, 11));
    } else if (rest.contains("7") ||
        (rest.contains("9") && !rest.contains("/") && !rest.contains("add")) ||
        rest.contains("11") ||
        rest.contains("13")) {
      if (rest.contains("dim")) {
        // diminished seventh
        notes.add(goUpNotes(root, 9));
      } else {
        // minor seventh
        notes.add(goUpNotes(root, 10));
      }
    }

    if (rest.contains("6")) {
      // sixth chords
      notes.add(goUpNotes(root, 9));
    }

    if (rest.contains("9") || rest.contains("11") || rest.contains("13")) {
      // ninth chords
      notes.add(goUpNotes(root, 14));
    }

    if (rest.contains("11") || (rest.contains("13") && !rest.contains("maj"))) {
      // eleventh chords
      notes.add(goUpNotes(root, 17));
    }

    if (rest.contains("13")) {
      // thirteenth chords
      notes.add(goUpNotes(root, 21));
    }

    if (rest.contains("sus")) {
      // remove third in suspended chords
      notes.removeAt(1);
    }

    if (rest.contains("2")) {
      // second chords
      notes.insert(1, goUpNotes(root, 2));
    }

    if (rest.contains("4")) {
      // fourth chords
      notes.insert(1, goUpNotes(root, 5));
    }
  }
}
