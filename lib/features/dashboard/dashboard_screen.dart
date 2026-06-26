import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/scan_history_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.localeCode,
    required this.scanHistoryStore,
    required this.userName,
    required this.onOpenDocuments,
    required this.onOpenHistory,
    required this.onOpenScanner,
    super.key,
  });

  final String localeCode;
  final ScanHistoryStore scanHistoryStore;
  final String userName;
  final VoidCallback onOpenDocuments;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenScanner;

  bool get _isFrench => localeCode == 'fr';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isFrench ? 'Dashboard BI' : 'BI Dashboard')),
      body: AppBackdrop(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: scanHistoryStore,
            builder: (context, _) {
              final entries = scanHistoryStore.entries
                  .where((entry) => !entry.isDeleted)
                  .toList(growable: false);
              final total = entries.length;
              final translatedCount = entries
                  .where(
                    (entry) =>
                        entry.status == 'translated' ||
                        (entry.targetLanguageCode?.trim().isNotEmpty ?? false),
                  )
                  .length;
              final archivedCount = entries
                  .where((entry) => entry.isArchived)
                  .length;
              final averageConfidence = _averageConfidence(entries);
              final languages = _languageCounts(entries);
              final documentTypes = _typeCounts(entries);
              final weeklyVolumes = _weeklyVolumes(entries);
              final translatedRate = total == 0 ? 0.0 : translatedCount / total;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  AppPanel(
                    gradient: AppThemePalette.heroGradient(
                      theme.brightness == Brightness.dark,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isFrench
                                    ? 'Pilotage documentaire'
                                    : 'Document command center',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _isFrench
                                    ? 'Bonjour $userName, suivez en direct vos volumes, vos langues, la qualite OCR et l activite recente.'
                                    : 'Hi $userName, monitor live volume, languages, OCR quality and recent activity.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.description_outlined,
                          accent: AppThemePalette.primary,
                          label: _isFrench
                              ? 'Documents traites'
                              : 'Processed docs',
                          value: '$total',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.language_rounded,
                          accent: AppThemePalette.secondary,
                          label: _isFrench ? 'Langues detectees' : 'Languages',
                          value: '${languages.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.verified_rounded,
                          accent: AppThemePalette.success,
                          label: _isFrench ? 'Precision OCR' : 'OCR accuracy',
                          value: averageConfidence == null
                              ? '95%'
                              : '${(averageConfidence * 100).toStringAsFixed(1)}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.auto_awesome_rounded,
                          accent: AppThemePalette.warning,
                          label: _isFrench
                              ? 'Taux traduit'
                              : 'Translation rate',
                          value:
                              '${(translatedRate * 100).toStringAsFixed(0)}%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isFrench
                                    ? 'Volume des 7 derniers jours'
                                    : 'Volume over the last 7 days',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 140,
                                child: _MiniTrendChart(values: weeklyVolumes),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isFrench
                                    ? 'Taux de traduction'
                                    : 'Translation rate',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: translatedRate,
                                        strokeWidth: 12,
                                        backgroundColor: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${(translatedRate * 100).toStringAsFixed(0)}%',
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _isFrench
                                                ? 'traduits'
                                                : 'translated',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _isFrench
                                    ? '$archivedCount document(s) deja archives.'
                                    : '$archivedCount document(s) already archived.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFrench
                              ? 'Langues les plus utilisees'
                              : 'Most used languages',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        if (languages.isEmpty)
                          Text(
                            _isFrench
                                ? 'Les langues apparaitront ici apres les premiers traitements.'
                                : 'Languages will appear here after your first processed documents.',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          ...languages.entries
                              .take(5)
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _HorizontalStatBar(
                                    label: entry.key.toUpperCase(),
                                    value: entry.value,
                                    total: math.max(1, total),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFrench ? 'Types de documents' : 'Document types',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        if (documentTypes.isEmpty)
                          Text(
                            _isFrench
                                ? 'Aucune repartition disponible pour le moment.'
                                : 'No type distribution available yet.',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: documentTypes.entries
                                .take(6)
                                .map((entry) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      '${entry.key} · ${entry.value}',
                                      style: theme.textTheme.labelLarge,
                                    ),
                                  );
                                })
                                .toList(growable: false),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFrench ? 'Actions rapides' : 'Quick actions',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onOpenDocuments,
                                icon: const Icon(Icons.folder_copy_rounded),
                                label: Text(
                                  _isFrench ? 'Documents' : 'Documents',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onOpenHistory,
                                icon: const Icon(Icons.history_rounded),
                                label: Text(
                                  _isFrench ? 'Historique' : 'History',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: onOpenScanner,
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: Text(
                            _isFrench
                                ? 'Scanner un nouveau document'
                                : 'Scan a new document',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFrench ? 'Activite recente' : 'Recent activity',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        if (entries.isEmpty)
                          Text(
                            _isFrench
                                ? 'Aucune activite recente.'
                                : 'No recent activity yet.',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          ...entries
                              .take(5)
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: AppThemePalette.primary
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.description_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${entry.documentTypeLabel} · ${entry.detectedLanguages.join(' / ').toUpperCase()}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(entry.createdAtIso),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double? _averageConfidence(List<ScanHistoryEntry> entries) {
    final values = entries
        .map((entry) => entry.ocrConfidence)
        .whereType<double>()
        .toList(growable: false);
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Map<String, int> _languageCounts(List<ScanHistoryEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      for (final code in entry.detectedLanguages) {
        final normalized = code.trim().toLowerCase();
        if (normalized.isEmpty || normalized == 'unknown') continue;
        counts.update(normalized, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final entry in sorted) entry.key: entry.value};
  }

  Map<String, int> _typeCounts(List<ScanHistoryEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      counts.update(
        entry.documentTypeLabel,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final entry in sorted) entry.key: entry.value};
  }

  List<int> _weeklyVolumes(List<ScanHistoryEntry> entries) {
    final now = DateTime.now();
    final volumes = List<int>.filled(7, 0);
    for (final entry in entries) {
      final createdAt = DateTime.tryParse(entry.createdAtIso);
      if (createdAt == null) continue;
      final diff = now.difference(createdAt).inDays;
      if (diff < 0 || diff > 6) continue;
      volumes[6 - diff] += 1;
    }
    return volumes;
  }

  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 16),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HorizontalStatBar extends StatelessWidget {
  const _HorizontalStatBar({
    required this.label,
    required this.value,
    required this.total,
  });

  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = value / total;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: theme.textTheme.labelLarge),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}

class _MiniTrendChart extends StatelessWidget {
  const _MiniTrendChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _TrendPainter(
        values: values,
        lineColor: theme.colorScheme.primary,
        fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        gridColor: theme.colorScheme.outlineVariant,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<int> values;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.isEmpty ? 1 : math.max(1, values.reduce(math.max));
    final spacing = values.length <= 1
        ? size.width
        : size.width / (values.length - 1);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final fill = Path();
    for (var i = 0; i < values.length; i++) {
      final x = spacing * i;
      final y = size.height - ((values[i] / maxValue) * (size.height - 12)) - 6;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    if (values.isNotEmpty) {
      fill.lineTo(size.width, size.height);
      fill.close();
    }

    canvas.drawPath(
      fill,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}
