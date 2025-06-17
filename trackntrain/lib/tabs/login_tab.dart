import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/custom_snack_bar.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/google_auth_utils.dart';
import 'package:trackntrain/utils/misc.dart';
import 'package:trackntrain/utils/normal_auth_utils.dart';
import '../components/social_button.dart';
import '../components/auth_button.dart';
import '../components/auth_text_field.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        final message = await signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        print(AuthService.currentUser);
      } on Exception catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          if (e.toString() != null || e.toString().isNotEmpty == true) {
            showCustomSnackBar(
              context: context,
              message: cleanErrorMessage(e.toString()),
              type: 'error',
            );
          }
        }
      }
    }
  }

  void _loginViaGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      await signInWithGoogle();
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        if (e.toString() != null || e.toString().isNotEmpty == true) {
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
                  return 'Please enter your password';
                }
                return null;
              },
            ),

            // Remember me and Forgot password
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Login button
            AuthButton(text: 'Login', onPressed: _login, isLoading: isLoading),

            // OR divider
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
                    _loginViaGoogle();
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
