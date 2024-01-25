import 'package:bible_app/atom/bookmark.dart';
import 'package:bible_app/molecules/menu_bar.dart';
import 'package:bible_app/pages/book_mark.dart';
import 'package:bible_app/pages/home_page.dart';
import 'package:bible_app/pages/splash.dart';

import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bible_app/utils/bottom_bar.dart';
import 'package:bible_app/utils/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationHandler().getFcmToken();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyAppComponent();
  }
}

class MyAppComponent extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initializeNotificationService();
  }

  void initializeNotificationService() async {
    NotificationHandler().getFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (content) => BookState()),
        ],
        child: MaterialApp(
          title: 'BIBLE APP',
          initialRoute: 'splash',
          routes: {
            'Home': (context) => const MyHomePage(),
            'Book': (context) => const BookMarkPage(),
            'Menu': (context) => const SideMenu(),
            'bottom': (context) => const BottomBar(),
            'splash': (context) => const SplashScreen(),
          },
        ));
  }
}
