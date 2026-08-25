import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/weld_models.dart';
import '../calculator_page/calculator_page_models.dart' show FieldKey;

enum DrawingMode { visual, technical }

/// A tappable region of the drawing that corresponds to one editable
/// [FieldKey], recorded by the painter at the exact spot it draws that
/// dimension's label so a tap on the drawing can jump to the matching
/// input field below.
class DrawingHotspot {
  const DrawingHotspot(this.fieldKey, this.center, this.radius);

  final FieldKey fieldKey;
  final Offset center;
  final double radius;
}

extension DrawingModeX on DrawingMode {
  String get label => switch (this) {
    DrawingMode.visual => 'Visual',
    DrawingMode.technical => 'Technical',
  };
}

class WeldDrawingData {
  const WeldDrawingData({
    required this.weldingProcess,
    required this.geometryMode,
    required this.alignment,
    this.thicknessMm,
    this.thicknessAMm,
    this.thicknessBMm,
    this.rootGapMm,
    this.rootFaceMm,
    this.bevelAngleDeg,
    this.secondaryBevelAngleDeg,
    this.breakHeightMm,
    this.legSizeMm,
    this.pipeOdMm,
    this.pipeOdAMm,
    this.pipeOdBMm,
    this.gtawTransitionMm,
  });

  final WeldingProcess weldingProcess;
  final JointGeometryMode geometryMode;
  final JointAlignment alignment;
  final double? thicknessMm;
  final double? thicknessAMm;
  final double? thicknessBMm;
  final double? rootGapMm;
  final double? rootFaceMm;
  final double? bevelAngleDeg;
  final double? secondaryBevelAngleDeg;
  final double? breakHeightMm;
  final double? legSizeMm;
  final double? pipeOdMm;
  final double? pipeOdAMm;
  final double? pipeOdBMm;
  final double? gtawTransitionMm;
}

class WeldDrawingPreview extends StatefulWidget {
  const WeldDrawingPreview({
    super.key,
    required this.grooveType,
    required this.jointType,
    required this.drawingMode,
    required this.data,
    this.onFieldTap,
    this.fillAvailableSpace = false,
  });

  final GrooveType grooveType;
  final JointType jointType;
  final DrawingMode drawingMode;
  final WeldDrawingData data;

  /// Called with the [FieldKey] of the dimension nearest to a tap on the
  /// drawing, so the caller can scroll to and focus that input field.
  final ValueChanged<FieldKey>? onFieldTap;

  /// When true, the painter renders directly at whatever box its parent
  /// gives it (which must have bounded width AND height) instead of being
  /// drawn on a fixed 760x400 virtual canvas that then gets shrunk by an
  /// outer FittedBox. On a small pinned mobile card that outer shrink was
  /// crushing dimension label font sizes to the point of illegibility;
  /// rendering at the real box size keeps every font/stroke constant in
  /// this file at its intended, legible on-screen pixel size.
  final bool fillAvailableSpace;

  @override
  State<WeldDrawingPreview> createState() => _WeldDrawingPreviewState();
}

class _WeldDrawingPreviewState extends State<WeldDrawingPreview> {
  List<DrawingHotspot> _hotspots = const [];

  @override
  Widget build(BuildContext context) {
    final gestureDetector = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: widget.onFieldTap == null ? null : _handleTapUp,
      child: CustomPaint(
        painter: _WeldDrawingPainter(
          grooveType: widget.grooveType,
          jointType: widget.jointType,
          drawingMode: widget.drawingMode,
          data: widget.data,
          onHotspots: (hotspots) => _hotspots = hotspots,
          fillAvailableSpace: widget.fillAvailableSpace,
        ),
        child: const SizedBox.expand(),
      ),
    );

    if (widget.fillAvailableSpace) {
      return SizedBox.expand(child: gestureDetector);
    }

    return AspectRatio(aspectRatio: 1.9, child: gestureDetector);
  }

  void _handleTapUp(TapUpDetails details) {
    final tapPosition = details.localPosition;
    DrawingHotspot? nearest;
    var nearestDistanceSq = double.infinity;
    for (final hotspot in _hotspots) {
      final distanceSq = (hotspot.center - tapPosition).distanceSquared;
      if (distanceSq > hotspot.radius * hotspot.radius) continue;
      if (distanceSq < nearestDistanceSq) {
        nearest = hotspot;
        nearestDistanceSq = distanceSq;
      }
    }
    if (nearest != null) {
      widget.onFieldTap!(nearest.fieldKey);
    }
  }
}

class _SectionLayout {
  const _SectionLayout({
    required this.scale,
    required this.centerX,
    required this.topY,
  });

  final double scale;
  final double centerX;
  final double topY;

  Offset point(double x, double y) =>
      Offset(centerX + (x * scale), topY + (y * scale));
}

class _MemberExtents {
  const _MemberExtents({
    required this.leftTop,
    required this.leftBottom,
    required this.rightTop,
    required this.rightBottom,
  });

  final double leftTop;
  final double leftBottom;
  final double rightTop;
  final double rightBottom;
}

class _WeldDrawingPainter extends CustomPainter {
  _WeldDrawingPainter({
    required this.grooveType,
    required this.jointType,
    required this.drawingMode,
    required this.data,
    this.onHotspots,
    this.fillAvailableSpace = false,
  });

  final GrooveType grooveType;
  final JointType jointType;
  final DrawingMode drawingMode;
  final WeldDrawingData data;
  final ValueChanged<List<DrawingHotspot>>? onHotspots;
  final bool fillAvailableSpace;

  final List<DrawingHotspot> _hotspots = [];

  // Radius constants below are tuned for the default mode, where the
  // painter always draws at a fixed 760x400 canvas size (see the SizedBox
  // in calculator_page.dart) that an outer FittedBox then shrinks to ~45%
  // to fit the pinned mobile drawing card — so a canvas-space radius has to
  // be generous to still clear a comfortable finger-sized target once that
  // shrink is applied. In [fillAvailableSpace] mode there is no such
  // shrink (the canvas IS the real on-screen box), so the same constants
  // would be wildly oversized; scale them down to roughly what they
  // resolve to on screen in the default mode.
  void _hotspot(FieldKey? fieldKey, Offset center, {double radius = 52}) {
    if (fieldKey == null) return;
    final effectiveRadius = fillAvailableSpace ? radius * 0.46 : radius;
    _hotspots.add(DrawingHotspot(fieldKey, center, effectiveRadius));
  }

  bool get _isPipeButt => jointType == JointType.pipeButt;

  // The top-center groove-type chip and the top-right pipe-OD chip sit close
  // enough together to overlap when drawn side by side on a narrow canvas.
  // Rather than guessing a fixed canvas-width breakpoint (fragile: it has to
  // assume a specific font's glyph metrics, and a prior attempt at this used
  // widths measured under flutter_test's Ahem font, which is ~1.9x wider
  // than real device fonts and made the breakpoint fire far too early), lay
  // both chips out with the same TextPainter-based sizing the painter
  // actually draws them with and stack only when their real rects would
  // intersect - see [_chipSize] / [_chipRect].
  bool _stackTopChips(Size size, String typeLabel) {
    if (!_isPipeButt || data.pipeOdMm == null || data.pipeOdMm! <= 0) {
      return false;
    }
    final typeRect = _chipRect(
      size,
      Offset(size.width * 0.5, 28),
      _chipSize(size, typeLabel, 11.5, FontWeight.w700),
    );
    final pipeLabel = 'OD ${_formatValue(data.pipeOdMm!)} mm';
    final pipeRect = _chipRect(
      size,
      Offset(size.width - 82, 28),
      _chipSize(size, pipeLabel, 10.5, FontWeight.w600),
    );
    // Small halo beyond bare pixel contact so stacked/unstacked chips keep a
    // hairline gap rather than just touching.
    const gap = 3.0;
    return typeRect.inflate(gap).overlaps(pipeRect.inflate(gap));
  }

  // Mirrors the pill sizing in [_drawTechnicalLabel] / [_drawSoftLabel] (the
  // two only differ in padding/minWidth, not in how they measure text) so
  // collision checks use the exact size the chip will actually be drawn at.
  Size _chipSize(Size size, String text, double fontSize, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: _annotationFontSize(size, fontSize),
          fontWeight: weight,
          letterSpacing: _isTechnical ? 0.04 : 0.06,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final horizontalPadding = _isTechnical ? 20.0 : 18.0;
    final verticalPadding = _isTechnical ? 11.0 : 11.0;
    final minWidth = _isTechnical ? 66.0 : 62.0;
    const minHeight = 28.0;
    return Size(
      math.max(painter.width + horizontalPadding, minWidth),
      math.max(painter.height + verticalPadding, minHeight),
    );
  }

