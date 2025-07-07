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
      rethrow ;
    }
  }

  static Future<void> deleteAccount() async{
    try {
      final user=currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      await user.delete();
    }on FirebaseAuthException catch (e) {
      if(e.code=='requires-recent-login'){
        throw Exception('For security reasons, please log-out and log back in to delete your account.');
      }
      else{
        throw Exception('Error deleting account: ${e.message}');
      }
    }catch(e){
      rethrow;
    }
  }
}
