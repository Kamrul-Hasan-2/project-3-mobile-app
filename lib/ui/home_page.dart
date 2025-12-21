import 'package:event_manager/SignIn/auth_service.dart';
import 'package:event_manager/SignIn/login_screen.dart';
import 'package:event_manager/cloud%20backup/backup_restore.dart';
import 'package:event_manager/controllers/taskfb_controller.dart';
import 'package:event_manager/pin/app_lock_service.dart';
import 'package:event_manager/pin/reset_pin_screen.dart';
import 'package:event_manager/pin/set_pin_screen.dart';
import 'package:event_manager/services/pdf_service.dart';
import 'package:event_manager/ui/widgets/addtask_btn.dart';
import 'package:event_manager/ui/widgets/progress_tracker_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:event_manager/models/task.dart';
import 'package:event_manager/services/notification_services.dart';
import 'package:event_manager/ui/add_task_bar.dart';
import 'package:event_manager/ui/theme.dart';
import 'package:event_manager/ui/widgets/task_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _taskfbController = Get.put(TaskFbController());

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchVisible = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshTasks();
    NotifyHelper();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: _appBar(),
        drawer: _buildDrawer(context), // Add the Drawer here
        body: Column(
          children: [
            _addTaskBar(),

            _addDateBar(),

            // Progress Tracker
            Obx(() {
              final totalTasks = _taskfbController.taskList.length;
              final completedTasks = _taskfbController.taskList
                  .where((task) => task.isCompleted == 1)
                  .length;
              final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ProgressTrackerWidget(
                  progress: progress,
                  backgroundColor: context.theme.primaryColor,
                  progressColor: Colors.white,
                  height: 30,
                  borderRadius: 10,
                  text: '$completedTasks of $totalTasks tasks completed',
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            }),

            const SizedBox(
              height: 10,
            ),

            // _isSearchVisible ? _searchBar() : Container(),

            _showTasks(),
          ],
        ));
  }

  _appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: context.theme.primaryColor,
      title: _isSearchVisible
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white, width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search events...",
                  hintStyle: subTitleStyle.copyWith(color: Colors.white70),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              ),
            )
          : null,

      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          _scaffoldKey.currentState!
              .openDrawer(); //  Use GlobalKey to open Drawer
        },
      ),

      actions: [
        if (!_isSearchVisible)
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = true;
              });
            },
            child: const Icon(Icons.search, size: 24, color: Colors.white),
          ),
        if (_isSearchVisible)
          GestureDetector(
            onTap: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _isSearchVisible = false;
              });
            },
            child: const Icon(Icons.close, size: 24, color: Colors.white),
          ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            Get.snackbar(
              "Under Development",
              "This feature is under development.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.white,
              colorText: pinkClr,
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            );
          },
          child: Icon(
            Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            size: 20,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text(
                  'Today',
                  style: headingStyle,
                )
              ],
            ),
          ),
          Addtask_btn(
              label: "+ Add Task",
              onTap: () async {
                await Get.to(() => AddTaskPage());
                _taskfbController.getTasks();
              })
        ],
      ),
    );
  }

  _addDateBar() {
    return DatePicker(
      DateTime.now(),
      height: 100,
      width: 80,
      initialSelectedDate: DateTime.now(),
      selectionColor: primaryClr,
      selectedTextColor: Colors.white,
      dateTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      dayTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      monthTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      onDateChange: (date) {
        setState(() {
          _selectedDate = date;
          print("Selected date: $_selectedDate");
        });
      },
    );
  }


  _showTasks() {
    return Expanded(
      child: Obx(() {
        final filteredTasks = _taskfbController.taskList.where((task) {
          return task.title!.toLowerCase().contains(_searchQuery) ||
              task.description!.toLowerCase().contains(_searchQuery) ||
              task.category!.toLowerCase().contains(_searchQuery);
        }).toList();

        final tasksToDisplay =
            _searchQuery.isNotEmpty ? filteredTasks : _taskfbController.taskList;

        return ListView.builder(
            itemCount: tasksToDisplay.length,
            itemBuilder: (_, index) {
              // print(_taskController.taskList.length);

              Task task = tasksToDisplay[index];
              print(task.toJson());

              // if (task.repeat == 'Daily' ||
              //     task.date == DateFormat.yMd().format(_selectedDate)) {
              //   // date picker
              //
              //   return AnimationConfiguration.staggeredList(
              //       position: index,
              //       child: SlideAnimation(
              //           child: FadeInAnimation(
              //               child: Row(
              //         children: [
              //           GestureDetector(
              //             onTap: () {
              //               _showBottomSheet(context, task);
              //             },
              //             child: TaskTile(task),
              //           )
              //         ],
              //       ))));
              // };

              if (task.date == DateFormat.yMd().format(_selectedDate)) {
                //
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                        child: FadeInAnimation(
                            child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context, task);
                          },
                          child: TaskTile(task),
                        )
                      ],
                    ))));
              } else {
                return Container();
              }
            });
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.32
            : MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width,
        color: Get.isDarkMode
            ? darkGreyClr
            : Colors.white, // Adjust color for dark mode

        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
            ),
            Spacer(),
            task.isCompleted == 1
                ? Container()
                : _bottomSheetButton(
                    label: "Task Completed",
                    onTap: () {
                      // _taskController.markTaskCompleted(task.id!);
                      Get.back();
                    },
                    clr: primaryClr,
                    context: context,
                  ),
            // update button
            _bottomSheetButton(
              label: "Update Task",
              onTap: () {
                Get.off(() => AddTaskPage(task: task));
              },
              clr: Colors.blue,
              context: context,
            ),
            // Delete button
            _bottomSheetButton(
              label: "Delete Task",
              onTap: () {
                _taskfbController.delete(task);
                Get.back();
              },
              clr: Colors.red[300]!,
              context: context,
            ),
            const SizedBox(
              height: 20,
            ),
            // Close button
            _bottomSheetButton(
              label: "Close",
              onTap: () {
                Get.back();
              },
              clr: Colors.red[300]!,
              isClose: true,
              context: context,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _bottomSheetButton({
    required String label,
    required Function()? onTap,
    required Color clr,
    bool isClose = false,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose == true
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose == true ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void refreshTasks() {
    _taskfbController.getTasks();
    setState(() {});
  }
}

  //    -- ---  Nav Drawer    ---  --
Widget _buildDrawer(BuildContext context) {
  User? user = FirebaseAuth.instance.currentUser;
  print("Display Name: ${user?.displayName}");
  return Container(
    width: MediaQuery.of(context).size.width * 0.75,
    child: Drawer(
      child: Column(
        children: [
          ///  Header ---------------
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: const EdgeInsets.only(top: 35, left: 30, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child:
                  Text(
                    user != null && user.displayName != null && user.displayName!.isNotEmpty
                        ? user.displayName![0].toUpperCase()
                        : (user != null && user.isAnonymous ? 'G' : 'U'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
        ///  If Anonymous user ------------------
                const SizedBox(height: 10),
                if (user != null && user.isAnonymous)
                  GestureDetector(
                    onTap: () async {
                      await  linkAnonymousWithGoogle(context);
                      await FirebaseAuth.instance.currentUser?.reload();
                      User? updatedUser = FirebaseAuth.instance.currentUser;
                      print("Updated Display Name: ${updatedUser?.displayName}");
                      Get.back();
                    },

                    child: const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
              /// ----------------------
                  else if (user != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Welcome back',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          SizedBox(height: 40,),
          ///  Home -----------------
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),

          SizedBox(height: 20,),
          ///  Download PDF  ----------------
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text("Download PDF"),
            onTap: () async {
              try {
                await PdfExportService.exportTask();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PDF export successful!"))

                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error exporting PDF: $e")),
                );
              }
              Navigator.pop(context);
            },
          ),

          SizedBox(height: 20,),

          ///  Backup Data ----------------
          // ListTile(
          //   leading: const Icon(Icons.backup, color: Colors.blueAccent),
          //   title: const Text("Back-Up"),
          //   onTap: () async {
          //     await BackupRestore.backupToLocal();
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Backup saved successfully!')),
          //     );
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.blueAccent),
            title: const Text("Back-Up"),
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                await BackupRestore.backupToLocal();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup saved successfully!')),
                );
                Get.back();
              } else {
                Get.back();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please sign in first!')),
                );
              }
            },
          ),
          SizedBox(height: 20,),

          /// Restore Data--------------
          // ListTile(
          //   leading: const Icon(Icons.restore, color: Colors.purple),
          //   title: const Text("Restore Data"),
          //   onTap: () async {
          //     await BackupRestore.restoreFromLocal();
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Database restored successfully!')),
          //     );
          //     Navigator.pop(context);
          //   },
          // ),

          ListTile(
            leading: const Icon(Icons.restore, color: Colors.purple),
            title: const Text("Restore Data"),
            onTap: () async {
              var currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser != null) {
                await BackupRestore.restoreFromLocal();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database restored successfully!')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please sign in first')),
                );
              }
            },
          ),

          SizedBox(height: 20,),
          ///  App Lock ------------
          ListTile(
            leading: const Icon(Icons.lock_open_rounded, color: Colors.purpleAccent),
            title: const Text("App Lock"),
            onTap: () {
              AppLockService.isPinSet().then((isPinSet) {
                if (isPinSet) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPinScreen()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SetPinScreen()));
                }
              });
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 20,),

          ///  Logout-----------------
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              _showLogoutConfirmation();
            },
          ),
        ],
      ),
    ),
  );
}


Future<void> linkAnonymousWithGoogle(BuildContext context) async {
  try {
    await GoogleSignIn().signOut();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && currentUser.isAnonymous) {
      try {
        // Try to link
        UserCredential result = await currentUser.linkWithCredential(credential);
        final email = result.user?.email ?? 'User';

        print("Anonymous account linked to Google. UID: ${result.user?.uid}");
        print("Signed in display name: $email");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Signed in successfully as $email",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          print("Google account already in use. Cannot link anonymous user.");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "This Google account is already linked to another user. Please use a different account.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          rethrow;
        }
      }
    } else {
      print("User is not anonymous.");
      final displayName = currentUser?.displayName ?? 'User';
      print("Signed in display name: $displayName");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Already signed in as $displayName",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print("Error during anonymous to Google upgrade: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sign-in failed: $e")),
    );
  }
}



// Logout Confirmation Dialog -------------
void _showLogoutConfirmation() {
  Get.defaultDialog(
    title: "Logout",
    middleText: "Are you sure you want to log out?",
    textConfirm: "Yes",
    textCancel: "No",
    confirmTextColor: Colors.white,
    onConfirm: () {
      AuthService().logout();
      Get.off(() => LoginScreen());
    },
  );
}

