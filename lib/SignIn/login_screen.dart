import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../SignIn/auth_service.dart';
import 'package:event_manager/ui/home_page.dart';
import 'register_screen.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  List<String> texts = [ "Event Reminder"];
  int currentIndex = 0;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _startTextAnimation();
  }

  void _startTextAnimation() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % texts.length;
        });
        _startTextAnimation();
      }
    });
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showSnackBar('Please enter a valid email!');
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnackBar('Password must be at least 6 characters long!');
      return;
    }

    var user = await _authService.loginWithEmail(email, password);
    if (user != null) {
      _showSnackBar('Login successful!');
      Get.off(() => HomePage());
    } else {
      _showSnackBar('Login failed! Please check your credentials.');
    }
  }

  void loginWithGoogle() async {
    var user = await _authService.signInWithGoogle();
    if (user != null) {
      Get.off(() => HomePage());
      _showSnackBar('Google Login successful!');
    } else {
      _showSnackBar('Google Login failed!');
    }
  }

  // Anonymous User create
  Future<void> signInAnonymously() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        print("Anonymous sign-in successful. UID: ${user.uid}");
        Get.off(() => HomePage());
      } else {
        print("Anonymous sign-in failed.");
      }
    } catch (e) {
      print("Error during anonymous sign-in: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
     return WillPopScope(
        onWillPop: () async {
      SystemNavigator.pop();
      return false;
    },
    child: Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.grey.shade50,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Image.asset('images/bg.jpg', height: 200),
                SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 800),
                  transitionBuilder: (widget, animation) {
                    return FadeTransition(opacity: animation, child: widget);
                  },
                  child: Text(
                    texts[currentIndex],
                    key: ValueKey<String>(texts[currentIndex]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                // SizedBox(height: 30),
                // TextField(
                //   controller: emailController,
                //   decoration: InputDecoration(
                //     labelText: 'Email',
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                //   ),
                // ),
                // SizedBox(height: 15),
                // TextField(
                //   controller: passwordController,
                //   obscureText: _isObscure,
                //   decoration: InputDecoration(
                //     labelText: 'Password',
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                //     suffixIcon: IconButton(
                //       icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                //       onPressed: () {
                //         setState(() {
                //           _isObscure = !_isObscure;
                //         });
                //       },
                //     ),
                //   ),
                // ),
                // SizedBox(height: 30),
                // ElevatedButton.icon(
                //   onPressed: login,
                //   icon: Icon(Icons.login, color: Colors.white),
                //   label: Text('Login', style: TextStyle(color: Colors.white)),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blueAccent,
                //     padding: EdgeInsets.symmetric(vertical: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                // ),

                SizedBox(height: 100),
                ElevatedButton.icon(
                  onPressed: loginWithGoogle,
                  icon: Icon(Icons.g_mobiledata, color: Colors.white),
                  label: Text('Sign in with Google', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () async {
                    _showSnackBar('Continuing as Guest...');

                    await signInAnonymously(); // Ensure Firebase signs in anonymously

                    Get.off(() => HomePage()); // Navigate to HomePage after successful sign-in
                  },
                  icon: Icon(Icons.person_outline, color: Colors.white),
                  label: Text('Continue as Guest', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/smuct.jpg', height: 50, width: 50,),
                    const SizedBox(width: 8),
                    const Text("Powered by SMUCT",style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                        color: Color(0xFF2F3B4B)
                    ),)
                  ],
                )


                // SizedBox(height: 20),
                // TextButton(
                //   onPressed: () => Get.to(() => RegisterScreen()),
                //   child: Text.rich(
                //     TextSpan(
                //       children: [
                //         TextSpan(text: "Don't have an account? "),
                //         TextSpan(
                //           text: 'Register',
                //           style: TextStyle(decoration: TextDecoration.underline),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    ),
     );
  }


  // @override
  // void dispose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }
}

