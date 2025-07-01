import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/classes.dart';
import 'package:trackntrain/utils/google_auth_utils.dart';
import 'package:trackntrain/utils/misc.dart';
import '../components/social_button.dart';
import '../components/auth_button.dart';
import '../components/auth_text_field.dart';
import 'package:trackntrain/utils/normal_auth_utils.dart';

class SignUpTab extends StatefulWidget {
  const SignUpTab({super.key});

  @override
  State<SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<SignUpTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        final message = await signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          context,
        );

        UserData userData = UserData(
          userId: AuthService.auth.currentUser?.uid ?? '',
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(message)
            .set(userData.toMap(), SetOptions(merge: true));
        final String today = DateTime.now().toIso8601String().split('T')[0];

        await FirebaseFirestore.instance
            .collection('userMetaLogs')
            .doc('${message}_$today')
            .set({
              'userId': message,
              'date': today,
              'createdAt': FieldValue.serverTimestamp(),
              'hasWorkedOut': false,
              'weight': null,
              'mood': null,
              'lastAIResponse':"",
              'lastAIResponseAt': null,
            });
      }
    } on Exception catch (e) {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        if (e.toString() != null || e.toString()?.isNotEmpty == true) {
          showCustomSnackBar(
            context: context,
            message: cleanErrorMessage(e.toString()),
            type: 'error',
          );
        }
      }
    }
  }

  void _signUpWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      final message = await signInWithGoogle();

      if (message != null) {
        UserData userData = UserData(userId: message);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(message)
            .set(userData.toMap(), SetOptions(merge: true));

        final String today = DateTime.now().toIso8601String().split('T')[0];
        final ninetyDaysTimeStamp = Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 90)),
        );

        await FirebaseFirestore.instance
            .collection('userMetaLogs')
            .doc('${message}_$today')
            .set({
              'userId': message,
              'date': today,
              'createdAt': FieldValue.serverTimestamp(),
              'sleep': 0,
              'hasWorkedOut': false,
              'weight': null,
              'mood': null,
              'expireAt': ninetyDaysTimeStamp,
            });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        if (e.toString() != null || e.toString().isNotEmpty) {
          showCustomSnackBar(
            context: context,
            message: cleanErrorMessage(e.toString()),
            type: 'error',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            AuthTextField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            AuthTextField(
              controller: _emailController,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            AuthTextField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            AuthTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            AuthButton(
              text: 'Sign Up',
              onPressed: _signUp,
              isLoading: isLoading,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SocialButton(
                  icon: 'assets/images/google.png',
                  onPressed: () {
                    _signUpWithGoogle();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
