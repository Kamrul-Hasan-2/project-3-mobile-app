
import 'package:event_manager/controllers/taskfb_controller.dart';
import 'package:event_manager/db/fb_db_helper.dart';
import 'package:event_manager/pin/app_lock_service.dart';
import 'package:event_manager/pin/pin_screen.dart';
import 'package:event_manager/services/notification_services.dart';
import 'package:event_manager/ui/home_page.dart';
import 'package:event_manager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:event_manager/services/theme_services.dart';
import 'package:event_manager/SignIn/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest_all.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  // await FBdbHelper.;
  tz.initializeTimeZones();
  await NotifyHelper.initNotification();
  Get.put(TaskFbController());

  bool isPinSet = await AppLockService.isPinSet();
  User? user = FirebaseAuth.instance.currentUser;

  // fixed only portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(isPinSet: isPinSet, user: user));
}

class MyApp extends StatelessWidget {
  final bool isPinSet;
  final User? user;

  const MyApp({Key? key, required this.isPinSet, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Manager',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
      home: isPinSet
          ? PinEntryScreen()
          : (user != null
              ? HomePage()
              : LoginScreen()),
    );
  }
}
