import 'dart:async';
import 'dart:io';

import 'package:bible_app/atom/music.dart';
import 'package:bible_app/state-management/AudioPlayers.dart';
import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toast/toast.dart';

class Chapters extends StatefulWidget {
  final String? bookId;

  const Chapters({Key? key, required this.bookId}) : super(key: key);

  @override
  _ChaptersState createState() => _ChaptersState();
}

class _ChaptersState extends State<Chapters>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  String _deviceId = 'Unknown';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (mounted) {
        await checkSelectedBook();
      }
      await initPlatformState();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> checkSelectedBook() async {
    final bookState = Provider.of<BookState>(context, listen: false);

    String defaultBookId =
        bookState.books.isNotEmpty ? bookState.books.first["_id"] : "";
    String selectedBookId = widget.bookId ?? defaultBookId;
    bookState.setSelectedBookId(selectedBookId);

    // Reset the selected cell index here
    bookState.setSelectedCellIndices(selectedBookId, -1);

    await bookState.getChapterBybookId(selectedBookId);
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

    List<String> chapterTitles = chapterState.chapter
        .map((chapter) => (chapter['chapterNumber']).toString())
        .toList();

    double screenWidth = MediaQuery.of(context).size.width;
    int initialColumns = (screenWidth / 100).floor();

    int columns = initialColumns > 0 ? initialColumns : 1;

    int rows = (chapterTitles.length / columns).ceil();

    String selectedBookTitle = chapterState.getSelectedBookTitle() ?? "";
    String selectedBookId = chapterState.selectedBookId;

    return Consumer<BookState>(
      builder: (context, chapterState, child) => DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red[700],
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedBookTitle,
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: chapterState
                                    .getSelectedCellIndex(selectedBookId) !=
                                -1
                            ? () async {
                                int index = chapterState
                                    .getSelectedCellIndex(selectedBookId);
                                String chapterId =
                                    chapterState.chapter[index]["_id"];
                                String deviceId = _deviceId;
                                chapterState.addBookmark(
                                    chapterId, deviceId, context);
                              }
                            : () => showToast(
                                "No audio is playing, please play any chapter first"),
                        icon: Icon(
                          chapterState.isBookMarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          size: 30.0,
                          color: chapterState
                                      .getSelectedCellIndex(selectedBookId) !=
                                  -1
                              ? Colors.amber[600] // Enabled color
                              : Colors.amber[600]?.withOpacity(
                                  0.5), // Disabled color with reduced opacity
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        color: Colors.white,
                        onPressed: () {
                          Share.share(chapterState.shareableLink);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            color: const Color(0xFFf5f5f5),
            child: Column(
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
                                  children: List.generate(rows, (rowIndex) {
                                    return TableRow(
                                      children: List.generate(
                                        columns,
                                        (colIndex) {
                                          int index =
                                              rowIndex * columns + colIndex;
                                          if (index < chapterTitles.length) {
                                            String cellText =
                                                chapterTitles[index];
                                            return GestureDetector(
                                              onTap: () async {
                                                chapterState
                                                    .setSelectedCellIndices(
                                                        selectedBookId, index);
                                                await Provider.of<AudioState>(
                                                  context,
                                                  listen: false,
                                                ).playChapter(
                                                  chapterState.chapter,
                                                  index,
                                                  chapterState
                                                      .getSelectedBookTitle(),
                                                );
                                                Provider.of<AudioState>(
                                                  context,
                                                  listen: false,
                                                )
                                                    .audioPlayer
                                                    .currentIndexStream
                                                    .listen((index) {
                                                  if (index != null) {
                                                    chapterState
                                                        .setSelectedCellIndices(
                                                            selectedBookId,
                                                            index);
                                                  }
                                                });
                                                String chapterId = chapterState
                                                    .chapter[index]["_id"];
                                                String deviceId = _deviceId;
                                                chapterState
                                                    .getBookMarkbychapterIddeviceId(
                                                        chapterId, deviceId);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: index ==
                                                            chapterState
                                                                .getSelectedCellIndex(
                                                                    selectedBookId)
                                                        ? Colors.red
                                                        : Colors.transparent,
                                                    width: 4.0,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 20,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      cellText,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
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
          ),
        ),
      ),
    );
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
