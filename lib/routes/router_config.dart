import 'package:find_a_friend/pages/home.dart';
import 'package:find_a_friend/pages/party_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

GoRouter router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
        path: "/",
        pageBuilder: (context, state) {
          return const MaterialPage(child: Home());
        }),
    GoRoute(
        path: "/party/:partyId",
        pageBuilder: (context, state) {
          return MaterialPage(
              child: PartyPage(
            partyId: state.pathParameters["partyId"]!,
          ));
        }),
  ],
);
