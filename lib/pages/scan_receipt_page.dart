import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Lets the user pick/take a photo of a receipt, runs ML Kit text recognition
/// on it, and returns the detected items (one per line) to the caller.
///
/// Pops with a `List<String>` of the selected item lines, or `null` if the
/// user cancels.
class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _recognizer = TextRecognizer();

  File? _image;
  bool _processing = false;
  String? _error;

  /// Detected lines paired with whether they are currently selected.
  List<_DetectedItem> _items = [];

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _error = null;
    });
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;
      setState(() {
        _image = File(picked.path);
        _processing = true;
        _items = [];
      });
      await _recognize(File(picked.path));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = 'Failed to read image: $e';
      });
    }
  }

  Future<void> _recognize(File file) async {
    final input = InputImage.fromFile(file);
    final result = await _recognizer.processImage(input);

    // New fridge items are separated by new line, so split the recognized
    // text into individual lines and drop any blank ones.
    final lines = result.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => _DetectedItem(l))
        .toList();

    if (!mounted) return;
    setState(() {
      _processing = false;
      _items = lines;
      if (lines.isEmpty) {
        _error = 'No text detected. Try another photo.';
      }
    });
  }

  void _addSelected() {
    final selected = _items
        .where((i) => i.selected)
        .map((i) => i.text)
        .toList();
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _items.where((i) => i.selected).length;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Scan Receipt'),
        trailing: _items.isEmpty
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: selectedCount == 0 ? null : _addSelected,
                child: Text('Add ($selectedCount)'),
              ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: _processing
                          ? null
                          : () => _pick(ImageSource.camera),
                      child: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: _processing
                          ? null
                          : () => _pick(ImageSource.gallery),
                      child: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_image!, height: 180, fit: BoxFit.cover),
                ),
              if (_processing) ...[
                const SizedBox(height: 24),
                const Center(child: CupertinoActivityIndicator()),
                const SizedBox(height: 8),
                const Center(child: Text('Reading receipt...')),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ],
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Detected Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap to include or exclude each item.',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < _items.length; i++)
                  GestureDetector(
                    onTap: () => setState(
                      () => _items[i].selected = !_items[i].selected,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.separator),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _items[i].selected
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            size: 20,
                            color: _items[i].selected
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _items[i].text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetectedItem {
  final String text;
  bool selected;

  _DetectedItem(this.text) : selected = true;
}