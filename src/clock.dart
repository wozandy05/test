import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analog Clock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ClockHomePage(),
    );
  }
}

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: AnalogClock(),
      ),
    );
  }
}

class AnalogClock extends StatefulWidget {
  const AnalogClock({super.key});

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  DateTime _dateTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _dateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: ClockPainter(dateTime: _dateTime),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter({required this.dateTime});

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);
    double radius = min(centerX, centerY);

    // Draw clock face
    Paint facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Draw clock border
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw hour markers
    for (int i = 0; i < 12; i++) {
      double angle = i * 2 * pi / 12 - pi / 2;
      Offset offset = Offset(
        centerX + (radius - 20) * cos(angle),
        centerY + (radius - 20) * sin(angle),
      );
      TextPainter tp = TextPainter(
        text: TextSpan(
            text: (i == 0) ? '12' : '${i}',
            style: const TextStyle(color: Colors.black, fontSize: 16)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
          canvas,
          Offset(offset.dx - tp.width / 2,
              offset.dy - tp.height / 2)); // Center the text
    }

    // Draw minute markers
    for (int i = 0; i < 60; i++) {
      double angle = i * 2 * pi / 60 - pi / 2;
      Offset offset = Offset(
        centerX + (radius - 8) * cos(angle),
        centerY + (radius - 8) * sin(angle),
      );
      Paint minuteMarkPaint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(offset, 2, minuteMarkPaint);
    }

    // Calculate hand angles
    double hourAngle = (dateTime.hour % 12 + dateTime.minute / 60) * 2 * pi / 12 - pi / 2;
    double minuteAngle = dateTime.minute * 2 * pi / 60 - pi / 2;
    double secondAngle = dateTime.second * 2 * pi / 60 - pi / 2;

    // Draw hour hand
    Paint hourHandPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    Offset hourHandOffset = Offset(
      centerX + (radius * 0.5) * cos(hourAngle),
      centerY + (radius * 0.5) * sin(hourAngle),
    );
    canvas.drawLine(center, hourHandOffset, hourHandPaint);

    // Draw minute hand
    Paint minuteHandPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    Offset minuteHandOffset = Offset(
      centerX + (radius * 0.8) * cos(minuteAngle),
      centerY + (radius * 0.8) * sin(minuteAngle),
    );
    canvas.drawLine(center, minuteHandOffset, minuteHandPaint);

    // Draw second hand
    Paint secondHandPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    Offset secondHandOffset = Offset(
      centerX + (radius * 0.9) * cos(secondAngle),
      centerY + (radius * 0.9) * sin(secondAngle),
    );
    canvas.drawLine(center, secondHandOffset, secondHandPaint);

    // Draw center dot
    Paint centerDotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 4, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime;
  }
}