import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.black54);
    return MaterialApp(
      title: 'Snake',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Test App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static List<int> snakePosition = [165, 185, 205, 225];
  int squaresNumber = 760;
  static var random = Random();
  int apple = random.nextInt(700);
  var direction = 'down';
  bool start = true;
  var bestScore;

  void generateApple() {
    this.apple = random.nextInt(700);
    if (snakePosition.contains(this.apple)) {
      generateApple();
    }
  }

  bool gameOver() {
    List<int> seenBefore = [];
    for (var i = 0 ; i < snakePosition.length ; i++) {
      if (seenBefore.contains(snakePosition[i])) {
        return true;
      } else {
        seenBefore.add(snakePosition[i]);
      }
    }
    return false;
  }

  void startGame() {
    if (start) {
      snakePosition = [165, 185, 205, 225];
      direction = 'down';
      start = false;
      const duration = const Duration(milliseconds: 300);
      Timer.periodic(duration, (Timer timer) {
        updateSnake();
        if (gameOver()) {
          start = true;
          timer.cancel();
          showMessage();
        }
      });
    }
  }

  void showMessage() {
    int length = snakePosition.length;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          if (length > this.bestScore) {
            this.bestScore = length;
            _updateBestScore();
            return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  title: Text(
                      "GAME OVER",
                      style: TextStyle(fontFamily: "HKNova-Medium", color: Colors.black54, fontSize: 27)
                  ),
                  content: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 100.0),
                      child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                "NEW BEST SCORE: $length",
                                style: TextStyle(fontFamily: "HKNova-Medium", color: Colors.orange, fontSize: 18)
                            ),
                          ]
                      )
                  )
            );
          } else {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                title: Text(
                    "GAME OVER",
                    style: TextStyle(fontFamily: "HKNova-Medium", color: Colors.black54, fontSize: 27)
                ),
                content: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 100.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            "You lost at level $length",
                            style: TextStyle(fontFamily: "HKNova-Medium", color: Colors.orange, fontSize: 18)
                        ),
                        Text(
                            "BestScore: $bestScore",
                            style: TextStyle(fontFamily: "HKNova-Medium", color: Colors.orange, fontSize: 18)
                        ),
                      ]
                  ),
                )
            );
          }
        }
        );
  }

  void updateSnake() {
    setState(() {
      switch(direction) {
        case 'down':
          if (snakePosition.last > 740) {
            snakePosition.add(snakePosition.last + 20 - 760);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break ;
        case 'up':
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last - 20 + 760);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break ;
        case 'left':
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break ;
        case 'right':
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break ;

        default:
      }
      if (snakePosition.last == apple) {
        generateApple();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  _readBestScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.bestScore = (prefs.getInt('BestScore') ?? 0);
  }

  _updateBestScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('BestScore', bestScore);
  }

  @override
  void initState() {
    super.initState();
    _readBestScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        body: Column(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (direction != 'up' && details.delta.dy > 0) {
                          direction = 'down';
                        } else if ( direction != 'down' && details.delta.dy < 0) {
                          direction = 'up';
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        if (direction != 'left' && details.delta.dx > 0) {
                          direction = 'right';
                        } else
                        if (direction != 'left' && details.delta.dx < 0) {
                          direction = 'left';
                        }
                      },
                      child: Container(
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: squaresNumber,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 20),
                          itemBuilder: (BuildContext context, int index) {
                            if (snakePosition.contains(index)) {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      color: (snakePosition.first == index) ? Colors.orangeAccent :
                                                ((snakePosition.last == index) ? Colors.deepOrangeAccent : Colors.orange), //CHANGER EN BLANC QUAND SNAKE READY
                                    ),
                                  ),
                                ),
                              );
                            } else if (index == apple) {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      color: Colors.green, //CHANGER EN BLANC QUAND SNAKE READY
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      color: Colors.white10, //CHANGER EN BLANC QUAND SNAKE READY
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: startGame,
                              child: Text(
                                'S T A R T',
                                style: TextStyle(fontFamily: "HKNova-Medium", color: Colors.white, fontSize: 20),
                              )
                            )
                          ]
                      )
                  )
                )
              ]
            )
    );
  }
}
