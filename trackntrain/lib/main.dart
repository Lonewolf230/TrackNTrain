import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/pages/create_full_body.dart';
import 'package:trackntrain/pages/full_body_workout.dart';
import 'package:trackntrain/pages/hiit_workout.dart';
import 'package:trackntrain/pages/home_page.dart';
import 'package:trackntrain/pages/profile_page.dart';
import 'package:trackntrain/pages/create_hiit_page.dart';
import 'package:trackntrain/pages/walk_or_run.dart';
import 'package:trackntrain/tabs/full_body_tab.dart';
import 'package:trackntrain/tabs/hiit_tab.dart';
import 'package:trackntrain/tabs/walking_tab.dart';
import 'package:trackntrain/utils/auth_notifier.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/slide_left_transition_builder.dart';
import 'pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final AuthNotifier _authNotifier= AuthNotifier();

final _router = GoRouter(
  initialLocation: '/auth',
  observers: [HeroController()],
  redirect: (context, state) {
    final isAuthenticated=AuthService.isAuthenticated;
    final isAuthRoute=state.matchedLocation.startsWith('/auth');
    print('Redirect check - Auth: $isAuthenticated, Auth Route: ${state.matchedLocation}');
    print('Current User: ${AuthService.currentUser}');
    if(!isAuthenticated && !isAuthRoute){
      print('Redirecting to auth page');
      return '/auth';
    } 
    if(isAuthenticated && isAuthRoute) {
      print('Redirecting to home page');
      return '/home';
    }
    return null;
  } ,
  refreshListenable: _authNotifier,
  routes: [
    GoRoute(path: '/auth', name: 'auth', builder: (context, state) =>const AuthPage()),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: 'full-body',
          name: 'full-body',
          builder: (context, state) => const FullBodyTab(),
          routes: <RouteBase>[
            GoRoute(
              path:'create-full-body',
              name: 'create-full-body',
              builder: (context,state)=>const CreateFullBody()
            ),
            GoRoute(
              path:'start-full-body',
              name: 'start-full-body',
              builder: (context,state)=>const FullBodyWorkout()
            )
          ]
        ),
        GoRoute(
          path: 'walking',
          name: 'walking',
          builder: (context, state) => const WalkingTab(),
          routes: <RouteBase>[
            GoRoute(path: 'walk-progress', name: 'walk-progress', builder: (context, state) => const WalkProgress())
          ]
        ),
        GoRoute(
          path: 'hiit',
          name: 'hiit',
          builder: (context, state) => HiitTab(),
          routes: <RouteBase>[
            GoRoute(
              path: 'create-hiit',
              name: 'create-hiit',
              builder: (context, state) => const CreateHiitPage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'hiit-started',
                  name: 'hiit-started',
                  builder: (context, state) {
                    final exercises = state.extra as List<String>;
                    final rounds =
                        int.tryParse(
                          state.uri.queryParameters['rounds'] ?? '5',
                        ) ??
                        5;
                    final rest =
                        int.tryParse(
                          state.uri.queryParameters['rest'] ?? '15',
                        ) ??
                        15;
                    final work =
                        int.tryParse(
                          state.uri.queryParameters['work'] ?? '30',
                        ) ??
                        30;

                    return HiitWorkout(
                      exercises: exercises,
                      rounds: rounds,
                      restDuration: rest,
                      workDuration: work,
                    );
                  },
                ),
              ],
            ),
          ],
        ), 
      ],
    ),
  ],
);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(ProviderScope(child: const MyApp()));
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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SlideLeftTransitionBuilder(),
            TargetPlatform.iOS: SlideLeftTransitionBuilder(),
          }
        ),
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
