import 'package:find_a_friend/routes/router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';

void main() async {
  await initializeRust(assignRustSignal);
  runApp(const MyApp());
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "flutter_background example app",
    notificationText: "Background notification for keeping the example app running in the background",
    notificationImportance: AndroidNotificationImportance.normal,
    notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
        routerConfig: router,
        title: 'Find-A-Friend',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false);
  }
}
