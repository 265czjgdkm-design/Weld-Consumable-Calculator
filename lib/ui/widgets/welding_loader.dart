import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small welding-themed loading indicator: a hammer swings in from the
/// upper right and strikes the brand V mark, throwing an orange spark
/// burst -- a drop-in, on-brand replacement for [CircularProgressIndicator]
/// wherever the app needs a spinner (inline buttons, full-screen loads).
///
/// Uses the SAME 200x200 `p(x, y)` coordinate convention as
/// `_VaryosMarkPainter` (calculator_page_widgets.dart) so the hammer's
/// impact point lands exactly on that mark's existing spark diamond
/// ((100,136)-(112,158)-(100,180)-(88,158), impact point ~(100,158)). The
/// blade/spark path literals are intentionally duplicated locally rather
/// than reaching into that private class.
class WeldingLoader extends StatefulWidget {
  const WeldingLoader({
    super.key,
    required this.size,
    this.loop = true,
    this.onComplete,
    this.bladeColor = Colors.white,
  });

  final double size;

  /// True (default) for inline/button spinners: repeats forever. False for
  /// the splash's one-shot hammer-strike beat, which calls [onComplete]
  /// once the swing-strike-retract cycle finishes.
  final bool loop;

  final VoidCallback? onComplete;

  /// The V mark's blade color. Defaults to white, which reads correctly on
  /// this app's dark surfaces (splash, email gate). Callers placing this on
  /// a light surface (e.g. account_screen.dart's light theme) should pass a
  /// dark color instead, or the blades will have no contrast.
  final Color bladeColor;

  @override
  State<WeldingLoader> createState() => _WeldingLoaderState();
}

class _WeldingLoaderState extends State<WeldingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.addStatusListener(_handleStatus);
      _controller.forward();
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    if (!widget.loop) {
      _controller.removeStatusListener(_handleStatus);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final simplified = widget.size < 40;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WeldingLoaderPainter(
              progress: _controller.value,
              simplified: simplified,
              bladeColor: widget.bladeColor,
            ),
          );
        },
      ),
    );
  }
}

class _WeldingLoaderPainter extends CustomPainter {
  _WeldingLoaderPainter({
    required this.progress,
    required this.simplified,
    required this.bladeColor,
  });

  final double progress;
  final bool simplified;
  final Color bladeColor;

  // Beat weights per the plan: idle/up ~30%, swing ~20%, impact+flash ~15%,
  // retract ~35%, so a looping instance doesn't feel frantic at small sizes.
  static const _idleEnd = 0.30;
  static const _swingEnd = 0.50;
  static const _impactEnd = 0.65;
  static const _cockAngle = 0.85;

  static const _particleAnglesDeg = <double>[
    190.0,
    215.0,
    240.0,
    265.0,
    290.0,
    315.0,
    340.0,
    5.0,
  ];

  double get _hammerAngle {
    if (progress < _idleEnd) return _cockAngle;
    if (progress < _swingEnd) {
      final t = (progress - _idleEnd) / (_swingEnd - _idleEnd);
      return _cockAngle * (1 - Curves.easeIn.transform(t));
    }
    if (progress < _impactEnd) return 0.0;
    final t = (progress - _impactEnd) / (1 - _impactEnd);
    return _cockAngle * Curves.easeOut.transform(t);
  }

  /// Null outside the swing-to-impact window, otherwise a linear 0..1
  /// position within it (used to drive both the flash bump and the
  /// outward-flying particles).
  double? get _impactWindowT {
    if (progress < _swingEnd || progress > _impactEnd) return null;
    return (progress - _swingEnd) / (_impactEnd - _swingEnd);
  }

  double get _flashIntensity {
    final t = _impactWindowT;
    if (t == null) return 0.0;
    if (t < 0.35) return Curves.easeOut.transform(t / 0.35);
    return 1.0 - Curves.easeIn.transform((t - 0.35) / 0.65);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    Offset p(double x, double y) => Offset(x * scale, y * scale);

    final flash = _flashIntensity;
    _paintMark(canvas, p, sparkAlpha: simplified ? _lerp(0.5, 1.0, flash) : 1.0);

    if (flash > 0.01) {
      _paintFlash(canvas, p, scale, flash);
    }
    if (!simplified) {
      final windowT = _impactWindowT;
      if (windowT != null) {
        _paintParticles(canvas, p, scale, windowT);
      }
      _paintHammer(canvas, p, scale);
    }
  }

