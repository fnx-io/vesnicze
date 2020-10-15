import 'dart:math';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:vesnicze/data.dart';
import 'package:vesnicze/model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: VesniczeScreen());
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

    var commonWidget = CustomPaint(size: Size(cellWidth, cellHeight), painter: PanaCzechPaint(Colors.grey.shade200));
    var deadWidget = CustomPaint(size: Size(cellWidth, cellHeight), painter: PanaCzechPaint(Colors.black));
    var infectedWidget = CustomPaint(size: Size(cellWidth, cellHeight), painter: PanaCzechPaint(Colors.yellow.shade600));
    var hospitalWidget = CustomPaint(size: Size(cellWidth, cellHeight), painter: PanaCzechPaint(Colors.red));
    var fineWidget = CustomPaint(size: Size(cellWidth, cellHeight), painter: PanaCzechPaint(Colors.green.shade600));

    var nums = (data['data'] as List).first.cast<String, num>();
    VesniczeModel model = VesniczeModel(commonWidget);

    model.addPopulation(fineWidget, (nums['vyleceni'] * screenPeople / allPeople).round());
    model.addPopulation(deadWidget, max((nums['umrti'] * screenPeople / allPeople).round(), 1));
    model.addPopulation(hospitalWidget, (nums['aktualne_hospitalizovani'] * screenPeople / allPeople).round());
    model.addPopulation(infectedWidget, (nums['aktivni_pripady'] * screenPeople / allPeople).round());

    List<Widget> panaczkys = List.generate(screenPeople, (index) {
      int ry = index ~/ columns;
      int rx = index % columns;
      if (rx == 0) model.next();
      return Positioned(top: ry * cellHeight, left: rx * cellWidth, height: cellHeight, width: cellWidth, child: model.take());
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
      ..strokeWidth = (size.width / 8).ceilToDouble()
      ..style = PaintingStyle.stroke;

    if (size.width < 8) {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.5), size.width * 0.4, paint);
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
    canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.15), size.width / 7, paint);
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
