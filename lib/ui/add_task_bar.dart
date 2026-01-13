import 'dart:io';
import 'package:event_manager/controllers/taskfb_controller.dart';
import 'package:event_manager/models/task.dart';
import 'package:event_manager/ui/media_preview/image_screen.dart';
import 'package:event_manager/ui/theme.dart';
import 'package:event_manager/ui/widgets/create_task_btn.dart';
import 'package:event_manager/ui/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;
  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  // final TaskController _taskController = Get.put(TaskController());
  final TaskFbController _taskfbController = Get.put(TaskFbController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = "9:30 PM";

  String _selectedCategory = "Work";
  final List<String> categoryList = ["Work", "Personal", "Birthday", "Meeting"];

  int _selectedRemind = 5;
  final List<int> remindList = [0, 5, 10, 15, 20];

  String _selectedRepeat = "None";
  final List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];

  List<XFile> _selectedImages = [];

  int _selectedColor = 0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _loadTaskData(widget.task!);
    }
  }

  // void _loadTaskData(Task task) {
  //   _titleController.text = task.title!;
  //   _descController.text = task.description!;
  //   _locationController.text = task.location!;
  //   _selectedDate = DateFormat.yMd().parse(task.date!);
  //   _startTime = task.startTime!;
  //   _endTime = task.endTime!;
  //   _selectedCategory = task.category!;
  //   _selectedRemind = task.remind!;
  //   _selectedRepeat = task.repeat!;
  //   _selectedColor = task.color!;
  //
  //   if (task.photoPaths != "No Image Found!") {
  //     _selectedImages = File(task.photoPaths!);
  //   }
  //   if (task.videoPaths != "No Video Found!") {
  //     _selectedVideos = File(task.videoPaths!);
  //   }
  //   if (task.filePaths != "No File Found!") {
  //     _selectedFiles = File(task.filePaths!);
  //   }
  // }
  void _loadTaskData(Task task) {
    _titleController.text = task.title!;
    _descController.text = task.description!;
    _locationController.text = task.location!;
    _selectedDate = DateFormat.yMd().parse(task.date!);
    _startTime = task.startTime!;
    _endTime = task.endTime!;
    _selectedCategory = task.category!;
    _selectedRemind = task.remind!;
    _selectedRepeat = task.repeat!;
    _selectedColor = task.color!;

    _selectedImages =
        task.photoPaths?.map((path) => XFile(path)).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, task: widget.task),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyInputField(
                title: "Title",
                hint: "Enter your title",
                controller: _titleController,
              ),
              MyInputField(
                title: "Description",
                hint: "Enter your description",
                controller: _descController,
              ),
              MyInputField(
                title: "Date",
                hint: DateFormat('dd-MM-yyyy').format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined,
                      color: Colors.grey),
                  onPressed: _getDateFromUser,
                ),
                onTap: () => _getDateFromUser(),
              ),

              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: "Start Time",
                      hint: _startTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_rounded,
                            color: Colors.grey),
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                      ),
                      onTap: () => _getTimeFromUser(isStartTime: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyInputField(
                      title: "End Time",
                      hint: _endTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_rounded,
                            color: Colors.grey),
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                      ),
                      onTap: () => _getTimeFromUser(isStartTime: false),
                    ),
                  ),
                ],
              ),
              MyInputField(
                title: "Location",
                hint: "Enter your location",
                controller: _locationController,
              ),

              MyInputField(
                title: "Category",
                hint: _selectedCategory,
                onTap: () => _showCategoryPicker(),
                widget: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ),

              MyInputField(
                title: "Remind",
                hint: _selectedRemind == 0
                    ? "On time"
                    : "$_selectedRemind minutes early",
                onTap: () => _showRemindPicker(),
                widget: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ),

              // MyInputField(
              //   title: "Repeat",
              //   hint: _selectedRepeat,
              //   widget: Padding(
              //     padding: const EdgeInsets.only(right: 15),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         // Vertical Divider
              //         // Container(
              //         //   width: 1,
              //         //   height: 40, // Adjust height as per design
              //         //   color: Colors.grey, // Divider color (changeable)
              //         // ),
              //         // const SizedBox(width: 10), // Space between divider and dropdown
              //
              //         // Dropdown Button
              //         DropdownButton(
              //           icon: const Icon(Icons.keyboard_arrow_down,
              //               color: Colors.grey),
              //           iconSize: 32,
              //           elevation: 4,
              //           style: subTitleStyle,
              //           underline: Container(height: 0),
              //           items: repeatList.map((value) {
              //             return DropdownMenuItem(
              //               value: value,
              //               child: Text(
              //                 value,
              //                 style: TextStyle(
              //                   color: Get.isDarkMode
              //                       ? Colors.white
              //                       : Colors.black,
              //                 ),
              //               ),
              //             );
              //           }).toList(),
              //           onChanged: (newValue) {
              //             setState(() {
              //               _selectedRepeat = newValue!;
              //             });
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Attach Image", style: titleStyle),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _mediaButton(
                      "Image", Icons.image, Colors.blueAccent, _pickImages),
                ],
              ),
              const SizedBox(height: 10),

              /// media preview --------------
              if (_selectedImages.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _selectedImages
                        .map((img) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _mediaPreview("Image", img.path, () {
                                setState(() {
                                  _selectedImages.remove(img);
                                });
                              }),
                            ))
                        .toList(),
                  ),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _colorPalette(),
                ],
              ),
              const SizedBox(height: 16),
              MyCreateTaskBtn(
                  label: widget.task == null ? "Create Task" : "Update Task",
                  onTap: _validateData),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context, {required task}) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.primaryColor,
      leading: GestureDetector(
        onTap: Get.back,
        child: Icon(
          Icons.arrow_back_outlined,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      title: Text(
        task == null ? "Add Task" : "Update Task",
        style: headingStyle,
      ),
    );
  }

  Future<void> _getDateFromUser() async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2028),
    );
    if (pickerDate != null) {
      setState(() {
        _selectedDate = pickerDate;
      });
    }
  }

  Future<void> _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);

      setState(() {
        if (isStartTime) {
          _startTime = formattedTime;
        } else {
          _endTime = formattedTime;
        }
      });
    }
  }

  Widget _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select task color", style: titleStyle),
        const SizedBox(height: 8),
        Wrap(
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () {
                if (index == 3) {
                  _showColorPicker();
                } else {
                  setState(() {
                    _selectedColor = index;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : index == 2
                              ? yellowClr
                              : _customColor,
                  child: _selectedColor == index
                      ? const Icon(Icons.done, color: Colors.white, size: 16)
                      : (index == 3
                          ? const Icon(Icons.color_lens,
                              color: Colors.white, size: 16)
                          : Container()),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showColorPicker() {
    Color tempColor = _customColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a color"),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              showLabel: false,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _customColor = tempColor;
                  customColor =
                      tempColor; // ✅ Update global color in theme.dart
                  _selectedColor = 3;
                });
                Navigator.pop(context);
              },
              child: const Text("Select"),
            ),
          ],
        );
      },
    );
  }

  Color _customColor = Colors.blue;

  Future<void> _validateData() async {
    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
      if (widget.task != null) {
        await _updateTaskInDb();
      } else {
        await _addTaskToDb();
      }
      Get.back();
    } else {
      Get.snackbar(
        "Required",
        "All fields are required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      );
    }
  }

  // Future<void> _addTaskToDb() async {
  //   Task task = Task(
  //     title: _titleController.text,
  //     description: _descController.text,
  //     date: DateFormat.yMd().format(_selectedDate),
  //     startTime: _startTime,
  //     endTime: _endTime,
  //     location: _locationController.text,
  //     category: _selectedCategory,
  //     remind: _selectedRemind,
  //     repeat: _selectedRepeat,
  //     color: _selectedColor,
  //     photoPath: _selectedImage?.path ?? "No Image Found!",
  //     videoPath: _selectedVideo?.path ?? "No Video Found!",
  //     filePath: _selectedFile?.path ?? "No File Found!",
  //     isCompleted: 0,
  //   );
  //   int value = await _taskController.addTask(task: task);
  //   print("Task added with ID: $value");
  // }

  // Future<void> _addTaskToDb() async {
  //   Task task = Task(
  //     title: _titleController.text,
  //     description: _descController.text,
  //     date: DateFormat.yMd().format(_selectedDate),
  //     startTime: _startTime,
  //     endTime: _endTime,
  //     location: _locationController.text,
  //     category: _selectedCategory,
  //     remind: _selectedRemind,
  //     repeat: _selectedRepeat,
  //     color: _selectedColor,
  //     photoPath: _selectedImage?.path ?? "No Image Found!",
  //     videoPath: _selectedVideo?.path ?? "No Video Found!",
  //     filePath: _selectedFile?.path ?? "No File Found!",
  //     isCompleted: 0,
  //   );
  //
  //   await _taskfbController.addTask(task: task); // Firebase helper
  //   print("Task added to Firebase!");
  // }

  Future<void> _addTaskToDb() async {
    Task task = Task(
      title: _titleController.text,
      description: _descController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      location: _locationController.text,
      category: _selectedCategory,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
      photoPaths: _selectedImages.map((e) => e.path).toList(),
    );

    await _taskfbController.addTask(task: task);
    print("Task with images added to Firebase!");
  }

  Future<void> _updateTaskInDb() async {
    Task updatedTask = Task(
      id: widget.task!.id,
      title: _titleController.text,
      description: _descController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      location: _locationController.text,
      category: _selectedCategory,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      photoPaths: _selectedImages.map((e) => e.path).toList(),
      isCompleted: widget.task!.isCompleted,
    );
    await _taskfbController.updateEvents(updatedTask);
    print("Task updated: ${updatedTask.title}");
    print('Updating Task with ID: ${widget.task!.id}');
  }

  Widget _mediaButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 5),
          Text(label, style: subTitleStyle),
        ],
      ),
    );
  }

  Widget _mediaPreview(String type, String path, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullImageScreen(imagePath: path),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Pick images
  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    }
  }

  // Show category picker dialog
  void _showCategoryPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: categoryList.map((category) {
              return ListTile(
                title: Text(category),
                leading: Radio<String>(
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Show remind picker dialog
  void _showRemindPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Reminder Time"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: remindList.map((remind) {
              return ListTile(
                title: Text(remind == 0 ? "On time" : "$remind minutes early"),
                leading: Radio<int>(
                  value: remind,
                  groupValue: _selectedRemind,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedRemind = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedRemind = remind;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