  void _paintMark(
    Canvas canvas,
    Offset Function(double, double) p, {
    required double sparkAlpha,
  }) {
    final bladePaint = Paint()..color = bladeColor;
    final leftBlade = Path()
      ..moveTo(p(40, 25).dx, p(40, 25).dy)
      ..lineTo(p(65, 25).dx, p(65, 25).dy)
      ..lineTo(p(108, 168).dx, p(108, 168).dy)
      ..lineTo(p(83, 168).dx, p(83, 168).dy)
      ..close();
    final rightBlade = Path()
      ..moveTo(p(160, 25).dx, p(160, 25).dy)
      ..lineTo(p(135, 25).dx, p(135, 25).dy)
      ..lineTo(p(92, 168).dx, p(92, 168).dy)
      ..lineTo(p(117, 168).dx, p(117, 168).dy)
      ..close();
    canvas.drawPath(leftBlade, bladePaint);
    canvas.drawPath(rightBlade, bladePaint);

    final sparkPaint = Paint()
      ..color = const Color(0xFFFF6A35).withValues(alpha: sparkAlpha);
    final spark = Path()
      ..moveTo(p(100, 136).dx, p(100, 136).dy)
      ..lineTo(p(112, 158).dx, p(112, 158).dy)
      ..lineTo(p(100, 180).dx, p(100, 180).dy)
      ..lineTo(p(88, 158).dx, p(88, 158).dy)
      ..close();
    canvas.drawPath(spark, sparkPaint);
  }

  void _paintFlash(
    Canvas canvas,
    Offset Function(double, double) p,
    double scale,
    double intensity,
  ) {
    final center = p(100, 158);
    final radius = 46 * scale;
    final innerAlpha = (0x99 * intensity).clamp(0, 255).round();
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color(0xFF6A35 | (innerAlpha << 24)),
          const Color(0x00FF6A35),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _paintParticles(
    Canvas canvas,
    Offset Function(double, double) p,
    double scale,
    double windowT,
  ) {
    final impact = p(100, 158);
    for (var i = 0; i < _particleAnglesDeg.length; i++) {
      final stagger = (i * 0.03).clamp(0.0, 0.3);
      final t = ((windowT - stagger) / (1 - stagger)).clamp(0.0, 1.0);
      final distance = t * 34 * scale;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final angle = _particleAnglesDeg[i] * math.pi / 180;
      final dx = math.cos(angle) * distance;
      final dy = math.sin(angle) * distance;

      canvas.save();
      canvas.translate(impact.dx + dx, impact.dy + dy);
      canvas.rotate(angle);
      final paint = Paint()
        ..shader =
            LinearGradient(
              colors: [
                const Color(0xFFFFD9A0).withValues(alpha: opacity),
                const Color(0xFFFF6A35).withValues(alpha: opacity),
              ],
            ).createShader(
              Rect.fromCenter(
                center: Offset.zero,
                width: 14 * scale,
                height: 4 * scale,
              ),
            );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 14 * scale,
            height: 4 * scale,
          ),
          Radius.circular(2 * scale),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _paintHammer(
    Canvas canvas,
    Offset Function(double, double) p,
    double scale,
  ) {
    final impact = p(100, 158);
    canvas.save();
    canvas.translate(impact.dx, impact.dy);
    canvas.rotate(_hammerAngle);
    canvas.scale(scale);

    // Sized boldly relative to the 200x200 space (not to the 200x16-ish
    // proportions of the V blades) since this whole shape is scaled down a
    // lot at the sizes this widget is actually used at (e.g. 52px in the
    // splash frame) -- anything thinner reads as invisible once scaled.
    final handlePaint = Paint()..color = const Color(0xFF9AA5A8);
    canvas.drawRRect(
      RRect.fromLTRBR(-7, -58, 7, -10, const Radius.circular(5)),
      handlePaint,
    );

    final headRect = const Rect.fromLTRB(-28, -70, 28, -46);
    final headPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFCBD4D0)],
      ).createShader(headRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(6)),
      headPaint,
    );

    canvas.restore();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _WeldingLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.simplified != simplified ||
      oldDelegate.bladeColor != bladeColor;
}
