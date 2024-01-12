import 'dart:io';

import 'package:bible_app/atom/bookmark.dart';
import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:bible_app/utils/bottom-bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:device_info/device_info.dart';

import 'package:flutter/services.dart';
import 'dart:async';

import 'package:share_plus/share_plus.dart';

class BookMarkPage extends StatefulWidget {
  const BookMarkPage({super.key});

  @override
  _BookMarkPageState createState() => _BookMarkPageState();
}

late Timer _timer;

class _BookMarkPageState extends State<BookMarkPage> {
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      initializeAsyncLogic();
    });
    String platform = Platform.isAndroid ? "android" : "ios";
    final bookState = Provider.of<BookState>(context, listen: false);

    bookState.getShareLinkbyPlatform(platform);
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer.cancel();
    super.dispose();
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

    final bookState = Provider.of<BookState>(context, listen: false);
    await bookState.getBookMarkbydeviceId(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookState>(
      builder: (context, bookState, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[700],
          iconTheme: IconThemeData(color: Colors.white),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'BookMark',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.share),
                color: Colors.white,
                onPressed: () {
                  Share.share(bookState.shareableLink);
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookState.bookmark.length,
            itemBuilder: (context, index) {
              final data = bookState.bookmark[index];
              return BookMarkCard(
                data: data,
              );
            },
          ),
        ),
      ),
    );
  }
}
