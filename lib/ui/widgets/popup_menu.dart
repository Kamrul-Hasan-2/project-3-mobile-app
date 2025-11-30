import 'package:event_manager/SignIn/auth_service.dart';
import 'package:event_manager/SignIn/login_screen.dart';
import 'package:event_manager/pin/reset_pin_screen.dart';
import 'package:event_manager/pin/set_pin_screen.dart';
import 'package:event_manager/pin/app_lock_service.dart';
import 'package:event_manager/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:event_manager/cloud%20backup/backup_restore.dart';
import 'package:get/get.dart';

final AuthService _authService = AuthService();

extension PopupMenuAvatar on Widget {

  Widget popupMenu(
      {required BuildContext context, DateTime? startDate, DateTime? endDate}) {
    return
      PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'view') {
          // Handle view profile action`
        } else if (value == 'edit') {
          // Handle edit profile action
        } else if (value == 'pdf') {
          // Call the PdfExportService to export the tasks as PDF
          try {
            await PdfExportService.exportTask(); // Call export method
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("PDF export successful!")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error exporting PDF: $e")),
            );
          }
        } else if (value == 'backup') {
          await BackupRestore.backupToLocal();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup saved successfully!')),
          );
        } else if (value == 'restore') {
          await BackupRestore.restoreFromLocal();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Database restored successfully!')),
          );
        } else if (value == 'lock') {
          AppLockService.isPinSet().then((isPinSet) {
            if (isPinSet) {
              // Navigate to Reset PIN screen if PIN already exists
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResetPinScreen()),
              );
            } else {
              // Navigate to Set PIN screen if no PIN is set
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SetPinScreen()),
              );
            }
          });
        } else if (value == 'logout') {
          _showLogoutConfirmation();
          _authService.logout();
        }
      },
      itemBuilder: (context) => [
        _buildPopupItem(Icons.person, 'View Profile', 'view'),
        _buildPopupItem(Icons.edit, 'Edit Profile', 'edit'),
        _buildPopupItem(Icons.picture_as_pdf, 'Download PDF', 'pdf'),
        _buildPopupItem(Icons.backup, 'Back-Up', 'backup'),
        _buildPopupItem(Icons.restore, 'Restore Data', 'restore'),
        _buildPopupItem(Icons.lock_open_rounded, 'App Lock', 'lock'),
        _buildPopupItem(Icons.logout, 'Logout', 'logout'),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      color: Colors.white,
      elevation: 8, // Shadow effect
      child: this,
    );
  }

  PopupMenuItem<String> _buildPopupItem(
      IconData icon, String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent), // Colored icons
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to log out?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.off(() => LoginScreen());
      },
    );
  }
}
