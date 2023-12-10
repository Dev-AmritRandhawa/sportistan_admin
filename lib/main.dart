import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:sportistan_admin/authentication/login.dart';
import 'package:sportistan_admin/firebase_options.dart';
import 'package:sportistan_admin/home/home.dart';
import 'package:sportistan_admin/widgets/page_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.debug);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MaterialApp(home: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return  MaterialApp(
      theme: ThemeData.light(useMaterial3: false),
themeMode: ThemeMode.light,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(milliseconds: 3000), () async {
              if (_auth.currentUser != null) {
                try {
                  PageRouter.pushRemoveUntil(context, const Home());
                } catch (e) {
                  return e;
                }
              } else {
                PageRouter.pushRemoveUntil(context, const Login());
              }
            }));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Lottie.asset(
              'assets/loading.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..repeat();
              },
            ),
            Image.asset("assets/logo.png",
                height: MediaQuery.of(context).size.height / 8),
            const Text("Admin Console", style: TextStyle(fontFamily: "DMSans")),
            const CircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 1,
            )
          ],
        ),
      ),
    );
  }
}
