import 'package:flutter/material.dart';

// Progress Tracker Widget
class ProgressTrackerWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color backgroundColor;
  final Color progressColor;
  final double height;
  final double borderRadius;
  final String? text; // Optional text to display on progress bar
  final TextStyle? textStyle; // Optional text style

  const ProgressTrackerWidget({
    super.key,
    required this.progress,
    this.backgroundColor = Colors.white,
    this.progressColor = Colors.white,
    this.height = 30,
    this.borderRadius = 20,
    this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius - 2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          if (text != null)
            Text(
              text!,
              style: textStyle ?? const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}

// USAGE EXAMPLE:
// ProgressTrackerWidget(
//   progress: 0.3, // 30% progress (0.0 to 1.0)
//   backgroundColor: Colors.white,
//   progressColor: Colors.white,
//   height: 30,
//   borderRadius: 20,
// )