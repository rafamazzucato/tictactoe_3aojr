import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tictactoe_3aojr/models/game.dart';
import 'package:tictactoe_3aojr/utils/constants.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  
  Game? game;
  bool suaVez = false;
  List<List<int>> cells = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];

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
                        (game == null ? 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildButton("Criar", true),
                              const SizedBox(width: 10),
                              _buildButton("Entrar", false),
                            ],
                          )
                          : Text( suaVez ? "Sua vez!" : "Aguarde sua vez", style: textStyle36)),
                        
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

  Widget _buildButton(String label, bool isCreator){
    return SizedBox(
      width: ScreenUtil().setWidth(300),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(side: borderDefault),
        child: Padding(padding: paddingDefault,child: Text(label, style: textStyle36)),
        onPressed: () {
          
        })
    );
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
        onTap: () {});
  }
}
