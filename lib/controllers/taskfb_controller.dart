import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/models/task.dart';
import 'package:event_manager/db/fb_db_helper.dart';

class TaskFbController extends GetxController {
  var taskList = <Task>[].obs;

  @override
  void onReady() {
    super.onReady();
    getTasks();
  }

  ///  Add a task to Firebase
  Future<void> addTask({Task? task}) async {
    debugPrint("TaskFbController Adding task for user ${task?.title}");
    if (task != null) {
      try {
        debugPrint("!TaskFbController Adding task: ${task.title}");
        debugPrint("Task data before calling FBdbHelper: ${task.toJson()}");
        await FBdbHelper.addTask(task);
        debugPrint("Task added to Firestore successfully");
        
        // Refresh task list after adding
        debugPrint("TaskFbController Refreshing task list");
        getTasks();
        debugPrint("TaskFbController Task list refreshed");
      } catch (e, stackTrace) {
        debugPrint("ERROR in TaskFbController.addTask: $e");
        debugPrint("StackTrace: $stackTrace");
        
        if (e.toString().contains('not authenticated')) {
          Get.snackbar(
            "Authentication Required",
            "Please login to create tasks",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
            duration: const Duration(seconds: 3),
          );
        }
        rethrow;
      }
    }
  }

  ///  Fetch all tasks from Firebase
  void getTasks() async {
    try {
      taskList.value = await FBdbHelper.getTasks();
    } catch (e) {
      print('Error fetching tasks: $e');
      // Keep the existing task list if there's an error
      // You can also show a snackbar to the user here
    }
  }

  ///  Delete a task from Firebase
  Future<void> delete(Task task) async {
    if (task.id != null) {
      await FBdbHelper.deleteTask(task.id!);
      getTasks();
    }
  }

  /// Mark a task as completed
  Future<void> markTaskCompleted(String id) async {
    try {
      final userId = FBdbHelper.userId;
      if (userId == null) {
        Get.snackbar(
          "Authentication Required",
          "Please login to mark tasks as completed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }
      
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(userId)
          .collection('userTasks')
          .doc(id)
          .update({'isCompleted': 1});
      
      getTasks();
      
      Get.snackbar(
        "Success",
        "Task marked as completed!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint("Error marking task as completed: $e");
      Get.snackbar(
        "Error",
        "Failed to mark task as completed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Update a task in Firebase
  Future<void> updateEvents(Task updatedTask) async {
    try {
      if (updatedTask.id != null) {
        await FBdbHelper.updateTaskInFirebase(updatedTask);
        getTasks();
        print("Task updated successfully");
      }
    } catch (e) {
      print("Error updating task: $e");
    }
  }
}
