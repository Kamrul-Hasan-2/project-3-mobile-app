import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/controllers/taskfb_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//        Sqflite-------------------
// class BackupRestore {
//   static Future<void> backupToLocal() async {
//     try {
//       String dbPath = await getDatabasesPath() + 'tasks.db';
//       File dbFile = File(dbPath);
//
//       Directory? externalDir = await getExternalStorageDirectory();
//       String backupPath = '${externalDir!.path}/tasks_backup.db';
//
//       await dbFile.copy(backupPath);
//       print("Backup saved at: $backupPath");
//     } catch (e) {
//       print("Local backup failed: $e");
//     }
//   }
//   static Future<void> restoreFromLocal() async {
//     try {
//       Directory? externalDir = await getExternalStorageDirectory();
//       String backupPath = '${externalDir!.path}/tasks_backup.db';
//       File backupFile = File(backupPath);
//
//       if (!backupFile.existsSync()) {
//         print("Backup file not found!");
//         return;
//       }
//
//       String dbPath = await getDatabasesPath() + 'tasks.db';
//       await backupFile.copy(dbPath);
//
//       print("Database restored from local backup!");
//       // Refresh task list after restore
//       Get.find<TaskFbController>().getTasks();
//
//     } catch (e) {
//       print("Local restore failed: $e");
//     }
//   }
// }

//    Firebase --------------------------
class BackupRestore {
  static Future<void> backupToLocal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('tasks').doc(uid).get();
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('userTasks')
        .get();

    final backupData = {
      'user': userDoc.data(),
      'tasks': tasksSnapshot.docs.map((doc) => doc.data()).toList(),
    };

    final jsonStr = jsonEncode(backupData);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup.json');
    print('Backup path $file');
    await file.writeAsString(jsonStr);
  }

  static Future<void> restoreFromLocal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup.json');

    if (!(await file.exists())) return;

    final jsonStr = await file.readAsString();
    final backupData = jsonDecode(jsonStr);

    if (backupData['user'] != null) {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .set(backupData['user']);
    }

    if (backupData['tasks'] != null) {
      final userTasksCollection = FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('userTasks');

      for (final task in backupData['tasks']) {
        final docRef = userTasksCollection.doc();
        await docRef.set(task);
      }
      Get.find<TaskFbController>().getTasks();
    }
  }
}
