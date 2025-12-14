import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:event_manager/ui/home_page.dart';
import 'package:event_manager/pin/app_lock_service.dart';

class PinEntryScreen extends StatefulWidget {
  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  TextEditingController _pinController = TextEditingController();
  String? errorMessage;


  void _validatePin() async {
    bool isValid = await AppLockService.validatePin(_pinController.text);
    if (isValid) {
      Get.off(() => HomePage());
    } else {
      setState(() {
        errorMessage = "Incorrect PIN. Try again.";
      });
    }
  }


  void _testBiometricAuth() async {
    try {
      bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to proceed',
        options: AuthenticationOptions(biometricOnly: true),
      );

      print("Authentication success: $isAuthenticated");

      if (isAuthenticated) {
        Get.off(() => HomePage()); // Navigate on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric authentication failed!')),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  void _showForgotPinDialog() async {
    String? hintQuestion = await AppLockService.getHintQuestion();
    if (hintQuestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hint question set!')),
      );
      return;
    }

    TextEditingController hintAnswerController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Forgot PIN"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hint Question: $hintQuestion",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: hintAnswerController,
                decoration: InputDecoration(
                  labelText: "Enter your answer",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                String? storedAnswer = await AppLockService.getHintAnswer();
                if (hintAnswerController.text == storedAnswer) {
                  String? storedPin = await AppLockService.getPin();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Your PIN is: $storedPin')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect answer!')),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phonelink_lock, size: 80, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                "Enter your PIN to unlock",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Enter PIN",
                  prefixIcon: Icon(Icons.lock_outline),
                  errorText: errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _validatePin,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Unlock", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _showForgotPinDialog,
                child: Text(
                  "Forgot PIN?",
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _testBiometricAuth,
                child: Text("Use Fingerprint / Face ID"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
