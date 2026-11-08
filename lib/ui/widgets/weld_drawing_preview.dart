import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/weld_models.dart';
import '../calculator_page/calculator_page_models.dart' show FieldKey;

enum DrawingMode { visual, technical }

extension DrawingModeX on DrawingMode {
  String labelFor(L10nStrings strings) => switch (this) {
    DrawingMode.visual => strings.drawingModeVisual,
    DrawingMode.technical => strings.drawingModeTechnical,
  };
}

/// Smallest/largest plate thickness the cross-section is DRAWN at. Real
/// thicknesses outside this range only change the printed numbers, never the
/// shape: a 3 mm plate is drawn like a 10 mm one so the groove, gap and
/// dimension lines stay legible, and a 100 mm plate is drawn like a 40 mm one
/// so it still fits the card.
const double kWeldDrawingMinGeometryThicknessMm = 10;
const double kWeldDrawingMaxGeometryThicknessMm = 40;

@visibleForTesting
double weldDrawingGeometryThicknessMm(double thicknessMm) {
  if (!thicknessMm.isFinite) return kWeldDrawingMinGeometryThicknessMm;
  return thicknessMm.clamp(
    kWeldDrawingMinGeometryThicknessMm,
    kWeldDrawingMaxGeometryThicknessMm,
  );
}

/// Height of the drawing canvas on phones. Grows with the label text size
/// (same clamp the drawing's text uses) so larger text never squeezes it.
double weldDrawingPhoneCanvasHeight(GrooveType grooveType, TextScaler scaler) {
  final scale = (scaler.scale(_baseFontSize) / _baseFontSize).clamp(1.0, 1.3);
  return (grooveType == GrooveType.fillet ? 285.0 : 400.0) * scale;
}

/// Minimum touch target edge for every drawn value (logical px).
const double kWeldDrawingMinHitExtent = 44;

/// A tappable region of the drawing that corresponds to one editable
/// [FieldKey]. [rect] is the full >=44px hit area, not just the visible pill.
class DrawingHotspot {
  const DrawingHotspot(this.fieldKey, this.rect, [Rect? visibleRect])
    : visibleRect = visibleRect ?? rect;

  final FieldKey fieldKey;
  final Rect rect;

  /// The drawn pill itself. A tap inside it always wins over a neighbour's
  /// padded [rect].
  final Rect visibleRect;
}

/// One value shown on the drawing. [rect] is the visible pill; [hitRect] is
/// the (at least 44x44) area that opens the edit box. [value] is the REAL
/// entered number (null when nothing valid is entered yet, in which case the
/// label prints a dash).
class DrawingLabel {
  const DrawingLabel({
    required this.fieldKey,
    required this.text,
    required this.value,
    required this.rect,
  });

  final FieldKey fieldKey;
  final String text;
  final double? value;
  final Rect rect;

  Rect get hitRect => Rect.fromCenter(
    center: rect.center,
    width: math.max(rect.width, kWeldDrawingMinHitExtent),
    height: math.max(rect.height, kWeldDrawingMinHitExtent),
  );
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
    required this.capTopLabel,
    required this.capBottomLabel,
    required this.capOverlapValueLabel,
    required this.capHeightValueLabel,
    this.onFieldTap,
    this.fillAvailableSpace = false,
  });

  final GrooveType grooveType;
  final JointType jointType;
  final DrawingMode drawingMode;
  final WeldDrawingData data;

  // The joint/groove/fillet-face/T-joint names are shown by the dropdowns
  // above the drawing, so the drawing itself no longer repeats them; they stay
  // in the constructor so callers did not have to change.
  final String jointTypeLabel;
  final String grooveTypeLabel;
  final String filletWeldFaceLabel;
  final String tJointLabel;
  final String smawFillCapLabel;
  final String gtawRootLabel;
  final String capTopLabel;
  final String capBottomLabel;
  // Localized "mm cap overlap" / "mm cap height" suffixes, appended after the
  // number so each pill reads in a single language.
  final String capOverlapValueLabel;
  final String capHeightValueLabel;

  /// Called with the [FieldKey] of the tapped value so the caller can open
  /// the edit box for it.
  final ValueChanged<FieldKey>? onFieldTap;

  /// Kept for API compatibility: the drawing always renders at the real box
  /// size it is given.
  final bool fillAvailableSpace;

  @override
  State<WeldDrawingPreview> createState() => _WeldDrawingPreviewState();
}

class _WeldDrawingPreviewState extends State<WeldDrawingPreview> {
  List<DrawingHotspot> _hotspots = const [];

