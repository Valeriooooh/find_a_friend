import 'package:find_a_friend/pages/home.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class MyAppRouter {
  GoRouter router = GoRouter(
    routes: [
      GoRoute(
          name: "home",
          path: "/",
          pageBuilder: (context, state) {
            return MaterialPage(child: Home());
          }),
    ],
  );
}
