import 'dart:io';

import 'package:bible_app/atom/music.dart';
import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class Chapter extends StatefulWidget {
  @override
  _ChapterState createState() => _ChapterState();
}

class _ChapterState extends State<Chapter> {
  String _deviceId = 'Unknown';
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final bookState = Provider.of<BookState>(context, listen: false);
      String bookId = bookState.books.first["_id"];
      bookState.getChapterBybookId(bookId);
      bookState.setSelectedBookId(bookId);

      bookState.getSelectedCellIndex(bookId);

      bookState.getChapterBybookId(bookId);
    });
    initPlatformState();
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
    final chapterState = Provider.of<BookState>(context);

    List<String> chapterTitles = chapterState.chapter
        .map((chapter) => (chapter['chapterNumber']).toString())
        .toList();
    List<String> chapterTitle = chapterState.chapter
        .map((chapter) => (chapter['title'] ?? '').toString())
        .toList();
    List<dynamic> audioUrls =
        chapterState.chapter.map((chapter) => chapter['audioUrl']).toList();

    double screenWidth = MediaQuery.of(context).size.width;
    int initialColumns = (screenWidth / 100).floor();

    int columns = initialColumns > 0 ? initialColumns : 1;

    int rows = (chapterTitles.length / columns).ceil();

    return Consumer<BookState>(
      builder: (context, chapterState, child) => DefaultTabController(
        length: 1,
        child: Container(
          color: const Color(0xFFf5f5f5),
          child: TabBarView(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: {
                          for (var index
                              in List.generate(columns, (index) => index))
                            index: const FlexColumnWidth(1.0),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: TableBorder.all(
                          color: Color(0xFFf5f5f5),
                          width: 3.0,
                        ),
                        children: List.generate(rows, (rowIndex) {
                          return TableRow(
                            children: List.generate(
                              columns,
                              (colIndex) {
                                int index = rowIndex * columns + colIndex;
                                if (index < chapterTitles.length) {
                                   String cellText = (colIndex == 0 &&
                                                  rowIndex == 0)
                                              ? (index < chapterTitle.length
                                                  ? chapterTitle[index]
                                                  : "")
                                              : (index < chapterTitles.length
                                                  ? chapterTitles[index]
                                                  : "");

                                  return GestureDetector(
                                    onTap: () async {
                                      chapterState.setSelectedCellIndices(
                                        chapterState.selectedBookId,
                                        index,
                                      );
                                      String audioUrl = audioUrls[index];
                                      String chapterId =
                                          chapterState.chapter[index]["_id"];
                                      print('chapterId : $chapterId');
                                      String deviceId = _deviceId;
                                      chapterState
                                          .getBookMarkbychapterIddeviceId(
                                              chapterId, deviceId);
                                      chapterState.play(audioUrl,
                                          chapterState.selectedBookId);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: index ==
                                                  chapterState
                                                      .getSelectedCellIndex(
                                                          chapterState
                                                              .selectedBookId)
                                              ? Colors.red
                                              : Colors.transparent,
                                          width: 4.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Center(
                                          child: Text(
                                            cellText,
                                            style: GoogleFonts.lato(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MusicPlayer(),
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