  @override
  Widget build(BuildContext context) {
    // Label text follows the user's text-size setting, but only within a
    // band that keeps the pills from outgrowing the drawing.
    final fontSize = MediaQuery.textScalerOf(
      context,
    ).scale(_baseFontSize).clamp(_baseFontSize, _baseFontSize * 1.3);
    final gestureDetector = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: widget.onFieldTap == null ? null : _handleTapUp,
      child: CustomPaint(
        painter: _WeldDrawingPainter(
          grooveType: widget.grooveType,
          jointType: widget.jointType,
          drawingMode: widget.drawingMode,
          data: widget.data,
          labels: _SceneLabels(
            smawFillCap: widget.smawFillCapLabel,
            gtawRoot: widget.gtawRootLabel,
            capTop: widget.capTopLabel,
            capBottom: widget.capBottomLabel,
            capOverlapValue: widget.capOverlapValueLabel,
            capHeightValue: widget.capHeightValueLabel,
          ),
          fontSize: fontSize,
          onHotspots: (hotspots) => _hotspots = hotspots,
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
    // Pass 0: taps on a drawn pill. Pass 1: the padded areas around them.
    for (var pass = 0; pass < 2 && nearest == null; pass++) {
      for (final hotspot in _hotspots) {
        final area = pass == 0 ? hotspot.visibleRect : hotspot.rect;
        if (!area.contains(tapPosition)) continue;
        final distanceSq = (hotspot.rect.center - tapPosition).distanceSquared;
        if (distanceSq < nearestDistanceSq) {
          nearest = hotspot;
          nearestDistanceSq = distanceSq;
        }
      }
    }
    if (nearest != null) {
      widget.onFieldTap!(nearest.fieldKey);
    }
  }
}

const double _baseFontSize = 11;

class _SceneLabels {
  const _SceneLabels({
    required this.smawFillCap,
    required this.gtawRoot,
    required this.capTop,
    required this.capBottom,
    required this.capOverlapValue,
    required this.capHeightValue,
  });

  final String smawFillCap;
  final String gtawRoot;
  final String capTop;
  final String capBottom;
  final String capOverlapValue;
  final String capHeightValue;
}

class _Seg {
  const _Seg(this.a, this.b);
  final Offset a;
  final Offset b;
}

class _Arrow {
  const _Arrow(this.tip, this.dir);
  final Offset tip;
  // Unit vector the arrow points along (towards the tip).
  final Offset dir;
}

class _Arc {
  const _Arc(this.center, this.radius, this.sweep);
  final Offset center;
  final double radius;
  // Starts straight up and sweeps clockwise by this many radians.
  final double sweep;
}

/// Everything the painter draws, already in canvas pixels. Built once per
/// paint from the entered values; also what the tests inspect.
class WeldDrawingScene {
  final List<Path> plates = [];
  Path weld = Path();
  // Canvas y from which the weld is tinted as the GTAW root zone.
  double? rootZoneTopY;
  final List<_Seg> _lines = [];
  final List<_Seg> _leaders = [];
  final List<_Arrow> _arrows = [];
  final List<_Arc> _arcs = [];
  final List<DrawingLabel> labels = [];

  /// Every straight line drawn (dimension, extension and leader lines), for
  /// tests that check lines never run through label text.
  @visibleForTesting
  List<(Offset, Offset)> get debugLineSegments => [
    for (final l in [..._lines, ..._leaders]) (l.a, l.b),
  ];

  @visibleForTesting
  List<(Offset, Offset)> get debugLeaderSegments => [
    for (final l in _leaders) (l.a, l.b),
  ];

  // Outline segments the labels try not to sit on.
  final List<_Seg> _outline = [];
}

@visibleForTesting
WeldDrawingScene buildWeldDrawingScene({
  required GrooveType grooveType,
  required JointType jointType,
  required WeldDrawingData data,
  required Size size,
  required String smawFillCapLabel,
  required String gtawRootLabel,
  required String capTopLabel,
  required String capBottomLabel,
  required String capOverlapValueLabel,
  required String capHeightValueLabel,
  double fontSize = _baseFontSize,
}) {
  return _SceneBuilder(
    grooveType: grooveType,
    jointType: jointType,
    data: data,
    size: size,
    fontSize: fontSize,
    labels: _SceneLabels(
      smawFillCap: smawFillCapLabel,
      gtawRoot: gtawRootLabel,
      capTop: capTopLabel,
      capBottom: capBottomLabel,
      capOverlapValue: capOverlapValueLabel,
      capHeightValue: capHeightValueLabel,
    ),
  ).build();
}

double? _positive(double? v) => (v != null && v.isFinite && v > 0) ? v : null;

String _fmt(double? v) {
  if (v == null || !v.isFinite) return '—';
  final r = (v * 100).round() / 100;
  if (r == r.roundToDouble()) return r.toStringAsFixed(0);
  return r.toString();
}

double _rad(double deg) => deg * math.pi / 180;

class _SceneBuilder {
  _SceneBuilder({
    required this.grooveType,
    required this.jointType,
    required this.data,
    required this.size,
    required this.fontSize,
    required this.labels,
  });

  final GrooveType grooveType;
  final JointType jointType;
  final WeldDrawingData data;
  final Size size;
  final double fontSize;
  final _SceneLabels labels;

  final WeldDrawingScene scene = WeldDrawingScene();

  static const double _padH = 8;
  static const double _padV = 4;
  static const double _arrowLen = 6;

  double get _labelH => fontSize + (_padV * 2) + 2;

  Size _labelSize(String text) {
    final tp = _textPainter(text);
    return Size(tp.width + (_padH * 2), math.max(tp.height + _padV, _labelH));
  }

  TextPainter _textPainter(String text) => TextPainter(
    text: TextSpan(text: text, style: weldDrawingLabelStyle(fontSize)),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();

  // ---- Label placement ------------------------------------------------

  /// Places a label at the best of [centers] (tried in order, then the same
  /// positions nudged up/down in whole label heights): first one that
  /// overlaps no placed label and touches no outline/dimension line wins; if
  /// none is perfect, the least-bad one is used. Always clamped to the canvas.
  Rect _place(
    String text,
    List<Offset> centers, {
    bool overLine = false,
    List<Offset> leaderTargets = const [],
  }) {
    _chosenTarget = null;
    _lastLead = 0;
    final sz = _labelSize(text);
    final step = sz.height + 2;
    // Leader labels may also sit right on their target, which needs no
    // leader at all.
    final spots = [...centers, ...leaderTargets];
    final candidates = <Offset>[
      ...spots,
      for (var k = 1; k <= 6; k++)
        for (final c in spots) ...[
          c.translate(0, -k * step),
          c.translate(0, k * step),
        ],
    ];
    Rect? best;
    var bestScore = double.infinity;
    for (final c in candidates) {
      var r = Rect.fromCenter(center: c, width: sz.width, height: sz.height);
      final dx = r.left < 3
          ? 3 - r.left
          : (r.right > size.width - 3 ? (size.width - 3) - r.right : 0.0);
      final dy = r.top < 3
          ? 3 - r.top
          : (r.bottom > size.height - 3 ? (size.height - 3) - r.bottom : 0.0);
      r = r.shift(Offset(dx, dy));
      final lead = _leaderPenalty(r, leaderTargets);
      final score = _score(r, overLine) + lead.$1 + (dx.abs() + dy.abs()) * 0.5;
      if (score < bestScore) {
        best = r;
        bestScore = score;
        _chosenTarget = lead.$2;
        _lastLead = lead.$1;
        if (score < 0.5) break;
      }
    }
    if (bestScore >= 1000) {
      // Crowded canvas (long strings, narrow phone): fall back to any free
      // row, closest to the preferred spot first.
      final want = centers.first;
      final grid = <Offset>[];
      for (
        var y = sz.height / 2 + 3;
        y <= size.height - sz.height / 2 - 3;
        y += step
      ) {
        for (final x in [
          want.dx,
          sz.width / 2 + 3,
          size.width - sz.width / 2 - 3,
          for (var gx = 0.25; gx < 1; gx += 0.25) size.width * gx,
        ]) {
          grid.add(Offset(x, y));
        }
      }
      grid.sort((a, b) => (a - want).distance.compareTo((b - want).distance));
      for (final c in grid) {
        final r = Rect.fromCenter(
          center: c,
          width: sz.width,
          height: sz.height,
        );
        if (r.left < 3 || r.right > size.width - 3) continue;
        final lead = _leaderPenalty(r, leaderTargets);
        final score =
            _score(r, overLine) + lead.$1 + (c - want).distance * 0.001;
        if (score < bestScore) {
          best = r;
          bestScore = score;
          _chosenTarget = lead.$2;
          _lastLead = lead.$1;
          if (score < 0.5) break;
        }
      }
    }
    return best!;
  }

  bool _segHitsRect(Offset a, Offset b, Rect rect) {
    final d = b - a;
    final n = math.max((d.distance / 2).ceil(), 1);
    for (var i = 0; i <= n; i++) {
      if (rect.contains(a + d * (i / n))) return true;
    }
    return false;
  }

  _Seg? _leaderFor(Rect r, Offset to) {
    final from = Offset(
      to.dx.clamp(r.left, r.right),
      to.dy.clamp(r.top, r.bottom),
    );
    return (from - to).distance > 3 ? _Seg(from, to) : null;
  }

  Offset? _chosenTarget;
  double _lastLead = 0;

  // Best of the possible leader targets for a label at [r]: penalised when
  // the leader would run through an already placed label.
  (double, Offset?) _leaderPenalty(Rect r, List<Offset> targets) {
    var best = 0.0;
    Offset? bestTarget;
    var first = true;
    for (final t in targets) {
      final leader = _leaderFor(r, t);
      var pen = 0.0;
      if (leader != null) {
        for (final l in scene.labels) {
          if (_segHitsRect(leader.a, leader.b, l.rect.inflate(2))) pen += 100000;
        }
      }
      if (first || pen < best) {
        best = pen;
        bestTarget = t;
        first = false;
      }
    }
    return (best, bestTarget);
  }

  double _score(Rect r, bool overLine) {
    var score = 0.0;
    for (final l in scene.labels) {
      if (l.rect.inflate(2).overlaps(r)) score += 1000000;
    }
    for (final seg in scene._leaders) {
      if (_segHitsRect(seg.a, seg.b, r.inflate(2))) score += 100000;
    }
    final probe = r.inflate(1);
    for (final seg in scene._outline) {
      final d = seg.b - seg.a;
      final n = math.max((d.distance / 3).ceil(), 1);
      for (var i = 0; i <= n; i++) {
        if (probe.contains(seg.a + d * (i / n))) score += 1;
      }
    }
    if (!overLine) {
      for (final seg in scene._lines) {
        if (_segHitsRect(seg.a, seg.b, probe)) score += 1000;
      }
    }
    return score;
  }

  void _label(
    FieldKey key,
    String text,
    double? value,
    List<Offset> centers, {
    List<Offset> leaderTargets = const [],
    bool overLine = false,
  }) {
    var rect = _place(
      text,
      centers,
      overLine: overLine,
      leaderTargets: leaderTargets,
    );
    Offset? leaderTo = _chosenTarget;
    if (leaderTargets.isNotEmpty && _lastLead >= 100000) {
      // No clean leader route on this crowded canvas: put the label on the
      // shape next to its target without a leader instead of crossing text.
      rect = _place(text, leaderTargets, overLine: overLine);
      leaderTo = null;
    }
    scene.labels.add(
      DrawingLabel(fieldKey: key, text: text, value: value, rect: rect),
    );
    if (leaderTo != null) {
      final leader = _leaderFor(rect, leaderTo);
      if (leader != null) scene._leaders.add(leader);
    }
  }

  // ---- Dimension primitives -------------------------------------------

  void _seg(Offset a, Offset b) => scene._lines.add(_Seg(a, b));

  /// Dimension line between [a] and [b] with arrowheads whose tips touch the
  /// extension lines; when too short for arrows inside, they point in from
  /// outside instead.
  void _dim(Offset a, Offset b) {
    final d = b - a;
    final len = d.distance;
    if (len < 0.5) return;
    final u = d / len;
    if (len >= (_arrowLen * 2) + 4) {
      _seg(a, b);
      scene._arrows
        ..add(_Arrow(a, -u))
        ..add(_Arrow(b, u));
    } else {
      _seg(a - u * (_arrowLen + 6), b + u * (_arrowLen + 6));
      scene._arrows
        ..add(_Arrow(a, u))
        ..add(_Arrow(b, -u));
    }
  }

  Path _poly(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  void _outlineOf(List<Offset> pts, {bool closed = true}) {
    for (var i = 0; i < pts.length - 1; i++) {
      scene._outline.add(_Seg(pts[i], pts[i + 1]));
    }
    if (closed) scene._outline.add(_Seg(pts.last, pts.first));
  }

  List<Offset> _quad(Offset a, Offset c, Offset b, {int n = 8}) => [
    for (var i = 1; i < n; i++)
      () {
        final t = i / n;
        final m = 1 - t;
        return a * (m * m) + c * (2 * m * t) + b * (t * t);
      }(),
  ];

  /// Clamps a real value for drawing only; labels always print the real one.
  double _vis(double? real, double fallback, double lo, double hi) {
    final v = (real != null && real.isFinite && real >= 0) ? real : fallback;
    return v.clamp(lo, math.max(lo, hi));
  }

  // ---- Scene ----------------------------------------------------------

  WeldDrawingScene build() {
    if (size.width <= 0 || size.height <= 0) return scene;
    if (grooveType == GrooveType.fillet) {
      _buildFillet();
    } else {
      _buildButt();
    }
    return scene;
  }

  bool get _combined =>
      data.weldingProcess == WeldingProcess.gtawSmaw &&
      _positive(data.gtawTransitionMm) != null;

  void _buildButt() {
    final w = size.width;
    final h = size.height;
    final isDouble = grooveType == GrooveType.doubleV;

    final unequal = data.geometryMode == JointGeometryMode.unequal;
    final tReal = _positive(data.thicknessMm);
    final aReal = unequal ? (_positive(data.thicknessAMm) ?? tReal) : null;
    final bReal = unequal ? (_positive(data.thicknessBMm) ?? tReal) : null;
    final govMm = [
      tReal,
      aReal,
      bReal,
    ].whereType<double>().fold<double>(0, math.max);
    final gov = govMm > 0 ? govMm : 12.0;
    final gv = weldDrawingGeometryThicknessMm(gov);
    final aShown = unequal ? _positive(data.thicknessAMm) : null;
    final bShown = unequal ? _positive(data.thicknessBMm) : null;
    final tA = unequal ? math.max(gv * (aReal ?? gov) / gov, gv * 0.3) : gv;
    final tB = unequal ? math.max(gv * (bReal ?? gov) / gov, gv * 0.3) : gv;

    late final double lt, lb, rt, rb;
    if (!unequal) {
      lt = rt = 0;
      lb = rb = gv;
    } else {
      switch (data.alignment) {
        case JointAlignment.centerline:
          lt = (gv - tA) / 2;
          lb = (gv + tA) / 2;
          rt = (gv - tB) / 2;
          rb = (gv + tB) / 2;
        case JointAlignment.odMatch:
          lt = rt = 0;
          lb = tA;
          rb = tB;
        case JointAlignment.idMatch:
          lt = gv - tA;
          rt = gv - tB;
          lb = rb = gv;
      }
    }

    final gap = _vis(data.rootGapMm, 3, gv * 0.1, gv * 0.35);
    final hG = gap / 2;
    final alphaDeg = _vis(data.bevelAngleDeg, 30, 10, 65);
    final betaDeg = _vis(data.secondaryBevelAngleDeg, 10, 5, 45);
    final tanA = math.tan(_rad(alphaDeg));
    final tanB = math.tan(_rad(betaDeg));
    final cSingle = _vis(data.rootFaceMm, 2, gv * 0.08, gv * 0.45);
    final cDouble = _vis(data.rootFaceMm, 2, gv * 0.05, gv * 0.25);
    final brkVis = _vis(data.breakHeightMm, 4, gv * 0.12, gv * 0.6);

    final capOv = _positive(data.capOverlapMm);
    final capH = _positive(data.capHeightMm);
    final capsOn = capOv != null || capH != null;
    final riseTop = capH != null
        ? _vis(capH * 0.5, 0, gv * 0.03, gv * 0.1)
        : gv * 0.06;
    final riseBot = isDouble ? riseTop : gv * 0.04;

    // Face of one plate as (distance from centre, y) points, top to bottom.
    List<Offset> face(bool right, double yT, double yB) {
      final thick = yB - yT;
      switch (grooveType) {
        case GrooveType.square:
          return [Offset(hG, yT), Offset(hG, yB)];
        case GrooveType.halfV when !right:
          return [Offset(hG, yT), Offset(hG, yB)];
        case GrooveType.halfV:
        case GrooveType.singleV:
        case GrooveType.fillet:
          final c = math.min(cSingle, thick * 0.6);
          final yr = yB - c;
          return [
            Offset(hG + (yr - yT) * tanA, yT),
            Offset(hG, yr),
            Offset(hG, yB),
          ];
        case GrooveType.doubleV:
          final mid = (yT + yB) / 2;
          final c = math.min(cDouble, thick * 0.3);
          return [
            Offset(hG + (mid - c - yT) * tanA, yT),
            Offset(hG, mid - c),
            Offset(hG, mid + c),
            Offset(hG + (yB - mid - c) * tanA, yB),
          ];
        case GrooveType.compoundV:
          final c = math.min(cSingle, thick * 0.4);
          final depth = thick - c;
          final brk = math.min(brkVis, depth * 0.75);
          final upper = depth - brk;
          final xb = hG + brk * tanA;
          return [
            Offset(xb + upper * tanB, yT),
            Offset(xb, yT + upper),
            Offset(hG, yB - c),
            Offset(hG, yB),
          ];
      }
    }

    final faceL = face(false, lt, lb);
    final faceR = face(true, rt, rb);
    final xTop = math.max(faceL.first.dx, faceR.first.dx);

    // ---- Pixel frame ----
    final isPipe = jointType == JointType.pipeButt;
    // Unequal pipes edit OD A / OD B separately; equal ones a single OD.
    final odLabels = <({FieldKey key, String prefix, double? value})>[
      if (isPipe && unequal) ...[
        (
          key: FieldKey.pipeOdAMm,
          prefix: 'OD A',
          value: _positive(data.pipeOdAMm),
        ),
        (
          key: FieldKey.pipeOdBMm,
          prefix: 'OD B',
          value: _positive(data.pipeOdBMm),
        ),
      ] else if (isPipe && _positive(data.pipeOdMm) != null)
        (key: FieldKey.pipeOdMm, prefix: 'OD', value: _positive(data.pipeOdMm)),
    ];
    final leftText = unequal ? 'A ${_fmt(aShown)} mm' : 't ${_fmt(tReal)} mm';
    final rightText = 'B ${_fmt(bShown)} mm';
    const gL = 8.0;
    const gR = 8.0;

    var top = 8.0;
    if (odLabels.isNotEmpty || _combined) top += _labelH + 8;
    if (odLabels.length > 1 && _combined) top += _labelH + 4;
    if (capsOn) top += 12 + 4 + _labelH + 4;
    var bottom = 14 + 4 + _labelH + 8;
    if (isDouble && capsOn) bottom += (12 + 4 + _labelH + 4) + (_labelH + 4);

    final areaW = w - gL - gR;
    final areaH = h - top - bottom;
    final hMm = gv + riseTop + riseBot;
    final minPlate = (w * 0.22).clamp(52.0, 80.0);
    final s = [
      areaH / hMm,
      (areaW - 2 * minPlate) / (2 * xTop),
      18.0,
    ].reduce(math.min);
    final cx = gL + areaW / 2;
    final y0 = top + (areaH - hMm * s) / 2 + riseTop * s;
    Offset p(double x, double y) => Offset(cx + x * s, y0 + y * s);
    final endMm = areaW / 2 / s;

    // ---- Shapes ----
    final leftPts = [
      p(-endMm, lt),
      for (final f in faceL) p(-f.dx, f.dy),
      p(-endMm, lb),
    ];
    final rightPts = [
      p(endMm, rt),
      for (final f in faceR) p(f.dx, f.dy),
      p(endMm, rb),
    ];
    scene.plates
      ..add(_poly(leftPts))
      ..add(_poly(rightPts));
    _outlineOf(leftPts);
    _outlineOf(rightPts);

    final topCtrl = p(0, math.min(lt, rt) - 2 * riseTop);
    final botCtrl = p(0, math.max(lb, rb) + 2 * riseBot);
    final tl = p(-faceL.first.dx, faceL.first.dy);
    final tr = p(faceR.first.dx, faceR.first.dy);
    final br = p(faceR.last.dx, faceR.last.dy);
    final bl = p(-faceL.last.dx, faceL.last.dy);
    final weld = Path()..moveTo(tl.dx, tl.dy);
    weld.quadraticBezierTo(topCtrl.dx, topCtrl.dy, tr.dx, tr.dy);
    for (final f in faceR.skip(1)) {
      final q = p(f.dx, f.dy);
      weld.lineTo(q.dx, q.dy);
    }
    weld.quadraticBezierTo(botCtrl.dx, botCtrl.dy, bl.dx, bl.dy);
    for (final f in faceL.reversed.skip(1)) {
      final q = p(-f.dx, f.dy);
      weld.lineTo(q.dx, q.dy);
    }
    weld.close();
    scene.weld = weld;
    _outlineOf([
      tl,
      ..._quad(tl, topCtrl, tr),
      tr,
      for (final f in faceR.skip(1)) p(f.dx, f.dy),
      ..._quad(br, botCtrl, bl),
      bl,
      for (final f in faceL.reversed.skip(1)) p(-f.dx, f.dy),
    ]);

    final yLt = p(0, lt).dy;
    final yLb = p(0, lb).dy;
    final yRt = p(0, rt).dy;
    final yRb = p(0, rb).dy;
    final bottomPx = p(0, math.max(lb, rb) + riseBot).dy;

    // ---- Dimensions (geometry first, then labels, so every label can steer
    // clear of every line) ----

    // Thickness t / A (left) and B (right), measured on the plate ends.
    final xDimL = gL + 12;
    _dim(Offset(xDimL, yLt), Offset(xDimL, yLb));
    final xDimR = w - gR - 12;
    if (unequal) {
      _dim(Offset(xDimR, yRt), Offset(xDimR, yRb));
    }

    // Root gap b, below the joint.
    final dimY = bottomPx + 12;
    final xGapL = cx - hG * s;
    final xGapR = cx + hG * s;
    _seg(Offset(xGapL, yLb + 2), Offset(xGapL, dimY + 4));
    _seg(Offset(xGapR, yRb + 2), Offset(xGapR, dimY + 4));
    _dim(Offset(xGapL, dimY), Offset(xGapR, dimY));

    // Root face c (right plate): from the groove's lower corner to the
    // plate's back face. Double V measures from the mid-plane to the land
    // end, because the land is c on each side of it.
    final hasRootFace = grooveType != GrooveType.square;
    double? yC1, yC2, xC;
    if (hasRootFace) {
      final i = faceR.length - 2;
      final lowerRoot = isDouble ? faceR[2] : faceR[i];
      final upper = isDouble ? (rt + rb) / 2 : faceR[i].dy;
      yC1 = p(0, upper).dy;
      yC2 = p(0, isDouble ? lowerRoot.dy : faceR.last.dy).dy;
      xC = cx + hG * s + 12;
      _seg(Offset(cx + hG * s + 2, yC1), Offset(xC + 4, yC1));
      _seg(Offset(cx + hG * s + 2, yC2), Offset(xC + 4, yC2));
      _dim(Offset(xC, yC1), Offset(xC, yC2));
    }

    // Compound V: height of the steep lower section.
    double? yH1, yH2, xH;
    if (grooveType == GrooveType.compoundV) {
      yH1 = p(0, faceR[1].dy).dy;
      yH2 = p(0, faceR[2].dy).dy;
      xH = cx + faceR[1].dx * s + 12;
      _seg(Offset(cx + faceR[1].dx * s + 2, yH1), Offset(xH + 4, yH1));
      _seg(Offset(cx + faceR[2].dx * s + 2, yH2), Offset(xH + 4, yH2));
      _dim(Offset(xH, yH1), Offset(xH, yH2));
    }

    // Groove angles: arc against a vertical reference at the lower end of
    // the sloped face, label beside it.
    final arcIndexA = grooveType == GrooveType.compoundV ? 2 : 1;
    final angleSpecs =
        <({int idx, double deg, FieldKey key, String sym, double? real})>[
          if (grooveType != GrooveType.square)
            (
              idx: arcIndexA,
              deg: alphaDeg,
              key: FieldKey.bevelAngleDeg,
              sym: 'α',
              real: _positive(data.bevelAngleDeg),
            ),
          if (grooveType == GrooveType.compoundV)
            (
              idx: 1,
              deg: betaDeg,
              key: FieldKey.secondaryBevelAngleDeg,
              sym: 'β',
              real: _positive(data.secondaryBevelAngleDeg),
            ),
        ];
    final angleLabels =
        <
          ({
            FieldKey key,
            String text,
            double? real,
            List<Offset> centers,
            Offset leader,
          })
        >[];
    for (final a in angleSpecs) {
      final q = p(faceR[a.idx].dx, faceR[a.idx].dy);
      final up = p(faceR[a.idx - 1].dx, faceR[a.idx - 1].dy);
      final segLen = (up - q).distance;
      final r = math.max(math.min(24.0, segLen * 0.55), 9.0);
      final sweep = _rad(a.deg);
      scene._arcs.add(_Arc(q, r, sweep));
      _seg(q, q.translate(0, -(r + 6)));
      final dir = Offset(math.sin(sweep / 2), -math.cos(sweep / 2));
      final text = '${a.sym} ${_fmt(a.real)}°';
      final lw = _labelSize(text).width;
      angleLabels.add((
        key: a.key,
        text: text,
        real: a.real,
        centers: [
          for (final d in [r + 10, r + 22, r + 36])
            for (final dx in [0.0, 10.0, 20.0, 32.0])
              q + Offset(dir.dx * d + lw / 2 + dx, dir.dy * d),
          for (final d in [r + 14, r + 30]) q + Offset(-(lw / 2 + 8), -d),
        ],
        leader: q + dir * r,
      ));
    }

    // Cap overlap / height, top face (and bottom face for Double V).
    final capSpecs = <({bool top, String prefix})>[
      (top: true, prefix: isDouble ? '${labels.capTop} ' : ''),
      if (isDouble) (top: false, prefix: '${labels.capBottom} '),
    ];
    final capLabels =
        <({FieldKey key, String text, double? real, List<Offset> centers})>[];
    if (capsOn) {
      for (final spec in capSpecs) {
        final dirY = spec.top ? -1.0 : 1.0;
        final rise = spec.top ? riseTop : riseBot;
        if (capOv != null) {
          final surf = spec.top ? yRt : yRb;
          final x0 = cx + faceR.first.dx * s;
          final capW = (capOv * s).clamp(14.0, 40.0);
          final lineY = surf + dirY * 14;
          _seg(Offset(x0, surf + dirY * 2), Offset(x0, lineY + dirY * 4));
          _seg(
            Offset(x0 + capW, surf + dirY * 2),
            Offset(x0 + capW, lineY + dirY * 4),
          );
          _dim(Offset(x0, lineY), Offset(x0 + capW, lineY));
          final text = '${spec.prefix}${_fmt(capOv)} ${labels.capOverlapValue}';
          final lw = _labelSize(text).width;
          final cy = lineY + dirY * (6 + _labelH / 2);
          capLabels.add((
            key: FieldKey.capOverlapMm,
            text: text,
            real: capOv,
            centers: [
              Offset(x0 + capW / 2, cy),
              Offset(x0 + lw / 2 - 4, cy),
              Offset(w - 4 - lw / 2, cy),
            ],
          ));
        }
        if (capH != null) {
          final surf = spec.top ? yLt : yLb;
          final apex = p(
            0,
            spec.top ? math.min(lt, rt) - rise : math.max(lb, rb) + rise,
          ).dy;
          final xl = cx - faceL.first.dx * s - 16;
          _seg(Offset(cx, apex), Offset(xl - 4, apex));
          _dim(Offset(xl, apex), Offset(xl, surf));
          final text = '${spec.prefix}${_fmt(capH)} ${labels.capHeightValue}';
          final lw = _labelSize(text).width;
          final cy =
              (spec.top
                  ? math.min(apex, surf - 14)
                  : math.max(apex, surf + 14)) +
              dirY * (6 + _labelH / 2);
          capLabels.add((
            key: FieldKey.capHeightMm,
            text: text,
            real: capH,
            centers: [Offset(xl + 10 - lw / 2, cy), Offset(4 + lw / 2, cy)],
          ));
        }
      }
    }

    // ---- Labels, in priority order ----
    _label(
      unequal ? FieldKey.thicknessAMm : FieldKey.thicknessMm,
      leftText,
      unequal ? aShown : tReal,
      [Offset(xDimL + 8 + _labelSize(leftText).width / 2, (yLt + yLb) / 2)],
    );
    if (unequal) {
      _label(FieldKey.thicknessBMm, rightText, bShown, [
        Offset(xDimR - 8 - _labelSize(rightText).width / 2, (yRt + yRb) / 2),
      ]);
    }
    final gapText = 'b ${_fmt(data.rootGapMm)} mm';
    _label(FieldKey.rootGapMm, gapText, data.rootGapMm, [
      Offset(cx, dimY + 6 + _labelH / 2),
    ]);
    if (hasRootFace && xC != null) {
      final text = 'c ${_fmt(data.rootFaceMm)} mm';
      final lw = _labelSize(text).width;
      _label(FieldKey.rootFaceMm, text, data.rootFaceMm, [
        Offset(xC + 8 + lw / 2, (yC1! + yC2!) / 2),
      ]);
    }
    if (xH != null) {
      final text = 'h ${_fmt(data.breakHeightMm)} mm';
      final lw = _labelSize(text).width;
      _label(FieldKey.breakHeightMm, text, data.breakHeightMm, [
        Offset(xH + 8 + lw / 2, (yH1! + yH2!) / 2),
      ]);
    }
    for (final c in capLabels) {
      _label(c.key, c.text, c.real, c.centers);
    }

    if (_combined) {
      final tr0 = _positive(data.gtawTransitionMm)!;
      final trVis = _vis(tr0, 0, gv * 0.12, gv * 0.7);
      final zoneTop = math.max(lb, rb) - trVis;
      scene.rootZoneTopY = p(0, zoneTop).dy;
      final smaw = labels.smawFillCap;
      final sw = _labelSize(smaw).width;
      _label(
        FieldKey.gtawTransitionMm,
        smaw,
        null,
        [Offset(w - 6 - sw / 2, 8 + _labelH / 2)],
        leaderTargets: [
          for (final fx in [0.0, -0.4, 0.4])
            for (final fy in [0.5, 0.3, 0.7])
              p(fx * faceR.first.dx, (math.min(lt, rt) + zoneTop) * fy),
        ],
      );
      final root = '${labels.gtawRoot} ${_fmt(tr0)} mm';
      final rw = _labelSize(root).width;
      _label(
        FieldKey.gtawTransitionMm,
        root,
        tr0,
        [Offset(w - 6 - rw / 2, dimY + 6 + _labelH / 2)],
        leaderTargets: [
          for (final fx in [0.0, -0.6, 0.6])
            for (final fy in [0.5, 0.25, 0.75])
              p(fx * hG, math.max(lb, rb) - trVis * fy),
        ],
      );
    }

    for (final a in angleLabels) {
      _label(a.key, a.text, a.real, a.centers, leaderTargets: [a.leader]);
    }

    var odX = 6.0;
    for (final od in odLabels) {
      final text = '${od.prefix} ${_fmt(od.value)} mm';
      final lw = _labelSize(text).width;
      _label(od.key, text, od.value, [Offset(odX + lw / 2, 8 + _labelH / 2)]);
      odX += lw + 6;
    }
  }

  void _buildFillet() {
    final w = size.width;
    final h = size.height;
    final legReal = _positive(data.legSizeMm);
    final leg = _vis(data.legSizeMm, 6, 3, 14);
    const web = 5.0; // half web thickness (drawn units)
    const flange = 10.0;
    final webH = leg + 14;
    final hMm = webH + flange;

    final legText = 'z ${_fmt(legReal)} mm';
    final lw = _labelSize(legText).width;
    final gL = 14.0;
    const gR = 8.0;
    final top = 14.0;
    final bottom = 14 + 4 + _labelH + 8;
    final areaW = w - gL - gR;
    final areaH = h - top - bottom;
    final minPlate = (w * 0.22).clamp(52.0, 80.0);
    final s = [
      areaH / hMm,
      (areaW - 2 * minPlate) / (2 * (web + leg)),
      18.0,
    ].reduce(math.min);
    final cx = gL + areaW / 2;
    final y0 = top + (areaH - hMm * s) / 2;
    Offset p(double x, double y) => Offset(cx + x * s, y0 + y * s);
    final endMm = areaW / 2 / s;

    final webPts = [p(-web, 0), p(web, 0), p(web, webH), p(-web, webH)];
    final flangePts = [
      p(-endMm, webH),
      p(endMm, webH),
      p(endMm, webH + flange),
      p(-endMm, webH + flange),
    ];
    scene.plates
      ..add(_poly(webPts))
      ..add(_poly(flangePts));
    _outlineOf(webPts);
    _outlineOf(flangePts);

    final tip = p(web, webH - leg);
    final toe = p(web + leg, webH);
    final root = p(web, webH);
    final ctrl = p(web + leg * 0.72, webH - leg * 0.18);
    scene.weld = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(root.dx, root.dy)
      ..lineTo(toe.dx, toe.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy)
      ..close();
    _outlineOf([tip, root, toe, ..._quad(toe, ctrl, tip), tip]);

    // Horizontal leg, below the flange.
    final yFlangeBottom = p(0, webH + flange).dy;
    final dimY = yFlangeBottom + 12;
    _seg(Offset(root.dx, yFlangeBottom + 2), Offset(root.dx, dimY + 4));
    _seg(Offset(toe.dx, yFlangeBottom + 2), Offset(toe.dx, dimY + 4));
    _dim(Offset(root.dx, dimY), Offset(toe.dx, dimY));
    // Vertical leg, right of the weld.
    final xDim = toe.dx + 16;
    _seg(Offset(root.dx + 2, tip.dy), Offset(xDim + 4, tip.dy));
    _seg(Offset(toe.dx + 2, toe.dy), Offset(xDim + 4, toe.dy));
    _dim(Offset(xDim, tip.dy), Offset(xDim, toe.dy));

    _label(FieldKey.legSizeMm, legText, legReal, [
      Offset((root.dx + toe.dx) / 2, dimY + 6 + _labelH / 2),
    ]);
    _label(FieldKey.legSizeMm, legText, legReal, [
      Offset(xDim + 8 + lw / 2, (tip.dy + toe.dy) / 2),
    ]);
  }
}

TextStyle weldDrawingLabelStyle(double fontSize) => TextStyle(
  fontFamily: 'Roboto',
  fontSize: fontSize,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF22343D),
  height: 1.1,
);

class _WeldDrawingPainter extends CustomPainter {
  _WeldDrawingPainter({
    required this.grooveType,
    required this.jointType,
    required this.drawingMode,
    required this.data,
    required this.labels,
    required this.fontSize,
    this.onHotspots,
  });

  final GrooveType grooveType;
  final JointType jointType;
  final DrawingMode drawingMode;
  final WeldDrawingData data;
  final _SceneLabels labels;
  final double fontSize;
  final ValueChanged<List<DrawingHotspot>>? onHotspots;

  static const _outlineColor = Color(0xFF34515E);
  static const _dimColor = Color(0xFF546E7A);
  static const _rootColor = Color(0xFF539A96);
  static const double _strokeOutline = 1.6;
  static const double _strokeDim = 0.9;

  bool get _technical => drawingMode == DrawingMode.technical;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final scene = _SceneBuilder(
      grooveType: grooveType,
      jointType: jointType,
      data: data,
      size: size,
      fontSize: fontSize,
      labels: labels,
    ).build();

    final steel = Paint()
      ..color = _technical ? const Color(0xFFEEF2F5) : const Color(0xFFD3DCE3);
    final weld = Paint()
      ..color = _technical ? const Color(0xFFF3C9A5) : const Color(0xFFEF8354);
    final outline = Paint()
      ..color = _outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeOutline
      ..strokeJoin = StrokeJoin.round;
    final dim = Paint()
      ..color = _dimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeDim
      ..strokeCap = StrokeCap.round;

    for (final plate in scene.plates) {
      canvas.drawPath(plate, steel);
    }
    canvas.drawPath(scene.weld, weld);
    final rootY = scene.rootZoneTopY;
    if (rootY != null) {
      canvas.save();
      canvas.clipPath(scene.weld);
      canvas.drawRect(
        Rect.fromLTRB(0, rootY, size.width, size.height),
        Paint()..color = _rootColor.withValues(alpha: 0.85),
      );
      canvas.restore();
    }
    for (final plate in scene.plates) {
      canvas.drawPath(plate, outline);
    }
    canvas.drawPath(scene.weld, outline);

    for (final seg in [...scene._lines, ...scene._leaders]) {
      canvas.drawLine(seg.a, seg.b, dim);
    }
    for (final arc in scene._arcs) {
      canvas.drawArc(
        Rect.fromCircle(center: arc.center, radius: arc.radius),
        -math.pi / 2,
        arc.sweep,
        false,
        dim,
      );
    }
    final arrowPaint = Paint()..color = _dimColor;
    for (final arrow in scene._arrows) {
      final n = Offset(-arrow.dir.dy, arrow.dir.dx);
      final base = arrow.tip - arrow.dir * _SceneBuilder._arrowLen;
      canvas.drawPath(
        Path()
          ..moveTo(arrow.tip.dx, arrow.tip.dy)
          ..lineTo(base.dx + n.dx * 2.2, base.dy + n.dy * 2.2)
          ..lineTo(base.dx - n.dx * 2.2, base.dy - n.dy * 2.2)
          ..close(),
        arrowPaint,
      );
    }

    final fill = Paint()..color = const Color(0xF2FFFFFF);
    final stroke = Paint()
      ..color = _dimColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final label in scene.labels) {
      final rrect = RRect.fromRectAndRadius(
        label.rect,
        const Radius.circular(5),
      );
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);
      final tp = TextPainter(
        text: TextSpan(
          text: label.text,
          style: weldDrawingLabelStyle(fontSize),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      tp.paint(canvas, label.rect.center - Offset(tp.width / 2, tp.height / 2));
    }

    onHotspots?.call([
      for (final label in scene.labels)
        DrawingHotspot(label.fieldKey, label.hitRect, label.rect),
    ]);
  }

  @override
  bool shouldRepaint(covariant _WeldDrawingPainter oldDelegate) =>
      oldDelegate.grooveType != grooveType ||
      oldDelegate.jointType != jointType ||
      oldDelegate.drawingMode != drawingMode ||
      oldDelegate.data != data ||
      oldDelegate.fontSize != fontSize;
}
