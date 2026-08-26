import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../models/custom_material_models.dart';
import '../services/custom_base_material_store.dart';
import 'widgets/optional_number_field.dart';

/// Standalone library of user-defined base materials (name, designation,
/// sheet thickness, producer data, chemical composition, notes). Not wired
/// into the calculator's own inputs/dropdowns yet -- that integration is an
/// explicitly deferred follow-up. Chemical composition / CET / Pcm are
/// captured as raw data only -- no carbon-equivalent calculation is done
/// here, that's a separate future task pending formula research.
class BaseMaterialScreen extends StatefulWidget {
  const BaseMaterialScreen({super.key});

  @override
  State<BaseMaterialScreen> createState() => _BaseMaterialScreenState();
}

class _BaseMaterialScreenState extends State<BaseMaterialScreen> {
  static const _store = CustomBaseMaterialStore();

  List<CustomBaseMaterial> _materials = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final materials = await _store.load();
      if (!mounted) return;
      setState(() => _materials = materials);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addMaterial() async {
    final result = await showDialog<_BaseMaterialFormResult>(
      context: context,
      builder: (context) => const _BaseMaterialFormDialog(),
    );
    if (result == null) return;

    final material = CustomBaseMaterial(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: result.name,
      designation: result.designation,
      notes: result.notes,
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      sheetThicknessMm: result.sheetThicknessMm,
      minSheetThicknessMm: result.minSheetThicknessMm,
      maxSheetThicknessMm: result.maxSheetThicknessMm,
      producerName: result.producerName,
      materialId: result.materialId,
      carbonPercent: result.carbonPercent,
      siliconPercent: result.siliconPercent,
      manganesePercent: result.manganesePercent,
      chromiumPercent: result.chromiumPercent,
      molybdenumPercent: result.molybdenumPercent,
      copperPercent: result.copperPercent,
      vanadiumPercent: result.vanadiumPercent,
      niobiumPercent: result.niobiumPercent,
      titaniumPercent: result.titaniumPercent,
      boronPercent: result.boronPercent,
      nitrogenPercent: result.nitrogenPercent,
      cetPercent: result.cetPercent,
      pcmPercent: result.pcmPercent,
    );
    final materials = [material, ..._materials];
    await _store.save(materials);
    if (!mounted) return;
    setState(() => _materials = materials);
  }

  Future<void> _editMaterial(CustomBaseMaterial material) async {
    final result = await showDialog<_BaseMaterialFormResult>(
      context: context,
      builder: (context) => _BaseMaterialFormDialog(initial: material),
    );
    if (result == null) return;

    // Not copyWith: several new fields are nullable and the form must be
    // able to clear them, but copyWith's `field ?? this.field` pattern
    // can't tell "not provided" apart from "explicitly cleared to null".
    final updated = CustomBaseMaterial(
      id: material.id,
      name: result.name,
      designation: result.designation,
      notes: result.notes,
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      sheetThicknessMm: result.sheetThicknessMm,
      minSheetThicknessMm: result.minSheetThicknessMm,
      maxSheetThicknessMm: result.maxSheetThicknessMm,
      producerName: result.producerName,
      materialId: result.materialId,
      carbonPercent: result.carbonPercent,
      siliconPercent: result.siliconPercent,
      manganesePercent: result.manganesePercent,
      chromiumPercent: result.chromiumPercent,
      molybdenumPercent: result.molybdenumPercent,
      copperPercent: result.copperPercent,
      vanadiumPercent: result.vanadiumPercent,
      niobiumPercent: result.niobiumPercent,
      titaniumPercent: result.titaniumPercent,
      boronPercent: result.boronPercent,
      nitrogenPercent: result.nitrogenPercent,
      cetPercent: result.cetPercent,
      pcmPercent: result.pcmPercent,
    );
    final materials = _materials
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
    await _store.save(materials);
    if (!mounted) return;
    setState(() => _materials = materials);
  }

