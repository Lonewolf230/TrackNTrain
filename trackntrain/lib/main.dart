import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/pages/home_page.dart';
import 'package:trackntrain/pages/profile_page.dart';
import 'package:trackntrain/pages/create_hiit_page.dart';
import 'package:trackntrain/tabs/full_body_tab.dart';
import 'package:trackntrain/tabs/hiit_tab.dart';
import 'package:trackntrain/tabs/running_tab.dart';
import 'package:trackntrain/tabs/split_tab.dart';
import 'package:trackntrain/tabs/walking_tab.dart';
import 'pages/auth_page.dart';

final _router=GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'auth',
      builder: (context,state)=>AuthPage()
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context,state)=>const HomePage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context,state)=>const ProfilePage()
        ),
        GoRoute(
          path: 'full-body',
          name: 'full-body',
          builder: (context,state)=> const FullBodyTab()
        ),
        GoRoute(
          path: 'walking',
          name: 'walking',
          builder: (context,state)=> const WalkingTab()
        ),
        GoRoute(
          path: 'running',
          name: 'running',
          builder: (context,state)=> const RunningTab()
        ),
        GoRoute(
          path: 'splits',
          name: 'splits',
          builder: (context,state)=> const SplitTab()
        ),
        GoRoute(
          path: 'hiit',
          name: 'hiit',
          builder: (context,state)=> const HiitTab(),
          routes: <RouteBase>[
            GoRoute(
              path: 'create-hiit',
              name: 'create-hiit',
              builder: (context,state)=> const CreateHiitPage()
            ),
          ]
        )
      ]
    ),
  ]);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 247, 2, 2),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}