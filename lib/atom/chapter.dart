import 'dart:io';

import 'package:bible_app/atom/music.dart';
import 'package:bible_app/state-management/AudioPlayers.dart';

import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Chapter extends StatefulWidget {
  const Chapter({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChapterState createState() => _ChapterState();
}

class _ChapterState extends State<Chapter> {
  bool isLoading = true;
  String _deviceId = 'Unknown';
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final bookState = Provider.of<BookState>(context, listen: false);

      String bookId = bookState.books.first["_id"];
      bookState.getChapterBybookId(bookId);
      bookState.setSelectedBookId(bookId);

 

      bookState.getChapterBybookId(bookId);

      setState(() {
        isLoading = false;
      });

      await initPlatformState(); // Move this line inside the microtask
    });
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
    final chapterState = Provider.of<BookState>(context, listen: false);
    final audioState = Provider.of<AudioState>(context, listen: false);

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
    String selectedBookTitle = chapterState.getSelectedBookTitle() ?? "";

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
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          )
                       : chapterTitles.isNotEmpty
                                  ? SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Table(
                                        columnWidths: {
                                          for (var index in List.generate(
                                              columns, (index) => index))
                                            index: const FlexColumnWidth(1.0),
                                        },
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        border: TableBorder.all(
                                          color: const Color(0xFFf5f5f5),
                                          width: 3.0,
                                        ),
                                        children:
                                            List.generate(rows, (rowIndex) {
                                          return TableRow(
                                            children: List.generate(
                                              columns,
                                              (colIndex) {
                                                int index = rowIndex * columns +
                                                    colIndex;
                                                if (index <
                                                    chapterTitles.length) {
                                                  String cellText = (index <
                                                          chapterTitles.length)
                                                      ? (chapterState.chapter[
                                                                      index][
                                                                  "chapterNumber"] ==
                                                              0
                                                          ? "Introduction"
                                                          : chapterTitles[
                                                              index])
                                                      : "";
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      chapterState
                                                          .setSelectedChapterId(
                                                        chapterState
                                                                .chapter[index]
                                                            ["_id"],
                                                      );
                                                      List<dynamic> chapters =
                                                          chapterState.chapter;
                                                      await audioState
                                                          .audioPlayer
                                                          .stop();
                                                      await audioState
                                                          .playChapter(
                                                              chapters,
                                                              index,
                                                              selectedBookTitle);
                                                      audioState.audioPlayer
                                                          .currentIndexStream
                                                          .listen((index) {
                                                        if (index != null) {
                                                          chapterState
                                                              .setSelectedChapterId(
                                                            chapterState
                                                                    .chapter[
                                                                index]["_id"],
                                                          );
                                                        }
                                                      });
                                                      String chapterId =
                                                          chapterState.chapter[
                                                              index]["_id"];

                                                      String deviceId =
                                                          _deviceId;
                                                      if (kDebugMode) {
                                                        print(deviceId);
                                                      }
                                                      chapterState
                                                          .getBookMarkbychapterIddeviceId(
                                                              chapterId,
                                                              deviceId);
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: chapterState
                                                                      .selectedChapterId ==
                                                                  chapterState.chapter[
                                                                          index]
                                                                      ["_id"]
                                                              ? Colors.red
                                                              : Colors
                                                                  .transparent,
                                                          width: 4.0,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 20),
                                                        child: Center(
                                                          child: Text(
                                                            cellText,
                                                            style: GoogleFonts
                                                                .lato(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
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
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40),
                                        child: Container(
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 40),
                                            child: Text(
                                              'No chapter available for this book',
                                              style: GoogleFonts.lato(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
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
