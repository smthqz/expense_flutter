import 'package:hive/hive.dart';

class HiveUser {
  static final _userBox = Hive.box('userBox');

  static Future<void> saveUserEmail(String email) async {
    await _userBox.put('userEmail', email);
  }

  static String? getUserEmail() {
    return _userBox.get('userEmail');
  }

  static Future<void> removeUserEmail() async {
    await _userBox.delete('userEmail');
  }
}
