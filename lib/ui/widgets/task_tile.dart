import 'dart:io';
import 'package:event_manager/models/task.dart';
import 'package:event_manager/ui/media_preview/image_screen.dart';
import 'package:event_manager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskTile extends StatefulWidget {
  final Task? task;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onTap;

  TaskTile(this.task, {this.onMarkComplete, this.onTap});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBGClr(widget.task?.color ?? 0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact View (Header)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isExpanded)
                  Container(
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.calendar_today_sharp,
                            color: Colors.white, size: 52),
                        Container(
                          margin: EdgeInsets.only(top: 14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getDay(widget.task?.date ?? ''),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                _getMonth(widget.task?.date ?? ''),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(width: 12),

                // Title & Description
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Title : ${widget.task?.title ?? ''}",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Description : ${widget.task?.description ?? ''}",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                fontSize: 14, color: Colors.grey[100]),
                          ),
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          maxLines: isExpanded ? null : 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Mark Complete Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.task?.isCompleted == 1
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: widget.task?.isCompleted == 1
                          ? Colors.greenAccent
                          : Colors.white,
                      size: 28,
                    ),
                    onPressed: widget.onMarkComplete,
                    tooltip: widget.task?.isCompleted == 1
                        ? 'Mark Incomplete'
                        : 'Mark Complete',
                  ),
                ),
                SizedBox(width: 4),
                // Expand Button
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),

            // EXPANDED DETAILS (INSIDE the Column!)
            if (isExpanded) ...[
              SizedBox(height: 10),
              _buildDetailRow(
                  Icons.category, "Category", widget.task?.category ?? "N/A"),
              _buildDetailRow(
                  Icons.date_range, "Date", widget.task?.date ?? "N/A"),
              _buildDetailRow(Icons.access_time_rounded, "Time",
                  "${widget.task?.startTime ?? ''} - ${widget.task?.endTime ?? ''}"),
              _buildDetailRow(Icons.location_on, "Location",
                  widget.task?.location ?? "No Location"),
              SizedBox(height: 10),
              if (widget.task?.photoPaths?.isNotEmpty ?? false) ...[
                Text(
                  "Attached Images:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photos - Full Width
                    if (widget.task?.photoPaths != null)
                      ...widget.task!.photoPaths!.map((path) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FullImageScreen(imagePath: path),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(maxHeight: 200),
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBGClr(int no) {
    switch (no) {
      case 0:
        return bluishClr;
      case 1:
        return pinkClr;
      case 2:
        return yellowClr;
      case 3:
        return customColor;
      default:
        return bluishClr;
    }
  }
}

String _getDay(String date) {
  try {
    final parts = date.split('/');
    return parts[1];
  } catch (e) {
    return '';
  }
}

String _getMonth(String date) {
  try {
    final parts = date.split('/');
    int month = int.tryParse(parts[0]) ?? 0;
    List<String> months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  } catch (e) {
    return '';
  }
}

//      Sqflite-----------------
// class TaskTile extends StatelessWidget {
//   final Task? task;
//
//   TaskTile(this.task);
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       width: MediaQuery.of(context).size.width,
//       margin: EdgeInsets.only(bottom: 12),
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: _getBGClr(task?.color ?? 0),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title
//                   Text(
//                     task?.title ?? "",
//                     style: GoogleFonts.lato(
//                       textStyle: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 8),
//
//                   // Time Range
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.access_time_rounded,
//                         color: Colors.grey[200],
//                         size: 18,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         "${task?.startTime ?? 'N/A'} - ${task?.endTime ?? 'N/A'}",
//                         style: GoogleFonts.lato(
//                           textStyle: TextStyle(fontSize: 14, color: Colors.grey[100]),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   // Description and Location
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Text(
//                           task?.description ?? "",
//                           style: GoogleFonts.lato(
//                             textStyle: TextStyle(fontSize: 14, color: Colors.grey[100]),
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       SizedBox(width: 8),
//
//                           Icon(
//                             Icons.location_on,
//                             color: Colors.grey[200],
//                             size: 18,
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             task?.location ?? "No location",
//                             style: GoogleFonts.lato(
//                               textStyle: TextStyle(fontSize: 13, color: Colors.grey[100]),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                       SizedBox(width: 8),
//                       Icon(
//                             Icons.category,
//                             color: Colors.grey[200],
//                             size: 18,
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             task?.category ?? "No category",
//                             style: GoogleFonts.lato(
//                               textStyle: TextStyle(fontSize: 13, color: Colors.grey[100]),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//
//                     ],
//                   ),
//
//                   SizedBox(height: 8),
//
//                   // Media Display
//                   if (task?.photoPath != null && task!.photoPath != "No Image Found!")
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.file(
//                         File(task!.photoPath!),
//                         fit: BoxFit.cover,
//                         height: 160,
//                         width: double.infinity,
//                       ),
//                     ),
//                   if (task?.videoPath != null && task!.videoPath != "No Video Found!")
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: VideoPlayerWidget(videoPath: task!.videoPath!),
//                     ),
//
//                   if (task?.filePath != null && task!.filePath != "No File Found!")
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.insert_drive_file,
//                             color: Colors.grey[200],
//                             size: 18,
//                           ),
//                           SizedBox(width: 4),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 OpenFilex.open(task!.filePath!);
//                               },
//                               child: Text(
//                                 task!.filePath!.split('/').last,
//                                 style: GoogleFonts.lato(
//                                   textStyle: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey[200], // Indicate it's clickable
//
//                                   ),
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   SizedBox(height: 8),
//
//                   Row(
//                     children: [
//                       // Share Button
//                       IconButton(
//                         onPressed: _shareTaskDetails,
//                         icon: Icon(Icons.share_outlined, color: Colors.grey[200]),
//                       ),
//
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 10),
//               height: 100,
//               width: 1,
//               color: Colors.grey[200]!.withOpacity(0.7),
//             ),
//             RotatedBox(
//               quarterTurns: 3,
//               child: Text(
//                 task!.isCompleted == 1 ? "COMPLETED" : "EVENT",
//                 style: GoogleFonts.lato(
//                   textStyle: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//       ),
//
//     );
//   }
//
//
//   // Background color based on task color index
//   _getBGClr(int no) {
//     switch (no) {
//       case 0:
//         return bluishClr;
//       case 1:
//         return pinkClr;
//       case 2:
//         return yellowClr;
//        //   add custom color choose from colopicker
//       case 3: // Custom color case
//         return customColor;
//       default:
//         return bluishClr;
//     }
//   }
//
//
//
// // Share Task Details
//   void _shareTaskDetails() async {
//     final taskDetails = '''
// Event Details:
// Title: ${task?.title ?? "No Title"}
// Date: ${task?.date ?? "No Date"}
// Time: ${task?.startTime ?? "N/A"} - ${task?.endTime ?? "N/A"}
// Description: ${task?.description ?? "No Description"}
// Location: ${task?.location ?? "No Location"}
// Category: ${task?.category ?? "No Category"}
//   ''';
//
//     List<XFile> filesToShare = [];
//
//     // Add image if exists
//     if (task?.photoPath != null && task!.photoPath != "No Image Found!") {
//       File imageFile = File(task!.photoPath!);
//       if (await imageFile.exists()) {
//         filesToShare.add(XFile(imageFile.path));
//       }
//     }
//
//     // Add video if exists
//     if (task?.videoPath != null && task!.videoPath != "No Video Found!") {
//       File videoFile = File(task!.videoPath!);
//       if (await videoFile.exists()) {
//         filesToShare.add(XFile(videoFile.path));
//       }
//     }
//
//     // Add file if exists
//     if (task?.filePath != null && task!.filePath!.isNotEmpty) {
//       File file = File(task!.filePath!);
//       if (await file.exists()) {
//         filesToShare.add(XFile(file.path));
//       } else {
//         print("File does not exist: ${task!.filePath}");
//       }
//     }
//
//     // Share media and text together
//     if (filesToShare.isNotEmpty) {
//       await Share.shareXFiles(
//         filesToShare,
//         text: taskDetails,
//       );
//     } else {
//       // If no media, just share text
//       await Share.share(taskDetails);
//     }
//   }
//
// }
