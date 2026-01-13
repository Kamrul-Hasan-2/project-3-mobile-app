import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager/models/task.dart';

class FBdbHelper {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Get current user ID
  static String get userId => _auth.currentUser!.uid;

  // Add Task
  static Future<void> addTask(Task task) async {
    await _firestore
        .collection('tasks')
        .doc(userId)
        .collection('userTasks')
        .add(task.toJson());
  }

  // Get All Tasks for current user
  static Future<List<Task>> getTasks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .doc(userId)
          .collection('userTasks')
          .get();

      return snapshot.docs.map((doc) {
        Task task = Task.fromJson(doc.data() as Map<String, dynamic>);
        task.id = doc.id;
        return task;
      }).toList();
    } catch (e) {
      print('Error getting tasks from Firestore: $e');
      // Return empty list if there's a permission error
      return [];
    }
  }

  //  Delete Task
  static Future<void> deleteTask(String id) async {
    await _firestore
        .collection('tasks')
        .doc(userId)
        .collection('userTasks')
        .doc(id)
        .delete();
  }

  // Update Task
  static Future<void> updateTaskInFirebase(Task task) async {
    await _firestore
        .collection('tasks')
        .doc(userId)
        .collection('userTasks')
        .doc(task.id)
        .update(task.toJson());
  }
}
