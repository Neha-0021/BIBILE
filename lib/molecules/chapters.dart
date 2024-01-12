import 'dart:async';
import 'dart:io';

import 'package:bible_app/atom/music.dart';
import 'package:bible_app/pages/Book-Mark.dart';
import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:device_info/device_info.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class Chapters extends StatefulWidget {
  final String? bookId;

  Chapters({required this.bookId});

  @override
  _ChaptersState createState() => _ChaptersState();
}

class _ChaptersState extends State<Chapters> {
  String _deviceId = 'Unknown';
  Timer? selcetedBookChapter;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        checkSelectedBook();
        initPlatformState();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Chapters oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if bookId has changed, then call checkSelectedBook
    if (widget.bookId != oldWidget.bookId) {
      checkSelectedBook();
    }
  }

  void checkSelectedBook() {
    final bookState = Provider.of<BookState>(context, listen: false);

    String defaultBookId =
        bookState.books.isNotEmpty ? bookState.books.first["_id"] : "";
    String selectedBookId = widget.bookId ?? defaultBookId;
    bookState.setSelectedBookId(selectedBookId);
    bookState.getSelectedCellIndex(selectedBookId);

    // Fetch chapters for the selected book
    bookState.getChapterBybookId(selectedBookId);

    setState(() {
      isLoading = false;
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

    String selectedBookTitle = chapterState.getSelectedBookTitle() ?? "";
    return DefaultTabController(
        length: 1,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red[700],
              iconTheme: IconThemeData(color: Colors.white),
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
                      child: Row(children: [
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: chapterState.getSelectedCellIndex(
                                      chapterState.selectedBookId) !=
                                  -1
                              ? () async {
                                  String chapterId = chapterState.chapter[
                                      chapterState.getSelectedCellIndex(
                                          chapterState.selectedBookId)]["_id"];
                                  String deviceId = _deviceId;
                                  print('Device ID: $_deviceId\n');
                                  chapterState.addBookmark(
                                      chapterId, deviceId, context);
                                }
                              : null, // Set onPressed to null when no cell text is selected
                          icon: Icon(
                            chapterState.isBookMarked
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            size: 30.0,
                            color: chapterState.getSelectedCellIndex(
                                        chapterState.selectedBookId) !=
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
                            Share.share(chapterState.shareableLink);
                          },
                        ),
                      ]))
                ],
              ),
            ),
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : Container(
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
                            child: SingleChildScrollView(
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
                                  color: Color(0xFFf5f5f5),
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
                                              chapterState
                                                  .setSelectedCellIndices(
                                                chapterState.selectedBookId,
                                                index,
                                              );
                                              String audioUrl =
                                                  audioUrls[index];
                                              String chapterId = chapterState
                                                  .chapter[index]["_id"];
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
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
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: MusicPlayer(),
                            ))
                      ],
                    ),
                  )));
  }
}
