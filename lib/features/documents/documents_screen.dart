import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/scan_history_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surfaces.dart';

enum _DocumentScope { all, active, favorites, archived, trash }

enum _DocumentViewMode { list, board }

enum _DocumentSortMode { newest, name, status, confidence }

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({
    required this.localeCode,
    required this.scanHistoryStore,
    required this.onOpenResultRequested,
    required this.onOpenScanner,
    super.key,
  });

  final String localeCode;
  final ScanHistoryStore scanHistoryStore;
  final ValueChanged<ScanHistoryEntry> onOpenResultRequested;
  final VoidCallback onOpenScanner;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _DocumentScope _scope = _DocumentScope.all;
  _DocumentViewMode _viewMode = _DocumentViewMode.list;
  _DocumentSortMode _sortMode = _DocumentSortMode.newest;
  String _selectedFolder = 'all';
  String _selectedStatus = 'all';
  String get _lc => widget.localeCode;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _title() {
    switch (_lc) {
      case 'en':
        return 'Documents';
      case 'ar':
        return 'المستندات';
      default:
        return 'Documents';
    }
  }

  String _heroTitle() {
    switch (_lc) {
      case 'en':
        return 'Structured document workspace';
      case 'ar':
        return 'مساحة مستندات منظمة';
      default:
        return 'Espace documents organise';
    }
  }

  String _heroSubtitle() {
    switch (_lc) {
      case 'en':
        return 'Search, classify, archive and reopen every processed document from one central library.';
      case 'ar':
        return 'ابحث ونظم وأرشف وأعد فتح كل مستند من مكتبة مركزية واحدة.';
      default:
        return 'Recherchez, classez, archivez et rouvrez chaque document depuis une bibliotheque centrale.';
    }
  }

  String _searchHint() {
    switch (_lc) {
      case 'en':
        return 'Search by file name, tag, text or folder';
      case 'ar':
        return 'ابحث بالاسم أو الوسوم أو النص أو المجلد';
      default:
        return 'Rechercher par nom, tag, texte ou dossier';
    }
  }

  String _folderTitle() {
    switch (_lc) {
      case 'en':
        return 'Folders';
      case 'ar':
        return 'المجلدات';
      default:
        return 'Dossiers';
    }
  }

  String _detailTitle() {
    switch (_lc) {
      case 'en':
        return 'Document detail';
      case 'ar':
        return 'تفاصيل المستند';
      default:
        return 'Detail du document';
    }
  }

  String _metadataTitle() {
    switch (_lc) {
      case 'en':
        return 'Metadata';
      case 'ar':
        return 'البيانات الوصفية';
      default:
        return 'Metadonnees';
    }
  }

  String _versionsTitle() {
    switch (_lc) {
      case 'en':
        return 'Versions';
      case 'ar':
        return 'الإصدارات';
      default:
        return 'Versions';
    }
  }

  String _activityTitle() {
    switch (_lc) {
      case 'en':
        return 'Action history';
      case 'ar':
        return 'سجل العمليات';
      default:
        return 'Historique des actions';
    }
  }

  String _notesTitle() {
    switch (_lc) {
      case 'en':
        return 'Notes';
      case 'ar':
        return 'ملاحظات';
      default:
        return 'Notes';
    }
  }

  String _openResultLabel() {
    switch (_lc) {
      case 'en':
        return 'Open detailed result';
      case 'ar':
        return 'فتح النتيجة التفصيلية';
      default:
        return 'Ouvrir le resultat detaille';
    }
  }

  String _copyExtractedTextLabel() {
    switch (_lc) {
      case 'en':
        return 'Copy extracted text';
      case 'ar':
        return 'نسخ النص المستخرج';
      default:
        return 'Copier le texte extrait';
    }
  }

  String _openScannerLabel() {
    switch (_lc) {
      case 'en':
        return 'Import document';
      case 'ar':
        return 'استيراد مستند';
      default:
        return 'Ajouter un document';
    }
  }

  String _scopeLabel(_DocumentScope scope) {
    switch (scope) {
      case _DocumentScope.all:
        return _lc == 'en'
            ? 'All'
            : _lc == 'ar'
            ? 'الكل'
            : 'Tous';
      case _DocumentScope.active:
        return _lc == 'en'
            ? 'Active'
            : _lc == 'ar'
            ? 'نشط'
            : 'Actifs';
      case _DocumentScope.favorites:
        return _lc == 'en'
            ? 'Favorites'
            : _lc == 'ar'
            ? 'مفضلة'
            : 'Favoris';
      case _DocumentScope.archived:
        return _lc == 'en'
            ? 'Archived'
            : _lc == 'ar'
            ? 'مؤرشف'
            : 'Archives';
      case _DocumentScope.trash:
        return _lc == 'en'
            ? 'Trash'
            : _lc == 'ar'
            ? 'محذوفات'
            : 'Corbeille';
    }
  }

  String _sortLabel(_DocumentSortMode mode) {
    switch (mode) {
      case _DocumentSortMode.newest:
        return _lc == 'en'
            ? 'Newest'
            : _lc == 'ar'
            ? 'الأحدث'
            : 'Recent';
      case _DocumentSortMode.name:
        return _lc == 'en'
            ? 'Name'
            : _lc == 'ar'
            ? 'الاسم'
            : 'Nom';
      case _DocumentSortMode.status:
        return _lc == 'en'
            ? 'Status'
            : _lc == 'ar'
            ? 'الحالة'
            : 'Statut';
      case _DocumentSortMode.confidence:
        return _lc == 'en'
            ? 'Confidence'
            : _lc == 'ar'
            ? 'الثقة'
            : 'Confiance';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'imported':
        return _lc == 'en'
            ? 'Imported'
            : _lc == 'ar'
            ? 'مستورد'
            : 'Importe';
      case 'ocr':
        return _lc == 'en'
            ? 'OCR running'
            : _lc == 'ar'
            ? 'OCR قيد التنفيذ'
            : 'OCR en cours';
      case 'translated':
        return _lc == 'en'
            ? 'Translated'
            : _lc == 'ar'
            ? 'مترجم'
            : 'Traduit';
      case 'validated':
        return _lc == 'en'
            ? 'Validated'
            : _lc == 'ar'
            ? 'معتمد'
            : 'Valide';
      case 'exported':
        return _lc == 'en'
            ? 'Exported'
            : _lc == 'ar'
            ? 'تم التصدير'
            : 'Exporte';
      case 'archived':
        return _lc == 'en'
            ? 'Archived'
            : _lc == 'ar'
            ? 'مؤرشف'
            : 'Archive';
      case 'error':
        return _lc == 'en'
            ? 'Error'
            : _lc == 'ar'
            ? 'خطأ'
            : 'Erreur';
      default:
        return _lc == 'en'
            ? 'Extracted'
            : _lc == 'ar'
            ? 'مستخرج'
            : 'Extrait';
    }
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'translated':
        return AppThemePalette.secondary;
      case 'validated':
        return AppThemePalette.success;
      case 'archived':
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case 'error':
        return Theme.of(context).colorScheme.error;
      default:
        return AppThemePalette.primary;
    }
  }

  List<String> _folderOptions(List<ScanHistoryEntry> entries) {
    final folders = <String>{
      'Rapports medicaux',
      'Factures',
      'Contrats',
      'Identite',
      'Bibliotheque generale',
    };
    for (final entry in entries) {
      if (entry.folder.trim().isNotEmpty) {
        folders.add(entry.folder);
      }
    }
    final sorted = folders.toList()..sort();
    return ['all', ...sorted];
  }

  List<String> _statusOptions(List<ScanHistoryEntry> entries) {
    final statuses = <String>{'all'};
    for (final entry in entries) {
      statuses.add(entry.status);
    }
    return statuses.toList(growable: false);
  }

  List<_DocumentItem> _filteredItems(List<ScanHistoryEntry> entries) {
    final query = _searchController.text.trim().toLowerCase();
    final items = entries
        .asMap()
        .entries
        .map((e) => _DocumentItem(index: e.key, entry: e.value))
        .where((item) {
          final entry = item.entry;

          switch (_scope) {
            case _DocumentScope.active:
              if (entry.isArchived || entry.isDeleted) {
                return false;
              }
            case _DocumentScope.favorites:
              if (!entry.isFavorite || entry.isDeleted) {
                return false;
              }
            case _DocumentScope.archived:
              if (!entry.isArchived || entry.isDeleted) {
                return false;
              }
            case _DocumentScope.trash:
              if (!entry.isDeleted) {
                return false;
              }
            case _DocumentScope.all:
              if (entry.isDeleted) {
                return false;
              }
          }

          if (_selectedFolder != 'all' && entry.folder != _selectedFolder) {
            return false;
          }
          if (_selectedStatus != 'all' && entry.status != _selectedStatus) {
            return false;
          }

          if (query.isEmpty) return true;

          final haystack = <String>[
            entry.displayName,
            entry.text,
            entry.resultSummary ?? '',
            entry.folder,
            entry.documentTypeLabel,
            entry.note ?? '',
            entry.importedBy,
            entry.detectedLanguages.join(' '),
            entry.tags.join(' '),
            entry.targetLanguageCode ?? '',
            entry.structuredReport?.patientInfo.fullName ?? '',
            entry.structuredReport?.patientInfo.organism ?? '',
            entry.structuredReport?.reportInfo.examNumber ?? '',
            entry.structuredReport?.labInfo.name ?? '',
          ].join(' ').toLowerCase();

          return haystack.contains(query);
        })
        .toList(growable: false);

    final sorted = [...items];
    sorted.sort((a, b) {
      if (a.entry.isPinned != b.entry.isPinned) {
        return a.entry.isPinned ? -1 : 1;
      }
      switch (_sortMode) {
        case _DocumentSortMode.name:
          return a.entry.displayName.toLowerCase().compareTo(
            b.entry.displayName.toLowerCase(),
          );
        case _DocumentSortMode.status:
          return a.entry.status.compareTo(b.entry.status);
        case _DocumentSortMode.confidence:
          return (b.entry.ocrConfidence ?? 0).compareTo(
            a.entry.ocrConfidence ?? 0,
          );
        case _DocumentSortMode.newest:
          return b.entry.createdAtIso.compareTo(a.entry.createdAtIso);
      }
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == _DocumentViewMode.list
                    ? _DocumentViewMode.board
                    : _DocumentViewMode.list;
              });
            },
            icon: Icon(
              _viewMode == _DocumentViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
            ),
          ),
          PopupMenuButton<_DocumentSortMode>(
            initialValue: _sortMode,
            onSelected: (value) {
              setState(() {
                _sortMode = value;
              });
            },
            itemBuilder: (context) => _DocumentSortMode.values
                .map(
                  (mode) => PopupMenuItem<_DocumentSortMode>(
                    value: mode,
                    child: Text(_sortLabel(mode)),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackdrop(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: widget.scanHistoryStore,
            builder: (context, _) {
              final entries = widget.scanHistoryStore.entries;
              final folderOptions = _folderOptions(entries);
              final statusOptions = _statusOptions(entries);
              final items = _filteredItems(entries);
              final activeCount = entries
                  .where((e) => !e.isArchived && !e.isDeleted)
                  .length;
              final archivedCount = entries
                  .where((e) => e.isArchived && !e.isDeleted)
                  .length;
              final favoriteCount = entries
                  .where((e) => e.isFavorite && !e.isDeleted)
                  .length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  AppPanel(
                    gradient: AppThemePalette.heroGradient(
                      theme.brightness == Brightness.dark,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _heroTitle(),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _heroSubtitle(),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
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
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.folder_copy_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _HeroMetric(
                                value: '$activeCount',
                                label: _scopeLabel(_DocumentScope.active),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroMetric(
                                value: '$archivedCount',
                                label: _scopeLabel(_DocumentScope.archived),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroMetric(
                                value: '$favoriteCount',
                                label: _scopeLabel(_DocumentScope.favorites),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: widget.onOpenScanner,
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: Text(_openScannerLabel()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: _searchHint(),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppSectionHeader(
                    eyebrow: _folderTitle(),
                    title: _folderTitle(),
                    subtitle: _heroSubtitle(),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: folderOptions
                          .map((folder) {
                            final isSelected = _selectedFolder == folder;
                            final label = folder == 'all'
                                ? (_lc == 'en'
                                      ? 'All folders'
                                      : _lc == 'ar'
                                      ? 'كل المجلدات'
                                      : 'Tous les dossiers')
                                : folder;
                            final count = folder == 'all'
                                ? entries.where((e) => !e.isDeleted).length
                                : entries
                                      .where(
                                        (e) =>
                                            !e.isDeleted && e.folder == folder,
                                      )
                                      .length;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _FolderChip(
                                label: label,
                                count: count,
                                selected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedFolder = folder;
                                  });
                                },
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _DocumentScope.values
                          .map((scope) {
                            final selected = _scope == scope;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(_scopeLabel(scope)),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _scope = scope;
                                  });
                                },
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statusOptions
                          .map((status) {
                            final selected = _selectedStatus == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  status == 'all'
                                      ? (_lc == 'en'
                                            ? 'All statuses'
                                            : _lc == 'ar'
                                            ? 'كل الحالات'
                                            : 'Tous statuts')
                                      : _statusLabel(status),
                                ),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedStatus = status;
                                  });
                                },
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (items.isEmpty)
                    AppEmptyState(
                      icon: Icons.folder_open_rounded,
                      title: _lc == 'en'
                          ? 'No document matches your filters'
                          : _lc == 'ar'
                          ? 'لا يوجد مستند يطابق عوامل التصفية'
                          : 'Aucun document ne correspond a vos filtres',
                      subtitle: _lc == 'en'
                          ? 'Try another folder, status or search keyword.'
                          : _lc == 'ar'
                          ? 'جرّب مجلدًا أو حالة أو كلمة بحث أخرى.'
                          : 'Essayez un autre dossier, statut ou mot-cle.',
                    )
                  else if (_viewMode == _DocumentViewMode.list)
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DocumentCard(
                          localeCode: _lc,
                          entry: item.entry,
                          statusColor: _statusColor(context, item.entry.status),
                          statusLabel: _statusLabel(item.entry.status),
                          onTap: () => _openDetail(item),
                        ),
                      );
                    })
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final tileWidth = constraints.maxWidth > 740
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: items
                              .map(
                                (item) => SizedBox(
                                  width: tileWidth,
                                  child: _DocumentCard(
                                    localeCode: _lc,
                                    entry: item.entry,
                                    statusColor: _statusColor(
                                      context,
                                      item.entry.status,
                                    ),
                                    statusLabel: _statusLabel(
                                      item.entry.status,
                                    ),
                                    compact: true,
                                    onTap: () => _openDetail(item),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openDetail(_DocumentItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DocumentDetailSheet(
        localeCode: _lc,
        item: item,
        scanHistoryStore: widget.scanHistoryStore,
        onOpenResultRequested: (entry) {
          Navigator.of(context).pop();
          widget.onOpenResultRequested(entry);
        },
        detailTitle: _detailTitle(),
        metadataTitle: _metadataTitle(),
        versionsTitle: _versionsTitle(),
        activityTitle: _activityTitle(),
        notesTitle: _notesTitle(),
        openResultLabel: _openResultLabel(),
        copyExtractedTextLabel: _copyExtractedTextLabel(),
        statusLabel: _statusLabel(item.entry.status),
        statusColor: _statusColor(context, item.entry.status),
      ),
    );
  }
}

class _DocumentItem {
  const _DocumentItem({required this.index, required this.entry});

  final int index;
  final ScanHistoryEntry entry;
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  const _FolderChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: theme.textTheme.labelLarge),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$count', style: theme.textTheme.labelSmall),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.localeCode,
    required this.entry,
    required this.statusColor,
    required this.statusLabel,
    required this.onTap,
    this.compact = false,
  });

  final String localeCode;
  final ScanHistoryEntry entry;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = DateTime.tryParse(entry.createdAtIso);
    final confidence = entry.ocrConfidence == null
        ? null
        : '${(entry.ocrConfidence! * 100).toStringAsFixed(0)}%';

    return AppPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DocumentThumb(entry: entry),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (entry.isPinned)
                          Icon(
                            Icons.push_pin_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        if (entry.isFavorite)
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: AppThemePalette.warning,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.documentTypeLabel,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TinyInfoPill(label: statusLabel, tone: statusColor),
                        _TinyInfoPill(
                          label: entry.folder,
                          tone: theme.colorScheme.secondary,
                        ),
                        if (confidence != null)
                          _TinyInfoPill(
                            label: 'OCR $confidence',
                            tone: AppThemePalette.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!compact)
            Text(
              (entry.resultSummary ?? entry.text).replaceAll('\n', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          if (!compact) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  createdAt == null
                      ? entry.importedBy
                      : '${createdAt.toLocal().toString().split('.').first} • ${entry.importedBy}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              if (entry.detectedLanguages.isNotEmpty)
                Text(
                  entry.detectedLanguages.join(' / ').toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entry.tags
                  .take(compact ? 2 : 4)
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentThumb extends StatelessWidget {
  const _DocumentThumb({required this.entry});

  final ScanHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entry.imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 74,
          height: 74,
          child: Image.memory(entry.imageBytes!, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        entry.displayName.toLowerCase().endsWith('.pdf')
            ? Icons.picture_as_pdf_rounded
            : Icons.description_rounded,
        color: theme.colorScheme.primary,
        size: 32,
      ),
    );
  }
}

class _TinyInfoPill extends StatelessWidget {
  const _TinyInfoPill({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: tone),
      ),
    );
  }
}

class _DocumentDetailSheet extends StatefulWidget {
  const _DocumentDetailSheet({
    required this.localeCode,
    required this.item,
    required this.scanHistoryStore,
    required this.onOpenResultRequested,
    required this.detailTitle,
    required this.metadataTitle,
    required this.versionsTitle,
    required this.activityTitle,
    required this.notesTitle,
    required this.openResultLabel,
    required this.copyExtractedTextLabel,
    required this.statusLabel,
    required this.statusColor,
  });

  final String localeCode;
  final _DocumentItem item;
  final ScanHistoryStore scanHistoryStore;
  final ValueChanged<ScanHistoryEntry> onOpenResultRequested;
  final String detailTitle;
  final String metadataTitle;
  final String versionsTitle;
  final String activityTitle;
  final String notesTitle;
  final String openResultLabel;
  final String copyExtractedTextLabel;
  final String statusLabel;
  final Color statusColor;

  @override
  State<_DocumentDetailSheet> createState() => _DocumentDetailSheetState();
}

class _DocumentDetailSheetState extends State<_DocumentDetailSheet> {
  late TextEditingController _noteController;

  ScanHistoryEntry get _entry =>
      widget.scanHistoryStore.entries[widget.item.index];

  static const List<String> _folderChoices = <String>[
    'Rapports medicaux',
    'Factures',
    'Contrats',
    'Identite',
    'Bibliotheque generale',
    'Archives',
  ];

  static const List<String> _tagChoices = <String>[
    'urgent',
    'a verifier',
    'valide',
    'finance',
    'juridique',
    'technique',
    'multilingue',
    'confidentiel',
    'medical',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.entry.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = _entry;
    final createdAt = DateTime.tryParse(entry.createdAtIso);
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Center(
                  child: Container(
                    width: 54,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.detailTitle,
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.displayName,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.scanHistoryStore.togglePinnedAt(
                        widget.item.index,
                      ),
                      icon: Icon(
                        entry.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.scanHistoryStore.toggleFavoriteAt(
                        widget.item.index,
                      ),
                      icon: Icon(
                        entry.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppPanel(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DocumentThumb(entry: entry),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TinyInfoPill(
                              label: widget.statusLabel,
                              tone: widget.statusColor,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              entry.documentTypeLabel,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.resultSummary ?? entry.text,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => widget.onOpenResultRequested(entry),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(widget.openResultLabel),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(
                            ClipboardData(text: entry.text),
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(widget.copyExtractedTextLabel),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(widget.copyExtractedTextLabel),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppSectionHeader(
                  eyebrow: widget.metadataTitle,
                  title: widget.metadataTitle,
                ),
                const SizedBox(height: 12),
                AppPanel(
                  child: Column(
                    children: [
                      _MetaRow(label: 'Dossier', value: entry.folder),
                      const Divider(),
                      _MetaRow(label: 'Type', value: entry.documentTypeLabel),
                      const Divider(),
                      _MetaRow(label: 'Importe par', value: entry.importedBy),
                      const Divider(),
                      _MetaRow(
                        label: 'Date',
                        value:
                            createdAt?.toLocal().toString().split('.').first ??
                            '-',
                      ),
                      const Divider(),
                      _MetaRow(
                        label: 'Taille',
                        value: _formatBytes(entry.fileSizeBytes),
                      ),
                      const Divider(),
                      _MetaRow(
                        label: 'Langues',
                        value: entry.detectedLanguages.isEmpty
                            ? '-'
                            : entry.detectedLanguages.join(' / ').toUpperCase(),
                      ),
                      const Divider(),
                      _MetaRow(
                        label: 'Confiance OCR',
                        value: entry.ocrConfidence == null
                            ? '-'
                            : '${(entry.ocrConfidence! * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dossier de classement',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _folderChoices
                            .map(
                              (folder) => ChoiceChip(
                                label: Text(folder),
                                selected: folder == entry.folder,
                                onSelected: (_) {
                                  widget.scanHistoryStore.updateFolderAt(
                                    widget.item.index,
                                    folder,
                                  );
                                  setState(() {});
                                },
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tags', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tagChoices
                            .map(
                              (tag) => FilterChip(
                                label: Text(tag),
                                selected: entry.tags.contains(tag),
                                onSelected: (selected) {
                                  final nextTags = [...entry.tags];
                                  if (selected) {
                                    if (!nextTags.contains(tag)) {
                                      nextTags.add(tag);
                                    }
                                  } else {
                                    nextTags.remove(tag);
                                  }
                                  widget.scanHistoryStore.updateTagsAt(
                                    widget.item.index,
                                    nextTags,
                                  );
                                  setState(() {});
                                },
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppSectionHeader(
                  eyebrow: widget.versionsTitle,
                  title: widget.versionsTitle,
                ),
                const SizedBox(height: 12),
                ...entry.versionLabels.map(
                  (version) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      radius: 22,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.layers_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              version,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppSectionHeader(
                  eyebrow: widget.activityTitle,
                  title: widget.activityTitle,
                ),
                const SizedBox(height: 12),
                ...entry.activityLog.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      radius: 22,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppSectionHeader(
                  eyebrow: widget.notesTitle,
                  title: widget.notesTitle,
                ),
                const SizedBox(height: 12),
                AppPanel(
                  child: Column(
                    children: [
                      TextField(
                        controller: _noteController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Ajouter un commentaire, une annotation ou une consigne...',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await widget.scanHistoryStore.updateNoteAt(
                                  widget.item.index,
                                  _noteController.text,
                                );
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Note enregistree.'),
                                  ),
                                );
                                setState(() {});
                              },
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Enregistrer la note'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await widget.scanHistoryStore.archiveEntryAt(
                            widget.item.index,
                            archived: !entry.isArchived,
                          );
                          if (!mounted) return;
                          setState(() {});
                        },
                        icon: Icon(
                          entry.isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                        ),
                        label: Text(
                          entry.isArchived ? 'Restaurer' : 'Archiver',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await widget.scanHistoryStore.setDeletedAt(
                            widget.item.index,
                            deleted: !entry.isDeleted,
                          );
                          if (!mounted) return;
                          setState(() {});
                        },
                        icon: Icon(
                          entry.isDeleted
                              ? Icons.restore_from_trash_rounded
                              : Icons.delete_outline_rounded,
                        ),
                        label: Text(
                          entry.isDeleted
                              ? 'Restaurer depuis la corbeille'
                              : 'Envoyer a la corbeille',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) return '-';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.labelLarge)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
