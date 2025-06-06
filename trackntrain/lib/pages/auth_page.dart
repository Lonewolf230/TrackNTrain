import 'package:flutter/material.dart';
import '../tabs/login_tab.dart';
import '../tabs/signup_tab.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // App logo
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Welcome text
                  Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login or create an account to continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Tab bar
            TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Login'),
                Tab(text: 'Sign Up'),
              ],
            ),
            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  LoginTab(),
                  SignUpTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}