import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  static Future<String> exportTask() async {
    try {
      print("=== PDF Export Started ===");
      
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("ERROR: User not logged in");
        throw Exception("User not logged in.");
      }
      print("User ID: ${currentUser.uid}");

      // Fetch tasks from nested collection: tasks/userId/userTasks
      print("Fetching tasks from Firestore...");
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(currentUser.uid)
          .collection('userTasks')
          .get();

      print("Fetched ${snapshot.docs.length} document(s) from Firestore");

      if (snapshot.docs.isEmpty) {
        print("ERROR: No tasks available");
        throw Exception("No tasks available for this user.");
      }

      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        print("Task data: $data");
        return data;
      }).toList();

      print("Total tasks to export: ${tasks.length}");

      // Create PDF without custom font first (fallback approach)
      print("Creating PDF document...");
      final pdf = pw.Document();

      // Try to load custom font, fallback to default if fails
      pw.Font? ttf;
      try {
        final font = await rootBundle.load("fonts/Lato-Regular.ttf");
        ttf = pw.Font.ttf(font);
        print("Custom font loaded successfully");
      } catch (e) {
        print("Could not load custom font, using default: $e");
      }

      print("Building PDF content...");
      // Prepare table data
      final tableData = tasks.map((task) {
        final row = [
          task['date']?.toString() ?? 'N/A',
          task['title']?.toString() ?? 'N/A',
          task['category']?.toString() ?? 'N/A',
          task['startTime']?.toString() ?? 'N/A',
          task['description']?.toString() ?? 'N/A',
          task['location']?.toString() ?? 'N/A',
        ];
        print("Table row: $row");
        return row;
      }).toList();

      print("Adding page to PDF with ${tableData.length} rows...");
      pdf.addPage(
        pw.Page(
          build: (pw.Context pdfContext) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  "Event Report",
                  style: pw.TextStyle(
                    fontSize: 28, 
                    fontWeight: pw.FontWeight.bold, 
                    font: ttf
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Title', 'Category', 'Time', 'Description', 'Location'],
                data: tableData,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, 
                  font: ttf
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: pw.TextStyle(font: ttf),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Generated on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                style: pw.TextStyle(font: ttf),
              ),
            ],
          ),
        ),
      );
      print("PDF page added successfully");

      // Request storage permission for Android
      Directory? downloadsDir;
      
      if (Platform.isAndroid) {
        // Try to get external storage directory (works without special permissions)
        try {
          final externalDir = await getExternalStorageDirectory();
          
          if (externalDir != null) {
            // Use the app's external files directory
            downloadsDir = externalDir;
            print("Using external storage directory: ${downloadsDir.path}");
          } else {
            // Fallback to app documents directory
            downloadsDir = await getApplicationDocumentsDirectory();
            print("Using app documents directory: ${downloadsDir.path}");
          }
        } catch (e) {
          print("Error getting external directory: $e");
          // Use app documents directory as last resort
          downloadsDir = await getApplicationDocumentsDirectory();
          print("Using app documents directory fallback: ${downloadsDir.path}");
        }
      } else {
        // For iOS/other platforms
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final random = Random().nextInt(100000);
      final fileName = "Task_Report_$random.pdf";
      final outputFile = File("${downloadsDir.path}/$fileName");

      print("Saving PDF to: ${outputFile.path}");
      // Write the PDF
      final bytes = await pdf.save();
      print("PDF bytes generated: ${bytes.length} bytes");
      
      await outputFile.writeAsBytes(bytes);
      print("PDF bytes written to file");
      
      // Verify the file exists
      final fileExists = await outputFile.exists();
      if (!fileExists) {
        print("ERROR: File does not exist after writing!");
        throw Exception("File was not saved successfully");
      }
      
      final fileSize = await outputFile.length();
      print("✓ PDF saved successfully!");
      print("  Path: ${outputFile.path}");
      print("  Size: $fileSize bytes");
      print("  Exists: $fileExists");
      print("=== PDF Export Complete ===");
      
      return outputFile.path; // Return the file path
    } catch (e) {
      print("PDF Export Error Details: $e");
      throw Exception("Failed to generate PDF: $e");
    }
  }
}


