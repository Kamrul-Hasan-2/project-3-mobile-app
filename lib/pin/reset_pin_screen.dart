import 'package:flutter/material.dart';
import 'package:event_manager/pin/app_lock_service.dart';
import 'package:get/get_utils/get_utils.dart';

class ResetPinScreen extends StatefulWidget {
  @override
  _ResetPinScreenState createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  TextEditingController oldPinController = TextEditingController();
  TextEditingController newPinController = TextEditingController();

  void _updatePin() async {
    String? savedPin = await AppLockService.getPin(); // Get current PIN

    if (oldPinController.text != savedPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect Old PIN!')),
      );
      return;
    }

    if (newPinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New PIN cannot be empty!')),
      );
      return;
    }

    await AppLockService.setPin(newPinController.text); // Save new PIN
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PIN Updated Successfully!')),
    );
  }

  void _removePin() async {
    String? savedPin = await AppLockService.getPin();
    if (oldPinController.text != savedPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter currect PIN first!')),
      );
      return;
    }

    bool success = await AppLockService.removePin(oldPinController.text);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('App Lock Removed Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove PIN! Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset or Remove App Lock PIN"),
      backgroundColor: context.theme.primaryColor, ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: oldPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Current PIN",
                border: OutlineInputBorder( // Adds a border
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue, width: 2), // Border color
                ),
                focusedBorder: OutlineInputBorder( // Border when focused
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding inside the input
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter New PIN",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _updatePin,
                  child: Text("Update PIN"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _removePin,
                  child: Text("Remove PIN"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
