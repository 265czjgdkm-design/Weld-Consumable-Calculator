import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/guide_content.dart';
import '../l10n/premium_account_copy.dart';

const _guideIcons = {
  'start': Icons.flag_outlined,
  'filler': Icons.calculate_outlined,
  'preheat': Icons.device_thermostat_outlined,
  'cooling': Icons.ac_unit_outlined,
  'heatinput': Icons.bolt_outlined,
  'library': Icons.construction_outlined,
  'presets': Icons.bookmark_outline,
  'pdf': Icons.picture_as_pdf_outlined,
  'ai': Icons.smart_toy_outlined,
  'premium': Icons.workspace_premium_outlined,
  'account': Icons.account_circle_outlined,
  'faq': Icons.help_outline,
};

/// Offline, searchable user guide. [initialSectionId] (one of
/// [guideSectionIds]) opens and scrolls to that section.
class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({super.key, this.initialSectionId});

  final String? initialSectionId;

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  final _searchController = TextEditingController();
  final _sectionKeys = {for (final id in guideSectionIds) id: GlobalKey()};
  String _query = '';

  @override
  void initState() {
    super.initState();
    final id = widget.initialSectionId;
    if (id != null && _sectionKeys.containsKey(id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _sectionKeys[id]!.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 250),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = guideCopyFor(AppLocaleScope.of(context).language);
    final query = _query.trim().toLowerCase();
    final visible = [
      for (final id in guideSectionIds)
        if (query.isEmpty ||
            copy.sections[id]!.title.toLowerCase().contains(query) ||
            copy.sections[id]!.body.toLowerCase().contains(query))
          id,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(copy.screenTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: copy.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 14),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(copy.noResults)),
                ),
              for (final id in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GuideSectionCard(
                    key: _sectionKeys[id],
                    sectionId: id,
                    entry: copy.sections[id]!,
                    initiallyExpanded:
                        id == widget.initialSectionId || query.isNotEmpty,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideSectionCard extends StatelessWidget {
  const _GuideSectionCard({
    super.key,
    required this.sectionId,
    required this.entry,
    required this.initiallyExpanded,
  });

  final String sectionId;
  final GuideEntry entry;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // Re-keyed on the expanded flag so a search (or deep link) opens
          // the tile even though ExpansionTile only reads it initially.
          key: PageStorageKey('$sectionId-$initiallyExpanded'),
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF12191B),
            ),
            child: Icon(
              _guideIcons[sectionId],
              size: 20,
              color: const Color(0xFFFF6A35),
            ),
          ),
          title: Text(entry.title, style: theme.textTheme.titleMedium),
          children: [
            for (final paragraph in entry.body.split('\n\n'))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(paragraph, style: theme.textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small "How to use?" text link placed at the top of a calculator; opens
/// the guide at [sectionId].
class GuideHowToLink extends StatelessWidget {
  const GuideHowToLink({super.key, required this.sectionId});

  final String sectionId;

  @override
  Widget build(BuildContext context) {
    final language = AppLocaleScope.of(context).language;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF6A35),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.help_outline, size: 18),
        label: Text(premiumAccountCopyFor(language).howToUse),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserGuideScreen(initialSectionId: sectionId),
          ),
        ),
      ),
    );
  }
}
