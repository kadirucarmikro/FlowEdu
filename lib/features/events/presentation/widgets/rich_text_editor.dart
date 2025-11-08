import 'package:flutter/material.dart';

class RichTextEditor extends StatefulWidget {
  const RichTextEditor({
    super.key,
    this.initialValue,
    this.onChanged,
    this.height = 200,
    this.hintText = 'İçerik yazın...',
  });

  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final double height;
  final String hintText;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  onPressed: () => _formatText('**', '**'),
                  tooltip: 'Kalın',
                ),
                IconButton(
                  icon: const Icon(Icons.format_italic),
                  onPressed: () => _formatText('*', '*'),
                  tooltip: 'İtalik',
                ),
                IconButton(
                  icon: const Icon(Icons.format_underlined),
                  onPressed: () => _formatText('<u>', '</u>'),
                  tooltip: 'Altı Çizili',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted),
                  onPressed: () => _insertText('- '),
                  tooltip: 'Liste',
                ),
                IconButton(
                  icon: const Icon(Icons.format_list_numbered),
                  onPressed: () => _insertText('1. '),
                  tooltip: 'Numaralı Liste',
                ),
                const Spacer(),
                Text(
                  'Basit Metin Editörü',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),

          // Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _formatText(String prefix, String suffix) {
    final text = _controller.text;
    final selection = _controller.selection;

    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(
        offset:
            selection.start +
            prefix.length +
            selectedText.length +
            suffix.length,
      );
    } else {
      _insertText('$prefix$suffix');
    }
  }

  void _insertText(String text) {
    final selection = _controller.selection;
    final newText = _controller.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: selection.start + text.length,
    );
  }
}
