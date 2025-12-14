import 'package:event_manager/cloud%20backup/backup_restore.dart';
import 'package:event_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:event_manager/pin/app_lock_service.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:event_manager/ui/theme.dart';

class SetPinScreen extends StatefulWidget {
  @override
  _SetPinScreenState createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  TextEditingController pinController = TextEditingController();
  TextEditingController hintAnswerController = TextEditingController();
  String selectedQuestion = "What is your Favourite Place";

  final List<String> hintQuestions = [
    "What is your Favourite Place",
    "What is your Favourite Food",
    "What is your Favourite Movie",
    "What is your Pet Name",
  ];

  void _savePin() async {
    if (pinController.text.isEmpty || hintAnswerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    // Save PIN & Hint Answer
    await AppLockService.setPin(pinController.text);
    await AppLockService.setHintQuestion(selectedQuestion);
    await AppLockService.setHintAnswer(hintAnswerController.text);

    Navigator.pop(context); // Close screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('App Lock PIN Set Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set App Lock PIN",),
       backgroundColor: context.theme.primaryColor,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField(
            //   controller: pinController,
            //   obscureText: true,
            //   keyboardType: TextInputType.number,
            //   decoration: InputDecoration(labelText: "Enter PIN"),
            // ),


            const SizedBox(height: 10), // Spacing between label and input field
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter your PIN", // Placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5), // Rounded border
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            SizedBox(height: 20),
            Text("Security Questions", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("These questions will help you when you forget your password. All your "
                "security answers will be encrypted and stored only in the local device.",
                style: TextStyle(fontWeight: FontWeight.normal)),
            DropdownButton<String>(
              value: selectedQuestion,
              onChanged: (value) {
                setState(() {
                  selectedQuestion = value!;
                });
              },
              items: hintQuestions.map((question) {
                return DropdownMenuItem(
                  value: question,
                  child: Text(question),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // TextField(
            //   controller: hintAnswerController,
            //   decoration: InputDecoration(labelText: "Enter Answer"),
            // ),
            TextField(
              controller: hintAnswerController,
              decoration: InputDecoration(
                hintText: "Type your answer here", // Optional hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2), // Highlighted when focused
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adds spacing inside the field
              ),
            ),

            SizedBox(height: 20),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: _savePin,
            //     style: ElevatedButton.styleFrom(// Button color
            //       foregroundColor: Colors.white, // Text color
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10), // Rounded corners
            //       ),
            //       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Padding for better touch area
            //       elevation: 5, // Adds a shadow effect
            //                       ),
            //     child: Text(
            //       "Save",
            //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryClr ,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _savePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Make button background transparent
                  shadowColor: Colors.transparent, // Remove default shadow
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )


          ],
        ),
      ),
    );
  }
}
