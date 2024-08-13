import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Paint App',
      debugShowCheckedModeBanner: false,
      home: PaintApp(),
    );
  }
}

class DrawingArea {
  Offset points;
  Paint areaPaint;
  DrawingArea({required this.points, required this.areaPaint});
}

class PaintApp extends StatefulWidget {
  const PaintApp({super.key});

  @override
  State<PaintApp> createState() => _PaintAppState();
}

class _PaintAppState extends State<PaintApp> {
  List<DrawingArea?> points = [];
  late Color selectedColor;
  late double strokeWidth;

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  addPoints(details) {
    setState(() {
      points.add(
        DrawingArea(
            points: details,
            areaPaint: Paint()
              ..color = selectedColor
              ..strokeWidth = strokeWidth
              ..isAntiAlias = true
              ..strokeCap = StrokeCap.round),
      );
    });
  }

  selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (value) {
              setState(() {
                selectedColor = value;
              });
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint App'),
        centerTitle: true,
      ),
      body: Container(
        height: height,
        width: width,
        color: Colors.cyan,
        child: GestureDetector(
          onPanStart: (details) {
            addPoints(details.localPosition);
          },
          onPanUpdate: (details) {
            addPoints(details.localPosition);
          },
          onPanEnd: (details) {
            setState(() {
              points.add(null);
            });
          },
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: MyCustomPainter(points),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        height: 50,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                selectColor();
              },
              icon: Icon(
                Icons.color_lens,
                color: selectedColor,
              ),
            ),
            Flexible(
              child: Slider(
                activeColor: selectedColor,
                value: strokeWidth,
                min: 1.0,
                max: 10.0,
                label: '$strokeWidth',
                onChanged: (value) {
                  setState(() {
                    strokeWidth = value;
                  });
                },
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  points.clear();
                });
              },
              icon: const Icon(Icons.layers_clear),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea?> points;
  MyCustomPainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i]!.areaPaint;
        canvas.drawLine(points[i]!.points, points[i + 1]!.points, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        Paint paint = points[i]!.areaPaint;
        canvas.drawPoints(ui.PointMode.points, [points[i]!.points], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
