// ignore_for_file: unused_local_variable

//import 'dart:ui';

import 'dart:ui';

import 'package:flutter/material.dart';

//DottedBorderWidget

class DashedBorder extends StatefulWidget {
  //const DashedBorder({super.key, this.color, required this.strokeWidth, required this.dotsWidth, required this.gap, required this.radius, required this.child, this.padding});

  final Color? color;
  final double strokeWidth;
  final double dotsWidth;
  final double gap;
  final double radius;
  final Widget child;
  final EdgeInsets? padding;

  const DashedBorder({
    Key? key,
    this.color = Colors.black,
    this.dotsWidth = 5.0,
    this.gap = 3.0,
    this.radius = 0,
    this.strokeWidth = 1.0,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DashedBorderState createState() => _DashedBorderState();
}

class _DashedBorderState extends State<DashedBorder> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedCustomPaint(
        color: widget.color!,
        dottedLength: widget.dotsWidth,
        space: widget.gap,
        strokeWidth: widget.strokeWidth,
        radius: widget.radius,
      ),
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(2),
        child: widget.child,
      ),
    );
  }
}

class _DottedCustomPaint extends CustomPainter {
  Color? color;
  double? dottedLength;
  double? space;
  double? strokeWidth;
  double? radius;

  _DottedCustomPaint({
    this.color,
    this.dottedLength,
    this.space,
    this.strokeWidth,
    this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth!;

    Path path = Path();
    path.addRRect(RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius!),
    ));

    Path draw = buildDashPath(path, dottedLength!, space!);
    canvas.drawPath(draw, paint);
  }

  Path buildDashPath(Path path, double dottedLength, double space) {
    final Path r = Path();
    for (PathMetric metric in path.computeMetrics()) {
      double start = 0.0;
      while (start < metric.length) {
        double end = start + dottedLength;
        r.addPath(metric.extractPath(start, end), Offset.zero);
        start = end + space;
      }
    }
    return r;
  }

  @override
  bool shouldRepaint(_DottedCustomPaint oldDelegate) {
    return true;
  }
}