  // Mirrors the edge-clamping in [_drawTechnicalLabel] / [_drawSoftLabel] so
  // the collision check sees the chip's actual on-canvas position, including
  // the clamp that pulls the two chips toward each other on narrow canvases.
  Rect _chipRect(Size size, Offset center, Size chipSize) {
    final rect = Rect.fromCenter(
      center: center,
      width: chipSize.width,
      height: chipSize.height,
    );
    return Rect.fromLTWH(
      _safeClamp(rect.left, 10, size.width - rect.width - 10),
      _safeClamp(rect.top, 10, size.height - rect.height - 10),
      rect.width,
      rect.height,
    );
  }
  bool get _isCombinedProcess =>
      data.weldingProcess == WeldingProcess.gtawSmaw &&
      (data.gtawTransitionMm ?? 0) > 0;
  bool get _isTechnical => drawingMode == DrawingMode.technical;

  static const _steelColor = Color(0xFFD8E0E6);
  static const _steelShade = Color(0xFFB8C5CF);
  static const _weldColor = Color(0xFFEF8354);
  static const _weldShade = Color(0xFFD96A3A);
  static const _gtawRootColor = Color(0xFF539A96);
  static const _gtawRootShade = Color(0xFF3D7D7A);
  static const _outlineColor = Color(0xFF34515E);
  static const _guideColor = Color(0xFF78909C);
  static const _labelColor = Color(0xFF22343D);
  static const _softLabelFill = Color(0xCCFFFFFF);
  static const _softLabelStroke = Color(0x335A7280);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final steelPaint = Paint()
      ..shader = LinearGradient(
        colors: _isTechnical
            ? const [Color(0xFFF6F8FA), Color(0xFFD8E1E8)]
            : const [_steelColor, _steelShade],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final weldPaint = Paint()
      ..shader = LinearGradient(
        colors: _isTechnical
            ? const [Color(0xFFF3BE8D), Color(0xFFDB8E56)]
            : const [_weldColor, _weldShade],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final outlinePaint = Paint()
      ..color = _outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isTechnical ? 2.25 : 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final guidePaint = Paint()
      ..color = _isTechnical ? const Color(0xFF546E7A) : _guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isTechnical ? 0.88 : 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final centerPaint = Paint()
      ..color = _isTechnical
          ? const Color(0xFF9AADB6).withValues(alpha: 0.82)
          : const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isTechnical ? 0.78 : 1
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    _drawBackdrop(canvas, size);

    switch (grooveType) {
      case GrooveType.singleV:
        _drawSingleV(
          canvas,
          size,
          steelPaint,
          weldPaint,
          outlinePaint,
          guidePaint,
        );
      case GrooveType.halfV:
        _drawHalfV(
          canvas,
          size,
          steelPaint,
          weldPaint,
          outlinePaint,
          guidePaint,
        );
      case GrooveType.doubleV:
        _drawDoubleV(
          canvas,
          size,
          steelPaint,
          weldPaint,
          outlinePaint,
          guidePaint,
        );
      case GrooveType.compoundV:
        _drawCompoundV(
          canvas,
          size,
          steelPaint,
          weldPaint,
          outlinePaint,
          guidePaint,
        );
      case GrooveType.square:
        _drawSquare(
          canvas,
          size,
          steelPaint,
          weldPaint,
          outlinePaint,
          guidePaint,
        );
      case GrooveType.fillet:
        _drawFillet(
          canvas,
          size,
          steelPaint,
          weldPaint,
          outlinePaint,
          guidePaint,
        );
    }

    _drawCenterLine(
      canvas,
      centerPaint,
      Offset(size.width * 0.5, size.height * 0.13),
      Offset(size.width * 0.5, size.height * 0.88),
    );
    // In fillAvailableSpace (compact/mobile) mode this fixed-position title
    // sits directly under the top-center groove-type chip and prints over
    // it on real phone widths — the groove type is already shown by that
    // chip and the joint type is already visible via the Joint Type
    // dropdown above the card, so the title is redundant there. Only draw
    // it in the roomier desktop 760px layout, where there's no chip to
    // collide with at this position.
    if (!fillAvailableSpace) {
      _drawLabel(
        canvas,
        size,
        '${jointType.label} / ${grooveType.label}',
        const Offset(14, 12),
        fontSize: 14,
        weight: FontWeight.w700,
      );
    }

    onHotspots?.call(_hotspots);
  }

  void _drawBackdrop(Canvas canvas, Size size) {
    if (_isTechnical) {
      final washPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF8FBFD), Color(0xFFF0F5F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.fill;
      final framePaint = Paint()
        ..color = const Color(0x2434515E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.95
        ..isAntiAlias = true;
      final frame = RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        const Radius.circular(12),
      );
      canvas.drawRRect(frame, washPaint);
      canvas.drawRRect(frame, framePaint);
      return;
    }

    final gridPaint = Paint()
      ..color = const Color(0x16FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final framePaint = Paint()
      ..color = const Color(0x2212191B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(20),
    );

    for (double x = 24; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 24; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawRRect(frame, framePaint);
  }

  void _drawSingleV(
    Canvas canvas,
    Size size,
    Paint steelPaint,
    Paint weldPaint,
    Paint outlinePaint,
    Paint guidePaint,
  ) {
    final thickness = _positiveOr(data.thicknessMm, _isPipeButt ? 14 : 12);
    final rootGap = _positiveOr(data.rootGapMm, 3, min: 0.8);
    final rootFace = _clampValue(
      data.rootFaceMm,
      fallback: 2,
      min: 0.5,
      max: thickness - 0.8,
    );
    final bevelAngle = _clampValue(
      data.bevelAngleDeg,
      fallback: 30,
      min: 10,
      max: 60,
    );
    final grooveHeight = math.max(thickness - rootFace, 0.8);
    final angleRad = _degToRad(bevelAngle);
    final topWidth = rootGap + (2 * grooveHeight * math.tan(angleRad));
    final halfGap = rootGap / 2;
    final halfTop = topWidth / 2;
    final halfBody = math.max(halfTop + (thickness * 1.05), 22.0);
    final layout = _createLayout(
      size,
      maxHalfWidthMm: halfBody + 10,
      heightMm: thickness + 7,
      topPaddingMm: 4,
      topChipLabel: 'Single V',
    );
    final p = layout.point;
    final member = _memberExtents(thickness);
    final leftThickness = member.leftBottom - member.leftTop;
    final rightThickness = member.rightBottom - member.rightTop;
    final leftRootFace = math.min(rootFace, math.max(leftThickness - 0.8, 0.5));
    final rightRootFace = math.min(
      rootFace,
      math.max(rightThickness - 0.8, 0.5),
    );
    final leftGrooveY = member.leftBottom - leftRootFace;
    final rightGrooveY = member.rightBottom - rightRootFace;
    final capRise = math.min(thickness * 0.16, 3.2);
    final rootCrown = math.min(rootFace * 0.35, 1.2);

    final leftPlate = Path()
      ..moveTo(p(-halfBody, member.leftTop).dx, p(-halfBody, member.leftTop).dy)
      ..lineTo(p(-halfTop, member.leftTop).dx, p(-halfTop, member.leftTop).dy)
      ..lineTo(p(-halfGap, leftGrooveY).dx, p(-halfGap, leftGrooveY).dy)
      ..lineTo(
        p(-halfGap, member.leftBottom).dx,
        p(-halfGap, member.leftBottom).dy,
      )
      ..lineTo(
        p(-halfBody, member.leftBottom).dx,
        p(-halfBody, member.leftBottom).dy,
      )
      ..close();
    final rightPlate = Path()
      ..moveTo(p(halfBody, member.rightTop).dx, p(halfBody, member.rightTop).dy)
      ..lineTo(p(halfTop, member.rightTop).dx, p(halfTop, member.rightTop).dy)
      ..lineTo(p(halfGap, rightGrooveY).dx, p(halfGap, rightGrooveY).dy)
      ..lineTo(
        p(halfGap, member.rightBottom).dx,
        p(halfGap, member.rightBottom).dy,
      )
      ..lineTo(
        p(halfBody, member.rightBottom).dx,
        p(halfBody, member.rightBottom).dy,
      )
      ..close();
    final weld = Path()
      ..moveTo(p(-halfTop, member.leftTop).dx, p(-halfTop, member.leftTop).dy)
      ..quadraticBezierTo(
        p(0, math.min(member.leftTop, member.rightTop) - capRise).dx,
        p(0, math.min(member.leftTop, member.rightTop) - capRise).dy,
        p(halfTop, member.rightTop).dx,
        p(halfTop, member.rightTop).dy,
      )
      ..lineTo(p(halfGap, rightGrooveY).dx, p(halfGap, rightGrooveY).dy)
      ..lineTo(
        p(halfGap, member.rightBottom).dx,
        p(halfGap, member.rightBottom).dy,
      )
      ..quadraticBezierTo(
        p(0, math.max(member.leftBottom, member.rightBottom) + rootCrown).dx,
        p(0, math.max(member.leftBottom, member.rightBottom) + rootCrown).dy,
        p(-halfGap, member.leftBottom).dx,
        p(-halfGap, member.leftBottom).dy,
      )
      ..lineTo(p(-halfGap, leftGrooveY).dx, p(-halfGap, leftGrooveY).dy)
      ..close();

    _drawJoint(
      canvas,
      size,
      leftPlate,
      rightPlate,
      weld,
      steelPaint,
      weldPaint,
      outlinePaint,
    );
    _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(halfTop * 0.48, thickness * 0.18),
      rootLabelCenter: p(halfGap + 6, thickness - 0.8),
    );
    _drawButtCommonMeasurements(
      canvas,
      size,
      guidePaint,
      layout: layout,
      thickness: thickness,
      halfGap: halfGap,
      grooveY: rightGrooveY - member.rightTop,
      thicknessLabelX: -halfBody - 6,
      rightThicknessLabelX: halfBody + 6,
      rootGapLabelY: math.max(member.leftBottom, member.rightBottom),
    );
    _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(halfGap + 5, rightGrooveY),
      end: p(halfGap + 5, member.rightBottom),
      label: '${_formatValue(rootFace)} mm root face',
      labelSize: size,
      labelOffset: const Offset(42, 0),
      extensionStart: p(halfGap, rightGrooveY),
      extensionEnd: p(halfGap, member.rightBottom),
      fieldKey: FieldKey.rootFaceMm,
    );
    _drawAngleTag(
      canvas,
      guidePaint,
      size,
      start: p(
        -(halfTop * 0.58),
        member.leftTop + ((leftGrooveY - member.leftTop) * 0.34),
      ),
      labelCenter: p(
        -(halfTop + 7.5),
        member.leftTop + ((leftGrooveY - member.leftTop) * 0.20),
      ),
      text: '${_formatValue(bevelAngle)}°',
      fieldKey: FieldKey.bevelAngleDeg,
    );
    _drawTopChips(canvas, size, 'Single V');
  }

  void _drawHalfV(
    Canvas canvas,
    Size size,
    Paint steelPaint,
    Paint weldPaint,
    Paint outlinePaint,
    Paint guidePaint,
  ) {
    final thickness = _positiveOr(data.thicknessMm, _isPipeButt ? 14 : 12);
    final rootGap = _positiveOr(data.rootGapMm, 3, min: 0.8);
    final rootFace = _clampValue(
      data.rootFaceMm,
      fallback: 2,
      min: 0.5,
      max: thickness - 0.8,
    );
    final bevelAngle = _clampValue(
      data.bevelAngleDeg,
      fallback: 30,
      min: 10,
      max: 60,
    );
    final grooveHeight = math.max(thickness - rootFace, 0.8);
    final topWidth = rootGap + (grooveHeight * math.tan(_degToRad(bevelAngle)));
    final halfGap = rootGap / 2;
    final topRight = -halfGap + topWidth;
    final leftBody = math.max(halfGap + (thickness * 1.05), 20.0);
    final rightBody = math.max(topRight + (thickness * 1.05), 24.0);
    final layout = _createLayout(
      size,
      maxHalfWidthMm: math.max(leftBody, rightBody) + 10.0,
      heightMm: thickness + 7,
      topPaddingMm: 4,
      topChipLabel: 'Half V',
    );
    final p = layout.point;
    final grooveY = thickness - rootFace;
    final capRise = math.min(thickness * 0.15, 2.8);
    final rootCrown = math.min(rootFace * 0.35, 1.0);

    final leftPlate = Path()
      ..moveTo(p(-leftBody, 0).dx, p(-leftBody, 0).dy)
      ..lineTo(p(-halfGap, 0).dx, p(-halfGap, 0).dy)
      ..lineTo(p(-halfGap, thickness).dx, p(-halfGap, thickness).dy)
      ..lineTo(p(-leftBody, thickness).dx, p(-leftBody, thickness).dy)
      ..close();
    final rightPlate = Path()
      ..moveTo(p(rightBody, 0).dx, p(rightBody, 0).dy)
      ..lineTo(p(topRight, 0).dx, p(topRight, 0).dy)
      ..lineTo(p(halfGap, grooveY).dx, p(halfGap, grooveY).dy)
      ..lineTo(p(halfGap, thickness).dx, p(halfGap, thickness).dy)
      ..lineTo(p(rightBody, thickness).dx, p(rightBody, thickness).dy)
      ..close();
    final weld = Path()
      ..moveTo(p(-halfGap, 0).dx, p(-halfGap, 0).dy)
      ..quadraticBezierTo(
        p((topRight - halfGap) / 2, -capRise).dx,
        p((topRight - halfGap) / 2, -capRise).dy,
        p(topRight, 0).dx,
        p(topRight, 0).dy,
      )
      ..lineTo(p(halfGap, grooveY).dx, p(halfGap, grooveY).dy)
      ..lineTo(p(halfGap, thickness).dx, p(halfGap, thickness).dy)
      ..quadraticBezierTo(
        p(0, thickness + rootCrown).dx,
        p(0, thickness + rootCrown).dy,
        p(-halfGap, thickness).dx,
        p(-halfGap, thickness).dy,
      )
      ..lineTo(p(-halfGap, 0).dx, p(-halfGap, 0).dy)
      ..close();

    _drawJoint(
      canvas,
      size,
      leftPlate,
      rightPlate,
      weld,
      steelPaint,
      weldPaint,
      outlinePaint,
    );
    _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(topRight * 0.72, thickness * 0.18),
      rootLabelCenter: p(halfGap + 6, thickness - 0.8),
    );
    // Unlike Single V/Double V (whose single angle tag sits on the opposite
    // side from the groove-depth label), Half V's bevel angle and groove
    // depth both live on the right-hand side, close enough together that
    // their mm-space lanes collapse into overlapping pixel-space bubbles on
    // a real narrow phone canvas (same root cause as the Compound V fix
    // above - see the comment on that block, and TEAM_LEARNINGS.md). Draw
    // the angle tag and root-face label first (both at fixed positions),
    // then let groove depth nudge clear of their real measured rects.
    final angleRect = _drawAngleTag(
      canvas,
      guidePaint,
      size,
      start: p(halfGap + ((topRight - halfGap) * 0.44), grooveY * 0.34),
      labelCenter: p(topRight + 7.0, grooveY * 0.20),
      text: '${_formatValue(bevelAngle)}°',
      fieldKey: FieldKey.bevelAngleDeg,
    );
    final rootFaceRect = _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(halfGap + 5, grooveY),
      end: p(halfGap + 5, thickness),
      label: '${_formatValue(rootFace)} mm root face',
      labelSize: size,
      labelOffset: const Offset(42, 0),
      extensionStart: p(halfGap, grooveY),
      extensionEnd: p(halfGap, thickness),
      fieldKey: FieldKey.rootFaceMm,
    );
    _drawButtCommonMeasurements(
      canvas,
      size,
      guidePaint,
      layout: layout,
      thickness: thickness,
      halfGap: halfGap,
      grooveY: grooveY,
      thicknessLabelX: -leftBody - 6,
      rightThicknessLabelX: rightBody + 6,
      avoidRects: [angleRect, rootFaceRect],
    );
    _drawTopChips(canvas, size, 'Half V');
  }

  void _drawDoubleV(
    Canvas canvas,
    Size size,
    Paint steelPaint,
    Paint weldPaint,
    Paint outlinePaint,
    Paint guidePaint,
  ) {
    final thickness = _positiveOr(data.thicknessMm, _isPipeButt ? 14 : 12);
    final rootGap = _positiveOr(data.rootGapMm, 3, min: 0.8);
    final halfThickness = thickness / 2;
    final rootFace = _clampValue(
      data.rootFaceMm,
      fallback: 2,
      min: 0.4,
      max: halfThickness - 0.4,
    );
    final bevelAngle = _clampValue(
      data.bevelAngleDeg,
      fallback: 30,
      min: 10,
      max: 60,
    );
    final bevelHeightPerSide = math.max(halfThickness - rootFace, 0.4);
    final topWidth =
        rootGap + (2 * bevelHeightPerSide * math.tan(_degToRad(bevelAngle)));
    final halfGap = rootGap / 2;
    final halfTop = topWidth / 2;
    final halfBody = math.max(halfTop + (thickness * 1.00), 22.0);
    final layout = _createLayout(
      size,
      maxHalfWidthMm: halfBody + 10,
      heightMm: thickness + 7,
      topPaddingMm: 4,
      topChipLabel: 'Double V',
    );
    final p = layout.point;
    final member = _memberExtents(thickness);
    final leftMid = (member.leftTop + member.leftBottom) / 2;
    final rightMid = (member.rightTop + member.rightBottom) / 2;
    final leftUpperRootY = math.max(leftMid - rootFace, member.leftTop + 0.4);
    final leftLowerRootY = math.min(
      leftMid + rootFace,
      member.leftBottom - 0.4,
    );
    final rightUpperRootY = math.max(
      rightMid - rootFace,
      member.rightTop + 0.4,
    );
    final rightLowerRootY = math.min(
      rightMid + rootFace,
      member.rightBottom - 0.4,
    );
    final capRise = math.min(thickness * 0.12, 2.4);

    final leftPlate = Path()
      ..moveTo(p(-halfBody, member.leftTop).dx, p(-halfBody, member.leftTop).dy)
      ..lineTo(p(-halfTop, member.leftTop).dx, p(-halfTop, member.leftTop).dy)
      ..lineTo(p(-halfGap, leftUpperRootY).dx, p(-halfGap, leftUpperRootY).dy)
      ..lineTo(p(-halfGap, leftLowerRootY).dx, p(-halfGap, leftLowerRootY).dy)
      ..lineTo(
        p(-halfTop, member.leftBottom).dx,
        p(-halfTop, member.leftBottom).dy,
      )
      ..lineTo(
        p(-halfBody, member.leftBottom).dx,
        p(-halfBody, member.leftBottom).dy,
      )
      ..close();
    final rightPlate = Path()
      ..moveTo(p(halfBody, member.rightTop).dx, p(halfBody, member.rightTop).dy)
      ..lineTo(p(halfTop, member.rightTop).dx, p(halfTop, member.rightTop).dy)
      ..lineTo(p(halfGap, rightUpperRootY).dx, p(halfGap, rightUpperRootY).dy)
      ..lineTo(p(halfGap, rightLowerRootY).dx, p(halfGap, rightLowerRootY).dy)
      ..lineTo(
        p(halfTop, member.rightBottom).dx,
        p(halfTop, member.rightBottom).dy,
      )
      ..lineTo(
        p(halfBody, member.rightBottom).dx,
        p(halfBody, member.rightBottom).dy,
      )
      ..close();
    final weld = Path()
      ..moveTo(p(-halfTop, member.leftTop).dx, p(-halfTop, member.leftTop).dy)
      ..quadraticBezierTo(
        p(0, math.min(member.leftTop, member.rightTop) - capRise).dx,
        p(0, math.min(member.leftTop, member.rightTop) - capRise).dy,
        p(halfTop, member.rightTop).dx,
        p(halfTop, member.rightTop).dy,
      )
      ..lineTo(p(halfGap, rightUpperRootY).dx, p(halfGap, rightUpperRootY).dy)
      ..lineTo(p(halfGap, rightLowerRootY).dx, p(halfGap, rightLowerRootY).dy)
      ..lineTo(
        p(halfTop, member.rightBottom).dx,
        p(halfTop, member.rightBottom).dy,
      )
      ..quadraticBezierTo(
        p(0, math.max(member.leftBottom, member.rightBottom) + capRise).dx,
        p(0, math.max(member.leftBottom, member.rightBottom) + capRise).dy,
        p(-halfTop, member.leftBottom).dx,
        p(-halfTop, member.leftBottom).dy,
      )
      ..lineTo(p(-halfGap, leftLowerRootY).dx, p(-halfGap, leftLowerRootY).dy)
      ..lineTo(p(-halfGap, leftUpperRootY).dx, p(-halfGap, leftUpperRootY).dy)
      ..close();

    _drawJoint(
      canvas,
      size,
      leftPlate,
      rightPlate,
      weld,
      steelPaint,
      weldPaint,
      outlinePaint,
    );
    _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      includeBottomRootTint: false,
      extraRootZone: Path()
        ..moveTo(p(-halfGap, leftUpperRootY).dx, p(-halfGap, leftUpperRootY).dy)
        ..lineTo(p(halfGap, rightUpperRootY).dx, p(halfGap, rightUpperRootY).dy)
        ..lineTo(p(halfGap, rightLowerRootY).dx, p(halfGap, rightLowerRootY).dy)
        ..lineTo(p(-halfGap, leftLowerRootY).dx, p(-halfGap, leftLowerRootY).dy)
        ..close(),
      topLabelCenter: p(halfTop * 0.45, thickness * 0.16),
      rootLabelCenter: p(halfGap + 6, thickness - 1.0),
    );
    _drawButtCommonMeasurements(
      canvas,
      size,
      guidePaint,
      layout: layout,
      thickness: thickness,
      halfGap: halfGap,
      grooveY: rightUpperRootY - member.rightTop,
      thicknessLabelX: -halfBody - 6,
      rightThicknessLabelX: halfBody + 6,
      rootGapLabelY: (leftMid + rightMid) / 2,
    );
    _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(halfGap + 5, rightUpperRootY),
      end: p(halfGap + 5, rightLowerRootY),
      label: '${_formatValue(rootFace * 2)} mm total root face',
      labelSize: size,
      labelOffset: const Offset(44, 0),
      extensionStart: p(halfGap, rightUpperRootY),
      extensionEnd: p(halfGap, rightLowerRootY),
      fieldKey: FieldKey.rootFaceMm,
    );
    _drawAngleTag(
      canvas,
      guidePaint,
      size,
      start: p(
        -(halfTop * 0.62),
        member.leftTop + ((leftUpperRootY - member.leftTop) * 0.48),
      ),
      labelCenter: p(
        -(halfTop + 7.0),
        member.leftTop + ((leftUpperRootY - member.leftTop) * 0.28),
      ),
      text: '${_formatValue(bevelAngle)}°',
      fieldKey: FieldKey.bevelAngleDeg,
    );
    if (data.geometryMode == JointGeometryMode.equal) {
      // These two half-thickness brackets share the thickness label's outer
      // lane (there's no room to push them further out without risking the
      // canvas edge), so they're pushed up/down in screen space instead -
      // clear of the shared thickness label, which always sits pinned at
      // the exact midpoint between them.
      _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(-halfBody - 1, 0),
        end: p(-halfBody - 1, halfThickness),
        label: '${_formatValue(halfThickness)} mm',
        labelSize: size,
        labelOffset: const Offset(-30, -16),
      );
      _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(-halfBody - 1, halfThickness),
        end: p(-halfBody - 1, thickness),
        label: '${_formatValue(halfThickness)} mm',
        labelSize: size,
        labelOffset: const Offset(-30, 16),
      );
    }
    _drawTopChips(canvas, size, 'Double V');
  }

  void _drawCompoundV(
    Canvas canvas,
    Size size,
    Paint steelPaint,
    Paint weldPaint,
    Paint outlinePaint,
    Paint guidePaint,
  ) {
    final thickness = _positiveOr(data.thicknessMm, 14);
    final rootGap = _positiveOr(data.rootGapMm, 3, min: 0.8);
    final rootFace = _clampValue(
      data.rootFaceMm,
      fallback: 2,
      min: 0.5,
      max: thickness - 1.2,
    );
    final primaryAngle = _clampValue(
      data.bevelAngleDeg,
      fallback: 30,
      min: 8,
      max: 60,
    );
    final maxBreakHeight = math.max(thickness - rootFace - 0.8, 0.8);
    final breakHeight = _clampValue(
      data.breakHeightMm,
      fallback: math.min(4.0, maxBreakHeight),
      min: 0.8,
      max: maxBreakHeight,
    );
    final secondaryAngle = _clampValue(
      data.secondaryBevelAngleDeg,
      fallback: 10,
      min: 5,
      max: 45,
    );
    final upperHeight = math.max(thickness - rootFace - breakHeight, 0.5);
    final widthAtBreak =
        rootGap + (2 * breakHeight * math.tan(_degToRad(primaryAngle)));
    final topWidth =
        widthAtBreak + (2 * upperHeight * math.tan(_degToRad(secondaryAngle)));
    final halfGap = rootGap / 2;
    final halfBreak = widthAtBreak / 2;
    final halfTop = topWidth / 2;
    final halfBody = math.max(halfTop + (thickness * 0.95), 24.0);
    final layout = _createLayout(
      size,
      maxHalfWidthMm: halfBody + 10,
      heightMm: thickness + 7,
      topPaddingMm: 4,
      topChipLabel: 'Compound V',
    );
    final p = layout.point;
    final breakY = upperHeight;
    final grooveY = thickness - rootFace;
    final capRise = math.min(thickness * 0.14, 3.0);
    final rootCrown = math.min(rootFace * 0.32, 1.1);

    final leftPlate = Path()
      ..moveTo(p(-halfBody, 0).dx, p(-halfBody, 0).dy)
      ..lineTo(p(-halfTop, 0).dx, p(-halfTop, 0).dy)
      ..lineTo(p(-halfBreak, breakY).dx, p(-halfBreak, breakY).dy)
      ..lineTo(p(-halfGap, grooveY).dx, p(-halfGap, grooveY).dy)
      ..lineTo(p(-halfGap, thickness).dx, p(-halfGap, thickness).dy)
      ..lineTo(p(-halfBody, thickness).dx, p(-halfBody, thickness).dy)
      ..close();
    final rightPlate = Path()
      ..moveTo(p(halfBody, 0).dx, p(halfBody, 0).dy)
      ..lineTo(p(halfTop, 0).dx, p(halfTop, 0).dy)
      ..lineTo(p(halfBreak, breakY).dx, p(halfBreak, breakY).dy)
      ..lineTo(p(halfGap, grooveY).dx, p(halfGap, grooveY).dy)
      ..lineTo(p(halfGap, thickness).dx, p(halfGap, thickness).dy)
      ..lineTo(p(halfBody, thickness).dx, p(halfBody, thickness).dy)
      ..close();
    final weld = Path()
      ..moveTo(p(-halfTop, 0).dx, p(-halfTop, 0).dy)
      ..quadraticBezierTo(
        p(0, -capRise).dx,
        p(0, -capRise).dy,
        p(halfTop, 0).dx,
        p(halfTop, 0).dy,
      )
      ..lineTo(p(halfBreak, breakY).dx, p(halfBreak, breakY).dy)
      ..lineTo(p(halfGap, grooveY).dx, p(halfGap, grooveY).dy)
      ..lineTo(p(halfGap, thickness).dx, p(halfGap, thickness).dy)
      ..quadraticBezierTo(
        p(0, thickness + rootCrown).dx,
        p(0, thickness + rootCrown).dy,
        p(-halfGap, thickness).dx,
        p(-halfGap, thickness).dy,
      )
      ..lineTo(p(-halfGap, grooveY).dx, p(-halfGap, grooveY).dy)
      ..lineTo(p(-halfBreak, breakY).dx, p(-halfBreak, breakY).dy)
      ..close();

    _drawJoint(
      canvas,
      size,
      leftPlate,
      rightPlate,
      weld,
      steelPaint,
      weldPaint,
      outlinePaint,
    );
    _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(halfTop * 0.48, thickness * 0.16),
      rootLabelCenter: p(halfGap + 6, thickness - 0.8),
    );
    // Compound V carries six callouts (thickness, root gap, groove depth,
    // break height, root face, alpha, beta) plus the type/pipe chips - the
    // busiest drawing in the app. Each label starts in its own mm-space
    // lane - a distinct horizontal distance from the joint - but an
    // mm-space lane alone isn't enough: the drawing's mm-to-pixel scale
    // shrinks on a narrow canvas while each label bubble's own rendered
    // size stays roughly fixed in pixels, so lanes that are comfortably
    // separated on the desktop canvas can collapse into overlapping
    // pixel-space bubbles on a real phone canvas (this is exactly what
    // happened between alpha and groove depth - see TEAM_LEARNINGS.md).
    // So alpha is measured and drawn first at its normal lane position,
    // then groove depth and beta are each nudged straight down/up in real
    // pixel space (see [_clearLabelPosition]), using their actual rendered
    // bubble sizes, just far enough to clear whichever already-placed
    // bubble they'd otherwise overlap.
    final alphaRect = _drawAngleTag(
      canvas,
      guidePaint,
      size,
      start: p(
        halfGap + ((halfBreak - halfGap) * 0.52),
        grooveY - ((grooveY - breakY) * 0.42),
      ),
      labelCenter: p(halfGap + 6, breakY * 0.35),
      text: 'α ${_formatValue(primaryAngle)}°',
      fieldKey: FieldKey.bevelAngleDeg,
    );
    final grooveDepthRect = _drawButtCommonMeasurements(
      canvas,
      size,
      guidePaint,
      layout: layout,
      thickness: thickness,
      halfGap: halfGap,
      grooveY: grooveY,
      thicknessLabelX: -halfBody - 6,
      rightThicknessLabelX: halfBody + 6,
      avoidRects: [alphaRect],
    );
    // Break height "h": inner-left lane, kept close to the joint. The label
    // is nudged down toward groove depth's height, well clear of the
    // thickness label's fixed mid-height position on the far-left lane.
    _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(-halfGap - 12, breakY),
      end: p(-halfGap - 12, grooveY),
      label: 'h ${_formatValue(breakHeight)} mm',
      labelSize: size,
      labelOffset: const Offset(-14, 16),
      extensionStart: p(-halfBreak, breakY),
      extensionEnd: p(-halfGap, grooveY),
      fieldKey: FieldKey.breakHeightMm,
    );
    // Root face: bottom, inner-right lane, close to the joint.
    final rootFaceRect = _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(halfGap + 5, grooveY),
      end: p(halfGap + 5, thickness),
      label: '${_formatValue(rootFace)} mm root face',
      labelSize: size,
      labelOffset: const Offset(20, 6),
      extensionStart: p(halfGap, grooveY),
      extensionEnd: p(halfGap, thickness),
      fieldKey: FieldKey.rootFaceMm,
    );
    // Secondary angle (beta): inner-right, between alpha's lane above and
    // root face's lane below - nudged clear of alpha, of groove depth's
    // real (possibly already-nudged) rect, and of root face if they'd
    // otherwise collide.
    _drawAngleTag(
      canvas,
      guidePaint,
      size,
      start: p(halfBreak + ((halfTop - halfBreak) * 0.48), breakY * 0.48),
      labelCenter: p(halfGap + 14, (breakY + grooveY) / 2),
      text: 'β ${_formatValue(secondaryAngle)}°',
      fieldKey: FieldKey.secondaryBevelAngleDeg,
      avoidRects: [alphaRect, ?grooveDepthRect, rootFaceRect],
    );
    _drawTopChips(canvas, size, 'Compound V');
  }

  void _drawSquare(
    Canvas canvas,
    Size size,
    Paint steelPaint,
    Paint weldPaint,
    Paint outlinePaint,
    Paint guidePaint,
  ) {
    final thickness = _positiveOr(data.thicknessMm, _isPipeButt ? 14 : 12);
    final rootGap = _positiveOr(data.rootGapMm, 3, min: 0.8);
    final halfGap = rootGap / 2;
    final halfBody = math.max(halfGap + (thickness * 1.2), 24.0);
    final layout = _createLayout(
      size,
      maxHalfWidthMm: halfBody + 10,
      heightMm: thickness + 7,
      topPaddingMm: 4,
      topChipLabel: 'Square',
    );
    final p = layout.point;
    final member = _memberExtents(thickness);
    final capRise = math.min(thickness * 0.12, 2.4);

    final leftPlate = Path()
      ..moveTo(p(-halfBody, member.leftTop).dx, p(-halfBody, member.leftTop).dy)
      ..lineTo(p(-halfGap, member.leftTop).dx, p(-halfGap, member.leftTop).dy)
      ..lineTo(
        p(-halfGap, member.leftBottom).dx,
        p(-halfGap, member.leftBottom).dy,
      )
      ..lineTo(
        p(-halfBody, member.leftBottom).dx,
        p(-halfBody, member.leftBottom).dy,
      )
      ..close();
    final rightPlate = Path()
      ..moveTo(p(halfBody, member.rightTop).dx, p(halfBody, member.rightTop).dy)
      ..lineTo(p(halfGap, member.rightTop).dx, p(halfGap, member.rightTop).dy)
      ..lineTo(
        p(halfGap, member.rightBottom).dx,
        p(halfGap, member.rightBottom).dy,
      )
      ..lineTo(
        p(halfBody, member.rightBottom).dx,
        p(halfBody, member.rightBottom).dy,
      )
      ..close();
    final weld = Path()
      ..moveTo(p(-halfGap, member.leftTop).dx, p(-halfGap, member.leftTop).dy)
      ..quadraticBezierTo(
        p(0, math.min(member.leftTop, member.rightTop) - capRise).dx,
        p(0, math.min(member.leftTop, member.rightTop) - capRise).dy,
        p(halfGap, member.rightTop).dx,
        p(halfGap, member.rightTop).dy,
      )
      ..lineTo(
        p(halfGap, member.rightBottom).dx,
        p(halfGap, member.rightBottom).dy,
      )
      ..quadraticBezierTo(
        p(0, math.max(member.leftBottom, member.rightBottom) + capRise).dx,
        p(0, math.max(member.leftBottom, member.rightBottom) + capRise).dy,
        p(-halfGap, member.leftBottom).dx,
        p(-halfGap, member.leftBottom).dy,
      )
      ..close();

    _drawJoint(
      canvas,
      size,
      leftPlate,
      rightPlate,
      weld,
      steelPaint,
      weldPaint,
      outlinePaint,
    );
    _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(halfGap + 8, thickness * 0.18),
      rootLabelCenter: p(halfGap + 5.5, thickness - 0.8),
    );
    _drawButtCommonMeasurements(
      canvas,
      size,
      guidePaint,
      layout: layout,
      thickness: thickness,
      halfGap: halfGap,
      grooveY: 0,
      thicknessLabelX: -halfBody - 6,
      rightThicknessLabelX: halfBody + 6,
      rootGapLabelY: math.max(member.leftBottom, member.rightBottom),
    );
    _drawTopChips(canvas, size, 'Square');
  }

  void _drawFillet(
    Canvas canvas,
    Size size,
    Paint steelPaint,
    Paint weldPaint,
    Paint outlinePaint,
    Paint guidePaint,
  ) {
    final leg = _positiveOr(data.legSizeMm, 6, min: 2);
    final plateThickness = math.max(leg * 0.65, 4.5);
    final flangeHalfWidth = math.max(leg * 2.8, 16.0);
    final webHalfThickness = plateThickness / 2;
    final layout = _createLayout(
      size,
      maxHalfWidthMm: flangeHalfWidth + 10,
      heightMm: (leg + plateThickness + 10),
    );
    final p = layout.point;
    final baseTopY = leg + 2.5;
    final baseBottomY = baseTopY + plateThickness;
    final webTopY = math.max(baseTopY - (leg + plateThickness * 1.6), 0.0);
    final toeX = webHalfThickness + leg;
    final topToeY = baseTopY - leg;
    final faceControlX = webHalfThickness + (leg * 0.72);
    final faceControlY = baseTopY - (leg * 0.18);

    final web = Path()
      ..moveTo(
        p(-webHalfThickness, webTopY).dx,
        p(-webHalfThickness, webTopY).dy,
      )
      ..lineTo(p(webHalfThickness, webTopY).dx, p(webHalfThickness, webTopY).dy)
      ..lineTo(
        p(webHalfThickness, baseTopY).dx,
        p(webHalfThickness, baseTopY).dy,
      )
      ..lineTo(
        p(-webHalfThickness, baseTopY).dx,
        p(-webHalfThickness, baseTopY).dy,
      )
      ..close();
    final flange = Path()
      ..moveTo(
        p(-flangeHalfWidth, baseTopY).dx,
        p(-flangeHalfWidth, baseTopY).dy,
      )
      ..lineTo(p(flangeHalfWidth, baseTopY).dx, p(flangeHalfWidth, baseTopY).dy)
      ..lineTo(
        p(flangeHalfWidth, baseBottomY).dx,
        p(flangeHalfWidth, baseBottomY).dy,
      )
      ..lineTo(
        p(-flangeHalfWidth, baseBottomY).dx,
        p(-flangeHalfWidth, baseBottomY).dy,
      )
      ..close();
    final weld = Path()
      ..moveTo(p(webHalfThickness, topToeY).dx, p(webHalfThickness, topToeY).dy)
      ..lineTo(
        p(webHalfThickness, baseTopY).dx,
        p(webHalfThickness, baseTopY).dy,
      )
      ..lineTo(p(toeX, baseTopY).dx, p(toeX, baseTopY).dy)
      ..quadraticBezierTo(
        p(faceControlX, faceControlY).dx,
        p(faceControlX, faceControlY).dy,
        p(webHalfThickness, topToeY).dx,
        p(webHalfThickness, topToeY).dy,
      )
      ..close();

    _drawJoint(
      canvas,
      size,
      web,
      flange,
      weld,
      steelPaint,
      weldPaint,
      outlinePaint,
    );
    _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(webHalfThickness, baseBottomY + 3),
      end: p(toeX, baseBottomY + 3),
      label: '${_formatValue(leg)} mm leg',
      labelSize: size,
      extensionStart: p(webHalfThickness, baseTopY),
      extensionEnd: p(toeX, baseTopY),
      fieldKey: FieldKey.legSizeMm,
    );
    _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(toeX + 4, topToeY),
      end: p(toeX + 4, baseTopY),
      label: '${_formatValue(leg)} mm leg',
      labelSize: size,
      // `labelOffset` is a raw screen-pixel nudge (unlike the geometry
      // itself, it is not scaled by the drawing's mm-to-px scale), so the
      // old +42px-right push landed this label's center only ~40px from
      // the "fillet weld face" leader label above it - close enough for
      // their bubbles to overlap. Push down instead of right so it clears
      // that leader vertically regardless of canvas size.
      labelOffset: const Offset(10, 30),
      extensionStart: p(webHalfThickness, topToeY),
      extensionEnd: p(webHalfThickness, baseTopY),
      fieldKey: FieldKey.legSizeMm,
    );
    _drawLeader(
      canvas,
      guidePaint,
      start: p(webHalfThickness + (leg * 0.48), baseTopY - (leg * 0.34)),
      mid: p(flangeHalfWidth * 0.78, baseTopY - (leg * 0.72)),
      end: p(flangeHalfWidth + 3, baseTopY - (leg * 0.72)),
      text: 'fillet weld face',
      size: size,
    );
    _drawLeader(
      canvas,
      guidePaint,
      start: p(0, webTopY + ((baseTopY - webTopY) * 0.45)),
      mid: p(-flangeHalfWidth * 0.82, webTopY + 2),
      end: p(-flangeHalfWidth - 4, webTopY + 2),
      text: 'T-joint',
      size: size,
    );
    _drawTypeChip(canvas, size, 'Fillet');
  }

  void _drawJoint(
    Canvas canvas,
    Size size,
    Path firstPlate,
    Path secondPlate,
    Path weld,
    Paint steelPaint,
    Paint weldPaint,
    Paint outlinePaint,
  ) {
    canvas.drawPath(firstPlate, steelPaint);
    canvas.drawPath(secondPlate, steelPaint);
    canvas.drawPath(weld, weldPaint);
    _drawWeldHatch(canvas, weld, size);
    canvas.drawPath(firstPlate, outlinePaint);
    canvas.drawPath(secondPlate, outlinePaint);
    canvas.drawPath(weld, outlinePaint);
  }

  void _drawCombinedProcessTint(
    Canvas canvas,
    Size size,
    Path weld, {
    required _SectionLayout layout,
    required double totalHeightMm,
    required double? rootHeightMm,
    bool includeBottomRootTint = true,
    Path? extraRootZone,
    required Offset topLabelCenter,
    required Offset rootLabelCenter,
  }) {
    if (!_isCombinedProcess || rootHeightMm == null) return;

    final boundedRoot = rootHeightMm.clamp(0.0, totalHeightMm).toDouble();
    if (boundedRoot <= 0 || boundedRoot >= totalHeightMm) return;

    final topOfRoot =
        layout.topY + ((totalHeightMm - boundedRoot) * layout.scale);
    final rootPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _gtawRootColor.withValues(alpha: 0.88),
          _gtawRootShade.withValues(alpha: 0.94),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.clipPath(weld);
    if (includeBottomRootTint) {
      canvas.drawRect(
        Rect.fromLTWH(0, topOfRoot, size.width, size.height - topOfRoot),
        rootPaint,
      );
    }
    if (extraRootZone != null) {
      canvas.drawPath(extraRootZone, rootPaint);
    }
    canvas.restore();

    _drawAnnotationLabel(
      canvas,
      size,
      'SMAW fill / cap',
      topLabelCenter,
      fontSize: 10,
    );
    _drawAnnotationLabel(
      canvas,
      size,
      'GTAW root',
      rootLabelCenter,
      fontSize: 10,
    );
    _hotspot(FieldKey.gtawTransitionMm, rootLabelCenter, radius: 22);
  }

  Rect? _drawButtCommonMeasurements(
    Canvas canvas,
    Size size,
    Paint guidePaint, {
    required _SectionLayout layout,
    required double thickness,
    required double halfGap,
    required double grooveY,
    required double thicknessLabelX,
    double? rightThicknessLabelX,
    double? rootGapLabelY,
    List<Rect> avoidRects = const [],
  }) {
    final p = layout.point;
    final memberExtents = _memberExtents(thickness);
    final unequal = data.geometryMode == JointGeometryMode.unequal;

    _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(thicknessLabelX, memberExtents.leftTop),
      end: p(thicknessLabelX, memberExtents.leftBottom),
      label: unequal
          ? 'A ${_formatValue(memberExtents.leftBottom - memberExtents.leftTop)} mm'
          : '${_formatValue(thickness)} mm t',
      labelSize: size,
      labelOffset: const Offset(-42, 0),
      extensionStart: p(-halfGap, memberExtents.leftTop),
      extensionEnd: p(-halfGap, memberExtents.leftBottom),
      fieldKey: unequal ? FieldKey.thicknessAMm : FieldKey.thicknessMm,
    );
    if (unequal && rightThicknessLabelX != null) {
      _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(rightThicknessLabelX, memberExtents.rightTop),
        end: p(rightThicknessLabelX, memberExtents.rightBottom),
        label:
            'B ${_formatValue(memberExtents.rightBottom - memberExtents.rightTop)} mm',
        labelSize: size,
        labelOffset: const Offset(42, 0),
        extensionStart: p(halfGap, memberExtents.rightTop),
        extensionEnd: p(halfGap, memberExtents.rightBottom),
        fieldKey: FieldKey.thicknessBMm,
      );
    }
    _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(-halfGap, thickness + 3.5),
      end: p(halfGap, thickness + 3.5),
      label: '${_formatValue(halfGap * 2)} mm root gap',
      labelSize: size,
      labelOffset: const Offset(0, 16),
      extensionStart: p(-halfGap, rootGapLabelY ?? thickness),
      extensionEnd: p(halfGap, rootGapLabelY ?? thickness),
      fieldKey: FieldKey.rootGapMm,
    );
    if (grooveY > 0) {
      // In unequal-geometry mode the "B ... mm" thickness label (right
      // lane, below) shares almost the same horizontal reach as this one
      // and sits at a nearly identical vertical center (thickness/2 vs.
      // grooveY/2), so a horizontal-only offset isn't enough to keep them
      // apart once the canvas is small enough to shrink that gap below
      // both bubbles' widths. Nudge this one up so it keeps its own lane
      // near the top of the member regardless of canvas size.
      final grooveDepthOffset = unequal
          ? const Offset(46, -22)
          : const Offset(46, 0);
      return _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(halfGap + 20, 0),
        end: p(halfGap + 20, grooveY),
        label: '${_formatValue(grooveY)} mm groove depth',
        labelSize: size,
        labelOffset: grooveDepthOffset,
        extensionStart: p(halfGap, 0),
        extensionEnd: p(halfGap, grooveY),
        fieldKey: FieldKey.rootFaceMm,
        avoidRects: avoidRects,
      );
    }
    return null;
  }

  _MemberExtents _memberExtents(double governingThickness) {
    if (data.geometryMode != JointGeometryMode.unequal) {
      return _MemberExtents(
        leftTop: 0,
        leftBottom: governingThickness,
        rightTop: 0,
        rightBottom: governingThickness,
      );
    }

    final thicknessA = _positiveOr(
      data.thicknessAMm ?? data.thicknessMm,
      governingThickness,
    );
    final thicknessB = _positiveOr(
      data.thicknessBMm ?? data.thicknessMm,
      governingThickness,
    );

    return switch (data.alignment) {
      JointAlignment.centerline => _MemberExtents(
        leftTop: (governingThickness - thicknessA) / 2,
        leftBottom: (governingThickness + thicknessA) / 2,
        rightTop: (governingThickness - thicknessB) / 2,
        rightBottom: (governingThickness + thicknessB) / 2,
      ),
      JointAlignment.odMatch => _MemberExtents(
        leftTop: 0,
        leftBottom: thicknessA,
        rightTop: 0,
        rightBottom: thicknessB,
      ),
      JointAlignment.idMatch => _MemberExtents(
        leftTop: governingThickness - thicknessA,
        leftBottom: governingThickness,
        rightTop: governingThickness - thicknessB,
        rightBottom: governingThickness,
      ),
    };
  }

  _SectionLayout _createLayout(
    Size size, {
    required double maxHalfWidthMm,
    required double heightMm,
    double topPaddingMm = 3.5,
    String topChipLabel = '',
  }) {
    // Margins as a fraction of canvas size (matching the original fixed
    // 50/42/100/92 px margins against the 760x400 reference canvas) so the
    // layout looks identical whether painted on that virtual canvas or
    // directly at a real, smaller box (see [WeldDrawingPreview.fillAvailableSpace]).
    final marginX = size.width * 0.0658;
    var marginTop = size.height * 0.105;
    final marginBottom = size.height * 0.125;
    if (fillAvailableSpace) {
      // In this mode `size` is the *real* on-screen box - there's no outer
      // FittedBox uniformly re-scaling everything back up - and it can be
      // much shorter than the 760x400 reference canvas, e.g. the pinned
      // mobile drawing card. The top-center groove-type chip is drawn at a
      // constant on-screen pixel size for legibility (see the
      // [WeldDrawingPreview.fillAvailableSpace] doc), so unlike this
      // proportional margin it does not shrink along with a short canvas.
      // Floor the margin so there is always real room above the drawing
      // for that fixed-size chip, even on a very short canvas. When the
      // pipe-OD chip is stacked below the type chip instead of beside it
      // (see [_stackTopChips]) that top-center column is two chips tall,
      // so raise the floor to keep clearing it.
      marginTop = math.max(
        marginTop,
        _stackTopChips(size, topChipLabel) ? 80.0 : 48.0,
      );
    }
    final frame = Rect.fromLTWH(
      marginX,
      marginTop,
      size.width - (marginX * 2),
      size.height - marginTop - marginBottom,
    );
    final scale = math.min(
      frame.width / (maxHalfWidthMm * 2),
      frame.height / heightMm,
    );
    final actualHeight = heightMm * scale;
    final slack = math.max(frame.height - actualHeight, 0.0);
    // `heightMm` already budgets `topPaddingMm` of extra room above the
    // plate's top surface (y=0) for the weld-cap crown to rise into - see
    // each call site. Reserve that as guaranteed space instead of letting
    // it collapse into pure centering slack, which is zero whenever the
    // drawing is height-constrained (the common case on a short canvas).
    // Without this, y=0 sits flush with the frame's top edge and the
    // crown, which renders above y=0, pokes straight up into the margin
    // where the top labels live. Only apply it in [fillAvailableSpace]
    // mode so the always-760x400 desktop/FittedBox rendering (which never
    // hit this collision) is unaffected.
    final topPadding = fillAvailableSpace ? topPaddingMm * scale : 0.0;
    final topY = frame.top + topPadding + (slack / 2);
    return _SectionLayout(scale: scale, centerX: size.width / 2, topY: topY);
  }

  double _positiveOr(double? value, double fallback, {double min = 0.2}) {
    if (value == null || !value.isFinite || value <= 0) return fallback;
    return math.max(value, min);
  }

  double _clampValue(
    double? value, {
    required double fallback,
    required double min,
    required double max,
  }) {
    final resolved = value == null || !value.isFinite ? fallback : value;
    if (max <= min) return min;
    return resolved.clamp(min, max).toDouble();
  }

  double _degToRad(double degrees) => degrees * math.pi / 180;

  String _formatValue(double value) {
    if (value.abs() >= 100 || value == value.roundToDouble()) {
      return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
    }
    final text = value.toStringAsFixed(value < 10 ? 2 : 1);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  // Draws the top-center groove-type chip and, for pipe joints, the
  // top-right OD chip. When placed side by side the two chips can overlap
  // (the OD chip's independent canvas-edge clamping pulls it left just as
  // the type chip's clamping pulls it right), so on canvases where the two
  // chips' real measured rects would actually collide the OD chip stacks
  // directly below the type chip instead - see [_stackTopChips].
  void _drawTopChips(Canvas canvas, Size size, String typeLabel) {
    _drawTypeChip(canvas, size, typeLabel);
    _drawPipeChip(
      canvas,
      size,
      center: _stackTopChips(size, typeLabel)
          ? Offset(size.width * 0.5, 60)
          : Offset(size.width - 82, 28),
    );
  }

  void _drawTypeChip(Canvas canvas, Size size, String label) {
    _drawAnnotationLabel(
      canvas,
      size,
      label,
      Offset(size.width * 0.5, 28),
      fontSize: 11.5,
      weight: FontWeight.w700,
    );
  }

  void _drawPipeChip(Canvas canvas, Size size, {Offset? center}) {
    if (!_isPipeButt || data.pipeOdMm == null || data.pipeOdMm! <= 0) return;
    _drawAnnotationLabel(
      canvas,
      size,
      'OD ${_formatValue(data.pipeOdMm!)} mm',
      center ?? Offset(size.width - 82, 28),
      fontSize: 10.5,
    );
  }

  void _drawWeldHatch(Canvas canvas, Path path, Size size) {
    canvas.save();
    canvas.clipPath(path);
    final hatchPaint = Paint()
      ..color = _isTechnical ? const Color(0x4234515E) : const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isTechnical ? 0.72 : 1.1
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final spacing = _isTechnical ? 11.5 : 14.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height * 0.9),
        Offset(x + size.height * 0.28, size.height * 0.12),
        hatchPaint,
      );
    }
    canvas.restore();
  }

  void _drawCenterLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    const dash = 7.0;
    const gap = 5.0;
    final dy = end.dy - start.dy;
    double current = 0;
    while (current < dy) {
      canvas.drawLine(
        Offset(start.dx, start.dy + current),
        Offset(start.dx, math.min(start.dy + current + dash, end.dy)),
        paint,
      );
      current += dash + gap;
    }
  }

  Rect _drawDimensionLine(
    Canvas canvas,
    Paint paint, {
    required Offset start,
    required Offset end,
    required String label,
    required Size labelSize,
    Offset labelOffset = Offset.zero,
    Offset? extensionStart,
    Offset? extensionEnd,
    FieldKey? fieldKey,
    List<Rect> avoidRects = const [],
  }) {
    if (extensionStart != null) {
      canvas.drawLine(extensionStart, start, paint);
    }
    if (extensionEnd != null) {
      canvas.drawLine(extensionEnd, end, paint);
    }
    canvas.drawLine(start, end, paint);
    _drawArrowHead(canvas, paint, start, end);
    _drawArrowHead(canvas, paint, end, start);
    final midpoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    var labelCenter = Offset(
      midpoint.dx + labelOffset.dx,
      midpoint.dy + labelOffset.dy,
    );
    final fontSize = _measurementFontSize(labelSize);
    if (avoidRects.isNotEmpty) {
      labelCenter = _clearLabelPosition(
        labelSize,
        label,
        labelCenter,
        fontSize,
        avoidRects,
      );
    }
    _drawAnnotationLabel(
      canvas,
      labelSize,
      label,
      labelCenter,
      fontSize: fontSize,
      technicalDimension: true,
    );
    _hotspot(fieldKey, labelCenter);
    return _measurementLabelRect(labelSize, label, labelCenter, fontSize);
  }

  void _drawLeader(
    Canvas canvas,
    Paint paint, {
    required Offset start,
    required Offset mid,
    required Offset end,
    required String text,
    required Size size,
  }) {
    canvas.drawLine(start, mid, paint);
    canvas.drawLine(mid, end, paint);
    _drawArrowHead(canvas, paint, start, mid);
    _drawAnnotationLabel(
      canvas,
      size,
      text,
      Offset(end.dx + 4, end.dy - 4),
      fontSize: _annotationFontSize(size, 11.2),
    );
  }

  Rect _drawAngleTag(
    Canvas canvas,
    Paint paint,
    Size size, {
    required Offset start,
    required Offset labelCenter,
    required String text,
    FieldKey? fieldKey,
    List<Rect> avoidRects = const [],
  }) {
    final fontSize = _measurementFontSize(size);
    var resolvedCenter = labelCenter;
    if (avoidRects.isNotEmpty) {
      resolvedCenter = _clearLabelPosition(
        size,
        text,
        labelCenter,
        fontSize,
        avoidRects,
      );
    }
    final dx = resolvedCenter.dx - start.dx;
    final dy = resolvedCenter.dy - start.dy;
    final length = math.sqrt((dx * dx) + (dy * dy));
    final ux = length == 0 ? 0.0 : dx / length;
    final uy = length == 0 ? 0.0 : dy / length;
    final lineEnd = Offset(
      resolvedCenter.dx - (ux * 20),
      resolvedCenter.dy - (uy * 20),
    );

    canvas.drawLine(start, lineEnd, paint);
    canvas.drawCircle(start, 2.6, Paint()..color = paint.color);
    _drawAnnotationLabel(
      canvas,
      size,
      text,
      resolvedCenter,
      fontSize: fontSize,
      technicalDimension: true,
    );
    _hotspot(fieldKey, resolvedCenter);
    return _measurementLabelRect(size, text, resolvedCenter, fontSize);
  }

  // Mirrors the pill sizing/clamping in [_drawTechnicalLabel] / [_drawSoftLabel]
  // for a `technicalDimension: true` label - what every dimension line and
  // angle tag draws - the same measure-before-you-collide approach
  // [_chipSize]/[_chipRect] already use for the top chips, generalized to
  // any measurement label so [_clearLabelPosition] sees each label's real
  // on-canvas rect instead of an mm-space guess.
  Rect _measurementLabelRect(
    Size size,
    String text,
    Offset center,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: _annotationFontSize(size, fontSize),
          fontWeight: _isTechnical ? FontWeight.w500 : FontWeight.w600,
          letterSpacing: _isTechnical ? 0.04 : 0.06,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final verticalPadding = _isTechnical ? 10.0 : 11.0;
    final minWidth = _isTechnical ? 56.0 : 62.0;
    final minHeight = _isTechnical ? 26.0 : 28.0;
    final rect = Rect.fromCenter(
      center: center,
      width: math.max(painter.width + 18.0, minWidth),
      height: math.max(painter.height + verticalPadding, minHeight),
    );
    return Rect.fromLTWH(
      _safeClamp(rect.left, 10, size.width - rect.width - 10),
      _safeClamp(rect.top, 10, size.height - rect.height - 10),
      rect.width,
      rect.height,
    );
  }

  // Pushes [candidateCenter] straight down (or up, whichever direction it's
  // already on) by exactly the real pixel amount needed to clear each rect
  // in [avoidRects] - not a fixed mm-space or pixel nudge - so the fix holds
  // regardless of canvas scale or which font is actually rendering. This is
  // the general mechanism behind the alpha/groove-depth/beta fix on the
  // Compound V drawing (see the comment above that callout block) and is
  // reusable by any future dimension line or angle tag that needs to stay
  // clear of another label already placed nearby.
  Offset _clearLabelPosition(
    Size size,
    String text,
    Offset candidateCenter,
    double fontSize,
    List<Rect> avoidRects, {
    double gap = 4.0,
  }) {
    var center = candidateCenter;
    for (final raw in avoidRects) {
      final avoid = raw.inflate(gap);
      final rect = _measurementLabelRect(size, text, center, fontSize);
      if (!rect.overlaps(avoid)) continue;
      final pushDown = rect.center.dy >= avoid.center.dy;
      final delta = pushDown
          ? avoid.bottom - rect.top
          : avoid.top - rect.bottom;
      center = Offset(center.dx, center.dy + delta);
    }
    return center;
  }

  void _drawAnnotationLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset center, {
    double fontSize = 12,
    FontWeight weight = FontWeight.w600,
    bool technicalDimension = false,
  }) {
    if (_isTechnical) {
      _drawTechnicalLabel(
        canvas,
        size,
        text,
        center,
        fontSize: fontSize,
        weight: technicalDimension ? FontWeight.w500 : weight,
        square: technicalDimension,
      );
      return;
    }

    _drawSoftLabel(
      canvas,
      size,
      text,
      center,
      fontSize: fontSize,
      weight: weight,
    );
  }

  void _drawTechnicalLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset center, {
    double fontSize = 12,
    FontWeight weight = FontWeight.w600,
    bool square = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _labelColor,
          fontSize: _annotationFontSize(size, fontSize),
          fontWeight: weight,
          letterSpacing: 0.04,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final horizontalPadding = square ? 18.0 : 20.0;
    final verticalPadding = square ? 10.0 : 11.0;
    final minWidth = square ? 56.0 : 66.0;
    final minHeight = square ? 26.0 : 28.0;
    final rect = Rect.fromCenter(
      center: center,
      width: math.max(painter.width + horizontalPadding, minWidth),
      height: math.max(painter.height + verticalPadding, minHeight),
    );
    final safeRect = Rect.fromLTWH(
      _safeClamp(rect.left, 10, size.width - rect.width - 10),
      _safeClamp(rect.top, 10, size.height - rect.height - 10),
      rect.width,
      rect.height,
    );
    final fillPaint = Paint()
      ..color = const Color(0xF2FFFFFF)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final strokePaint = Paint()
      ..color = const Color(0x8878909C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = square ? 0.72 : 0.82
      ..isAntiAlias = true;
    final shadowPaint = Paint()
      ..color = const Color(0x1434515E)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    if (square) {
      final rrect = RRect.fromRectAndRadius(safeRect, const Radius.circular(4));
      canvas.drawRRect(rrect.shift(const Offset(0, 1.2)), shadowPaint);
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, strokePaint);
    } else {
      final rrect = RRect.fromRectAndRadius(safeRect, const Radius.circular(8));
      canvas.drawRRect(rrect.shift(const Offset(0, 1.2)), shadowPaint);
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, strokePaint);
    }

    painter.paint(
      canvas,
      Offset(
        safeRect.left + ((safeRect.width - painter.width) / 2),
        safeRect.top + ((safeRect.height - painter.height) / 2),
      ),
    );
  }

  void _drawSoftLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset center, {
    double fontSize = 12,
    FontWeight weight = FontWeight.w600,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _labelColor,
          fontSize: _annotationFontSize(size, fontSize),
          fontWeight: weight,
          letterSpacing: 0.06,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final horizontalPadding = 18.0;
    final verticalPadding = 11.0;
    final rect = Rect.fromCenter(
      center: center,
      width: math.max(painter.width + horizontalPadding, 62.0),
      height: math.max(painter.height + verticalPadding, 28.0),
    );
    final safeRect = Rect.fromLTWH(
      _safeClamp(rect.left, 10, size.width - rect.width - 10),
      _safeClamp(rect.top, 10, size.height - rect.height - 10),
      rect.width,
      rect.height,
    );
    final rrect = RRect.fromRectAndRadius(safeRect, const Radius.circular(999));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _softLabelFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _softLabelStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    painter.paint(
      canvas,
      Offset(
        safeRect.left + ((safeRect.width - painter.width) / 2),
        safeRect.top + ((safeRect.height - painter.height) / 2),
      ),
    );
  }

  void _drawArrowHead(Canvas canvas, Paint paint, Offset tip, Offset tail) {
    final angle = math.atan2(tail.dy - tip.dy, tail.dx - tip.dx);
    const length = 8.0;
    const spread = 0.45;
    final p1 = Offset(
      tip.dx + length * math.cos(angle - spread),
      tip.dy + length * math.sin(angle - spread),
    );
    final p2 = Offset(
      tip.dx + length * math.cos(angle + spread),
      tip.dy + length * math.sin(angle + spread),
    );
    canvas.drawLine(tip, p1, paint);
    canvas.drawLine(tip, p2, paint);
  }

  void _drawLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset offset, {
    double fontSize = 12,
    FontWeight weight = FontWeight.w600,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _labelColor,
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(0, size.width - offset.dx - 8));
    painter.paint(canvas, offset);
  }

  double _safeClamp(double value, double min, double max) {
    if (max <= min) return min;
    return value.clamp(min, max).toDouble();
  }

  double _annotationScale(Size size) =>
      (size.width / 760).clamp(0.98, 1.10).toDouble();

  double _annotationFontSize(Size size, double base) =>
      base * _annotationScale(size);

  double _measurementFontSize(Size size) =>
      (_isTechnical ? 11.1 : 11.4) * _annotationScale(size);

  @override
  bool shouldRepaint(covariant _WeldDrawingPainter oldDelegate) =>
      oldDelegate.grooveType != grooveType ||
      oldDelegate.jointType != jointType ||
      oldDelegate.drawingMode != drawingMode ||
      oldDelegate.data != data;
}
