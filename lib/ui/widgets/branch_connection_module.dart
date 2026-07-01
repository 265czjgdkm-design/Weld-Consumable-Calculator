import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'weld_drawing_preview.dart';

enum BranchConnectionType { setOnNozzle, setInNozzle, weldolet }

extension BranchConnectionTypeX on BranchConnectionType {
  String get label => switch (this) {
    BranchConnectionType.setOnNozzle => 'Set-on Nozzle',
    BranchConnectionType.setInNozzle => 'Set-in Nozzle',
    BranchConnectionType.weldolet => 'Weldolet',
  };

  String get subtitle => switch (this) {
    BranchConnectionType.setOnNozzle =>
      'Nozzle sits on the run pipe OD with external fillet welds and optional repad.',
    BranchConnectionType.setInNozzle =>
      'Branch penetrates into the run opening and is shown with an inserted section detail.',
    BranchConnectionType.weldolet =>
      'Integrally reinforced fitting body transitions from the run shell to the branch neck.',
  };
}

class BranchConnectionsModule extends StatefulWidget {
  const BranchConnectionsModule({super.key});

  @override
  State<BranchConnectionsModule> createState() =>
      _BranchConnectionsModuleState();
}

class _BranchConnectionsModuleState extends State<BranchConnectionsModule> {
  final TextEditingController _runOdController = TextEditingController(
    text: '323.9',
  );
  final TextEditingController _runThicknessController = TextEditingController(
    text: '12.7',
  );
  final TextEditingController _branchOdController = TextEditingController(
    text: '114.3',
  );
  final TextEditingController _branchThicknessController =
      TextEditingController(text: '8.6');
  final TextEditingController _projectionController = TextEditingController(
    text: '85',
  );
  final TextEditingController _filletSizeController = TextEditingController(
    text: '6',
  );
  final TextEditingController _setInDepthController = TextEditingController(
    text: '8',
  );
  final TextEditingController _repadThicknessController = TextEditingController(
    text: '8',
  );
  final TextEditingController _repadOdController = TextEditingController(
    text: '190',
  );
  final TextEditingController _oletHeightController = TextEditingController(
    text: '28',
  );

  BranchConnectionType _connectionType = BranchConnectionType.setOnNozzle;
  DrawingMode _drawingMode = DrawingMode.technical;

  @override
  void dispose() {
    _runOdController.dispose();
    _runThicknessController.dispose();
    _branchOdController.dispose();
    _branchThicknessController.dispose();
    _projectionController.dispose();
    _filletSizeController.dispose();
    _setInDepthController.dispose();
    _repadThicknessController.dispose();
    _repadOdController.dispose();
    _oletHeightController.dispose();
    super.dispose();
  }

  BranchConnectionDrawingData get _drawingData => BranchConnectionDrawingData(
    runOdMm: _parse(_runOdController, 323.9),
    runThicknessMm: _parse(_runThicknessController, 12.7),
    branchOdMm: _parse(_branchOdController, 114.3),
    branchThicknessMm: _parse(_branchThicknessController, 8.6),
    projectionMm: _parse(_projectionController, 85),
    filletSizeMm: _parse(_filletSizeController, 6),
    setInDepthMm: _parse(_setInDepthController, 8),
    repadThicknessMm: _parse(_repadThicknessController, 8),
    repadOdMm: _parse(_repadOdController, 190),
    oletHeightMm: _parse(_oletHeightController, 28),
  );

  double _parse(TextEditingController controller, double fallback) {
    final parsed = double.tryParse(controller.text.replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return fallback;
    }
    return parsed;
  }

  List<String> get _strengths {
    final data = _drawingData;
    final branchRatio = data.branchOdMm / data.runOdMm;
    final wallRatio = data.branchThicknessMm / data.runThicknessMm;

    return [
      'Section geometry now reacts to real run/branch OD and thickness values instead of a fixed sketch.',
      'A dedicated weld-detail panel now magnifies the actual branch-to-run seat so toe location and fit-up are easier to read.',
      'Current branch-to-run ratio is ${branchRatio.toStringAsFixed(2)} and wall ratio is ${wallRatio.toStringAsFixed(2)}, which already makes proportion changes visible during input edits.',
    ];
  }

  List<String> get _questions {
    final data = _drawingData;
    final branchRatio = data.branchOdMm / data.runOdMm;
    final questions = <String>[
      'This is still a section-driven visual prototype. True saddle weld path and developed intersection length are not solved yet.',
      'This view is intentionally 2D-first. It is optimized for weld-seat clarity rather than free-rotation visualization.',
    ];

    if (_connectionType == BranchConnectionType.setOnNozzle &&
        data.repadThicknessMm > 0) {
      questions.add(
        'Repad is shown in section, but pad outline and vent-hole conventions would need a dedicated detailing layer before we call it production-grade.',
      );
    }

    if (_connectionType == BranchConnectionType.weldolet) {
      questions.add(
        'Weldolet body is currently a parametric approximation. A catalog-driven shape library would be the next accuracy jump.',
      );
    }

    if (branchRatio > 0.6) {
      questions.add(
        'Large branch ratio detected. Visual readability stays acceptable, but final metraj logic should switch to a more exact branch intersection model.',
      );
    }

    return questions;
  }

