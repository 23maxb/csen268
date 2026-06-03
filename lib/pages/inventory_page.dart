import 'package:flutter/cupertino.dart';

import '../services/inventory_service.dart';
import 'scan_receipt_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  Future<void>? _loadFuture;
  Map<String, List<String>> _sections = {};
  bool _editMode = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<void> _load() async {
    try {
      final data = await InventoryService.instance.fetchOrCreate();
      if (!mounted) return;
      setState(() {
        _sections = data;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _toggleEditMode() async {
    if (_editMode) {
      setState(() => _saving = true);
      try {
        await InventoryService.instance.save(_sections);
        if (!mounted) return;
        setState(() {
          _editMode = false;
          _saving = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        _showError('Failed to save: $e');
      }
    } else {
      setState(() => _editMode = true);
    }
  }

  void _showError(String msg) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateItem(String section, int index, String value) {
    setState(() {
      _sections[section]![index] = value;
    });
  }

  void _deleteItem(String section, int index) {
    setState(() {
      _sections[section]!.removeAt(index);
    });
  }

  Future<void> _addItem(String section) async {
    final value = await _promptText('Add to $section');
    if (value == null || value.trim().isEmpty) return;
    setState(() {
      _sections[section]!.add(value.trim());
    });
  }

  Future<void> _scanReceipt() async {
    final items = await Navigator.of(context).push<List<String>>(
      CupertinoPageRoute(builder: (_) => const ScanReceiptPage()),
    );
    if (items == null || items.isEmpty) return;
    if (!mounted) return;

    final section = await _pickSection();
    if (section == null) return;

    setState(() {
      _sections.putIfAbsent(section, () => []).addAll(items);
    });

    // Persist the scanned items immediately.
    setState(() => _saving = true);
    try {
      await InventoryService.instance.save(_sections);
      if (!mounted) return;
      setState(() => _saving = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Failed to save: $e');
    }
  }

  /// Asks the user which section the scanned items should be added to,
  /// offering existing sections plus the option to create a new one.
  Future<String?> _pickSection() async {
    if (_sections.isEmpty) {
      return _promptText('New section name').then((v) => v?.trim());
    }
    return showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Add scanned items to'),
        actions: [
          for (final name in _sections.keys)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(ctx).pop(name),
              child: Text(name),
            ),
          CupertinoActionSheetAction(
            onPressed: () async {
              final value = await _promptText('New section name');
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop(value?.trim());
            },
            child: const Text('New Section...'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    ).then((v) => (v == null || v.isEmpty) ? null : v);
  }

  Future<void> _addSection() async {
    final value = await _promptText('New section name');
    if (value == null || value.trim().isEmpty) return;
    final name = value.trim();
    if (_sections.containsKey(name)) return;
    setState(() {
      _sections[name] = [];
    });
  }

  void _deleteSection(String section) {
    setState(() {
      _sections.remove(section);
    });
  }

  Future<String?> _promptText(String title) {
    final controller = TextEditingController();
    return showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CupertinoTextField(controller: controller, autofocus: true),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load inventory.\n$_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      onPressed: () {
                        setState(() => _loadFuture = _load());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Inventory',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ToolButton(
                      icon: CupertinoIcons.doc_text,
                      label: 'Scan Receipt',
                      onPressed: _scanReceipt,
                    ),
                    const SizedBox(width: 12),
                    _ToolButton(
                      icon: _editMode
                          ? CupertinoIcons.check_mark
                          : CupertinoIcons.pencil,
                      label: _saving
                          ? 'Saving...'
                          : (_editMode ? 'Done' : 'Edit Mode'),
                      onPressed: _saving ? () {} : _toggleEditMode,
                    ),
                    if (_editMode) ...[
                      const SizedBox(width: 12),
                      _ToolButton(
                        icon: CupertinoIcons.add,
                        label: 'Section',
                        onPressed: _addSection,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                for (final entry in _sections.entries) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_editMode) ...[
                        GestureDetector(
                          onTap: () => _addItem(entry.key),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(CupertinoIcons.add, size: 18),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _deleteSection(entry.key),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              CupertinoIcons.trash,
                              size: 16,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (var i = 0; i < entry.value.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: _editMode
                          ? Row(
                              children: [
                                Expanded(
                                  child: CupertinoTextField(
                                    controller: TextEditingController(
                                      text: entry.value[i],
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                    onSubmitted: (v) =>
                                        _updateItem(entry.key, i, v),
                                    onChanged: (v) =>
                                        _sections[entry.key]![i] = v,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _deleteItem(entry.key, i),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      CupertinoIcons.minus_circle,
                                      size: 18,
                                      color: CupertinoColors.systemRed,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              entry.value[i],
                              style: const TextStyle(fontSize: 13),
                            ),
                    ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.separator),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: CupertinoColors.black),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
