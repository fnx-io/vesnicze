import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:vesnicze/data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: VesniczeScreen());
  }
}

class VesniczeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VesniczeView();
  }
}

class VesniczeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildUi);
  }

  Widget _buildUi(BuildContext context, BoxConstraints constraints) {
    var screenWidth = constraints.maxWidth - 20;
    var screenHeight = constraints.maxHeight - 20;
    var ratio = screenWidth / screenHeight;

    int allPeople = 10600000;
    int vesniczePeople = allPeople ~/ 1000;

    int rows = sqrt(vesniczePeople / ratio).floor();
    int columns = (rows * ratio).floor();

    var cellWidth = (screenWidth / columns).floorToDouble();
    var cellHeight = (screenHeight / rows).floorToDouble();

    columns = (screenWidth / cellWidth).floor();
    rows = (screenHeight / cellHeight).floor();

    int screenPeople = columns * rows;

    var nums = (data['data'] as List).first.cast<String, num>();
    int deadCount = max((nums['umrti'] * screenPeople / allPeople).round(), 1);
    int hospitalCount = (nums['aktualne_hospitalizovani'] * screenPeople / allPeople).round() + deadCount;
    int infectedCount = (nums['aktivni_pripady'] * screenPeople / allPeople).round() + hospitalCount;
    int fineCount = (nums['vyleceni'] * screenPeople / allPeople).round() + infectedCount;

    var commonWidget = CustomPaint(
        size: Size(cellWidth, cellHeight), //You can Replace this with your desired WIDTH and HEIGHT
        painter: PanaCzechPaint(Colors.grey.shade200));

    var deadWidget = CustomPaint(
        size: Size(cellWidth, cellHeight), //You can Replace this with your desired WIDTH and HEIGHT
        painter: PanaCzechPaint(Colors.black));

    var infectedWidget = CustomPaint(
        size: Size(cellWidth, cellHeight), //You can Replace this with your desired WIDTH and HEIGHT
        painter: PanaCzechPaint(Colors.yellow.shade600));

    var hospitalWidget = CustomPaint(
        size: Size(cellWidth, cellHeight), //You can Replace this with your desired WIDTH and HEIGHT
        painter: PanaCzechPaint(Colors.red));

    var fineWidget = CustomPaint(
        size: Size(cellWidth, cellHeight), //You can Replace this with your desired WIDTH and HEIGHT
        painter: PanaCzechPaint(Colors.green.shade600));

    List<Widget> panaczkys = List.generate(screenPeople, (index) {
      int ry = index ~/ columns;
      int rx = index % columns;

      Widget p = commonWidget;
      if (index < deadCount) {
        p = deadWidget;
      } else if (index < hospitalCount) {
        p = hospitalWidget;
      } else if (index < infectedCount) {
        p = infectedWidget;
      } else if (index < fineCount) {
        p = fineWidget;
      }
      return Positioned(top: ry * cellHeight, left: rx * cellWidth, height: cellHeight, width: cellWidth, child: p);
    }).toList();

    print("Celkem panacku: $screenPeople");
    return Container(
        color: Colors.white,
        child: Center(
            child: SizedBox(
          width: columns * cellWidth,
          height: rows * cellHeight,
          child: Stack(
            children: panaczkys,
          ),
        )));
  }
}

class PanaCzechPaint extends CustomPainter {
  final Color color;

  const PanaCzechPaint(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..isAntiAlias = false
      ..color = color
      ..strokeWidth = (size.width / 10).ceilToDouble()
      ..style = PaintingStyle.stroke;

    if (size.width < 8) {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.5), size.width / 3, paint);
      return;
    }

    Path path = Path();
    path.moveTo(size.width * 0.20, size.height * 0.40);
    path.lineTo(size.width * 0.80, size.height * 0.40);
    path.moveTo(size.width * 0.50, size.height * 0.30);
    path.lineTo(size.width * 0.50, size.height * 0.60);
    path.lineTo(size.width * 0.30, size.height * 0.90);
    path.moveTo(size.width * 0.50, size.height * 0.60);
    path.lineTo(size.width * 0.70, size.height * 0.90);
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.2), size.width / 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PanaCzechPaint && runtimeType == other.runtimeType && color == other.color;

  @override
  int get hashCode => color.hashCode;
}
