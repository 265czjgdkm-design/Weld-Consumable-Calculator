import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/weld_models.dart';
import '../calculator_page/calculator_page_models.dart' show FieldKey;

enum DrawingMode { visual, technical }

/// A tappable region of the drawing that corresponds to one editable
/// [FieldKey], recorded by the painter as the exact clamped rect it drew
/// that dimension's label pill at, so a tap on the drawing can jump to the
/// matching input field below. Using the real drawn rect (rather than a
/// separately-tracked center point) means a tap target can never drift from
/// the visible pill, even once canvas-edge clamping moves that pill from
/// its natural, unclamped position.
class DrawingHotspot {
  const DrawingHotspot(this.fieldKey, this.rect);

  final FieldKey fieldKey;
  final Rect rect;
}

extension DrawingModeX on DrawingMode {
  String labelFor(L10nStrings strings) => switch (this) {
    DrawingMode.visual => strings.drawingModeVisual,
    DrawingMode.technical => strings.drawingModeTechnical,
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
    this.capOverlapMm,
    this.capHeightMm,
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
  final double? capOverlapMm;
  final double? capHeightMm;
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
    required this.jointTypeLabel,
    required this.grooveTypeLabel,
    required this.filletWeldFaceLabel,
    required this.tJointLabel,
    required this.smawFillCapLabel,
    required this.gtawRootLabel,
    this.onFieldTap,
    this.fillAvailableSpace = false,
  });

  final GrooveType grooveType;
  final JointType jointType;
  final DrawingMode drawingMode;
  final WeldDrawingData data;

  // Pre-resolved localized labels, passed in by the caller (which has a
  // BuildContext) since the CustomPainter that actually draws them does not.
  final String jointTypeLabel;
  final String grooveTypeLabel;
  final String filletWeldFaceLabel;
  final String tJointLabel;
  final String smawFillCapLabel;
  final String gtawRootLabel;

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
          jointTypeLabel: widget.jointTypeLabel,
          grooveTypeLabel: widget.grooveTypeLabel,
          filletWeldFaceLabel: widget.filletWeldFaceLabel,
          tJointLabel: widget.tJointLabel,
          smawFillCapLabel: widget.smawFillCapLabel,
          gtawRootLabel: widget.gtawRootLabel,
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
      if (!hotspot.rect.contains(tapPosition)) continue;
      final distanceSq = (hotspot.rect.center - tapPosition).distanceSquared;
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
    double? scaleY,
  }) : scaleY = scaleY ?? scale;

  final double scale;
  // Independent vertical scale, only ever >= [scale] - see _createLayout's
  // comment on why the joint cross-section (inherently wide/short) is
  // allowed a bounded vertical stretch beyond its true-to-width scale.
  final double scaleY;
  final double centerX;
  final double topY;

  Offset point(double x, double y) =>
      Offset(centerX + (x * scale), topY + (y * scaleY));
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
    required this.jointTypeLabel,
    required this.grooveTypeLabel,
    required this.filletWeldFaceLabel,
    required this.tJointLabel,
    required this.smawFillCapLabel,
    required this.gtawRootLabel,
    this.onHotspots,
    this.fillAvailableSpace = false,
  });

  final GrooveType grooveType;
  final JointType jointType;
  final DrawingMode drawingMode;
  final WeldDrawingData data;
  final String jointTypeLabel;
  final String grooveTypeLabel;
  final String filletWeldFaceLabel;
  final String tJointLabel;
  final String smawFillCapLabel;
  final String gtawRootLabel;
  final ValueChanged<List<DrawingHotspot>>? onHotspots;
  final bool fillAvailableSpace;

  final List<DrawingHotspot> _hotspots = [];

  // Records the exact clamped rect a label was actually drawn at (see
  // [_measurementLabelRect] / [_drawTechnicalLabel] / [_drawSoftLabel]'s
  // `safeRect`) as this field's tap target, so hit-testing is inherently in
  // sync with what's visible on screen regardless of canvas-edge clamping.
  void _hotspot(FieldKey? fieldKey, Rect rect) {
    if (fieldKey == null) return;
    _hotspots.add(DrawingHotspot(fieldKey, rect));
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
          fontFamily: 'Roboto',
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
        '$jointTypeLabel / $grooveTypeLabel',
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
      topChipLabel: grooveTypeLabel,
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
    final tint = _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(halfTop * 0.48, thickness * 0.18),
      rootLabelCenter: p(halfGap + 6, thickness - 0.8),
    );
    final tintRects = [?tint.topLabel, ?tint.rootLabel];
    // Root face is drawn before common measurements (unlike its natural
    // top-to-bottom reading order) so its real rect is available for groove
    // depth's avoid list - mirrors Half V/Compound V's established pattern
    // for this same class of collision (see the comment on those blocks).
    final rootFaceRect = _drawDimensionLine(
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
      avoidRects: tintRects,
    );
    final commonRects = _drawButtCommonMeasurements(
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
      avoidRects: [...tintRects, rootFaceRect],
    );
    // Every label below avoids every label already placed before it - the
    // angle tag sits on the opposite (left) side from root face/groove
    // depth, so it rarely collides with them, but root face shares the
    // same right-hand lane as thickness/root gap/groove depth and can
    // still collapse into them at narrow canvas widths.
    final angleRect = _drawAngleTag(
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
      avoidRects: [
        ...tintRects,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        rootFaceRect,
      ],
    );
    final chipRects = _drawTopChips(canvas, size, grooveTypeLabel);
    _drawCapDimensions(
      canvas,
      size,
      guidePaint,
      layout: layout,
      halfTop: halfTop,
      topY: math.min(member.leftTop, member.rightTop),
      thickness: thickness,
      avoidRects: [
        ...tintRects,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        rootFaceRect,
        angleRect,
        chipRects.typeChip,
        ?chipRects.pipeChip,
      ],
    );
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
      topChipLabel: grooveTypeLabel,
    );
    final p = layout.point;
    // Half V only bevels its right-hand member - the left member is a flat,
    // square edge - but Unequal geometry can still give the two members
    // different thicknesses, so (like Single V/Double V/Square) the actual
    // per-member vertical extents have to come from [_memberExtents], not a
    // flat 0..thickness range, or the drawing renders both plates at the
    // same thickness even when the entered A/B thicknesses differ.
    final member = _memberExtents(thickness);
    final rightThickness = member.rightBottom - member.rightTop;
    final rightRootFace = math.min(
      rootFace,
      math.max(rightThickness - 0.8, 0.5),
    );
    final rightGrooveY = member.rightBottom - rightRootFace;
    final capRise = math.min(thickness * 0.15, 2.8);
    final rootCrown = math.min(rootFace * 0.35, 1.0);

    final leftPlate = Path()
      ..moveTo(p(-leftBody, member.leftTop).dx, p(-leftBody, member.leftTop).dy)
      ..lineTo(p(-halfGap, member.leftTop).dx, p(-halfGap, member.leftTop).dy)
      ..lineTo(
        p(-halfGap, member.leftBottom).dx,
        p(-halfGap, member.leftBottom).dy,
      )
      ..lineTo(
        p(-leftBody, member.leftBottom).dx,
        p(-leftBody, member.leftBottom).dy,
      )
      ..close();
    final rightPlate = Path()
      ..moveTo(
        p(rightBody, member.rightTop).dx,
        p(rightBody, member.rightTop).dy,
      )
      ..lineTo(p(topRight, member.rightTop).dx, p(topRight, member.rightTop).dy)
      ..lineTo(p(halfGap, rightGrooveY).dx, p(halfGap, rightGrooveY).dy)
      ..lineTo(
        p(halfGap, member.rightBottom).dx,
        p(halfGap, member.rightBottom).dy,
      )
      ..lineTo(
        p(rightBody, member.rightBottom).dx,
        p(rightBody, member.rightBottom).dy,
      )
      ..close();
    final weld = Path()
      ..moveTo(p(-halfGap, member.leftTop).dx, p(-halfGap, member.leftTop).dy)
      ..quadraticBezierTo(
        p(
          (topRight - halfGap) / 2,
          math.min(member.leftTop, member.rightTop) - capRise,
        ).dx,
        p(
          (topRight - halfGap) / 2,
          math.min(member.leftTop, member.rightTop) - capRise,
        ).dy,
        p(topRight, member.rightTop).dx,
        p(topRight, member.rightTop).dy,
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
      ..lineTo(p(-halfGap, member.leftTop).dx, p(-halfGap, member.leftTop).dy)
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
    final tint = _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(topRight * 0.72, thickness * 0.18),
      rootLabelCenter: p(halfGap + 6, thickness - 0.8),
    );
    final tintRects = [?tint.topLabel, ?tint.rootLabel];
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
      start: p(
        halfGap + ((topRight - halfGap) * 0.44),
        member.rightTop + ((rightGrooveY - member.rightTop) * 0.34),
      ),
      labelCenter: p(
        topRight + 7.0,
        member.rightTop + ((rightGrooveY - member.rightTop) * 0.20),
      ),
      text: '${_formatValue(bevelAngle)}°',
      fieldKey: FieldKey.bevelAngleDeg,
      avoidRects: tintRects,
    );
    final rootFaceRect = _drawDimensionLine(
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
      avoidRects: [...tintRects, angleRect],
    );
    final commonRects = _drawButtCommonMeasurements(
      canvas,
      size,
      guidePaint,
      layout: layout,
      thickness: thickness,
      halfGap: halfGap,
      grooveY: rightGrooveY - member.rightTop,
      thicknessLabelX: -leftBody - 6,
      rightThicknessLabelX: rightBody + 6,
      avoidRects: [...tintRects, angleRect, rootFaceRect],
    );
    final chipRects = _drawTopChips(canvas, size, grooveTypeLabel);
    _drawCapDimensions(
      canvas,
      size,
      guidePaint,
      layout: layout,
      halfTop: topRight,
      topY: math.min(member.leftTop, member.rightTop),
      thickness: thickness,
      avoidRects: [
        ...tintRects,
        angleRect,
        rootFaceRect,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        chipRects.typeChip,
        ?chipRects.pipeChip,
      ],
    );
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
    // Double V gets a cap-reinforcement dimension pair on BOTH faces (see
    // _drawCapDimensions below), so with cap values actually set it needs
    // real extra vertical room above AND below the plate for those two
    // extra labels, not just the small generic crown buffer every other
    // groove type's single (top-only) cap already fits inside.
    final hasCapDimensions =
        (data.capOverlapMm ?? 0) > 0 || (data.capHeightMm ?? 0) > 0;
    final layout = _createLayout(
      size,
      maxHalfWidthMm: halfBody + 10,
      heightMm: thickness + 7 + (hasCapDimensions ? 22 : 0),
      topPaddingMm: 4,
      topChipLabel: grooveTypeLabel,
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
    final tint = _drawCombinedProcessTint(
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
    final tintRects = [?tint.topLabel, ?tint.rootLabel];
    final commonRects = _drawButtCommonMeasurements(
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
      avoidRects: tintRects,
    );
    final totalRootFaceRect = _drawDimensionLine(
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
      avoidRects: [
        ...tintRects,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
      ],
    );
    final angleRect = _drawAngleTag(
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
      avoidRects: [
        ...tintRects,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        totalRootFaceRect,
      ],
    );
    Rect? upperHalfRectOuter;
    Rect? lowerHalfRect;
    if (data.geometryMode == JointGeometryMode.equal) {
      // These two half-thickness brackets sit in their own lane, closer to
      // the plate than the main thickness line (`thicknessLabelX`, above).
      // They used to sit only 5mm outside the plate edge - just 5mm from
      // the main thickness line's own lane - so the arrowheads where the
      // two half-bracket lines meet (at y=halfThickness, the exact same
      // height the main "<t> mm t" label is centered on) landed inside that
      // label's pill, reading as a stray diagonal mark crossing the text
      // (see TEAM_LEARNINGS.md, 2026-08-25). Pulled in closer to the plate
      // instead of further out, widening the gap from the main line's lane
      // without pushing this lane past the canvas edge. Also on the same
      // (left) side as the bevel angle tag, which lanes compress into on a
      // narrow enough canvas - must avoid it too, not just the labels drawn
      // above.
      final beforeHalves = [
        ...tintRects,
        commonRects.thickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        totalRootFaceRect,
        angleRect,
      ];
      // These represent the same underlying value as the main thickness
      // label elsewhere in this drawing, just displayed as a half-value -
      // wire both to the same field so they're tappable too.
      final upperHalfRect = _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(-halfBody + 4, 0),
        end: p(-halfBody + 4, halfThickness),
        label: '${_formatValue(halfThickness)} mm',
        labelSize: size,
        labelOffset: const Offset(-30, -16),
        fieldKey: FieldKey.thicknessMm,
        avoidRects: beforeHalves,
      );
      lowerHalfRect = _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(-halfBody + 4, halfThickness),
        end: p(-halfBody + 4, thickness),
        label: '${_formatValue(halfThickness)} mm',
        labelSize: size,
        labelOffset: const Offset(-30, 16),
        fieldKey: FieldKey.thicknessMm,
        avoidRects: [...beforeHalves, upperHalfRect],
      );
      upperHalfRectOuter = upperHalfRect;
    }
    final chipRects = _drawTopChips(canvas, size, grooveTypeLabel);
    final beforeCapRects = [
      ...tintRects,
      commonRects.thickness,
      ?commonRects.bThickness,
      commonRects.rootGap,
      ?commonRects.grooveDepth,
      totalRootFaceRect,
      angleRect,
      ?upperHalfRectOuter,
      ?lowerHalfRect,
      chipRects.typeChip,
      // Slightly inflated: the pipe-OD chip sits at a fixed pixel position
      // independent of mm-scale, and a few combinations (unequal geometry
      // + pipe joint) left the top cap-overlap label a couple of pixels
      // short of fully clearing it without this.
      if (chipRects.pipeChip != null) chipRects.pipeChip!.inflate(4),
    ];
    // Double V is welded from both sides, so it gets a cap-reinforcement
    // pass on BOTH faces (the entered overlap/height values apply
    // identically to each, per the user's explicit decision) - draw the
    // dimension callouts on the top face as usual, then a mirrored set on
    // the bottom face, each avoiding everything the other has already
    // placed.
    final topCap = _drawCapDimensions(
      canvas,
      size,
      guidePaint,
      layout: layout,
      halfTop: halfTop,
      topY: math.min(member.leftTop, member.rightTop),
      thickness: thickness,
      avoidRects: beforeCapRects,
    );
    _drawCapDimensions(
      canvas,
      size,
      guidePaint,
      layout: layout,
      halfTop: halfTop,
      topY: math.max(member.leftBottom, member.rightBottom),
      thickness: thickness,
      direction: 1,
      avoidRects: [...beforeCapRects, ?topCap.overlap, ?topCap.height],
    );
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
      topChipLabel: grooveTypeLabel,
    );
    final p = layout.point;
    // Compound V bevels both sides symmetrically, so (like Single V/Double
    // V/Square) member extents come from [_memberExtents] rather than a
    // flat 0..thickness range, or Unequal geometry's different A/B
    // thicknesses render identically. The bevel's horizontal geometry
    // (widths/angles) stays shared between both sides - only the vertical
    // references (top/break/groove/bottom) are per-member.
    final member = _memberExtents(thickness);
    final leftThickness = member.leftBottom - member.leftTop;
    final rightThickness = member.rightBottom - member.rightTop;
    final leftRootFace = math.min(rootFace, math.max(leftThickness - 1.2, 0.5));
    final rightRootFace = math.min(
      rootFace,
      math.max(rightThickness - 1.2, 0.5),
    );
    final leftGrooveY = member.leftBottom - leftRootFace;
    final rightGrooveY = member.rightBottom - rightRootFace;
    // `upperHeight` is derived from the governing (max A/B) thickness, so
    // applying it unclamped to a thinner member's own top would land its
    // break vertex below its own groove vertex, self-intersecting the
    // polygon - clamp it the same way `leftRootFace`/`rightRootFace` above
    // are already clamped to each member's own actual extent.
    final leftBreakY =
        member.leftTop +
        math.min(
          upperHeight,
          math.max(leftThickness - leftRootFace - 0.8, 0.5),
        );
    final rightBreakY =
        member.rightTop +
        math.min(
          upperHeight,
          math.max(rightThickness - rightRootFace - 0.8, 0.5),
        );
    final capRise = math.min(thickness * 0.14, 3.0);
    final rootCrown = math.min(rootFace * 0.32, 1.1);

    final leftPlate = Path()
      ..moveTo(p(-halfBody, member.leftTop).dx, p(-halfBody, member.leftTop).dy)
      ..lineTo(p(-halfTop, member.leftTop).dx, p(-halfTop, member.leftTop).dy)
      ..lineTo(p(-halfBreak, leftBreakY).dx, p(-halfBreak, leftBreakY).dy)
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
      ..lineTo(p(halfBreak, rightBreakY).dx, p(halfBreak, rightBreakY).dy)
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
      ..lineTo(p(halfBreak, rightBreakY).dx, p(halfBreak, rightBreakY).dy)
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
      ..lineTo(p(-halfBreak, leftBreakY).dx, p(-halfBreak, leftBreakY).dy)
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
    final tint = _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(halfTop * 0.48, thickness * 0.16),
      rootLabelCenter: p(halfGap + 6, thickness - 0.8),
    );
    final tintRects = [?tint.topLabel, ?tint.rootLabel];
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
    // So alpha and root face are measured and drawn first at their normal
    // lane positions, then groove depth and beta are each nudged straight
    // down in real pixel space (see [_clearLabelPosition]), using their
    // actual rendered bubble sizes, just far enough to clear every
    // already-placed bubble they'd otherwise overlap - groove depth must
    // avoid BOTH alpha (above) and root face (below), not just alpha, or a
    // push that clears alpha can land it straight on top of root face
    // instead (this happened in an earlier version of this fix - see
    // TEAM_LEARNINGS.md).
    final alphaRect = _drawAngleTag(
      canvas,
      guidePaint,
      size,
      start: p(
        halfGap + ((halfBreak - halfGap) * 0.52),
        rightGrooveY - ((rightGrooveY - rightBreakY) * 0.42),
      ),
      // `halfBreak + 6`, not a fixed offset from the centerline - the bevel
      // is `halfBreak` wide at this height, so the label needs to clear
      // that actual width (which grows with a wider root gap or steeper
      // bevel angle) rather than a constant that only happened to clear a
      // narrower bevel. A fixed `halfGap + 6` sat visibly on top of the
      // weld metal once the compact canvas's scale was increased to make
      // the drawing itself bigger (see TEAM_LEARNINGS.md).
      labelCenter: p(halfBreak + 6, rightBreakY * 0.35),
      text: 'α ${_formatValue(primaryAngle)}°',
      fieldKey: FieldKey.bevelAngleDeg,
      avoidRects: tintRects,
    );
    // Root face: bottom, inner-right lane, close to the joint. Drawn before
    // groove depth (unlike its natural top-to-bottom reading order) so its
    // real rect is available for groove depth's avoid list.
    final rootFaceRect = _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(halfGap + 5, rightGrooveY),
      end: p(halfGap + 5, member.rightBottom),
      label: '${_formatValue(rootFace)} mm root face',
      labelSize: size,
      labelOffset: const Offset(20, 6),
      extensionStart: p(halfGap, rightGrooveY),
      extensionEnd: p(halfGap, member.rightBottom),
      fieldKey: FieldKey.rootFaceMm,
      avoidRects: [...tintRects, alphaRect],
    );
    final commonRects = _drawButtCommonMeasurements(
      canvas,
      size,
      guidePaint,
      layout: layout,
      thickness: thickness,
      halfGap: halfGap,
      grooveY: rightGrooveY - member.rightTop,
      thicknessLabelX: -halfBody - 6,
      rightThicknessLabelX: halfBody + 6,
      avoidRects: [...tintRects, alphaRect, rootFaceRect],
    );
    // Break height "h": inner-left lane, kept close to the joint. Every
    // label in this drawing avoids every other label already placed before
    // it - Compound V is busy enough (six callouts sharing a canvas this
    // narrow) that any label sharing an avoid list with only SOME of its
    // predecessors reliably lands on whichever one was left out (this
    // happened three separate times across earlier attempts at this exact
    // drawing - see TEAM_LEARNINGS.md).
    final hRect = _drawDimensionLine(
      canvas,
      guidePaint,
      start: p(-halfGap - 12, leftBreakY),
      end: p(-halfGap - 12, leftGrooveY),
      label: 'h ${_formatValue(breakHeight)} mm',
      labelSize: size,
      labelOffset: const Offset(-14, 16),
      extensionStart: p(-halfBreak, leftBreakY),
      extensionEnd: p(-halfGap, leftGrooveY),
      fieldKey: FieldKey.breakHeightMm,
      avoidRects: [
        ...tintRects,
        alphaRect,
        rootFaceRect,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
      ],
    );
    // Secondary angle (beta): drawn last of the six, so it must avoid all
    // five already-placed labels, not a subset.
    final betaRect = _drawAngleTag(
      canvas,
      guidePaint,
      size,
      start: p(halfBreak + ((halfTop - halfBreak) * 0.48), rightBreakY * 0.48),
      labelCenter: p(halfBreak + 6, (rightBreakY + rightGrooveY) / 2),
      text: 'β ${_formatValue(secondaryAngle)}°',
      fieldKey: FieldKey.secondaryBevelAngleDeg,
      avoidRects: [
        ...tintRects,
        alphaRect,
        rootFaceRect,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        hRect,
      ],
    );
    final chipRects = _drawTopChips(canvas, size, grooveTypeLabel);
    _drawCapDimensions(
      canvas,
      size,
      guidePaint,
      layout: layout,
      halfTop: halfTop,
      topY: math.min(member.leftTop, member.rightTop),
      thickness: thickness,
      avoidRects: [
        ...tintRects,
        alphaRect,
        rootFaceRect,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        hRect,
        betaRect,
        chipRects.typeChip,
        ?chipRects.pipeChip,
      ],
    );
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
      topChipLabel: grooveTypeLabel,
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
    final tint = _drawCombinedProcessTint(
      canvas,
      size,
      weld,
      layout: layout,
      totalHeightMm: thickness,
      rootHeightMm: data.gtawTransitionMm,
      topLabelCenter: p(halfGap + 8, thickness * 0.18),
      rootLabelCenter: p(halfGap + 5.5, thickness - 0.8),
    );
    final commonRects = _drawButtCommonMeasurements(
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
      avoidRects: [?tint.topLabel, ?tint.rootLabel],
    );
    final chipRects = _drawTopChips(canvas, size, grooveTypeLabel);
    _drawCapDimensions(
      canvas,
      size,
      guidePaint,
      layout: layout,
      halfTop: halfGap,
      topY: math.min(member.leftTop, member.rightTop),
      thickness: thickness,
      avoidRects: [
        ?tint.topLabel,
        ?tint.rootLabel,
        commonRects.thickness,
        ?commonRects.bThickness,
        commonRects.rootGap,
        ?commonRects.grooveDepth,
        chipRects.typeChip,
        ?chipRects.pipeChip,
      ],
    );
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
    final leg1Rect = _drawDimensionLine(
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
    final leg2Rect = _drawDimensionLine(
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
      avoidRects: [leg1Rect],
    );
    // Leaders are drawn last, so they nudge clear of the leg labels rather
    // than the other way around - reordering the leg labels after the
    // leaders would just move which pair needs the avoid list.
    final filletFaceRect = _drawLeader(
      canvas,
      guidePaint,
      start: p(webHalfThickness + (leg * 0.48), baseTopY - (leg * 0.34)),
      mid: p(flangeHalfWidth * 0.78, baseTopY - (leg * 0.72)),
      end: p(flangeHalfWidth + 3, baseTopY - (leg * 0.72)),
      text: filletWeldFaceLabel,
      size: size,
      avoidRects: [leg1Rect, leg2Rect],
    );
    _drawLeader(
      canvas,
      guidePaint,
      start: p(0, webTopY + ((baseTopY - webTopY) * 0.45)),
      mid: p(-flangeHalfWidth * 0.82, webTopY + 2),
      end: p(-flangeHalfWidth - 4, webTopY + 2),
      text: tJointLabel,
      size: size,
      avoidRects: [leg1Rect, leg2Rect, filletFaceRect],
    );
    _drawTypeChip(canvas, size, grooveTypeLabel);
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

  ({Rect? topLabel, Rect? rootLabel}) _drawCombinedProcessTint(
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
    List<Rect> avoidRects = const [],
  }) {
    if (!_isCombinedProcess || rootHeightMm == null) {
      return (topLabel: null, rootLabel: null);
    }

    final boundedRoot = rootHeightMm.clamp(0.0, totalHeightMm).toDouble();
    if (boundedRoot <= 0 || boundedRoot >= totalHeightMm) {
      return (topLabel: null, rootLabel: null);
    }

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

    final topLabelRect = _drawAnnotationLabel(
      canvas,
      size,
      smawFillCapLabel,
      topLabelCenter,
      fontSize: 10,
      avoidRects: avoidRects,
    );
    // Both labels mark the same user-editable boundary (the fill/cap zone
    // is simply the complement of the GTAW root zone), so both jump to the
    // same field.
    _hotspot(FieldKey.gtawTransitionMm, topLabelRect);
    final rootLabelRect = _drawAnnotationLabel(
      canvas,
      size,
      gtawRootLabel,
      rootLabelCenter,
      fontSize: 10,
      avoidRects: [...avoidRects, topLabelRect],
    );
    _hotspot(FieldKey.gtawTransitionMm, rootLabelRect);
    return (topLabel: topLabelRect, rootLabel: rootLabelRect);
  }

  ({Rect thickness, Rect? bThickness, Rect rootGap, Rect? grooveDepth})
  _drawButtCommonMeasurements(
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

    final thicknessRect = _drawDimensionLine(
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
      avoidRects: avoidRects,
    );
    Rect? bThicknessRect;
    if (unequal && rightThicknessLabelX != null) {
      bThicknessRect = _drawDimensionLine(
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
        avoidRects: [...avoidRects, thicknessRect],
      );
    }
    final rootGapRect = _drawDimensionLine(
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
      avoidRects: [...avoidRects, thicknessRect, ?bThicknessRect],
    );
    if (grooveY > 0) {
      final grooveDepthRect = _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(halfGap + 20, 0),
        end: p(halfGap + 20, grooveY),
        label: '${_formatValue(grooveY)} mm groove depth',
        labelSize: size,
        labelOffset: const Offset(46, 0),
        extensionStart: p(halfGap, 0),
        extensionEnd: p(halfGap, grooveY),
        fieldKey: FieldKey.rootFaceMm,
        // Thickness, B-thickness (unequal geometry) and root gap are drawn
        // just above, in this same function - avoid all of them too, not
        // just the caller-supplied rects, or a push clear of those can
        // still land groove depth on top of one of them. Real avoidance
        // (rather than the fixed vertical nudge this used to apply for
        // unequal geometry) keeps this correct regardless of canvas size or
        // locale string length - see Finding 3/4 in the reviewer audit this
        // fixed.
        avoidRects: [
          ...avoidRects,
          thicknessRect,
          ?bThicknessRect,
          rootGapRect,
        ],
      );
      return (
        thickness: thicknessRect,
        bThickness: bThicknessRect,
        rootGap: rootGapRect,
        grooveDepth: grooveDepthRect,
      );
    }
    return (
      thickness: thicknessRect,
      bThickness: bThicknessRect,
      rootGap: rootGapRect,
      grooveDepth: null,
    );
  }

  // Cap overlap/height are optional (null/zero means "no reinforcement
  // counted" in the calculation, the default for every pre-existing saved
  // calculation) - unlike every other dimension in this file, this one only
  // draws when the user has actually entered a positive value, rather than
  // always showing an illustrative fallback. These are the first genuinely
  // optional dimensions in this drawing (every other field is either always
  // required for its groove type or already has a meaningful non-zero
  // fallback), so always-on illustrative lines would add two new labels to
  // every existing drawing regardless of whether this feature is used at
  // all, which is both visually misleading (implying reinforcement that
  // isn't there) and a backward-compatibility break for every existing
  // combination this file's overlap/hotspot tests already cover.
  // `halfTop` is the groove opening's half-width at the top surface (the x
  // where cap overlap starts extending outward); `topY` is that surface's
  // y-coordinate (where cap height starts rising from).
  ({Rect? overlap, Rect? height}) _drawCapDimensions(
    Canvas canvas,
    Size size,
    Paint guidePaint, {
    required _SectionLayout layout,
    required double halfTop,
    required double topY,
    required double thickness,
    List<Rect> avoidRects = const [],
    // -1 draws the cap rising upward off `topY` (the normal single-face
    // groove types, and Double V's top face). +1 draws it rising downward
    // off `topY` instead (Double V's bottom face, welded from the other
    // side) - Double V gets a cap pass on BOTH faces per the user's
    // explicit decision that the cap dimensions apply identically to each.
    double direction = -1,
  }) {
    final p = layout.point;
    final rawOverlap = data.capOverlapMm;
    final rawHeight = data.capHeightMm;

    Rect? overlapRect;
    if (rawOverlap != null && rawOverlap > 0) {
      final capOverlap = rawOverlap.clamp(0, math.max(halfTop, 2) * 1.5);
      final overlapY = topY + (3 * direction);
      overlapRect = _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(halfTop, overlapY),
        end: p(halfTop + capOverlap, overlapY),
        // Label shows the real entered value, not the drawing's clamped
        // geometry (the clamp is a visual-sanity bound on the drawn line
        // only, mirroring the root-face label pattern above) - the
        // calculation itself always uses the true entered value.
        label: '${_formatValue(rawOverlap.toDouble())} mm cap overlap',
        labelSize: size,
        labelOffset: Offset(6, 10 * direction),
        extensionStart: p(halfTop, topY),
        extensionEnd: p(halfTop + capOverlap, topY),
        fieldKey: FieldKey.capOverlapMm,
        avoidRects: avoidRects,
      );
    }

    Rect? heightRect;
    if (rawHeight != null && rawHeight > 0) {
      final capHeight = rawHeight.clamp(0, math.max(thickness * 0.4, 1));
      final heightX = -(halfTop + 10);
      heightRect = _drawDimensionLine(
        canvas,
        guidePaint,
        start: p(heightX, topY),
        end: p(heightX, topY + (capHeight * direction)),
        // See the cap-overlap label above: show the real entered value,
        // only the drawn geometry is clamped for visual sanity.
        label: '${_formatValue(rawHeight.toDouble())} mm cap height',
        labelSize: size,
        labelOffset: Offset(-6, 10 * direction),
        extensionStart: p(0, topY),
        extensionEnd: p(0, topY + (capHeight * direction)),
        fieldKey: FieldKey.capHeightMm,
        avoidRects: [...avoidRects, ?overlapRect],
      );
    }

    return (overlap: overlapRect, height: heightRect);
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
    //
    // In fillAvailableSpace mode the joint geometry's scale is width-bound,
    // not height-bound, on essentially every real phone width (verified:
    // frame.width/(maxHalfWidthMm*2) comes out smaller than
    // frame.height/heightMm for every groove type at 316-390px canvas
    // width) - so the taller compact card added above (see
    // _narrowDrawingHeight in calculator_page.dart) bought label breathing
    // room but did not make the drawing itself any bigger. A slimmer side
    // margin directly raises that width-bound scale instead, since both
    // the geometry and every label position share the same mm-to-px scale
    // (see [_SectionLayout]/`layout.point`) - everything grows together,
    // labels included, which also widens the natural pixel gaps between
    // mm-separated labels and makes the collision-avoidance system's job
    // easier, not harder. Left at the original, more generous fraction for
    // the desktop/FittedBox path, which already renders at a verified-good
    // size and has no width pressure to relieve.
    final marginX = size.width * (fillAvailableSpace ? 0.038 : 0.0658);
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
    // The joint cross-section is inherently wide/short (a plate seen from
    // the side), so on a narrow phone canvas `scale` above is width-bound
    // by a wide margin - the true-to-width scale leaves most of the
    // compact card's generous vertical room (added for label spacing, see
    // _narrowDrawingHeight in calculator_page.dart) completely unused by
    // the drawing itself, reading as "a tiny picture in a big empty box."
    // Per explicit product decision, allow the vertical scale to stretch
    // further than the width-bound scale, capped at a bounded multiple of
    // it, so the drawing visibly fills more of the card's height - bevel
    // angles read a little steeper than their literal value as a result,
    // an accepted, deliberately-bounded tradeoff (this is a schematic, not
    // a to-scale CAD reproduction - the app already takes similar
    // liberties with fixed-size chips/pills). Only in fillAvailableSpace
    // mode; the desktop/FittedBox path keeps true proportions since it has
    // no vertical-space problem to solve.
    final scaleY = fillAvailableSpace
        ? math.min(frame.height / heightMm, scale * 1.6)
        : scale;
    final actualHeight = heightMm * scaleY;
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
    final topPadding = fillAvailableSpace ? topPaddingMm * scaleY : 0.0;
    final topY = frame.top + topPadding + (slack / 2);
    return _SectionLayout(
      scale: scale,
      scaleY: scaleY,
      centerX: size.width / 2,
      topY: topY,
    );
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
  ({Rect typeChip, Rect? pipeChip}) _drawTopChips(
    Canvas canvas,
    Size size,
    String typeLabel,
  ) {
    final typeChipRect = _drawTypeChip(canvas, size, typeLabel);
    final pipeChipRect = _drawPipeChip(
      canvas,
      size,
      center: _stackTopChips(size, typeLabel)
          ? Offset(size.width * 0.5, 60)
          : Offset(size.width - 82, 28),
    );
    return (typeChip: typeChipRect, pipeChip: pipeChipRect);
  }

  Rect _drawTypeChip(Canvas canvas, Size size, String label) {
    return _drawAnnotationLabel(
      canvas,
      size,
      label,
      Offset(size.width * 0.5, 28),
      fontSize: 11.5,
      weight: FontWeight.w700,
    );
  }

  Rect? _drawPipeChip(Canvas canvas, Size size, {Offset? center}) {
    if (!_isPipeButt || data.pipeOdMm == null || data.pipeOdMm! <= 0) {
      return null;
    }
    final rect = _drawAnnotationLabel(
      canvas,
      size,
      'OD ${_formatValue(data.pipeOdMm!)} mm',
      center ?? Offset(size.width - 82, 28),
      fontSize: 10.5,
    );
    _hotspot(FieldKey.pipeOdMm, rect);
    return rect;
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
    final rect = _measurementLabelRect(labelSize, label, labelCenter, fontSize);
    _hotspot(fieldKey, rect);
    return rect;
  }

  Rect _drawLeader(
    Canvas canvas,
    Paint paint, {
    required Offset start,
    required Offset mid,
    required Offset end,
    required String text,
    required Size size,
    List<Rect> avoidRects = const [],
  }) {
    canvas.drawLine(start, mid, paint);
    canvas.drawLine(mid, end, paint);
    _drawArrowHead(canvas, paint, start, mid);
    final fontSize = _annotationFontSize(size, 11.2);
    var labelCenter = Offset(end.dx + 4, end.dy - 4);
    if (avoidRects.isNotEmpty) {
      labelCenter = _clearLabelPosition(
        size,
        text,
        labelCenter,
        fontSize,
        avoidRects,
      );
    }
    _drawAnnotationLabel(canvas, size, text, labelCenter, fontSize: fontSize);
    return _measurementLabelRect(size, text, labelCenter, fontSize);
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
    canvas.drawCircle(start, 2.6, Paint()..color = paint.color);
    // A busy drawing (Compound V especially) can push a label far enough
    // from its natural spot that one straight line from `start` reads as
    // pointing somewhere else entirely, and can visually cut across other
    // labels or the geometry itself on its way there. Past a small
    // vertical threshold, route it as an elbow instead: a short stub in
    // the label's natural direction (so it still clearly marks the right
    // spot on the drawing), then a clean vertical-then-horizontal run to
    // wherever collision-avoidance actually placed it - the same "routed
    // leader" convention real engineering drawings use, not a single long
    // diagonal.
    final pushedFar = (resolvedCenter.dy - labelCenter.dy).abs() > 6;
    if (!pushedFar) {
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
    } else {
      final naturalDx = labelCenter.dx - start.dx;
      final naturalDy = labelCenter.dy - start.dy;
      final naturalLength = math.sqrt(
        (naturalDx * naturalDx) + (naturalDy * naturalDy),
      );
      final ux = naturalLength == 0 ? 0.0 : naturalDx / naturalLength;
      final uy = naturalLength == 0 ? 0.0 : naturalDy / naturalLength;
      final stub = Offset(start.dx + (ux * 16), start.dy + (uy * 16));
      final elbow = Offset(stub.dx, resolvedCenter.dy);
      final horizontalDir = resolvedCenter.dx >= elbow.dx ? 1.0 : -1.0;
      final lineEnd = Offset(
        resolvedCenter.dx - (horizontalDir * 20),
        resolvedCenter.dy,
      );
      canvas.drawLine(start, stub, paint);
      canvas.drawLine(stub, elbow, paint);
      canvas.drawLine(elbow, lineEnd, paint);
    }
    _drawAnnotationLabel(
      canvas,
      size,
      text,
      resolvedCenter,
      fontSize: fontSize,
      technicalDimension: true,
    );
    final rect = _measurementLabelRect(size, text, resolvedCenter, fontSize);
    _hotspot(fieldKey, rect);
    return rect;
  }

  // The true, unclamped pill size/position for a `technicalDimension: true`
  // label at [center] - what [_measurementLabelRect] clamps to the canvas
  // edge for actual drawing. [_clearLabelPosition] deliberately measures
  // against THIS unclamped rect while it iterates, not the clamped one: a
  // clamped rect's top/left freezes once a push would carry it past the
  // canvas edge, so checking overlap against the clamped rect made further
  // pushes silently do nothing once a label neared the bottom of a busy,
  // multi-label canvas (like Compound V's) even though the label was still
  // overlapping something - the loop kept "moving" the candidate center
  // without the measured rect ever actually changing. Iterating on the real
  // (possibly off-canvas) rect lets the push amount keep growing to wherever
  // it actually needs to go; only the final draw clamps it to stay visible.
  Rect _unclampedMeasurementRect(
    Size size,
    String text,
    Offset center,
    double fontSize,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Roboto',
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
    return Rect.fromCenter(
      center: center,
      width: math.max(painter.width + 18.0, minWidth),
      height: math.max(painter.height + verticalPadding, minHeight),
    );
  }

  // Same as [_unclampedMeasurementRect] but with X clamped to the canvas
  // edge (never Y). [_clearLabelPosition] only ever pushes a label
  // vertically, so the X the label finally draws at is fixed and known
  // from the very first check - clamping it up front means the collision
  // checks a label runs during resolution see the same X its neighbors'
  // already-finalized rects were measured at (also X-clamped, since they
  // came from [_measurementLabelRect]). Using the fully unclamped X here
  // instead let a label whose natural position ran off the canvas edge
  // get pushed clear of another label at an X position it would never
  // actually render at, then silently drawn back into it once the real
  // draw call clamped X afterwards - a real bug this exact mechanism hit
  // on Double V's "total root face" label (see TEAM_LEARNINGS.md). Y stays
  // unclamped here on purpose - see [_unclampedMeasurementRect].
  Rect _resolutionMeasurementRect(
    Size size,
    String text,
    Offset center,
    double fontSize,
  ) {
    final rect = _unclampedMeasurementRect(size, text, center, fontSize);
    return Rect.fromLTWH(
      _safeClamp(rect.left, 10, size.width - rect.width - 10),
      rect.top,
      rect.width,
      rect.height,
    );
  }

  // Mirrors the pill sizing/clamping in [_drawTechnicalLabel] / [_drawSoftLabel]
  // for a `technicalDimension: true` label - what every dimension line and
  // angle tag draws - the same measure-before-you-collide approach
  // [_chipSize]/[_chipRect] already use for the top chips, generalized to
  // any measurement label so [_clearLabelPosition] sees each label's real
  // on-canvas rect instead of an mm-space guess. This is the fully CLAMPED
  // rect - what actually gets drawn, and what other labels should treat as
  // the real thing to avoid - see [_unclampedMeasurementRect] and
  // [_resolutionMeasurementRect] for why the resolution loop itself uses a
  // partially-clamped version instead.
  Rect _measurementLabelRect(
    Size size,
    String text,
    Offset center,
    double fontSize,
  ) {
    final rect = _unclampedMeasurementRect(size, text, center, fontSize);
    return Rect.fromLTWH(
      _safeClamp(rect.left, 10, size.width - rect.width - 10),
      _safeClamp(rect.top, 10, size.height - rect.height - 10),
      rect.width,
      rect.height,
    );
  }

  // Pushes [candidateCenter] straight down by exactly the real pixel amount
  // needed to clear each rect in [avoidRects] - not a fixed mm-space or
  // pixel nudge - so the fix holds regardless of canvas scale or which font
  // is actually rendering. This is the general mechanism behind the
  // alpha/groove-depth/beta fix on the Compound V drawing (see the comment
  // above that callout block) and is reusable by any future dimension line
  // or angle tag that needs to stay clear of another label already placed
  // nearby.
  //
  // Deliberately ALWAYS pushes down, never up, and re-scans the full
  // [avoidRects] list in a loop until a full pass moves nothing (or a
  // generous iteration cap is hit). An earlier version picked push
  // direction per-rect (toward whichever side the candidate was already
  // closer to) in a single pass - when a label is sandwiched between one
  // avoid rect above and another below, that let a later push undo an
  // earlier one (push down to clear the rect above, then straight back up
  // to clear the rect below, netting almost no movement and leaving the
  // label overlapping the first rect again). Always pushing down is
  // monotonic - dy only ever increases - so it can't oscillate, and a
  // bounded re-scan handles the case where clearing one rect's bottom edge
  // walks the label into a second rect that hadn't been checked yet.
  Offset _clearLabelPosition(
    Size size,
    String text,
    Offset candidateCenter,
    double fontSize,
    List<Rect> avoidRects, {
    double gap = 4.0,
  }) {
    var center = candidateCenter;
    for (var pass = 0; pass < avoidRects.length + 2; pass++) {
      var moved = false;
      for (final raw in avoidRects) {
        final avoid = raw.inflate(gap);
        final rect = _resolutionMeasurementRect(size, text, center, fontSize);
        if (!rect.overlaps(avoid)) continue;
        final delta = avoid.bottom - rect.top;
        center = Offset(center.dx, center.dy + delta);
        moved = true;
      }
      if (!moved) break;
    }
    return center;
  }

  Rect _drawAnnotationLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset center, {
    double fontSize = 12,
    FontWeight weight = FontWeight.w600,
    bool technicalDimension = false,
    List<Rect> avoidRects = const [],
  }) {
    var resolvedCenter = center;
    if (avoidRects.isNotEmpty) {
      resolvedCenter = _clearLabelPosition(
        size,
        text,
        center,
        fontSize,
        avoidRects,
      );
    }
    if (_isTechnical) {
      return _drawTechnicalLabel(
        canvas,
        size,
        text,
        resolvedCenter,
        fontSize: fontSize,
        weight: technicalDimension ? FontWeight.w500 : weight,
        square: technicalDimension,
      );
    }

    return _drawSoftLabel(
      canvas,
      size,
      text,
      resolvedCenter,
      fontSize: fontSize,
      weight: weight,
    );
  }

  Rect _drawTechnicalLabel(
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
          fontFamily: 'Roboto',
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
    return safeRect;
  }

  Rect _drawSoftLabel(
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
          fontFamily: 'Roboto',
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
    return safeRect;
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

/// Test-only ground truth for [DrawingHotspot]s: builds the same private
/// painter [WeldDrawingPreview] uses internally and returns exactly the
/// hotspot list it records for a single paint pass, so tests can assert tap
/// correctness (which [FieldKey] a tap at a given rect resolves to) against
/// real production geometry instead of re-deriving label positions by hand.
/// [canvas] only needs to support whatever draw calls the caller cares
/// about recording (e.g. a label-pill-recording mock) - the painter doesn't
/// require real rendering to compute correct hotspot rects.
@visibleForTesting
List<DrawingHotspot> debugWeldDrawingHotspots({
  required GrooveType grooveType,
  required JointType jointType,
  required DrawingMode drawingMode,
  required WeldDrawingData data,
  required String jointTypeLabel,
  required String grooveTypeLabel,
  required String filletWeldFaceLabel,
  required String tJointLabel,
  required String smawFillCapLabel,
  required String gtawRootLabel,
  required Canvas canvas,
  required Size size,
  bool fillAvailableSpace = true,
}) {
  var hotspots = const <DrawingHotspot>[];
  _WeldDrawingPainter(
    grooveType: grooveType,
    jointType: jointType,
    drawingMode: drawingMode,
    data: data,
    jointTypeLabel: jointTypeLabel,
    grooveTypeLabel: grooveTypeLabel,
    filletWeldFaceLabel: filletWeldFaceLabel,
    tJointLabel: tJointLabel,
    smawFillCapLabel: smawFillCapLabel,
    gtawRootLabel: gtawRootLabel,
    onHotspots: (result) => hotspots = result,
    fillAvailableSpace: fillAvailableSpace,
  ).paint(canvas, size);
  return hotspots;
}
