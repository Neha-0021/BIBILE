import 'dart:async';
import 'dart:io';

import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:bible_app/utils/bottom-bar.dart';
import 'package:bible_app/utils/notification-handler.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeAsyncLogic();

   Timer(
      const Duration(seconds: 3),
       () => Navigator.pushNamedAndRemoveUntil(
       context, "bottom", (route) => false));
  }

  Future<void> initializeAsyncLogic() async {
    String deviceId = "";

    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.androidId;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      deviceId = 'Failed to get Device ID.';
    }

    if (!mounted) return;

    setState(() {
      deviceId;
    });

    print("Device ID: $deviceId");
    String fcmToken = await NotificationHandler().getFcmToken();
    final bookState = Provider.of<BookState>(context, listen: false);
    bookState.SaveToken(deviceId, fcmToken);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF931916),
      child: Center(
        child: Image.asset(
          'assets/images/splash.png',
        ),
      ),
    );
  }
}
