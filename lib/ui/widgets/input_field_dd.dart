import 'package:event_manager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyInputFieldDropdown extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  final VoidCallback? onTap;

  const MyInputFieldDropdown({
    super.key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
    this.onTap,
  });

  @override
  _MyInputFieldDropdownState createState() => _MyInputFieldDropdownState();
}

class _MyInputFieldDropdownState extends State<MyInputFieldDropdown> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
          Container(
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue
                        .withOpacity(0.3), // Blue shadow with opacity
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                focusNode: _focusNode,
                readOnly: widget.widget != null || widget.onTap != null,
                autofocus: false,
                cursorColor:
                    Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
                controller: widget.controller,
                style: subTitleStyle,
                onTap: widget.onTap,
                enableInteractiveSelection:
                    false, // Disable selection & magnifier
                contextMenuBuilder: (context, editableTextState) {
                  return Container(); // Disable long-press menu
                },
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: subTitleStyle,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  suffixIcon: widget.widget,
                ),
              )),
        ],
      ),
    );
  }
}
