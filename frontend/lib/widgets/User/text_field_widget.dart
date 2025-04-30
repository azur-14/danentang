import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onChanged;
  final IconData? icon;

  const TextFieldWidget({
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    super.key,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'e.g. ${widget.value}',
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        border: const OutlineInputBorder(),
      ),
      controller: _controller,
      onChanged: widget.onChanged,
    );
  }
}