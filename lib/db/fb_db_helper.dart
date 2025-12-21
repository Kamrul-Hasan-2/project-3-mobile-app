import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager/models/task.dart';
import 'package:flutter/material.dart';

class FBdbHelper {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get userId => _auth.currentUser?.uid;

  // Add Task
  static Future<void> addTask(Task task) async {
    try {
      if (userId == null) {
        throw Exception("User is not authenticated. Please login first.");
      }
      debugPrint("FBdbHelper Adding task for user: $userId");
      final taskJson = task.toJson();
      debugPrint("Task JSON: $taskJson");
      
      await _firestore
          .collection('tasks')
          .doc(userId)
          .collection('userTasks')
          .add(taskJson);
      
      debugPrint("FBdbHelper Task added to Firestore successfully");
    } catch (e, stackTrace) {
      debugPrint("ERROR in FBdbHelper.addTask: $e");
      debugPrint("StackTrace: $stackTrace");
      rethrow;
    }
  }

  // Get All Tasks for current user
  static Future<List<Task>> getTasks() async {
    try {
      if (userId == null) {
        debugPrint("User is not authenticated. Returning empty task list.");
        return [];
      }
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
    if (userId == null) {
      throw Exception("User is not authenticated. Please login first.");
    }
    await _firestore
        .collection('tasks')
        .doc(userId)
        .collection('userTasks')
        .doc(id)
        .delete();
  }

  // Update Task
  static Future<void> updateTaskInFirebase(Task task) async {
    if (userId == null) {
      throw Exception("User is not authenticated. Please login first.");
    }
    await _firestore
        .collection('tasks')
        .doc(userId)
        .collection('userTasks')
        .doc(task.id)
        .update(task.toJson());
  }

}
