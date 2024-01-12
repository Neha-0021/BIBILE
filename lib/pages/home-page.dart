import 'dart:io';

import 'package:bible_app/atom/books.dart';
import 'package:bible_app/atom/chapter.dart';
import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:device_info/device_info.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _toggleIndex = 1; // Set the initial index to 1 for "New"
  String _deviceId = 'Unknown';
  bool shouldUpdateSelectedIndex = true;

  @override
  void initState() {
    super.initState();
    final bookState = Provider.of<BookState>(context, listen: false);
    String platform = Platform.isAndroid ? "android" : "ios";

    bookState.getShareLinkbyPlatform(platform);

    initPlatformState();

    // Set the initial state of the toggle button to "New"
    setState(() {
      _toggleIndex = 1;
    });

    if (_toggleIndex == 0) {
      bookState.getBooksByType('old');
    } else if (_toggleIndex == 1) {
      bookState.getBooksByType('new');
    }
  }

  Future<void> initPlatformState() async {
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
      _deviceId = deviceId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookState = Provider.of<BookState>(context, listen: false);

    return Consumer<BookState>(
      builder: (context, bookState, child) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red[700],
            title: Row(
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/Logo.png',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ToggleSwitch(
                    minWidth: 50.0,
                    cornerRadius: 20.0,
                    activeBgColors: [
                      [Colors.amber[600]!],
                      [Colors.amber[600]!],
                    ],
                    activeFgColor: Colors.black,
                    inactiveBgColor: Colors.white,
                    inactiveFgColor: Colors.black,
                    initialLabelIndex: _toggleIndex,
                    totalSwitches: 2,
                    labels: const ['Old', 'New'],
                    radiusStyle: true,
                    onToggle: (index) async {
                      print('switched to: $index');
                      setState(() {
                        _toggleIndex = index!;
                      });

                      if (_toggleIndex == 0) {
                        await bookState.getBooksByType('old');
                      } else if (_toggleIndex == 1) {
                        await bookState.getBooksByType('new');
                      }
                    },
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: bookState.getSelectedCellIndex(
                              bookState.selectedBookId) !=
                          -1
                      ? () async {
                          String chapterId = bookState.chapter[
                              bookState.getSelectedCellIndex(
                                  bookState.selectedBookId)]["_id"];
                          String deviceId = _deviceId;
                          print('Device ID: $_deviceId\n');
                          bookState.addBookmark(
                              chapterId, deviceId, context);
                        }
                      : null, // Set onPressed to null when no cell text is selected
                  icon: Icon(
                    bookState.isBookMarked
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    size: 30.0,
                    color: bookState.getSelectedCellIndex(
                                bookState.selectedBookId) !=
                            -1
                        ? Colors.amber[600] // Enabled color
                        : Colors.amber[600]?.withOpacity(
                            0.5), // Disabled color with reduced opacity
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  color: Colors.white,
                  onPressed: () {
                    // Use the share package to share content
                    Share.share(bookState.shareableLink);
                  },
                ),
              ],
            ),
            bottom: TabBar(
              tabs: const [
                Tab(text: 'Books'),
                Tab(text: 'Chapters'),
              ],
              indicator: BoxDecoration(
                color: Colors.amber[600],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              labelStyle: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Container(
            color: const Color(0xFFf5f5f5),
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Books(
                      selectedType: _toggleIndex == 0
                          ? 'old'
                          : (_toggleIndex == 1 ? 'new' : 'all')),
                ),
                Chapter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
