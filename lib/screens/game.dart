import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tictactoe_3aojr/models/game.dart';
import 'package:tictactoe_3aojr/utils/constants.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  static const platform = MethodChannel("game/exchange");

  Game? game;
  bool suaVez = false;
  List<List<int>> cells = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];

  final dialogTitle = const Text("Qual é o nome do jogo?");
  final buttonPlay = const Text("Jogar");
  final buttonCancel = const Text("Cancelar");

  @override
  void initState() {
    super.initState();
    _configureMethodChannelCallback();
  }

  _configureMethodChannelCallback() {
    platform.setMethodCallHandler((call) async {
      print('Flutter Platform received $call');

      final action = call.method;
      final arguments = call.arguments.toString().replaceAll("\"", "");
      final splitted = arguments.split("|");

      if (action == "sendAction") {
        final player = splitted[0];
        final x = int.parse(splitted[1]);
        final y = int.parse(splitted[2]);

        print('player $player, x $x e y $y');

        if (player == (game!.creator ? "p2" : "p1")) {
          setState(() {
            suaVez = true;
            cells[x][y] = 2;
          });

          _checkWinner();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(700, 1400));
    return Scaffold(
      body: SingleChildScrollView(
          child: Stack(children: [
        Column(children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(550),
                height: ScreenUtil().setHeight(550),
                color: colorBackBlue1,
              ),
              Container(
                width: ScreenUtil().setWidth(150),
                height: ScreenUtil().setHeight(550),
                color: colorBackBlue2,
              ),
            ],
          ),
          Container(
            width: ScreenUtil().setWidth(700),
            height: ScreenUtil().setHeight(850),
            color: colorBackBlue3,
          )
        ]),
        SizedBox(
            width: ScreenUtil().setWidth(700),
            height: ScreenUtil().setHeight(1400),
            child: Padding(
                padding: paddingDefault,
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (game == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildButton("Criar", true),
                                  const SizedBox(width: 10),
                                  _buildButton("Entrar", false),
                                ],
                              )
                            : Text(suaVez ? "Sua vez!" : "Aguarde sua vez",
                                style: textStyle36)),
                        GridView.count(
                            shrinkWrap: true,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            crossAxisCount: 3,
                            children: [
                              _getCell(0, 0),
                              _getCell(0, 1),
                              _getCell(0, 2),
                              _getCell(1, 0),
                              _getCell(1, 1),
                              _getCell(1, 2),
                              _getCell(2, 0),
                              _getCell(2, 1),
                              _getCell(2, 2),
                            ])
                      ]),
                )))
      ])),
    );
  }

  Widget _buildButton(String label, bool isCreator) {
    return SizedBox(
        width: ScreenUtil().setWidth(300),
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(side: borderDefault),
            child: Padding(
                padding: paddingDefault,
                child: Text(label, style: textStyle36)),
            onPressed: () {
              _createGame(isCreator);
            }));
  }

  Widget _getCell(int x, int y) {
    return InkWell(
        child: Container(
          padding: paddingDefault,
          color: colorBlueSquare,
          child: Center(
            child: Text(
                cells[x][y] == 0
                    ? ""
                    : cells[x][y] == 1
                        ? "X"
                        : "0",
                style: textStyle72),
          ),
        ),
        onTap: () async {
          if (suaVez == true && cells[x][y] == 0) {
            final result = await _sendAction(
                "sendAction", {"tap": "${game!.creator ? "p1" : "p2"}|$x|$y"});
            if (result) {
              setState(() {
                suaVez = false;
                cells[x][y] = 1;
              });
            }

            _checkWinner();
          }
        });
  }

  Future _createGame(bool isCreator) {
    final editingController = TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: dialogTitle,
            content: TextField(controller: editingController),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await _sendAction(
                        "subscribe", {"channel": editingController.text});
                    if (result) {
                      setState(() {
                        game = Game(editingController.text, isCreator);
                        suaVez = isCreator;
                      });
                    }
                  },
                  child: buttonPlay),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context), child: buttonCancel),
            ],
          );
        });
  }

  Future<bool> _sendAction(
      String action, Map<String, dynamic> arguments) async {
    try {
      final result = await platform.invokeMethod(action, arguments);
      if (result) {
        return true;
      }
    } on PlatformException catch (e) {
      print('Ocorreu erro ao enviar para plataforma nativa: $e');
    }

    return false;
  }

  _checkWinner() {
    bool youWin = false;
    bool otherWin = false;
    if (cells[0][0] != 0 &&
        cells[0][0] == cells[0][1] &&
        cells[0][0] == cells[0][2]) {
      if (cells[0][0] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    } else if (cells[1][0] != 0 &&
        cells[1][0] == cells[1][1] &&
        cells[1][0] == cells[1][2]) {
      if (cells[1][0] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    } else if (cells[2][0] != 0 &&
        cells[2][0] == cells[2][1] &&
        cells[2][0] == cells[2][2]) {
      if (cells[2][0] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    } else if (cells[0][0] != 0 &&
        cells[0][0] == cells[1][0] &&
        cells[0][0] == cells[2][0]) {
      if (cells[0][0] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    } else if (cells[0][1] != 0 &&
        cells[0][1] == cells[1][1] &&
        cells[0][1] == cells[2][1]) {
      if (cells[0][1] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    } else if (cells[0][2] != 0 &&
        cells[0][2] == cells[1][2] &&
        cells[0][2] == cells[2][2]) {
      if (cells[0][2] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    } else if (cells[0][0] != 0 &&
        cells[0][0] == cells[1][1] &&
        cells[0][0] == cells[2][2]) {
      if (cells[0][0] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    } else if (cells[0][2] != 0 &&
        cells[0][2] == cells[1][1] &&
        cells[0][2] == cells[2][0]) {
      if (cells[0][2] == 1) {
        youWin = true;
      } else {
        otherWin = true;
      }
    }

    if (youWin) {
      _showFinishGame(true);
    } else if (otherWin) {
      _showFinishGame(false);
    } else {
      bool allPlaysDone = true;

      for (var line in cells) {
        for (var col in line) {
          if (allPlaysDone == false) break;
          if (col == 0) {
            allPlaysDone = false;
            break;
          }
        }
      }

      if (allPlaysDone) {
        _showFinishGame(null);
      }
    }
  }

  Future _showFinishGame(bool? youWin) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("FIM DE JOGO"),
            content: Text(youWin == true
                ? "Você ganhou"
                : youWin == false
                    ? "Você perdeu"
                    : "Não houve Ganhadores"),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      game = null;
                      suaVez = false;
                      cells = [
                        [0, 0, 0],
                        [0, 0, 0],
                        [0, 0, 0]
                      ];
                    });
                  },
                  child: const Text("Fechar")),
            ],
          );
        });
  }
}