  @override
  Widget build(BuildContext context) {
    final data = _drawingData;
    final ratioText = (data.branchOdMm / data.runOdMm).toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F4C5C), Color(0xFF2A6F78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'BRANCH CONNECTIONS / PROTOTYPE',
                    style: TextStyle(
                      color: Color(0xFF0F4C5C),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _connectionType.label,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_connectionType.subtitle} This pass is intentionally focused on section clarity, geometry proportion, and magnified weld-seat readability before exact branch metraj math.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.94),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _summaryPill('Preview basis', 'Section + weld detail'),
                    _summaryPill('Branch/Run ratio', ratioText),
                    _summaryPill('Mode', _drawingMode.label),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final type in BranchConnectionType.values)
                      ChoiceChip(
                        label: Text(type.label),
                        selected: _connectionType == type,
                        showCheckmark: false,
                        selectedColor: const Color(0xFF0F4C5C),
                        backgroundColor: const Color(0xFFF1F5F7),
                        side: BorderSide(
                          color: _connectionType == type
                              ? const Color(0xFF0F4C5C)
                              : const Color(0xFFD6E0E6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        labelStyle: TextStyle(
                          color: _connectionType == type
                              ? Colors.white
                              : const Color(0xFF29414D),
                          fontWeight: _connectionType == type
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _connectionType = type;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoStrip(
                  icon: Icons.construction_outlined,
                  text:
                      'This module is currently a geometric prototype. The goal of this pass is to prove that a mobile-friendly technical section can look convincing before we add branch-specific formulas.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Technical Drawing',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final mode in DrawingMode.values)
                          ChoiceChip(
                            label: Text(mode.label),
                            selected: _drawingMode == mode,
                            showCheckmark: false,
                            selectedColor: const Color(0xFF0F4C5C),
                            backgroundColor: const Color(0xFFF1F5F7),
                            side: BorderSide(
                              color: _drawingMode == mode
                                  ? const Color(0xFF0F4C5C)
                                  : const Color(0xFFD6E0E6),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            labelStyle: TextStyle(
                              color: _drawingMode == mode
                                  ? Colors.white
                                  : const Color(0xFF29414D),
                              fontWeight: _drawingMode == mode
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _drawingMode = mode;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _drawingMode == DrawingMode.technical
                      ? 'Technical mode emphasizes line weight, centerlines, dimension callouts, and a clearer local weld-detail enlargement.'
                      : 'Visual mode keeps the section softer while still reacting to the live branch geometry.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF607482),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final split = constraints.maxWidth >= 860;
                    final sectionPanel = _DrawingSurface(
                      title: 'Section View',
                      subtitle:
                          'Primary technical section with dimensions, centerlines, and weld seat detail.',
                      child: BranchConnectionDrawingPreview(
                        connectionType: _connectionType,
                        drawingMode: _drawingMode,
                        data: data,
                      ),
                    );
                    final detailPanel = _DrawingSurface(
                      title: 'Weld Detail',
                      subtitle:
                          'Magnified local view of the branch-to-run interface so weld toe position and fit-up are easier to verify.',
                      child: BranchConnectionDetailPreview(
                        connectionType: _connectionType,
                        drawingMode: _drawingMode,
                        data: data,
                      ),
                    );

                    if (!split) {
                      return Column(
                        children: [
                          sectionPanel,
                          const SizedBox(height: 14),
                          detailPanel,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 11, child: sectionPanel),
                        const SizedBox(width: 14),
                        Expanded(flex: 7, child: detailPanel),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dimensional Inputs',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'These values currently drive the drawing only. The point is to test if the geometry feels believable enough before branch-specific quantity formulas are added.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5E7380),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 720;
                    final fieldWidth = wide
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFF7FBFD),
                        border: Border.all(color: const Color(0xFFDCE5EB)),
                      ),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: _numberField(
                              controller: _runOdController,
                              label: 'Run OD (mm)',
                              helperText:
                                  'Outside diameter of the header pipe.',
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _numberField(
                              controller: _runThicknessController,
                              label: 'Run Thickness (mm)',
                              helperText: 'Run pipe wall thickness.',
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _numberField(
                              controller: _branchOdController,
                              label: 'Branch OD (mm)',
                              helperText:
                                  'Outside diameter of the nozzle or branch.',
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _numberField(
                              controller: _branchThicknessController,
                              label: 'Branch Thickness (mm)',
                              helperText: 'Nozzle or branch wall thickness.',
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _numberField(
                              controller: _projectionController,
                              label: 'Branch Projection (mm)',
                              helperText: 'Visible neck height above the run.',
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _numberField(
                              controller: _filletSizeController,
                              label: 'Fillet Size (mm)',
                              helperText:
                                  'Visual weld size used around the connection.',
                            ),
                          ),
                          if (_connectionType ==
                              BranchConnectionType.setInNozzle)
                            SizedBox(
                              width: fieldWidth,
                              child: _numberField(
                                controller: _setInDepthController,
                                label: 'Set-in Depth (mm)',
                                helperText:
                                    'How far the branch enters the run shell.',
                              ),
                            ),
                          if (_connectionType ==
                              BranchConnectionType.setOnNozzle) ...[
                            SizedBox(
                              width: fieldWidth,
                              child: _numberField(
                                controller: _repadThicknessController,
                                label: 'Repad Thickness (mm)',
                                helperText:
                                    'Pad thickness shown around the opening.',
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _numberField(
                                controller: _repadOdController,
                                label: 'Repad OD (mm)',
                                helperText:
                                    'Pad width used only for section proportion.',
                              ),
                            ),
                          ],
                          if (_connectionType == BranchConnectionType.weldolet)
                            SizedBox(
                              width: fieldWidth,
                              child: _numberField(
                                controller: _oletHeightController,
                                label: 'Olet Height (mm)',
                                helperText:
                                    'Transition body height between run and branch.',
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prototype Review',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'This is the self-check layer: what already looks promising and what still needs real branch engineering logic.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5E7380),
                  ),
                ),
                const SizedBox(height: 16),
                _ReviewPanel(
                  title: 'What Feels Right',
                  accent: const Color(0xFF0F4C5C),
                  background: const Color(0xFFF7FBFD),
                  icon: Icons.check_circle_outline,
                  items: _strengths,
                ),
                const SizedBox(height: 14),
                _ReviewPanel(
                  title: 'What Still Needs Work',
                  accent: const Color(0xFFEF8354),
                  background: const Color(0xFFFFF7F2),
                  icon: Icons.rule_folder_outlined,
                  items: _questions,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(labelText: label, helperText: helperText),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _summaryPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF19333F)),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF6F9FB),
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F4C5C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    required this.title,
    required this.accent,
    required this.background,
    required this.icon,
    required this.items,
  });

  final String title;
  final Color accent;
  final Color background;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: background,
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334C58),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DrawingSurface extends StatelessWidget {
  const _DrawingSurface({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFD), Color(0xFFEAF1F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17303C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF607482),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class BranchConnectionDrawingData {
  const BranchConnectionDrawingData({
    required this.runOdMm,
    required this.runThicknessMm,
    required this.branchOdMm,
    required this.branchThicknessMm,
    required this.projectionMm,
    required this.filletSizeMm,
    required this.setInDepthMm,
    required this.repadThicknessMm,
    required this.repadOdMm,
    required this.oletHeightMm,
  });

  final double runOdMm;
  final double runThicknessMm;
  final double branchOdMm;
  final double branchThicknessMm;
  final double projectionMm;
  final double filletSizeMm;
  final double setInDepthMm;
  final double repadThicknessMm;
  final double repadOdMm;
  final double oletHeightMm;
}

class BranchConnectionDrawingPreview extends StatelessWidget {
  const BranchConnectionDrawingPreview({
    super.key,
    required this.connectionType,
    required this.drawingMode,
    required this.data,
  });

  final BranchConnectionType connectionType;
  final DrawingMode drawingMode;
  final BranchConnectionDrawingData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.9,
      child: CustomPaint(
        painter: _BranchConnectionPainter(
          connectionType: connectionType,
          drawingMode: drawingMode,
          data: data,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class BranchConnectionDetailPreview extends StatelessWidget {
  const BranchConnectionDetailPreview({
    super.key,
    required this.connectionType,
    required this.drawingMode,
    required this.data,
  });

  final BranchConnectionType connectionType;
  final DrawingMode drawingMode;
  final BranchConnectionDrawingData data;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.02,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFFF9FBFC), Color(0xFFEAF1F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFD8E2E8)),
        ),
        padding: const EdgeInsets.all(10),
        child: CustomPaint(
          painter: _BranchDetailPainter(
            connectionType: connectionType,
            drawingMode: drawingMode,
            data: data,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BranchDetailPainter extends CustomPainter {
  _BranchDetailPainter({
    required this.connectionType,
    required this.drawingMode,
    required this.data,
  });

  final BranchConnectionType connectionType;
  final DrawingMode drawingMode;
  final BranchConnectionDrawingData data;

  bool get _isTechnical => drawingMode == DrawingMode.technical;

  static const _steelFill = Color(0xFFD7E1E7);
  static const _steelShade = Color(0xFFBCC9D2);
  static const _paper = Color(0xFFF9FBFC);
  static const _outline = Color(0xFF35515E);
  static const _guide = Color(0xFF7D93A0);
  static const _hatch = Color(0xFF8FA3AE);
  static const _weldFill = Color(0xFFEF8354);
  static const _weldShade = Color(0xFFD66D40);
  static const _rootFill = Color(0xFF4F9D8A);
  static const _gapFill = Color(0xFFDDF2FA);

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(22),
    );
    canvas.drawRRect(frame, Paint()..color = _paper.withValues(alpha: 0.52));

    final focusRect = Rect.fromLTWH(
      size.width * 0.07,
      size.height * 0.12,
      size.width * 0.86,
      size.height * 0.72,
    );
    final focusRRect = RRect.fromRectAndRadius(
      focusRect,
      const Radius.circular(20),
    );
    canvas.drawRRect(
      focusRRect,
      Paint()..color = Colors.white.withValues(alpha: 0.58),
    );
    canvas.drawRRect(
      focusRRect,
      Paint()
        ..color = _guide.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawLine(
      Offset(focusRect.left + 22, focusRect.top + 22),
      Offset(focusRect.right - 22, focusRect.top + 22),
      Paint()
        ..color = _guide.withValues(alpha: 0.14)
        ..strokeWidth = 0.9,
    );

    final centerX = size.width * 0.5;
    final runStartX = focusRect.left + 16;
    final runEndX = focusRect.right - 16;
    final crownLift = _isTechnical ? 11.0 : 7.0;
    final runTopY = size.height * 0.61;
    final runThicknessPx = (data.runThicknessMm * 3.0).clamp(28.0, 58.0);
    final runInnerY = runTopY + runThicknessPx;
    final branchOuterWidth = (data.branchOdMm * 0.96).clamp(94.0, 146.0);
    final branchWallPx = (data.branchThicknessMm * 2.25).clamp(10.0, 24.0);
    final branchInnerWidth = math.max(
      branchOuterWidth - (branchWallPx * 2),
      34,
    );
    final branchProjectionPx = (data.projectionMm * 1.05).clamp(88.0, 146.0);
    final branchTopY = runTopY - branchProjectionPx;
    final branchLeft = centerX - (branchOuterWidth / 2);
    final branchRight = centerX + (branchOuterWidth / 2);
    final innerLeft = centerX - (branchInnerWidth / 2);
    final innerRight = centerX + (branchInnerWidth / 2);
    final runTop = _curvedLine(runStartX, runEndX, runTopY, crownLift);
    final runInner = _curvedLine(
      runStartX,
      runEndX,
      runInnerY,
      crownLift * 0.38,
    );

    final runBand = Path.from(runTop)
      ..lineTo(runEndX, runInnerY)
      ..quadraticBezierTo(
        centerX,
        runInnerY - (crownLift * 0.38),
        runStartX,
        runInnerY,
      )
      ..close();
    final runPaint = Paint()
      ..shader = LinearGradient(
        colors: _isTechnical
            ? const [Color(0xFFF4F7F9), _steelShade]
            : const [_steelFill, _steelShade],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(focusRect);
    canvas.drawPath(runBand, runPaint);
    canvas.drawPath(
      runBand,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = _isTechnical ? 2.0 : 1.7,
    );
    _drawSectionHatch(canvas, runBand, spacing: 10, inset: 3);

    canvas.drawPath(
      runInner,
      Paint()
        ..color = _outline.withValues(alpha: 0.58)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    _drawPipeShellGuides(
      canvas,
      runStartX: runStartX,
      runEndX: runEndX,
      runTopY: runTopY,
      runInnerY: runInnerY,
      crownLift: crownLift,
    );

    _drawCenterline(canvas, size, centerX);
    _drawHeaderBadge(canvas, size, connectionType);
    _drawMiniDetailInset(
      canvas,
      rect: Rect.fromLTWH(focusRect.left + 18, focusRect.top + 34, 150, 58),
      connectionType: connectionType,
    );

    switch (connectionType) {
      case BranchConnectionType.setOnNozzle:
        _drawSetOnDetail(
          canvas,
          size,
          centerX: centerX,
          runTopY: runTopY,
          branchTopY: branchTopY,
          branchLeft: branchLeft,
          branchRight: branchRight,
          innerLeft: innerLeft,
          innerRight: innerRight,
          branchWallPx: branchWallPx,
          runInnerY: runInnerY,
          runStartX: runStartX,
          runEndX: runEndX,
        );
        break;
      case BranchConnectionType.setInNozzle:
        _drawSetInDetail(
          canvas,
          size,
          centerX: centerX,
          runTopY: runTopY,
          branchTopY: branchTopY,
          branchLeft: branchLeft,
          branchRight: branchRight,
          innerLeft: innerLeft,
          innerRight: innerRight,
          branchWallPx: branchWallPx,
          runInnerY: runInnerY,
        );
        break;
      case BranchConnectionType.weldolet:
        _drawWeldoletDetail(
          canvas,
          size,
          centerX: centerX,
          runTopY: runTopY,
          branchTopY: branchTopY,
          branchLeft: branchLeft,
          branchRight: branchRight,
          innerLeft: innerLeft,
          innerRight: innerRight,
          runInnerY: runInnerY,
        );
        break;
    }
  }

  void _drawSetOnDetail(
    Canvas canvas,
    Size size, {
    required double centerX,
    required double runTopY,
    required double branchTopY,
    required double branchLeft,
    required double branchRight,
    required double innerLeft,
    required double innerRight,
    required double branchWallPx,
    required double runInnerY,
    required double runStartX,
    required double runEndX,
  }) {
    final repadThicknessPx = (data.repadThicknessMm * 2.0).clamp(0.0, 18.0);
    final repadWidth = (data.repadOdMm * 0.58).clamp(
      branchRight - branchLeft + 36.0,
      runEndX - runStartX - 26.0,
    );
    final repadLeft = centerX - (repadWidth / 2);
    final repadRight = centerX + (repadWidth / 2);
    final seatY = runTopY - repadThicknessPx;
    final openingWidth = (innerRight - innerLeft) * 0.84;
    final openingLeft = centerX - (openingWidth / 2);
    final openingRight = centerX + (openingWidth / 2);

    if (repadThicknessPx > 1) {
      final repadPath = Path()
        ..moveTo(repadLeft, runTopY)
        ..lineTo(repadLeft, seatY + 2)
        ..quadraticBezierTo(centerX, seatY - 4, repadRight, seatY + 2)
        ..lineTo(repadRight, runTopY)
        ..close();
      canvas.drawPath(
        repadPath,
        Paint()..color = _steelShade.withValues(alpha: 0.94),
      );
      canvas.drawPath(
        repadPath,
        Paint()
          ..color = _outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      _drawSectionHatch(canvas, repadPath, spacing: 8, inset: 2);
    }

    final leftToeX = branchLeft - 24;
    final rightToeX = branchRight + 24;
    final leftToeY = repadThicknessPx > 1
        ? _quadraticCurveY(
            x: leftToeX,
            startX: repadLeft,
            endX: repadRight,
            edgeY: seatY + 2,
            controlX: centerX,
            controlY: seatY - 4,
          )
        : _quadraticCurveY(
            x: leftToeX,
            startX: runStartX,
            endX: runEndX,
            edgeY: runTopY,
            controlX: centerX,
            controlY: runTopY - 11,
          );
    final rightToeY = repadThicknessPx > 1
        ? _quadraticCurveY(
            x: rightToeX,
            startX: repadLeft,
            endX: repadRight,
            edgeY: seatY + 2,
            controlX: centerX,
            controlY: seatY - 4,
          )
        : _quadraticCurveY(
            x: rightToeX,
            startX: runStartX,
            endX: runEndX,
            edgeY: runTopY,
            controlX: centerX,
            controlY: runTopY - 11,
          );

    final branchBody = Path()
      ..moveTo(branchLeft, branchTopY)
      ..lineTo(branchLeft, seatY)
      ..lineTo(branchRight, seatY)
      ..lineTo(branchRight, branchTopY)
      ..close();
    final branchInner = Rect.fromLTRB(
      innerLeft,
      branchTopY + branchWallPx * 0.25,
      innerRight,
      seatY + 1,
    );
    canvas.drawPath(
      branchBody,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF6F8FA), Color(0xFFB8C6D0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(branchBody.getBounds()),
    );
    canvas.drawPath(
      branchBody,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9,
    );
    _drawSectionHatch(canvas, branchBody, spacing: 8, inset: 4);
    canvas.drawRect(
      branchInner,
      Paint()..color = Colors.white.withValues(alpha: 0.97),
    );
    canvas.drawRect(
      branchInner,
      Paint()
        ..color = _outline.withValues(alpha: 0.34)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final openingPath = Path()
      ..moveTo(openingLeft, runTopY + 1)
      ..quadraticBezierTo(centerX, runTopY - 7, openingRight, runTopY + 1);
    canvas.drawPath(
      openingPath,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.drawLine(
      Offset(openingLeft + 8, runTopY + 1),
      Offset(openingRight - 8, runTopY + 1),
      Paint()
        ..color = _outline.withValues(alpha: 0.42)
        ..strokeWidth = 0.9,
    );
    final openingZone = Path()
      ..moveTo(openingLeft, runTopY + 1)
      ..quadraticBezierTo(centerX, runTopY - 7, openingRight, runTopY + 1)
      ..lineTo(openingRight - 2, runTopY + 10)
      ..quadraticBezierTo(centerX, runTopY + 4, openingLeft + 2, runTopY + 10)
      ..close();
    _paintGapZone(canvas, openingZone);

    final leftWeld = _buildFilletPath(
      heel: Offset(branchLeft, seatY + 1),
      toe: Offset(leftToeX, leftToeY),
      leg: 28,
    );
    final rightWeld = _buildFilletPath(
      heel: Offset(branchRight, seatY + 1),
      toe: Offset(rightToeX, rightToeY),
      leg: 28,
      mirror: true,
    );
    _paintWeldPath(canvas, leftWeld);
    _paintWeldPath(canvas, rightWeld);
    _drawWeldToeMarkers(
      canvas,
      heel: Offset(branchLeft, seatY + 1),
      toe: Offset(leftToeX, leftToeY),
    );
    _drawWeldToeMarkers(
      canvas,
      heel: Offset(branchRight, seatY + 1),
      toe: Offset(rightToeX, rightToeY),
    );
    _drawNumberMarker(
      canvas,
      center: Offset(centerX + 52, branchTopY + 26),
      number: '1',
      fill: const Color(0xFF274552),
    );
    _drawNumberMarker(
      canvas,
      center: Offset(branchRight + 22, seatY + 16),
      number: '2',
      fill: _weldShade,
    );
    _drawNumberMarker(
      canvas,
      center: Offset(centerX, runTopY + 18),
      number: '3',
      fill: _gapFill,
      textColor: _outline,
    );
    if (repadThicknessPx > 1) {
      _drawNumberMarker(
        canvas,
        center: Offset(centerX - 102, seatY - 16),
        number: '4',
        fill: const Color(0xFFF3F7F9),
        textColor: _outline,
      );
    }
    _drawNumberMarker(
      canvas,
      center: Offset(runEndX - 26, runTopY + 16),
      number: '5',
      fill: const Color(0xFFE7EEF2),
      textColor: _outline,
    );
    _drawLegendPanel(
      canvas,
      rect: Rect.fromLTWH(size.width * 0.64, size.height * 0.16, 178, 142),
      title: 'DETAIL KEY',
      rows: [
        (id: '1', label: 'Branch neck', color: const Color(0xFF274552)),
        (id: '2', label: 'Fillet weld metal', color: _weldShade),
        (id: '3', label: 'Open gap / saddle opening', color: _gapFill),
        (id: '4', label: 'Reinforcing pad', color: const Color(0xFFF3F7F9)),
        (
          id: '5',
          label: 'Base metal / run pipe',
          color: const Color(0xFFE7EEF2),
        ),
      ],
    );

    _drawThicknessDimension(
      canvas,
      x: size.width - 36,
      top: runTopY,
      bottom: runInnerY,
      label: 'Run t ${data.runThicknessMm.toStringAsFixed(1)} mm',
      placeLabelLeft: true,
    );
    _drawHorizontalDimension(
      canvas,
      y: branchTopY - 22,
      left: branchLeft,
      right: branchRight,
      label: 'Branch OD ${data.branchOdMm.toStringAsFixed(1)} mm',
    );
    _drawCallout(
      canvas,
      label: 'Fillet size ${data.filletSizeMm.toStringAsFixed(1)} mm',
      target: Offset(branchRight + 12, seatY + 12),
      labelCenter: Offset(size.width * 0.77, size.height * 0.39),
      accent: _weldShade,
    );
  }

  void _drawSetInDetail(
    Canvas canvas,
    Size size, {
    required double centerX,
    required double runTopY,
    required double branchTopY,
    required double branchLeft,
    required double branchRight,
    required double innerLeft,
    required double innerRight,
    required double branchWallPx,
    required double runInnerY,
  }) {
    final insertionPx = (data.setInDepthMm * 2.45).clamp(16.0, 34.0);
    final branchBottomY = runTopY + insertionPx;
    final branchBody = Path()
      ..moveTo(branchLeft, branchTopY)
      ..lineTo(branchLeft, branchBottomY)
      ..lineTo(branchRight, branchBottomY)
      ..lineTo(branchRight, branchTopY)
      ..close();
    final branchInner = Rect.fromLTRB(
      innerLeft,
      branchTopY + branchWallPx * 0.2,
      innerRight,
      branchBottomY - branchWallPx * 0.15,
    );

    canvas.drawPath(
      branchBody,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF6F8FA), Color(0xFFB8C6D0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(branchBody.getBounds()),
    );
    canvas.drawPath(
      branchBody,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9,
    );
    _drawSectionHatch(canvas, branchBody, spacing: 8, inset: 4);
    canvas.drawRect(
      branchInner,
      Paint()..color = Colors.white.withValues(alpha: 0.97),
    );
    canvas.drawRect(
      branchInner,
      Paint()
        ..color = _outline.withValues(alpha: 0.34)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final rootFill = Rect.fromLTRB(
      innerLeft + 3,
      runTopY + 2,
      innerRight - 3,
      branchBottomY - 2,
    );
    final leftToeX = branchLeft - 22;
    final rightToeX = branchRight + 22;
    final leftToeY = _quadraticCurveY(
      x: leftToeX,
      startX: size.width * 0.07 + 24,
      endX: size.width * 0.93 - 24,
      edgeY: runTopY,
      controlX: centerX,
      controlY: runTopY - 11,
    );
    final rightToeY = _quadraticCurveY(
      x: rightToeX,
      startX: size.width * 0.07 + 24,
      endX: size.width * 0.93 - 24,
      edgeY: runTopY,
      controlX: centerX,
      controlY: runTopY - 11,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rootFill, const Radius.circular(8)),
      Paint()..color = _rootFill.withValues(alpha: 0.72),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rootFill, const Radius.circular(8)),
      Paint()
        ..color = _rootFill.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    _paintGapZone(
      canvas,
      Path()
        ..addRRect(RRect.fromRectAndRadius(rootFill, const Radius.circular(8))),
    );

    final leftWeld = _buildFilletPath(
      heel: Offset(branchLeft, runTopY + 1),
      toe: Offset(leftToeX, leftToeY),
      leg: 25,
    );
    final rightWeld = _buildFilletPath(
      heel: Offset(branchRight, runTopY + 1),
      toe: Offset(rightToeX, rightToeY),
      leg: 25,
      mirror: true,
    );
    _paintWeldPath(canvas, leftWeld);
    _paintWeldPath(canvas, rightWeld);
    _drawWeldToeMarkers(
      canvas,
      heel: Offset(branchLeft, runTopY + 1),
      toe: Offset(leftToeX, leftToeY),
    );
    _drawWeldToeMarkers(
      canvas,
      heel: Offset(branchRight, runTopY + 1),
      toe: Offset(rightToeX, rightToeY),
    );
    _drawInlineTag(
      canvas,
      center: Offset(branchRight + 30, runTopY + 34),
      text: 'WELD',
      fill: _weldFill,
      textColor: Colors.white,
    );
    _drawInlineTag(
      canvas,
      center: Offset(centerX, runTopY + insertionPx * 0.65),
      text: 'OPEN ROOT',
      fill: _gapFill,
      textColor: _outline,
    );

    _drawThicknessDimension(
      canvas,
      x: size.width - 36,
      top: runTopY,
      bottom: runInnerY,
      label: 'Run t ${data.runThicknessMm.toStringAsFixed(1)} mm',
      placeLabelLeft: true,
    );
    _drawThicknessDimension(
      canvas,
      x: size.width * 0.18,
      top: runTopY,
      bottom: branchBottomY,
      label: 'Set-in ${data.setInDepthMm.toStringAsFixed(1)} mm',
    );
    _drawHorizontalDimension(
      canvas,
      y: branchTopY - 22,
      left: branchLeft,
      right: branchRight,
      label: 'Branch OD ${data.branchOdMm.toStringAsFixed(1)} mm',
    );
    _drawCallout(
      canvas,
      label: 'Weld metal\n${data.filletSizeMm.toStringAsFixed(1)} mm fillet',
      target: Offset(branchRight + 10, runTopY + 12),
      labelCenter: Offset(size.width * 0.8, size.height * 0.28),
      accent: _weldShade,
    );
    _drawCallout(
      canvas,
      label: 'Inserted branch wall',
      target: Offset(branchRight - 4, runTopY + 18),
      labelCenter: Offset(size.width * 0.79, size.height * 0.28),
      accent: _outline,
    );
    _drawCallout(
      canvas,
      label: 'Open root / fusion zone',
      target: Offset(centerX, runTopY + insertionPx * 0.7),
      labelCenter: Offset(size.width * 0.5, size.height * 0.78),
      accent: _gapFill,
    );
  }

  void _drawWeldoletDetail(
    Canvas canvas,
    Size size, {
    required double centerX,
    required double runTopY,
    required double branchTopY,
    required double branchLeft,
    required double branchRight,
    required double innerLeft,
    required double innerRight,
    required double runInnerY,
  }) {
    final fittingHeight = (data.oletHeightMm * 2.2).clamp(36.0, 74.0);
    final neckWidth = (branchRight - branchLeft) * 0.72;
    final neckLeft = centerX - (neckWidth / 2);
    final neckRight = centerX + (neckWidth / 2);
    final fittingTopY = runTopY - fittingHeight;

    final bodyPath = Path()
      ..moveTo(branchLeft - 18, runTopY)
      ..cubicTo(
        branchLeft - 6,
        runTopY - 18,
        neckLeft - 10,
        fittingTopY + 12,
        neckLeft,
        fittingTopY,
      )
      ..lineTo(neckRight, fittingTopY)
      ..cubicTo(
        neckRight + 10,
        fittingTopY + 12,
        branchRight + 6,
        runTopY - 18,
        branchRight + 18,
        runTopY,
      )
      ..close();
    final branchPath = Rect.fromLTRB(
      neckLeft,
      branchTopY,
      neckRight,
      fittingTopY,
    );
    final branchInner = Rect.fromLTRB(
      innerLeft + 8,
      branchTopY + 4,
      innerRight - 8,
      fittingTopY + 1,
    );
    final leftToeX = branchLeft - 32;
    final rightToeX = branchRight + 32;
    final leftToeY = _quadraticCurveY(
      x: leftToeX,
      startX: size.width * 0.07 + 24,
      endX: size.width * 0.93 - 24,
      edgeY: runTopY,
      controlX: centerX,
      controlY: runTopY - 11,
    );
    final rightToeY = _quadraticCurveY(
      x: rightToeX,
      startX: size.width * 0.07 + 24,
      endX: size.width * 0.93 - 24,
      edgeY: runTopY,
      controlX: centerX,
      controlY: runTopY - 11,
    );

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFCBD7DF), Color(0xFFAEBCC7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bodyPath.getBounds()),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9,
    );
    _drawSectionHatch(canvas, bodyPath, spacing: 8, inset: 3);
    canvas.drawRect(
      branchPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF6F8FA), Color(0xFFBBC7D0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(branchPath),
    );
    canvas.drawRect(
      branchPath,
      Paint()
        ..color = _outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9,
    );
    _drawSectionHatch(
      canvas,
      Path()..addRect(branchPath),
      spacing: 8,
      inset: 3,
    );
    canvas.drawRect(
      branchInner,
      Paint()..color = Colors.white.withValues(alpha: 0.96),
    );
    canvas.drawRect(
      branchInner,
      Paint()
        ..color = _outline.withValues(alpha: 0.34)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final leftWeld = _buildFilletPath(
      heel: Offset(branchLeft - 10, runTopY + 1),
      toe: Offset(leftToeX, leftToeY),
      leg: 24,
    );
    final rightWeld = _buildFilletPath(
      heel: Offset(branchRight + 10, runTopY + 1),
      toe: Offset(rightToeX, rightToeY),
      leg: 24,
      mirror: true,
    );
    _paintWeldPath(canvas, leftWeld);
    _paintWeldPath(canvas, rightWeld);
    _drawWeldToeMarkers(
      canvas,
      heel: Offset(branchLeft - 10, runTopY + 1),
      toe: Offset(leftToeX, leftToeY),
    );
    _drawWeldToeMarkers(
      canvas,
      heel: Offset(branchRight + 10, runTopY + 1),
      toe: Offset(rightToeX, rightToeY),
    );
    _drawInlineTag(
      canvas,
      center: Offset(branchRight + 36, runTopY + 34),
      text: 'WELD',
      fill: _weldFill,
      textColor: Colors.white,
    );

    _drawThicknessDimension(
      canvas,
      x: size.width - 36,
      top: runTopY,
      bottom: runInnerY,
      label: 'Run t ${data.runThicknessMm.toStringAsFixed(1)} mm',
      placeLabelLeft: true,
    );
    _drawThicknessDimension(
      canvas,
      x: size.width * 0.2,
      top: fittingTopY,
      bottom: runTopY,
      label: 'Olet h ${data.oletHeightMm.toStringAsFixed(1)} mm',
    );
    _drawCallout(
      canvas,
      label: 'Integrally reinforced body',
      target: Offset(branchRight + 8, runTopY - 12),
      labelCenter: Offset(size.width * 0.78, size.height * 0.26),
      accent: _outline,
    );
    _drawCallout(
      canvas,
      label: 'Weld metal',
      target: Offset(branchRight + 18, runTopY + 10),
      labelCenter: Offset(size.width * 0.82, size.height * 0.4),
      accent: _weldShade,
    );
    _drawCallout(
      canvas,
      label: 'Run pipe shell',
      target: Offset(centerX + 90, runTopY + 10),
      labelCenter: Offset(size.width * 0.82, size.height * 0.66),
      accent: _outline,
    );
  }

  Path _curvedLine(double startX, double endX, double y, double crownLift) =>
      Path()
        ..moveTo(startX, y)
        ..quadraticBezierTo(centerX(startX, endX), y - crownLift, endX, y);

  double centerX(double startX, double endX) => (startX + endX) / 2;

  double _quadraticCurveY({
    required double x,
    required double startX,
    required double endX,
    required double edgeY,
    required double controlX,
    required double controlY,
  }) {
    if (endX == startX) {
      return edgeY;
    }
    final t = ((x - startX) / (endX - startX)).clamp(0.0, 1.0);
    final mt = 1 - t;
    return (mt * mt * edgeY) + (2 * mt * t * controlY) + (t * t * edgeY);
  }

  void _drawCenterline(Canvas canvas, Size size, double x) {
    final guide = Paint()
      ..color = _guide.withValues(alpha: _isTechnical ? 0.85 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    double y = 18;
    while (y < size.height - 18) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 8), guide);
      y += 14;
    }
  }

  void _drawHeaderBadge(
    Canvas canvas,
    Size size,
    BranchConnectionType connectionType,
  ) {
    final text = switch (connectionType) {
      BranchConnectionType.setOnNozzle => 'DETAIL A  SET-ON',
      BranchConnectionType.setInNozzle => 'DETAIL A  SET-IN',
      BranchConnectionType.weldolet => 'DETAIL A  WELDOLET',
    };
    _drawBadge(canvas, Offset(size.width * 0.2, 28), text);
    _drawBadge(
      canvas,
      Offset(size.width * 0.76, size.height - 30),
      'LOCAL ENLARGEMENT',
    );
  }

  void _drawBadge(Canvas canvas, Offset center, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _outline,
          fontSize: 10.2,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: painter.width + 18,
        height: painter.height + 8,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.94),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = _guide.withValues(alpha: 0.52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      Paint()
        ..color = _guide.withValues(alpha: 0.28)
        ..strokeWidth = 2.0,
    );
    painter.paint(
      canvas,
      Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
    );
  }

  Path _buildFilletPath({
    required Offset heel,
    required Offset toe,
    required double leg,
    bool mirror = false,
  }) {
    final direction = mirror ? -1.0 : 1.0;
    return Path()
      ..moveTo(heel.dx, heel.dy)
      ..lineTo(toe.dx, toe.dy)
      ..quadraticBezierTo(
        toe.dx + (6 * direction),
        toe.dy + (leg * 0.42),
        heel.dx,
        heel.dy + leg,
      )
      ..close();
  }

  void _paintWeldPath(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..color = _weldShade.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2,
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [(_isTechnical ? _weldShade : _weldFill), _weldFill],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(path.getBounds()),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _weldShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15,
    );
  }

  void _drawWeldToeMarkers(
    Canvas canvas, {
    required Offset heel,
    required Offset toe,
  }) {
    final fill = Paint()..color = _weldShade;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final point in [heel, toe]) {
      canvas.drawCircle(point, 3.4, fill);
      canvas.drawCircle(point, 3.4, stroke);
    }
  }

  void _drawThicknessDimension(
    Canvas canvas, {
    required double x,
    required double top,
    required double bottom,
    required String label,
    bool placeLabelLeft = false,
  }) {
    final guide = Paint()
      ..color = _guide
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    canvas.drawLine(Offset(x, top), Offset(x, bottom), guide);
    _drawArrowHead(canvas, tip: Offset(x, top), vertical: true, reverse: false);
    _drawArrowHead(
      canvas,
      tip: Offset(x, bottom),
      vertical: true,
      reverse: true,
    );
    _drawLabelBubble(
      canvas,
      center: Offset(x + (placeLabelLeft ? -64 : 64), (top + bottom) / 2),
      text: label,
      alignLeft: !placeLabelLeft,
    );
  }

  void _drawHorizontalDimension(
    Canvas canvas, {
    required double y,
    required double left,
    required double right,
    required String label,
  }) {
    final guide = Paint()
      ..color = _guide
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    canvas.drawLine(Offset(left, y), Offset(right, y), guide);
    _drawArrowHead(
      canvas,
      tip: Offset(left, y),
      vertical: false,
      reverse: false,
    );
    _drawArrowHead(
      canvas,
      tip: Offset(right, y),
      vertical: false,
      reverse: true,
    );
    _drawLabelBubble(
      canvas,
      center: Offset((left + right) / 2, y - 18),
      text: label,
    );
  }

  void _drawCallout(
    Canvas canvas, {
    required String label,
    required Offset target,
    required Offset labelCenter,
    Color accent = _weldFill,
  }) {
    final guide = Paint()
      ..color = _guide.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final elbow = Offset(target.dx, labelCenter.dy);
    canvas.drawLine(target, elbow, guide);
    canvas.drawLine(
      elbow,
      Offset(
        labelCenter.dx + (labelCenter.dx < target.dx ? 28 : -28),
        labelCenter.dy,
      ),
      guide,
    );
    canvas.drawCircle(target, 2.7, Paint()..color = accent);
    _drawLabelBubble(canvas, center: labelCenter, text: label, accent: accent);
  }

  void _drawPipeShellGuides(
    Canvas canvas, {
    required double runStartX,
    required double runEndX,
    required double runTopY,
    required double runInnerY,
    required double crownLift,
  }) {
    final guidePaint = Paint()
      ..color = _guide.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(
      _curvedLine(runStartX + 12, runEndX - 12, runTopY - 14, crownLift * 0.7),
      guidePaint,
    );
    canvas.drawPath(
      _curvedLine(
        runStartX + 12,
        runEndX - 12,
        runInnerY + 14,
        crownLift * 0.34,
      ),
      guidePaint,
    );
  }

  void _drawMiniDetailInset(
    Canvas canvas, {
    required Rect rect,
    required BranchConnectionType connectionType,
  }) {
    final panel = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(
      panel,
      Paint()..color = Colors.white.withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..color = _guide.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    final baseY = rect.bottom - 22;
    final left = rect.left + 16;
    final right = rect.right - 16;
    final cx = rect.center.dx;
    final runPath = Path()
      ..moveTo(left, baseY)
      ..quadraticBezierTo(cx, baseY - 6, right, baseY)
      ..lineTo(right, baseY + 12)
      ..lineTo(left, baseY + 12)
      ..close();
    canvas.drawPath(
      runPath,
      Paint()..color = _steelFill.withValues(alpha: 0.85),
    );
    canvas.drawPath(
      runPath,
      Paint()
        ..color = _outline.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final neckLeft = cx - 12;
    final neckRight = cx + 12;
    final neckTop = rect.top + 16;
    final neckBottom = baseY - 2;
    final neckPath = Path()
      ..moveTo(neckLeft, neckTop)
      ..lineTo(neckLeft, neckBottom)
      ..lineTo(neckRight, neckBottom)
      ..lineTo(neckRight, neckTop)
      ..close();
    canvas.drawPath(
      neckPath,
      Paint()..color = _steelShade.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      neckPath,
      Paint()
        ..color = _outline.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final gapPath = switch (connectionType) {
      BranchConnectionType.setOnNozzle =>
        Path()
          ..moveTo(cx - 14, baseY)
          ..quadraticBezierTo(cx, baseY - 5, cx + 14, baseY)
          ..lineTo(cx + 11, baseY + 7)
          ..quadraticBezierTo(cx, baseY + 2, cx - 11, baseY + 7)
          ..close(),
      BranchConnectionType.setInNozzle =>
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(cx - 11, baseY - 2, cx + 11, baseY + 12),
            const Radius.circular(4),
          ),
        ),
      BranchConnectionType.weldolet =>
        Path()
          ..moveTo(cx - 10, baseY)
          ..quadraticBezierTo(cx, baseY - 4, cx + 10, baseY)
          ..lineTo(cx + 7, baseY + 6)
          ..quadraticBezierTo(cx, baseY + 3, cx - 7, baseY + 6)
          ..close(),
    };
    _paintGapZone(canvas, gapPath, strokeWidth: 0.8);

    final leftWeld = _buildFilletPath(
      heel: Offset(neckLeft, neckBottom),
      toe: Offset(neckLeft - 11, baseY),
      leg: 12,
    );
    final rightWeld = _buildFilletPath(
      heel: Offset(neckRight, neckBottom),
      toe: Offset(neckRight + 11, baseY),
      leg: 12,
      mirror: true,
    );
    _paintWeldPath(canvas, leftWeld);
    _paintWeldPath(canvas, rightWeld);

    _drawMiniLegendSwatch(
      canvas,
      origin: Offset(rect.left + 10, rect.top + 8),
      color: _weldFill,
      label: 'WELD',
    );
    _drawMiniLegendSwatch(
      canvas,
      origin: Offset(rect.left + 74, rect.top + 8),
      color: _gapFill,
      label: 'GAP',
    );
  }

  void _drawMiniLegendSwatch(
    Canvas canvas, {
    required Offset origin,
    required Color color,
    required String label,
  }) {
    final swatch = Rect.fromLTWH(origin.dx, origin.dy, 12, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(swatch, const Radius.circular(2)),
      Paint()..color = color,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: _outline,
          fontSize: 8.4,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(origin.dx + 16, origin.dy - 1));
  }

  void _drawInlineTag(
    Canvas canvas, {
    required Offset center,
    required String text,
    required Color fill,
    required Color textColor,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 8.8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.55,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: painter.width + 16,
        height: painter.height + 8,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = fill);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = _outline.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    painter.paint(
      canvas,
      Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
    );
  }

  void _drawNumberMarker(
    Canvas canvas, {
    required Offset center,
    required String number,
    required Color fill,
    Color textColor = Colors.white,
  }) {
    canvas.drawCircle(center, 10, Paint()..color = fill);
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = _outline.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: number,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
    );
  }

  void _drawLegendPanel(
    Canvas canvas, {
    required Rect rect,
    required String title,
    required List<({String id, String label, Color color})> rows,
  }) {
    final panel = RRect.fromRectAndRadius(rect, const Radius.circular(14));
    canvas.drawRRect(
      panel,
      Paint()..color = Colors.white.withValues(alpha: 0.97),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..color = _guide.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: _outline,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 24);
    titlePainter.paint(canvas, Offset(rect.left + 12, rect.top + 10));
    var y = rect.top + 32;
    for (final row in rows) {
      _drawNumberMarker(
        canvas,
        center: Offset(rect.left + 18, y + 8),
        number: row.id,
        fill: row.color,
        textColor: row.color.computeLuminance() > 0.6 ? _outline : Colors.white,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: row.label,
          style: const TextStyle(
            color: _outline,
            fontSize: 10.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width - 42);
      textPainter.paint(canvas, Offset(rect.left + 34, y));
      y += 22;
    }
  }

  void _paintGapZone(Canvas canvas, Path path, {double strokeWidth = 1.0}) {
    canvas.drawPath(path, Paint()..color = _gapFill.withValues(alpha: 0.92));
    canvas.drawPath(
      path,
      Paint()
        ..color = _guide.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final bounds = path.getBounds();
    canvas.save();
    canvas.clipPath(path);
    final dashPaint = Paint()
      ..color = _guide.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    for (double x = bounds.left - 10; x < bounds.right + 10; x += 7) {
      canvas.drawLine(
        Offset(x, bounds.bottom),
        Offset(x + 8, bounds.top),
        dashPaint,
      );
    }
    canvas.restore();
  }

  void _drawLabelBubble(
    Canvas canvas, {
    required Offset center,
    required String text,
    bool alignLeft = false,
    Color accent = _outline,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _outline,
          fontSize: 11.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 132);

    final bubbleWidth = painter.width + 24;
    final bubbleHeight = painter.height + 12;
    final rect = Rect.fromCenter(
      center: alignLeft
          ? Offset(center.dx + (bubbleWidth / 2) - 12, center.dy)
          : center,
      width: bubbleWidth,
      height: bubbleHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white.withValues(alpha: 0.97),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = accent.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.95,
    );
    canvas.drawLine(
      Offset(rect.left + 4, rect.bottom - 1.6),
      Offset(rect.right - 4, rect.bottom - 1.6),
      Paint()
        ..color = accent.withValues(alpha: 0.22)
        ..strokeWidth = 1.8,
    );
    painter.paint(
      canvas,
      Offset(
        rect.center.dx - (painter.width / 2),
        rect.center.dy - (painter.height / 2),
      ),
    );
  }

  void _drawArrowHead(
    Canvas canvas, {
    required Offset tip,
    required bool vertical,
    required bool reverse,
  }) {
    const size = 6.5;
    final path = Path();
    if (vertical) {
      final dir = reverse ? -1.0 : 1.0;
      path
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 4.5, tip.dy + (size * dir))
        ..lineTo(tip.dx + 4.5, tip.dy + (size * dir))
        ..close();
    } else {
      final dir = reverse ? -1.0 : 1.0;
      path
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + (size * dir), tip.dy - 4.5)
        ..lineTo(tip.dx + (size * dir), tip.dy + 4.5)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = _guide);
  }

  void _drawSectionHatch(
    Canvas canvas,
    Path path, {
    required double spacing,
    double inset = 0,
  }) {
    final bounds = path.getBounds().inflate(inset);
    canvas.save();
    canvas.clipPath(path);
    final hatchPaint = Paint()
      ..color = _hatch.withValues(alpha: _isTechnical ? 0.55 : 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    for (
      double x = bounds.left - bounds.height;
      x < bounds.right + bounds.height;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(x, bounds.bottom),
        Offset(x + bounds.height, bounds.top),
        hatchPaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BranchDetailPainter oldDelegate) =>
      oldDelegate.connectionType != connectionType ||
      oldDelegate.drawingMode != drawingMode ||
      oldDelegate.data != data;
}

class _BranchConnectionPainter extends CustomPainter {
  _BranchConnectionPainter({
    required this.connectionType,
    required this.drawingMode,
    required this.data,
  });

  final BranchConnectionType connectionType;
  final DrawingMode drawingMode;
  final BranchConnectionDrawingData data;

  bool get _isTechnical => drawingMode == DrawingMode.technical;

  static const _steelFill = Color(0xFFD7E1E7);
  static const _steelShade = Color(0xFFB8C5CF);
  static const _shadowSteel = Color(0xFFA4B4BF);
  static const _weldFill = Color(0xFFEF8354);
  static const _weldShade = Color(0xFFD66D40);
  static const _outline = Color(0xFF34515E);
  static const _guide = Color(0xFF7A909C);
  static const _label = Color(0xFF20333D);
  static const _paper = Color(0xFFF9FBFC);
  static const _paperEdge = Color(0xFFD7E1E7);

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8FBFD), Color(0xFFEAF1F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      background,
    );

    final panelStroke = Paint()
      ..color = const Color(0xFFD2DEE6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 6, 0, 0).expandToInclude(
          Rect.fromLTWH(6, 6, size.width - 12, size.height - 12),
        ),
        const Radius.circular(24),
      ),
      panelStroke,
    );

    final scale = math.min(
      size.width / 640,
      size.height / (data.runOdMm + data.projectionMm + 180),
    );
    final runHeight = (data.runOdMm * scale)
        .clamp(120, size.height * 0.44)
        .toDouble();
    final runWidth = size.width * 0.63;
    final runRect = Rect.fromCenter(
      center: Offset(size.width * 0.48, size.height * 0.62),
      width: runWidth,
      height: runHeight,
    );
    final runWall = (data.runThicknessMm * scale)
        .clamp(8, runHeight / 4)
        .toDouble();
    final branchWidth = (data.branchOdMm * scale)
        .clamp(62, size.width * 0.2)
        .toDouble();
    final branchWall = (data.branchThicknessMm * scale)
        .clamp(7, branchWidth / 4)
        .toDouble();
    final projection = (data.projectionMm * scale)
        .clamp(66, size.height * 0.28)
        .toDouble();
    final fillet = (data.filletSizeMm * scale * 0.95).clamp(12, 26).toDouble();
    final setInDepth = (data.setInDepthMm * scale)
        .clamp(10, runHeight * 0.28)
        .toDouble();
    final repadThickness = (data.repadThicknessMm * scale)
        .clamp(7, 18)
        .toDouble();
    final repadWidth = (data.repadOdMm * scale * 0.48)
        .clamp(branchWidth * 1.3, runWidth * 0.48)
        .toDouble();
    final oletHeight = (data.oletHeightMm * scale).clamp(18, 44).toDouble();
    final centerX = runRect.center.dx;
    final branchTop = runRect.top - projection;
    final shadowOffset = Offset(
      _isTechnical ? 22 : 26,
      _isTechnical ? -16 : -18,
    );
    final cavityPaint = Paint()..color = _paper;
    final shadowCavityPaint = Paint()
      ..color = _paper.withValues(alpha: _isTechnical ? 0.56 : 0.48);
    final outlinePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isTechnical ? 2.2 : 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final guidePaint = Paint()
      ..color = _guide
      ..style = PaintingStyle.stroke
      ..strokeWidth = _isTechnical ? 1.0 : 1.2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final steelFrontPaint = Paint()
      ..shader = LinearGradient(
        colors: _isTechnical
            ? const [Color(0xFFF4F7F9), _steelShade]
            : const [_steelFill, _steelShade],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(runRect)
      ..style = PaintingStyle.fill;
    final steelShadowPaint = Paint()
      ..color = _shadowSteel.withValues(alpha: _isTechnical ? 0.18 : 0.24)
      ..style = PaintingStyle.fill;
    final weldFrontPaint = Paint()
      ..shader = LinearGradient(
        colors: _isTechnical
            ? const [Color(0xFFF1C59B), _weldShade]
            : const [_weldFill, _weldShade],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(runRect)
      ..style = PaintingStyle.fill;
    final weldShadowPaint = Paint()
      ..color = _weldShade.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final connectionShadowPaint = Paint()
      ..color = const Color(0x2234515E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final runBackRect = runRect.shift(shadowOffset);
    _drawHorizontalPipe(
      canvas,
      outerRect: runBackRect,
      wallThickness: runWall,
      bodyPaint: steelShadowPaint,
      cavityPaint: shadowCavityPaint,
      outlinePaint: guidePaint,
      drawOutline: false,
    );

    _drawHorizontalPipe(
      canvas,
      outerRect: runRect,
      wallThickness: runWall,
      bodyPaint: steelFrontPaint,
      cavityPaint: cavityPaint,
      outlinePaint: outlinePaint,
    );

    final seatShadowRect = Rect.fromCenter(
      center: Offset(
        centerX,
        runRect.top + (data.repadThicknessMm > 0 ? repadThickness * 0.35 : 2),
      ),
      width: connectionType == BranchConnectionType.weldolet
          ? branchWidth * 2.35
          : branchWidth * 2.05,
      height: connectionType == BranchConnectionType.weldolet ? 16 : 13,
    );
    canvas.drawOval(seatShadowRect, connectionShadowPaint);

    final branchHeight =
        projection +
        (connectionType == BranchConnectionType.setInNozzle ? setInDepth : 0);
    final branchRect = Rect.fromLTWH(
      centerX - (branchWidth / 2),
      branchTop,
      branchWidth,
      branchHeight,
    );
    final branchBackRect = branchRect.shift(shadowOffset);

    if (connectionType == BranchConnectionType.setOnNozzle &&
        data.repadThicknessMm > 0) {
      final repadRect = Rect.fromCenter(
        center: Offset(centerX, runRect.top - (repadThickness / 2)),
        width: repadWidth,
        height: repadThickness,
      );
      final repadBackRect = repadRect.shift(shadowOffset);
      _drawSolidExtrusion(
        canvas,
        frontRect: repadRect,
        backRect: repadBackRect,
        fillPaint: steelShadowPaint,
        frontPaint: steelFrontPaint,
        outlinePaint: outlinePaint,
      );
    }

    if (connectionType == BranchConnectionType.weldolet) {
      final bodyPath = Path()
        ..moveTo(centerX - branchWidth * 0.92, runRect.top)
        ..cubicTo(
          centerX - branchWidth * 0.88,
          runRect.top - oletHeight * 0.28,
          centerX - branchWidth * 0.6,
          runRect.top - oletHeight * 0.84,
          centerX - branchWidth * 0.38,
          runRect.top - oletHeight,
        )
        ..lineTo(centerX + branchWidth * 0.38, runRect.top - oletHeight)
        ..cubicTo(
          centerX + branchWidth * 0.6,
          runRect.top - oletHeight * 0.84,
          centerX + branchWidth * 0.88,
          runRect.top - oletHeight * 0.28,
          centerX + branchWidth * 0.92,
          runRect.top,
        )
        ..close();
      canvas.drawPath(bodyPath.shift(shadowOffset), steelShadowPaint);
      canvas.drawPath(bodyPath, steelFrontPaint);
      canvas.drawPath(bodyPath, outlinePaint);
    }

    _drawVerticalPipe(
      canvas,
      outerRect: branchBackRect,
      wallThickness: branchWall,
      bodyPaint: steelShadowPaint,
      cavityPaint: shadowCavityPaint,
      outlinePaint: guidePaint,
      openBottom: connectionType == BranchConnectionType.setOnNozzle,
      drawOutline: false,
    );

    _drawVerticalPipe(
      canvas,
      outerRect: branchRect,
      wallThickness: branchWall,
      bodyPaint: steelFrontPaint,
      cavityPaint: cavityPaint,
      outlinePaint: outlinePaint,
      openBottom: connectionType == BranchConnectionType.setOnNozzle,
    );

    switch (connectionType) {
      case BranchConnectionType.setOnNozzle:
        _drawSetOnSaddleSeat(
          canvas,
          topY: runRect.top - (data.repadThicknessMm > 0 ? repadThickness : 0),
          centerX: centerX,
          branchWidth: branchWidth,
          branchWall: branchWall,
          fillet: fillet,
          slotPaint: Paint()..color = _outline.withValues(alpha: 0.88),
          guidePaint: guidePaint,
        );
        _drawFillets(
          canvas,
          baseY: runRect.top - (data.repadThicknessMm > 0 ? repadThickness : 0),
          centerX: centerX,
          branchWidth: branchWidth,
          fillet: fillet,
          frontPaint: weldFrontPaint,
          shadowPaint: weldShadowPaint,
          shadowOffset: shadowOffset,
          outlinePaint: outlinePaint,
        );
      case BranchConnectionType.setInNozzle:
        _drawSetInWeld(
          canvas,
          runRect: runRect,
          centerX: centerX,
          branchWidth: branchWidth,
          topY: runRect.top,
          depth: setInDepth,
          frontPaint: weldFrontPaint,
          shadowPaint: weldShadowPaint,
          shadowOffset: shadowOffset,
          outlinePaint: outlinePaint,
        );
      case BranchConnectionType.weldolet:
        _drawOletWelds(
          canvas,
          runRect: runRect,
          centerX: centerX,
          branchWidth: branchWidth,
          oletHeight: oletHeight,
          fillet: fillet,
          frontPaint: weldFrontPaint,
          shadowPaint: weldShadowPaint,
          shadowOffset: shadowOffset,
          outlinePaint: outlinePaint,
        );
    }

    _drawCenterLines(canvas, size, runRect, centerX, guidePaint);
    _drawLabels(
      canvas,
      size,
      runRect,
      centerX,
      branchRect,
      runWall,
      branchWall,
      projection,
      fillet,
      setInDepth,
      repadThickness,
      oletHeight,
    );
  }

  void _drawHorizontalPipe(
    Canvas canvas, {
    required Rect outerRect,
    required double wallThickness,
    required Paint bodyPaint,
    required Paint cavityPaint,
    required Paint outlinePaint,
    bool drawOutline = true,
  }) {
    final ellipseWidth = (outerRect.height * 0.22).clamp(18.0, 26.0).toDouble();
    final bodyRect = Rect.fromLTWH(
      outerRect.left + (ellipseWidth / 2),
      outerRect.top,
      math.max(outerRect.width - ellipseWidth, 8),
      outerRect.height,
    );
    final startEllipse = Rect.fromLTWH(
      outerRect.left,
      outerRect.top,
      ellipseWidth,
      outerRect.height,
    );
    final endEllipse = Rect.fromLTWH(
      bodyRect.right - (ellipseWidth / 2),
      outerRect.top,
      ellipseWidth,
      outerRect.height,
    );
    canvas.drawRect(bodyRect, bodyPaint);
    canvas.drawOval(startEllipse, bodyPaint);
    canvas.drawOval(endEllipse, bodyPaint);

    final innerHeight = outerRect.height - (wallThickness * 2);
    if (innerHeight > 0) {
      final innerBody = Rect.fromLTWH(
        outerRect.left + (ellipseWidth / 2),
        outerRect.top + wallThickness,
        bodyRect.width,
        innerHeight,
      );
      final innerStartEllipse = Rect.fromLTWH(
        outerRect.left + (ellipseWidth * 0.12),
        outerRect.top + wallThickness,
        ellipseWidth * 0.76,
        innerHeight,
      );
      final innerEllipse = Rect.fromLTWH(
        bodyRect.right - (ellipseWidth * 0.38),
        outerRect.top + wallThickness,
        ellipseWidth * 0.76,
        innerHeight,
      );
      canvas.drawRect(innerBody, cavityPaint);
      canvas.drawOval(innerStartEllipse, cavityPaint);
      canvas.drawOval(innerEllipse, cavityPaint);

      if (drawOutline) {
        canvas.drawRect(innerBody, outlinePaint);
        canvas.drawOval(innerStartEllipse, outlinePaint);
        canvas.drawOval(innerEllipse, outlinePaint);
      }
    }

    if (drawOutline) {
      canvas.drawRect(bodyRect, outlinePaint);
      canvas.drawOval(startEllipse, outlinePaint);
      canvas.drawOval(endEllipse, outlinePaint);
      _drawCylinderHighlights(
        canvas,
        axisStart: Offset(
          bodyRect.left + 12,
          bodyRect.top + outerRect.height * 0.22,
        ),
        axisEnd: Offset(
          bodyRect.right - 10,
          bodyRect.top + outerRect.height * 0.17,
        ),
        color: _guide.withValues(alpha: 0.28),
      );
      _drawCylinderHighlights(
        canvas,
        axisStart: Offset(
          bodyRect.left + 12,
          bodyRect.bottom - outerRect.height * 0.18,
        ),
        axisEnd: Offset(
          bodyRect.right - 10,
          bodyRect.bottom - outerRect.height * 0.22,
        ),
        color: _guide.withValues(alpha: 0.2),
      );
      _drawCylinderArc(
        canvas,
        rect: startEllipse,
        color: _guide.withValues(alpha: 0.22),
      );
      _drawCylinderArc(
        canvas,
        rect: endEllipse,
        color: _guide.withValues(alpha: 0.18),
      );
      if (_isTechnical) {
        _drawBandHatch(
          canvas,
          rect: Rect.fromLTWH(
            bodyRect.left + 6,
            outerRect.top + 2,
            math.max(bodyRect.width - 12, 0),
            math.max(wallThickness - 3, 0),
          ),
          color: _guide.withValues(alpha: 0.16),
        );
        _drawBandHatch(
          canvas,
          rect: Rect.fromLTWH(
            bodyRect.left + 6,
            outerRect.bottom - wallThickness + 1,
            math.max(bodyRect.width - 12, 0),
            math.max(wallThickness - 3, 0),
          ),
          color: _guide.withValues(alpha: 0.14),
        );
      }
    }
  }

  void _drawVerticalPipe(
    Canvas canvas, {
    required Rect outerRect,
    required double wallThickness,
    required Paint bodyPaint,
    required Paint cavityPaint,
    required Paint outlinePaint,
    bool openBottom = false,
    bool drawOutline = true,
  }) {
    final ellipseHeight = (outerRect.width * 0.24).clamp(16.0, 24.0).toDouble();
    final overlap = ellipseHeight * 0.52;
    final bodyRect = Rect.fromLTWH(
      outerRect.left,
      outerRect.top + overlap,
      outerRect.width,
      math.max(outerRect.height - overlap, 8),
    );
    final capEllipse = Rect.fromLTWH(
      outerRect.left,
      bodyRect.top - (ellipseHeight / 2),
      outerRect.width,
      ellipseHeight,
    );
    if (openBottom) {
      final leftWall = Rect.fromLTWH(
        outerRect.left,
        bodyRect.top,
        wallThickness,
        bodyRect.height,
      );
      final rightWall = Rect.fromLTWH(
        outerRect.right - wallThickness,
        bodyRect.top,
        wallThickness,
        bodyRect.height,
      );
      canvas.drawRect(leftWall, bodyPaint);
      canvas.drawRect(rightWall, bodyPaint);
    } else {
      canvas.drawRect(bodyRect, bodyPaint);
    }
    canvas.drawOval(capEllipse, bodyPaint);

    final innerWidth = outerRect.width - (wallThickness * 2);
    if (innerWidth > 0) {
      final innerBody = Rect.fromLTWH(
        outerRect.left + wallThickness,
        bodyRect.top,
        innerWidth,
        bodyRect.height,
      );
      final innerEllipse = Rect.fromLTWH(
        outerRect.left + wallThickness,
        bodyRect.top - (ellipseHeight * 0.32),
        innerWidth,
        ellipseHeight * 0.64,
      );
      canvas.drawRect(innerBody, cavityPaint);
      canvas.drawOval(innerEllipse, cavityPaint);

      if (drawOutline) {
        canvas.drawRect(innerBody, outlinePaint);
        canvas.drawOval(innerEllipse, outlinePaint);
      }
    }

    if (drawOutline) {
      if (openBottom) {
        canvas.drawLine(
          Offset(outerRect.left, bodyRect.top),
          Offset(outerRect.left, bodyRect.bottom),
          outlinePaint,
        );
        canvas.drawLine(
          Offset(outerRect.right, bodyRect.top),
          Offset(outerRect.right, bodyRect.bottom),
          outlinePaint,
        );
        canvas.drawLine(
          Offset(outerRect.left + wallThickness, bodyRect.top),
          Offset(outerRect.left + wallThickness, bodyRect.bottom),
          outlinePaint,
        );
        canvas.drawLine(
          Offset(outerRect.right - wallThickness, bodyRect.top),
          Offset(outerRect.right - wallThickness, bodyRect.bottom),
          outlinePaint,
        );
      } else {
        canvas.drawRect(bodyRect, outlinePaint);
      }
      canvas.drawOval(capEllipse, outlinePaint);
      _drawCylinderHighlights(
        canvas,
        axisStart: Offset(
          bodyRect.left + outerRect.width * 0.22,
          bodyRect.top + 14,
        ),
        axisEnd: Offset(
          bodyRect.left + outerRect.width * 0.22,
          bodyRect.bottom - 12,
        ),
        color: _guide.withValues(alpha: 0.22),
        vertical: true,
      );
      _drawCylinderHighlights(
        canvas,
        axisStart: Offset(
          bodyRect.right - outerRect.width * 0.22,
          bodyRect.top + 14,
        ),
        axisEnd: Offset(
          bodyRect.right - outerRect.width * 0.22,
          bodyRect.bottom - 12,
        ),
        color: _guide.withValues(alpha: 0.16),
        vertical: true,
      );
      _drawCylinderArc(
        canvas,
        rect: capEllipse,
        color: _guide.withValues(alpha: 0.24),
        vertical: true,
      );
      if (_isTechnical) {
        _drawBandHatch(
          canvas,
          rect: Rect.fromLTWH(
            outerRect.left + 2,
            bodyRect.top + 8,
            math.max(wallThickness - 2, 0),
            math.max(bodyRect.height - 16, 0),
          ),
          color: _guide.withValues(alpha: 0.16),
          vertical: true,
        );
        _drawBandHatch(
          canvas,
          rect: Rect.fromLTWH(
            outerRect.right - wallThickness,
            bodyRect.top + 8,
            math.max(wallThickness - 2, 0),
            math.max(bodyRect.height - 16, 0),
          ),
          color: _guide.withValues(alpha: 0.14),
          vertical: true,
        );
      }
    }
  }

  void _drawSetOnSaddleSeat(
    Canvas canvas, {
    required double topY,
    required double centerX,
    required double branchWidth,
    required double branchWall,
    required double fillet,
    required Paint slotPaint,
    required Paint guidePaint,
  }) {
    final toeHalfSpan = branchWidth * 0.54;
    final openingHalfSpan = math.max(
      branchWidth * 0.5 - branchWall,
      branchWidth * 0.22,
    );
    final crownPaint = Paint()
      ..color = guidePaint.color.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round;
    final slotPath = Path()
      ..moveTo(centerX - openingHalfSpan, topY)
      ..quadraticBezierTo(
        centerX,
        topY + fillet * 0.22,
        centerX + openingHalfSpan,
        topY,
      );
    final crownLeft = Path()
      ..moveTo(centerX - toeHalfSpan, topY)
      ..quadraticBezierTo(
        centerX - branchWidth * 0.28,
        topY - fillet * 0.18,
        centerX - openingHalfSpan - 2,
        topY,
      );
    final crownRight = Path()
      ..moveTo(centerX + openingHalfSpan + 2, topY)
      ..quadraticBezierTo(
        centerX + branchWidth * 0.28,
        topY - fillet * 0.18,
        centerX + toeHalfSpan,
        topY,
      );
    canvas.drawPath(crownLeft, crownPaint);
    canvas.drawPath(crownRight, crownPaint);
    canvas.drawPath(
      slotPath,
      slotPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
    if (_isTechnical) {
      final toeGuide = Paint()
        ..color = guidePaint.color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9;
      canvas.drawLine(
        Offset(centerX - toeHalfSpan, topY - 4),
        Offset(centerX - toeHalfSpan + 8, topY + fillet * 0.3),
        toeGuide,
      );
      canvas.drawLine(
        Offset(centerX + toeHalfSpan, topY - 4),
        Offset(centerX + toeHalfSpan - 8, topY + fillet * 0.3),
        toeGuide,
      );
    }
  }

  void _drawSolidExtrusion(
    Canvas canvas, {
    required Rect frontRect,
    required Rect backRect,
    required Paint fillPaint,
    required Paint frontPaint,
    required Paint outlinePaint,
  }) {
    final topPlane = Path()
      ..moveTo(frontRect.left, frontRect.top)
      ..lineTo(frontRect.right, frontRect.top)
      ..lineTo(backRect.right, backRect.top)
      ..lineTo(backRect.left, backRect.top)
      ..close();
    final sidePlane = Path()
      ..moveTo(frontRect.right, frontRect.top)
      ..lineTo(frontRect.right, frontRect.bottom)
      ..lineTo(backRect.right, backRect.bottom)
      ..lineTo(backRect.right, backRect.top)
      ..close();
    canvas.drawPath(topPlane, fillPaint);
    canvas.drawPath(sidePlane, fillPaint);
    if (_isTechnical) {
      canvas.drawPath(topPlane, outlinePaint);
      canvas.drawPath(sidePlane, outlinePaint);
    }
    canvas.drawRect(backRect, fillPaint);
    canvas.drawRect(frontRect, frontPaint);
    canvas.drawRect(frontRect, outlinePaint);
  }

  void _drawCylinderHighlights(
    Canvas canvas, {
    required Offset axisStart,
    required Offset axisEnd,
    required Color color,
    bool vertical = false,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(axisStart.dx, axisStart.dy);
    if (vertical) {
      path.quadraticBezierTo(
        axisStart.dx + 5,
        (axisStart.dy + axisEnd.dy) / 2,
        axisEnd.dx,
        axisEnd.dy,
      );
    } else {
      path.quadraticBezierTo(
        (axisStart.dx + axisEnd.dx) / 2,
        axisStart.dy - 5,
        axisEnd.dx,
        axisEnd.dy,
      );
    }
    canvas.drawPath(path, paint);
  }

  void _drawCylinderArc(
    Canvas canvas, {
    required Rect rect,
    required Color color,
    bool vertical = false,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final path = Path();
    if (vertical) {
      path.addArc(rect, math.pi * 1.08, math.pi * 0.84);
    } else {
      path.addArc(rect, math.pi * 1.24, math.pi * 1.52);
    }
    canvas.drawPath(path, paint);
  }

  void _drawBandHatch(
    Canvas canvas, {
    required Rect rect,
    required Color color,
    bool vertical = false,
  }) {
    if (rect.width <= 1 || rect.height <= 1) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    const step = 12.0;
    canvas.save();
    canvas.clipRect(rect);
    if (vertical) {
      for (
        double y = rect.bottom + rect.width;
        y >= rect.top - rect.width;
        y -= step
      ) {
        canvas.drawLine(
          Offset(rect.left - 8, y),
          Offset(rect.right + 8, y - rect.width - 8),
          paint,
        );
      }
    } else {
      for (
        double x = rect.left - rect.height;
        x <= rect.right + rect.height;
        x += step
      ) {
        canvas.drawLine(
          Offset(x, rect.bottom + 6),
          Offset(x + rect.height + 8, rect.top - 6),
          paint,
        );
      }
    }
    canvas.restore();
  }

  void _drawFillets(
    Canvas canvas, {
    required double baseY,
    required double centerX,
    required double branchWidth,
    required double fillet,
    required Paint frontPaint,
    required Paint shadowPaint,
    required Offset shadowOffset,
    required Paint outlinePaint,
  }) {
    final left = Path()
      ..moveTo(centerX - (branchWidth / 2), baseY)
      ..lineTo(centerX - (branchWidth / 2) - fillet, baseY)
      ..lineTo(centerX - (branchWidth / 2), baseY + fillet)
      ..close();
    final right = Path()
      ..moveTo(centerX + (branchWidth / 2), baseY)
      ..lineTo(centerX + (branchWidth / 2) + fillet, baseY)
      ..lineTo(centerX + (branchWidth / 2), baseY + fillet)
      ..close();
    canvas.drawPath(left.shift(shadowOffset), shadowPaint);
    canvas.drawPath(right.shift(shadowOffset), shadowPaint);
    canvas.drawPath(left, frontPaint);
    canvas.drawPath(right, frontPaint);
    canvas.drawPath(left, outlinePaint);
    canvas.drawPath(right, outlinePaint);
  }

  void _drawSetInWeld(
    Canvas canvas, {
    required Rect runRect,
    required double centerX,
    required double branchWidth,
    required double topY,
    required double depth,
    required Paint frontPaint,
    required Paint shadowPaint,
    required Offset shadowOffset,
    required Paint outlinePaint,
  }) {
    final left = Path()
      ..moveTo(centerX - (branchWidth / 2), topY)
      ..lineTo(centerX - (branchWidth / 2) - depth * 0.55, topY)
      ..lineTo(centerX - (branchWidth / 2), topY + depth)
      ..close();
    final right = Path()
      ..moveTo(centerX + (branchWidth / 2), topY)
      ..lineTo(centerX + (branchWidth / 2) + depth * 0.55, topY)
      ..lineTo(centerX + (branchWidth / 2), topY + depth)
      ..close();
    final rootCap = Rect.fromCenter(
      center: Offset(centerX, topY + (depth * 0.45)),
      width: branchWidth * 0.74,
      height: depth * 0.42,
    );
    canvas.drawPath(left.shift(shadowOffset), shadowPaint);
    canvas.drawPath(right.shift(shadowOffset), shadowPaint);
    canvas.drawRect(rootCap.shift(shadowOffset), shadowPaint);
    canvas.drawPath(left, frontPaint);
    canvas.drawPath(right, frontPaint);
    canvas.drawRect(rootCap, frontPaint);
    canvas.drawPath(left, outlinePaint);
    canvas.drawPath(right, outlinePaint);
    canvas.drawRect(rootCap, outlinePaint);
  }

  void _drawOletWelds(
    Canvas canvas, {
    required Rect runRect,
    required double centerX,
    required double branchWidth,
    required double oletHeight,
    required double fillet,
    required Paint frontPaint,
    required Paint shadowPaint,
    required Offset shadowOffset,
    required Paint outlinePaint,
  }) {
    final toeSpan = branchWidth * 0.9;
    final left = Path()
      ..moveTo(centerX - toeSpan, runRect.top)
      ..lineTo(centerX - toeSpan - fillet, runRect.top)
      ..lineTo(centerX - toeSpan * 0.76, runRect.top - fillet * 0.72)
      ..close();
    final right = Path()
      ..moveTo(centerX + toeSpan, runRect.top)
      ..lineTo(centerX + toeSpan + fillet, runRect.top)
      ..lineTo(centerX + toeSpan * 0.76, runRect.top - fillet * 0.72)
      ..close();
    final top = Rect.fromCenter(
      center: Offset(centerX, runRect.top - oletHeight),
      width: branchWidth * 0.58,
      height: fillet * 0.58,
    );
    canvas.drawPath(left.shift(shadowOffset), shadowPaint);
    canvas.drawPath(right.shift(shadowOffset), shadowPaint);
    canvas.drawRect(top.shift(shadowOffset), shadowPaint);
    canvas.drawPath(left, frontPaint);
    canvas.drawPath(right, frontPaint);
    canvas.drawRect(top, frontPaint);
    canvas.drawPath(left, outlinePaint);
    canvas.drawPath(right, outlinePaint);
    canvas.drawRect(top, outlinePaint);
  }

  void _drawCenterLines(
    Canvas canvas,
    Size size,
    Rect runRect,
    double centerX,
    Paint guidePaint,
  ) {
    final dashPaint = Paint()
      ..color = guidePaint.color.withValues(alpha: 0.78)
      ..strokeWidth = guidePaint.strokeWidth
      ..style = PaintingStyle.stroke;
    _dashedLine(
      canvas,
      Offset(centerX, 26),
      Offset(centerX, size.height - 26),
      dashPaint,
    );
    _dashedLine(
      canvas,
      Offset(32, runRect.center.dy),
      Offset(size.width - 32, runRect.center.dy),
      dashPaint,
    );
  }

  void _drawLabels(
    Canvas canvas,
    Size size,
    Rect runRect,
    double centerX,
    Rect branchRect,
    double runWall,
    double branchWall,
    double projection,
    double fillet,
    double setInDepth,
    double repadThickness,
    double oletHeight,
  ) {
    _verticalDimension(
      canvas,
      x: runRect.left - 64,
      y1: runRect.top,
      y2: runRect.bottom,
      label: '${data.runOdMm.toStringAsFixed(1)} mm run OD',
    );
    _verticalDimension(
      canvas,
      x: runRect.left - 24,
      y1: runRect.top,
      y2: runRect.top + runWall,
      label: '${data.runThicknessMm.toStringAsFixed(1)} mm t',
      compact: true,
    );
    _horizontalDimension(
      canvas,
      x1: branchRect.left,
      x2: branchRect.right,
      y: math.max(92, branchRect.top - 36),
      label: '${data.branchOdMm.toStringAsFixed(1)} mm branch OD',
    );
    _verticalDimension(
      canvas,
      x: runRect.right + 34,
      y1: branchRect.top,
      y2: runRect.top,
      label: '${data.projectionMm.toStringAsFixed(0)} mm projection',
    );
    _leaderLabel(
      canvas,
      anchor: Offset(
        branchRect.left - fillet * 0.55,
        runRect.top + fillet * 0.7,
      ),
      labelOffset: const Offset(-152, -22),
      text: '${data.filletSizeMm.toStringAsFixed(0)} mm fillet',
    );

    switch (connectionType) {
      case BranchConnectionType.setOnNozzle:
        if (data.repadThicknessMm > 0) {
          _leaderLabel(
            canvas,
            anchor: Offset(
              centerX + branchRect.width * 0.7,
              runRect.top - repadThickness / 2,
            ),
            labelOffset: const Offset(58, -8),
            text: '${data.repadThicknessMm.toStringAsFixed(0)} mm repad t',
          );
        }
      case BranchConnectionType.setInNozzle:
        _leaderLabel(
          canvas,
          anchor: Offset(
            branchRect.right + branchWall * 0.5,
            runRect.top + setInDepth,
          ),
          labelOffset: const Offset(30, -8),
          text: '${data.setInDepthMm.toStringAsFixed(0)} mm set-in',
        );
      case BranchConnectionType.weldolet:
        _leaderLabel(
          canvas,
          anchor: Offset(
            centerX + branchRect.width * 0.64,
            runRect.top - oletHeight,
          ),
          labelOffset: const Offset(34, -14),
          text: '${data.oletHeightMm.toStringAsFixed(0)} mm olet h',
        );
    }

    _drawSoftTag(
      canvas,
      Offset(size.width * 0.5 - 120, 18),
      240,
      connectionType.label,
      emphasized: true,
    );
  }

  void _verticalDimension(
    Canvas canvas, {
    required double x,
    required double y1,
    required double y2,
    required String label,
    bool compact = false,
  }) {
    final paint = Paint()
      ..color = _guide
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    canvas.drawLine(Offset(x, y1), Offset(x + 10, y1), paint);
    canvas.drawLine(Offset(x, y2), Offset(x + 10, y2), paint);
    _arrowHead(canvas, Offset(x, y1), const Offset(0, -1), paint);
    _arrowHead(canvas, Offset(x, y2), const Offset(0, 1), paint);
    _drawSoftTag(
      canvas,
      Offset(x - (compact ? 48 : 74), ((y1 + y2) / 2) - 16),
      compact ? 98 : 148,
      label,
    );
  }

  void _horizontalDimension(
    Canvas canvas, {
    required double x1,
    required double x2,
    required double y,
    required String label,
  }) {
    final paint = Paint()
      ..color = _guide
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
    canvas.drawLine(Offset(x1, y), Offset(x1, y + 10), paint);
    canvas.drawLine(Offset(x2, y), Offset(x2, y + 10), paint);
    _arrowHead(canvas, Offset(x1, y), const Offset(-1, 0), paint);
    _arrowHead(canvas, Offset(x2, y), const Offset(1, 0), paint);
    _drawSoftTag(canvas, Offset(((x1 + x2) / 2) - 78, y - 34), 156, label);
  }

  void _leaderLabel(
    Canvas canvas, {
    required Offset anchor,
    required Offset labelOffset,
    required String text,
  }) {
    final target = anchor + labelOffset;
    final paint = Paint()
      ..color = _guide
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(anchor, target + const Offset(10, 16), paint);
    canvas.drawCircle(anchor, 3.6, Paint()..color = _guide);
    _drawSoftTag(canvas, target, 136, text);
  }

  void _drawSoftTag(
    Canvas canvas,
    Offset offset,
    double width,
    String text, {
    bool emphasized = false,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, emphasized ? 34 : 30),
      Radius.circular(emphasized ? 16 : 14),
    );
    final fillPaint = Paint()
      ..color = emphasized
          ? Colors.white
          : _paper.withValues(alpha: _isTechnical ? 0.94 : 0.88);
    final strokePaint = Paint()
      ..color = _paperEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, strokePaint);

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _label,
          fontSize: emphasized ? 15 : 12.6,
          fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: emphasized ? 1 : 2,
      ellipsis: '...',
    )..layout(maxWidth: width - 18);
    painter.paint(
      canvas,
      Offset(
        offset.dx + ((width - painter.width) / 2),
        offset.dy + (((emphasized ? 34 : 30) - painter.height) / 2),
      ),
    );
  }

  void _dashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final delta = end - start;
    final distance = delta.distance;
    final direction = delta / distance;
    const dash = 8.0;
    const gap = 6.0;
    double current = 0;
    while (current < distance) {
      final next = math.min(current + dash, distance);
      canvas.drawLine(
        start + (direction * current),
        start + (direction * next),
        paint,
      );
      current += dash + gap;
    }
  }

  void _arrowHead(Canvas canvas, Offset point, Offset direction, Paint paint) {
    final unit = direction / direction.distance;
    final perp = Offset(-unit.dy, unit.dx);
    final a = point - (unit * 8) + (perp * 4);
    final b = point - (unit * 8) - (perp * 4);
    canvas.drawLine(point, a, paint);
    canvas.drawLine(point, b, paint);
  }

  @override
  bool shouldRepaint(covariant _BranchConnectionPainter oldDelegate) =>
      oldDelegate.connectionType != connectionType ||
      oldDelegate.drawingMode != drawingMode ||
      oldDelegate.data != data;
}