  Future<void> _deleteMaterial(CustomBaseMaterial material) async {
    final strings = AppLocaleScope.stringsOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.baseMaterialDeleteConfirmTitle),
        content: Text(
          strings.baseMaterialDeleteConfirmBody.replaceFirst(
            '{name}',
            material.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final materials = _materials.where((item) => item.id != material.id).toList();
    await _store.save(materials);
    if (!mounted) return;
    setState(() => _materials = materials);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.baseMaterialTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMaterial,
        icon: const Icon(Icons.add),
        label: Text(strings.baseMaterialAddButton),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _materials.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  strings.baseMaterialEmptyState,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF607482),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
              itemCount: _materials.length,
              itemBuilder: (context, index) {
                final material = _materials[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    title: Text(
                      material.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: material.designation.isEmpty
                        ? null
                        : Text(material.designation),
                    onTap: () => _editMaterial(material),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editMaterial(material),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: strings.commonEdit,
                        ),
                        IconButton(
                          onPressed: () => _deleteMaterial(material),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: strings.commonDelete,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _BaseMaterialFormResult {
  const _BaseMaterialFormResult({
    required this.name,
    required this.designation,
    required this.notes,
    required this.sheetThicknessMm,
    required this.minSheetThicknessMm,
    required this.maxSheetThicknessMm,
    required this.producerName,
    required this.materialId,
    required this.carbonPercent,
    required this.siliconPercent,
    required this.manganesePercent,
    required this.chromiumPercent,
    required this.molybdenumPercent,
    required this.copperPercent,
    required this.vanadiumPercent,
    required this.niobiumPercent,
    required this.titaniumPercent,
    required this.boronPercent,
    required this.nitrogenPercent,
    required this.cetPercent,
    required this.pcmPercent,
  });

  final String name;
  final String designation;
  final String notes;
  final double? sheetThicknessMm;
  final double? minSheetThicknessMm;
  final double? maxSheetThicknessMm;
  final String? producerName;
  final String? materialId;
  final double? carbonPercent;
  final double? siliconPercent;
  final double? manganesePercent;
  final double? chromiumPercent;
  final double? molybdenumPercent;
  final double? copperPercent;
  final double? vanadiumPercent;
  final double? niobiumPercent;
  final double? titaniumPercent;
  final double? boronPercent;
  final double? nitrogenPercent;
  final double? cetPercent;
  final double? pcmPercent;
}

/// The 11 chemical composition elements captured by this form, in the
/// order the reference app groups them. Each key maps to a controller and
/// (via [_elementLabel]/[_elementValueOf]) a string label and model field.
const _elementKeys = [
  'carbon',
  'silicon',
  'manganese',
  'chromium',
  'molybdenum',
  'copper',
  'vanadium',
  'niobium',
  'titanium',
  'boron',
  'nitrogen',
];

String _elementLabel(L10nStrings strings, String key) => switch (key) {
  'carbon' => strings.materialFieldCarbon,
  'silicon' => strings.materialFieldSilicon,
  'manganese' => strings.materialFieldManganese,
  'chromium' => strings.materialFieldChromium,
  'molybdenum' => strings.materialFieldMolybdenum,
  'copper' => strings.materialFieldCopper,
  'vanadium' => strings.materialFieldVanadium,
  'niobium' => strings.materialFieldNiobium,
  'titanium' => strings.materialFieldTitanium,
  'boron' => strings.materialFieldBoron,
  'nitrogen' => strings.materialFieldNitrogen,
  _ => throw ArgumentError('Unknown element key: $key'),
};

double? _elementValueOf(CustomBaseMaterial? material, String key) =>
    switch (key) {
      'carbon' => material?.carbonPercent,
      'silicon' => material?.siliconPercent,
      'manganese' => material?.manganesePercent,
      'chromium' => material?.chromiumPercent,
      'molybdenum' => material?.molybdenumPercent,
      'copper' => material?.copperPercent,
      'vanadium' => material?.vanadiumPercent,
      'niobium' => material?.niobiumPercent,
      'titanium' => material?.titaniumPercent,
      'boron' => material?.boronPercent,
      'nitrogen' => material?.nitrogenPercent,
      _ => throw ArgumentError('Unknown element key: $key'),
    };

/// A percent field (chemical composition, CET, Pcm) must be between 0 and
/// 100 if provided -- these feed carbon-equivalent formulas in a future
/// task, so garbage here becomes silently wrong engineering output later.
String? _percentFieldError(L10nStrings strings, OptionalNumberParseResult result) {
  if (result.invalid) return strings.materialFieldInvalidNumber;
  final value = result.value;
  if (value != null && (value < 0 || value > 100)) {
    return strings.materialFieldOutOfRange;
  }
  return null;
}

/// A sheet thickness must be a positive number if provided -- zero or
/// negative is physically meaningless.
String? _positiveFieldError(L10nStrings strings, OptionalNumberParseResult result) {
  if (result.invalid) return strings.materialFieldInvalidNumber;
  final value = result.value;
  if (value != null && value <= 0) {
    return strings.materialFieldOutOfRange;
  }
  return null;
}

/// Owns its own [TextEditingController]s as a StatefulWidget field, disposed
/// by the framework at the right point in this dialog route's own teardown
/// -- see calculator_page.dart's `_PresetNameDialog` for why disposing them
/// right after `showDialog` returns crashes Flutter web.
class _BaseMaterialFormDialog extends StatefulWidget {
  const _BaseMaterialFormDialog({this.initial});

  final CustomBaseMaterial? initial;

  @override
  State<_BaseMaterialFormDialog> createState() =>
      _BaseMaterialFormDialogState();
}

class _BaseMaterialFormDialogState extends State<_BaseMaterialFormDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late final TextEditingController _designationController =
      TextEditingController(text: widget.initial?.designation ?? '');
  late final TextEditingController _notesController = TextEditingController(
    text: widget.initial?.notes ?? '',
  );
  late final TextEditingController _thicknessController =
      TextEditingController(
        text: widget.initial?.sheetThicknessMm?.toString() ?? '',
      );
  late final TextEditingController _thicknessMinController =
      TextEditingController(
        text: widget.initial?.minSheetThicknessMm?.toString() ?? '',
      );
  late final TextEditingController _thicknessMaxController =
      TextEditingController(
        text: widget.initial?.maxSheetThicknessMm?.toString() ?? '',
      );
  late final TextEditingController _producerNameController =
      TextEditingController(text: widget.initial?.producerName ?? '');
  late final TextEditingController _materialIdController =
      TextEditingController(text: widget.initial?.materialId ?? '');
  late final TextEditingController _cetController = TextEditingController(
    text: widget.initial?.cetPercent?.toString() ?? '',
  );
  late final TextEditingController _pcmController = TextEditingController(
    text: widget.initial?.pcmPercent?.toString() ?? '',
  );
  late final Map<String, TextEditingController> _elementControllers = {
    for (final key in _elementKeys)
      key: TextEditingController(
        text: _elementValueOf(widget.initial, key)?.toString() ?? '',
      ),
  };

  String? _nameError;
  String? _thicknessError;
  String? _thicknessMinError;
  String? _thicknessMaxError;
  String? _cetError;
  String? _pcmError;
  Map<String, String?> _elementErrors = const {};

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _notesController.dispose();
    _thicknessController.dispose();
    _thicknessMinController.dispose();
    _thicknessMaxController.dispose();
    _producerNameController.dispose();
    _materialIdController.dispose();
    _cetController.dispose();
    _pcmController.dispose();
    for (final controller in _elementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final strings = AppLocaleScope.stringsOf(context);
    final name = _nameController.text.trim();

    final thickness = parseOptionalNumberField(_thicknessController.text);
    final thicknessMin = parseOptionalNumberField(
      _thicknessMinController.text,
    );
    final thicknessMax = parseOptionalNumberField(
      _thicknessMaxController.text,
    );
    final cet = parseOptionalNumberField(_cetController.text);
    final pcm = parseOptionalNumberField(_pcmController.text);
    final elementResults = {
      for (final entry in _elementControllers.entries)
        entry.key: parseOptionalNumberField(entry.value.text),
    };

    final thicknessRangeInvalid =
        !thicknessMin.invalid &&
        !thicknessMax.invalid &&
        thicknessMin.value != null &&
        thicknessMax.value != null &&
        thicknessMin.value! > thicknessMax.value!;

    final thicknessError = _positiveFieldError(strings, thickness);
    final thicknessMinFieldError = _positiveFieldError(strings, thicknessMin);
    final thicknessMaxFieldError = _positiveFieldError(strings, thicknessMax);
    final thicknessMinError =
        thicknessMinFieldError ??
        (thicknessRangeInvalid ? strings.materialFieldOutOfRange : null);
    final thicknessMaxError =
        thicknessMaxFieldError ??
        (thicknessRangeInvalid ? strings.materialFieldOutOfRange : null);
    final cetError = _percentFieldError(strings, cet);
    final pcmError = _percentFieldError(strings, pcm);
    final elementFieldErrors = {
      for (final entry in elementResults.entries)
        entry.key: _percentFieldError(strings, entry.value),
    };
    final elementErrors = {
      for (final entry in elementFieldErrors.entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    final invalid =
        name.isEmpty ||
        thicknessError != null ||
        thicknessMinError != null ||
        thicknessMaxError != null ||
        cetError != null ||
        pcmError != null ||
        elementErrors.isNotEmpty;

    setState(() {
      _nameError = name.isEmpty ? strings.commonNameRequired : null;
      _thicknessError = thicknessError;
      _thicknessMinError = thicknessMinError;
      _thicknessMaxError = thicknessMaxError;
      _cetError = cetError;
      _pcmError = pcmError;
      _elementErrors = elementErrors;
    });
    if (invalid) return;

    final producerName = _producerNameController.text.trim();
    final materialId = _materialIdController.text.trim();

    Navigator.of(context).pop(
      _BaseMaterialFormResult(
        name: name,
        designation: _designationController.text.trim(),
        notes: _notesController.text.trim(),
        sheetThicknessMm: thickness.value,
        minSheetThicknessMm: thicknessMin.value,
        maxSheetThicknessMm: thicknessMax.value,
        producerName: producerName.isEmpty ? null : producerName,
        materialId: materialId.isEmpty ? null : materialId,
        carbonPercent: elementResults['carbon']!.value,
        siliconPercent: elementResults['silicon']!.value,
        manganesePercent: elementResults['manganese']!.value,
        chromiumPercent: elementResults['chromium']!.value,
        molybdenumPercent: elementResults['molybdenum']!.value,
        copperPercent: elementResults['copper']!.value,
        vanadiumPercent: elementResults['vanadium']!.value,
        niobiumPercent: elementResults['niobium']!.value,
        titaniumPercent: elementResults['titanium']!.value,
        boronPercent: elementResults['boron']!.value,
        nitrogenPercent: elementResults['nitrogen']!.value,
        cetPercent: cet.value,
        pcmPercent: pcm.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(
        isEdit ? strings.commonEdit : strings.baseMaterialAddButton,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: strings.baseMaterialFieldName,
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _designationController,
              decoration: InputDecoration(
                labelText: strings.baseMaterialFieldDesignation,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(labelText: strings.baseMaterialFieldNotes),
            ),
            const Divider(height: 32),
            Text(
              strings.baseMaterialSectionThickness,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OptionalNumberField(
                  controller: _thicknessController,
                  label: strings.baseMaterialFieldThickness,
                  errorText: _thicknessError,
                  width: 150,
                ),
                OptionalNumberField(
                  controller: _thicknessMinController,
                  label: strings.baseMaterialFieldThicknessMin,
                  errorText: _thicknessMinError,
                  width: 150,
                ),
                OptionalNumberField(
                  controller: _thicknessMaxController,
                  label: strings.baseMaterialFieldThicknessMax,
                  errorText: _thicknessMaxError,
                  width: 150,
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              strings.materialSectionProducer,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _producerNameController,
              decoration: InputDecoration(
                labelText: strings.materialFieldProducerName,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _materialIdController,
              decoration: InputDecoration(
                labelText: strings.materialFieldMaterialId,
              ),
            ),
            const Divider(height: 32),
            Text(
              strings.materialSectionComposition,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final key in _elementKeys)
                  OptionalNumberField(
                    controller: _elementControllers[key]!,
                    label: _elementLabel(strings, key),
                    errorText: _elementErrors[key],
                    width: 130,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              strings.materialCompositionOrDivider,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF607482)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OptionalNumberField(
                  controller: _cetController,
                  label: strings.materialFieldCet,
                  errorText: _cetError,
                  width: 150,
                ),
                OptionalNumberField(
                  controller: _pcmController,
                  label: strings.materialFieldPcm,
                  errorText: _pcmError,
                  width: 150,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(strings.commonSave)),
      ],
    );
  }
}
