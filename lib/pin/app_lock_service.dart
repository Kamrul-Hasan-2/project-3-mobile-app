import 'package:get_storage/get_storage.dart';

class AppLockService {
  static final _storage = GetStorage();

  static Future<void> setPin(String pin) async {
    await _storage.write('app_pin', pin);
  }

  static Future<String?> getPin() async {
    return _storage.read('app_pin');
  }

  static Future<bool> isPinSet() async {
    return _storage.hasData('app_pin');
  }

  // Save hint question
  static Future<void> setHintQuestion(String question) async {
    await _storage.write('hint_question', question);
  }

  static Future<String?> getHintQuestion() async {
    return _storage.read('hint_question');
  }

  // Save hint answer
  static Future<void> setHintAnswer(String answer) async {
    await _storage.write('hint_answer', answer);
  }

  static Future<String?> getHintAnswer() async {
    return _storage.read('hint_answer');
  }

  // Validate the PIN
  static Future<bool> validatePin(String enteredPin) async {
    final storedPin = await getPin();
    return storedPin == enteredPin;
  }
  // Remove the App Lock PIN
  static Future<bool> removePin(String enteredPin) async {
    final storedPin = await getPin();
    if (storedPin == enteredPin) {
      await _storage.remove('app_pin');
      await _storage.remove('hint_question');
      await _storage.remove('hint_answer');
      return true; // PIN removed successfully
    }
    return false; // Incorrect PIN
  }

  // // Biometric Authentication
  // static Future<bool> authenticateWithBiometrics() async {
  //   try {
  //     bool canAuthenticate = await _auth.canCheckBiometrics;
  //     bool isDeviceSupported = await _auth.isDeviceSupported();
  //
  //     print("Can check biometrics: $canAuthenticate");
  //     print("Is device supported: $isDeviceSupported");
  //
  //     if (!canAuthenticate && !isDeviceSupported) {
  //       print("Biometric authentication is not available.");
  //       return false;
  //     }
  //
  //     bool isAuthenticated = await _auth.authenticate(
  //       localizedReason: 'Use fingerprint or face unlock',
  //       options: AuthenticationOptions(biometricOnly: true),
  //     );
  //
  //     print("Authentication successful: $isAuthenticated");
  //     return isAuthenticated;
  //   } catch (e) {
  //     print("Biometric authentication error: $e");
  //     return false;
  //   }
  // }


}


