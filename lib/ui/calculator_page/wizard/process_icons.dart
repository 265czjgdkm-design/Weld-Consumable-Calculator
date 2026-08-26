import 'package:flutter/material.dart';

import '../../../models/weld_models.dart';

/// Hand-coded torch/electrode-holder silhouettes, one per [WeldingProcess],
/// drawn the same way as [VaryosMark] in `calculator_page_widgets.dart`: a
/// 200x200 virtual coordinate space scaled to the actual paint size via a
/// `p(x, y)` helper, so every icon stays crisp at any card size.
class ProcessIcon extends StatelessWidget {
  const ProcessIcon({
    super.key,
    required this.process,
    this.size = 64,
    this.color = const Color(0xFF12191B),
  });

  final WeldingProcess process;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final painter = switch (process) {
      WeldingProcess.gtaw => _GtawIconPainter(color: color),
      WeldingProcess.smaw => _SmawIconPainter(color: color),
      WeldingProcess.gtawSmaw => _GtawSmawIconPainter(color: color),
      WeldingProcess.gmaw => _GmawIconPainter(color: color),
      WeldingProcess.fcaw => _FcawIconPainter(color: color),
    };
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: painter),
    );
  }
}

const Color _orangeAccent = Color(0xFFFF6A35);
const Color _tealAccent = Color(0xFF2B3538);

/// Draws a straight tapered "wand" body (shared by the GTAW/GMAW/FCAW torch
/// shapes) centered at the origin and pointing along +x, so callers just
/// rotate/translate the canvas before calling this.
void _drawTorchWand(Canvas canvas, Paint bodyPaint, double scale) {
  final body = RRect.fromRectAndRadius(
    Rect.fromLTRB(-62 * scale, -15 * scale, 34 * scale, 15 * scale),
    Radius.circular(11 * scale),
  );
  canvas.drawRRect(body, bodyPaint);
}

class _GtawIconPainter extends CustomPainter {
  _GtawIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.save();
    canvas.translate(size.width * 0.42, size.height * 0.58);
    canvas.rotate(-0.78);

    final bodyPaint = Paint()..color = color;
    _drawTorchWand(canvas, bodyPaint..strokeWidth = 0, scale);

    // Tapered nozzle narrowing to the tungsten tip.
    final nozzle = Path()
      ..moveTo(34 * scale, -15 * scale)
      ..lineTo(34 * scale, 15 * scale)
      ..lineTo(78 * scale, 3 * scale)
      ..lineTo(78 * scale, -3 * scale)
      ..close();
    canvas.drawPath(nozzle, bodyPaint);

    // Fine pointed tungsten electrode tip, in the orange accent.
    final tipPaint = Paint()..color = _orangeAccent;
    final tip = Path()
      ..moveTo(78 * scale, -3 * scale)
      ..lineTo(78 * scale, 3 * scale)
      ..lineTo(102 * scale, 0)
      ..close();
    canvas.drawPath(tip, tipPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GtawIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SmawIconPainter extends CustomPainter {
  _SmawIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    final bodyPaint = Paint()..color = color;

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.62);

    // Vertical pistol grip.
    canvas.save();
    canvas.rotate(-0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-16 * scale, 0, 16 * scale, 74 * scale),
        Radius.circular(10 * scale),
      ),
      bodyPaint,
    );
    canvas.restore();

    // Horizontal head/jaw the grip clamps into.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-46 * scale, -22 * scale, 30 * scale, 6 * scale),
        Radius.circular(9 * scale),
      ),
      bodyPaint,
    );

    // Covered electrode protruding from the jaw at a shallow angle, with
    // an orange tip standing in for the exposed arc end.
    canvas.save();
    canvas.translate(-46 * scale, -8 * scale);
    canvas.rotate(-0.55);
    final rodPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-58 * scale, -5 * scale, 6 * scale, 5 * scale),
        Radius.circular(4 * scale),
      ),
      rodPaint,
    );
    final tipPaint = Paint()..color = _orangeAccent;
    canvas.drawCircle(Offset(-58 * scale, 0), 6 * scale, tipPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SmawIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GmawIconPainter extends CustomPainter {
  _GmawIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.save();
    canvas.translate(size.width * 0.4, size.height * 0.58);
    canvas.rotate(-0.78);

    final bodyPaint = Paint()..color = color;
    _drawTorchWand(canvas, bodyPaint, scale);

    // Rounded gas cup / nozzle at the working end, outlined rather than
    // filled so it reads as a distinct part instead of blending into the
    // solid body behind it.
    final cupPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(28 * scale, -18 * scale, 68 * scale, 18 * scale),
        Radius.circular(9 * scale),
      ),
      cupPaint,
    );

    // Wire tip poking out past the cup, in the orange accent.
    final wirePaint = Paint()
      ..color = _orangeAccent
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(66 * scale, 0),
      Offset(92 * scale, 0),
      wirePaint,
    );
    canvas.drawCircle(Offset(92 * scale, 0), 4 * scale, wirePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GmawIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FcawIconPainter extends CustomPainter {
  _FcawIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.save();
    canvas.translate(size.width * 0.4, size.height * 0.58);
    canvas.rotate(-0.78);

    final bodyPaint = Paint()..color = color;
    _drawTorchWand(canvas, bodyPaint, scale);

    // Same gun-style gas cup as GMAW, but outlined in teal instead of a
    // solid fill and paired with a hollow "cored wire" ring at the tip
    // (instead of GMAW's solid wire dot) so the two are distinguishable
    // at a glance without changing the overall silhouette.
    final cupOutlinePaint = Paint()
      ..color = _tealAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(28 * scale, -18 * scale, 68 * scale, 18 * scale),
        Radius.circular(9 * scale),
      ),
      cupOutlinePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(30 * scale, -16 * scale, 66 * scale, 16 * scale),
        Radius.circular(8 * scale),
      ),
      bodyPaint,
    );

    final wirePaint = Paint()
      ..color = _orangeAccent
      ..strokeWidth = 5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(66 * scale, 0),
      Offset(90 * scale, 0),
      wirePaint,
    );
    final ringPaint = Paint()
      ..color = _orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale;
    canvas.drawCircle(Offset(90 * scale, 0), 6 * scale, ringPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FcawIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _GtawSmawIconPainter extends CustomPainter {
  _GtawSmawIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Overlap simplified GTAW and SMAW marks, each scaled down and offset
    // to opposite corners, to read as a single "combined process" glyph
    // rather than two full-size icons competing for the same space.
    canvas.save();
    canvas.translate(size.width * 0.06, size.height * 0.02);
    canvas.scale(0.62);
    _GtawIconPainter(color: color).paint(canvas, size);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.3, size.height * 0.32);
    canvas.scale(0.62);
    _SmawIconPainter(color: color).paint(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GtawSmawIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
