import 'package:event_manager/ui/theme.dart';
import 'package:flutter/material.dart';


class MyCreateTaskBtn extends StatelessWidget {
  final String label;
  final Function()? onTap;

  const MyCreateTaskBtn({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,   // sdk
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: primaryClr
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
