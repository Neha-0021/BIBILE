import 'package:bible_app/atom/bookmark.dart';
import 'package:bible_app/molecules/menu-bar.dart';
import 'package:bible_app/pages/Book-Mark.dart';
import 'package:bible_app/pages/home-page.dart';
import 'package:bible_app/pages/splashScreen.dart';

import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bible_app/utils/bottom-bar.dart';
import 'package:bible_app/utils/notification-handler.dart';
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
        ChangeNotifierProvider(create: (content) =>  AudioPlayerService ()),
        ],
        child: MaterialApp(
          title: 'BIBLE APP',
          initialRoute: 'splash',
          routes: {
            'Home': (context) => MyHomePage(),
            'Book': (context) => BookMarkPage(),
            'Menu': (context) => SideMenu(),
            'bottom': (context) =>  BottomBar(),
            'splash':(context)=>const SplashScreen(),
          },
           
        ));
  }
}
