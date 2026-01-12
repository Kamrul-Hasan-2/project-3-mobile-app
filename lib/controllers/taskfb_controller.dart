import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/models/task.dart';
import 'package:event_manager/db/fb_db_helper.dart';

class TaskFbController extends GetxController {
  var taskList = <Task>[].obs;
  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    getTasks();
  }

  ///  Add a task to Firebase
  Future<void> addTask({Task? task}) async {
    if (task != null) {
      await FBdbHelper.addTask(task);
      getTasks();
    }
  }

  ///  Fetch all tasks from Firebase
  void getTasks() async {
    try {
      isLoading.value = true;
      taskList.value = await FBdbHelper.getTasks();
    } catch (e) {
      print('Error fetching tasks: $e');
      // Keep the existing task list if there's an error
      // You can also show a snackbar to the user here
    } finally {
      isLoading.value = false;
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
    await FirebaseFirestore.instance.collection('tasks').doc(id).update({
      'isCompleted': 1,
    });
    getTasks();
  }

  /// Toggle task completion status (optimized for instant UI update)
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      if (task.id != null) {
        // Update locally first for instant UI feedback
        final index = taskList.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          taskList[index].isCompleted = task.isCompleted;
          taskList.refresh(); // Trigger UI update
        }
        
        // Update Firebase in background
        await FBdbHelper.updateTaskInFirebase(task);
        print("Task completion toggled successfully");
      }
    } catch (e) {
      print("Error toggling task completion: $e");
      // Revert on error
      getTasks();
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
