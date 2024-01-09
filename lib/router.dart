import 'package:flutter/material.dart';
import 'package:drbaapp/welcome.dart';
import 'package:go_router/go_router.dart';
import 'GroupInfoPage.dart';
import 'Newsfeed_Info.dart';
import 'chat.dart';
import 'event_info.dart';
import 'package:firebase_auth/firebase_auth.dart';

final router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) async {
    try {
      final user = await FirebaseAuth.instance.currentUser!;
      if (user.uid!=null) {
        print('Signed in');
      } else {
        print('Not Signed in');
        return '/';

      }
    }catch (e){
      print('Not Signed in');
      return '/';
    }
  },
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'Welcome', // Optional, add name to your routes. Allows you navigate by name instead of path
      path: '/',
      builder: (context, state) =>  Welcome(),
    routes: [
    GoRoute(
      path: "news:newsID",
      name: "news",
      builder: (context, state) => Newsfeed_info(
        state.pathParameters["newsID"].toString(),
        'from welcome',
      )
    ),
      GoRoute(
          path: "event:eventID",
          name: "Event",
          builder: (context, state) => eventInfo(
            state.pathParameters["eventID"].toString(),
            'from welcome',
          )
      ),
      GoRoute(
        path: "group:groupID",
        name: "Group",
        builder: (context, state) =>  GroupInfoPage(groupID: state.pathParameters["groupID"].toString(), currentUserName: 'from welcome'
        ),
      ),
      GoRoute(
        path: "chat:receiverName/:currentUserName/:receiverID",
        name: "Chat",
        builder: (context, state) => chatPage(
            receiverName:
            state.pathParameters["receiverName"].toString().replaceAll('%20', ' '),
            currentUserName:
            state.pathParameters["currentUserName"].toString().replaceAll('%20', ' '),
            receiverID:
            state.pathParameters["receiverID"].toString()),
      )
    ],),
  ],
);



