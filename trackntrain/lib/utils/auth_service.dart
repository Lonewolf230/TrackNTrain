import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
//   static Future<void> _reAuthenticateUser() async {
//     final user = currentUser;
//     if (user == null) throw Exception('No user signed in');

//     final isGoogleUser = user.providerData.any(
//       (info) => info.providerId == 'google.com'
//     );
    
//     if (isGoogleUser) {
//       await _reAuthenticateWithGoogle();
//     } else {
//       // For email/password users, you might need to prompt for password
//       throw Exception('Please sign out and sign back in, then try deleting your account again.');
//     }
//   }

//   static Future<void> _reAuthenticateWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) throw Exception('Google sign-in was cancelled');

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       await currentUser!.reauthenticateWithCredential(credential);
//     } catch (e) {
//       throw Exception('Re-authentication failed: $e');
//     }
//   }

//   static bool needsRecentLogin(FirebaseAuthException e) {
//     return e.code == 'requires-recent-login';
//   }
// }