import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'timer_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'GuessChords',
        initialRoute: '/home',
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => const MyHomePage(title: 'GuessChords'),
        });
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var best;
  int _difficulty = 1;
  var difficulty = ['Fácil', 'Médio', 'Díficil', 'Extremo'];

  void valueChanged(value) {
    setState(() {
      _difficulty = value.round();
    });
  }

  String getDifficulty(double index) {
    return difficulty[index.round() - 1];
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      best = prefs.getInt("highscore");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title, style: const TextStyle(fontSize: 30.0)),
          toolbarHeight: 65,
          backgroundColor: const Color.fromRGBO(80, 80, 80, 1)),
      body: Container(
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
              Flexible(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 75,
                      left: 52,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter:
                            CirclePainter(const Color.fromRGBO(60, 60, 60, 1)),
                      ),
                    ),
                    Positioned(
                      top: 70,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter:
                            CirclePainter(const Color.fromRGBO(80, 80, 80, 1)),
                      ),
                    ),
                    const Positioned(
                      top: 115,
                      left: 102,
                      child: FaIcon(FontAwesomeIcons.guitar,
                          color: Color.fromRGBO(224, 224, 224, 100), size: 200),
                    ),
                    const Positioned(
                      top: 105,
                      child: FaIcon(FontAwesomeIcons.guitar,
                          color: Colors.white, size: 200),
                    )
                  ],
                ),
              ), // Desenhos
              Container(
                  height: 60,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width - 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Dificuldade:',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Color.fromRGBO(150, 150, 161, 1),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 25,
                          child: Slider(
                            activeColor: const Color.fromRGBO(150, 150, 161, 1),
                            inactiveColor:
                                const Color.fromRGBO(180, 180, 192, 1),
                            min: 1.0,
                            max: 4.0,
                            value: _difficulty.toDouble(),
                            divisions: 3,
                            label: getDifficulty(_difficulty.toDouble()),
                            onChanged: (value) {
                              valueChanged(value);
                            },
                          ),
                        )
                      ],
                    ),
                  )), // Dificuldade
              Container(
                  height: 150,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 30),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(80, 80, 80, 1),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(80, 80, 80, 0.5),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: FlatButton(
                      height: 60,
                      minWidth: MediaQuery.of(context).size.width - 50,
                      child: const Text('Começar',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        pushStart();
                      },
                    ),
                  )), // Botao
              best != null
                  ? Container(
                          height: 40,
                          alignment: Alignment.topCenter,
                          //padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'highscore: $best',
                            style: const TextStyle(
                                fontSize: 20.0,
                                color: Color.fromRGBO(150, 150, 161, 1),
                                fontWeight: FontWeight.bold),
                          ))
                  : Container(height: 60,)
            ],
          )),
    );
  }

  void pushStart() {
    //Navigator.of(context).pushNamed('/timer', arguments: {_time, _difficulty} );
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TimerPage(difficulty: _difficulty)));
  }
}

class CirclePainter extends CustomPainter {
  Color color = Colors.white;

  CirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 15;

    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, 100, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
