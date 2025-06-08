import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Stream<User?> get authStateChanges=>auth.authStateChanges();
  static User? get currentUser => auth.currentUser;
  static bool get isAuthenticated=>currentUser != null;

  static Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static Future<void> deleteAccount() async{
    try {
      if (currentUser != null) {
        await currentUser!.delete();
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }
}