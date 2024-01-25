import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toast/toast.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> with WidgetsBindingObserver {
  String _deviceId = 'Unknown';
  final BookState bookState = BookState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final bookState = Provider.of<BookState>(context, listen: false);

    bookState.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          bookState.setIsPlaying(state);
        });
      }
    });
    bookState.audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          bookState.setDuration(d);
        });
      }
    });
    bookState.audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          bookState.setPosition(p);
        });
      }
    });

    initPlatformState();
  }

  @override
  void dispose() {
    bookState.audioPlayer.stop();

    bookState.audioPlayer.dispose();
    super.dispose();
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
    ToastContext().init(context);
    final chapterState = Provider.of<BookState>(context);
    List<String> chapterTitles = chapterState.chapter
        .map((chapter) => (chapter['chapterNumber']).toString())
        .toList();
    List<dynamic> audioUrls =
        chapterState.chapter.map((chapter) => chapter['audioUrl']).toList();

    Future<void> playPreviousChapter() async {
      if (chapterState.getSelectedCellIndex(chapterState.selectedBookId) > 0) {
        chapterState.setSelectedCellIndices(
          chapterState.selectedBookId,
          chapterState.getSelectedCellIndex(chapterState.selectedBookId) - 1,
        );
      } else {
        chapterState.setSelectedCellIndices(
          chapterState.selectedBookId,
          chapterTitles.length - 1,
        );
      }

      String audioUrl = audioUrls[
          chapterState.getSelectedCellIndex(chapterState.selectedBookId)];
      chapterState.play(
        audioUrl,
        chapterState.selectedBookId,
      );

      // Fetch chapterId and deviceId
      String chapterId = chapterState.chapter[chapterState
          .getSelectedCellIndex(chapterState.selectedBookId)]["_id"];
      String deviceId = _deviceId;

      // Call getBookmarkbychapterIddeviceId API
      chapterState.getBookMarkbychapterIddeviceId(chapterId, deviceId);
    }

    Future<void> playNextChapter() async {
      if (chapterState.getSelectedCellIndex(chapterState.selectedBookId) <
          chapterTitles.length - 1) {
        chapterState.setSelectedCellIndices(
          chapterState.selectedBookId,
          chapterState.getSelectedCellIndex(chapterState.selectedBookId) + 1,
        );
      } else {
        chapterState.setSelectedCellIndices(chapterState.selectedBookId, 0);
      }

      String audioUrl = audioUrls[
          chapterState.getSelectedCellIndex(chapterState.selectedBookId)];
      chapterState.play(audioUrl, chapterState.selectedBookId);

      String chapterId = chapterState.chapter[chapterState
          .getSelectedCellIndex(chapterState.selectedBookId)]["_id"];
      String deviceId = _deviceId;

      chapterState.getBookMarkbychapterIddeviceId(chapterId, deviceId);
    }

    bool isCellTextSelected = chapterState.books.any(
      (book) => chapterState.getSelectedCellIndex(book['_id']) != -1,
    );

    List<String> chapterTitle = chapterState.chapter
        .map((chapter) => (chapter['title'] ?? '').toString())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(60.0),
            bottomRight: Radius.circular(60.0),
          ),
          child: Container(
            height: 60,
            color: Colors.red[700],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Now Playing: ',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    for (var book in chapterState.books)
                      if (chapterState.getSelectedCellIndex(book['_id']) != -1)
                        TextSpan(
                          text: chapterState
                                      .getSelectedCellIndex(book['_id']) ==
                                  0
                              ? '${book["title"]} ${chapterTitle[chapterState.getSelectedCellIndex(book['_id'])]}'
                              : '${book["title"]} ${chapterTitles[chapterState.getSelectedCellIndex(book['_id'])]}',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Slider(
          value: isCellTextSelected
              ? chapterState.position.inSeconds.toDouble()
              : 0.0,
          min: 0,
          max: isCellTextSelected
              ? chapterState.duration.inSeconds.toDouble()
              : 0.0,
          activeColor: isCellTextSelected ? Colors.red[700] : Colors.grey,
          onChanged: (value) {
            if (isCellTextSelected) {
              final position = Duration(seconds: value.toInt());
              chapterState.audioPlayer.seek(position);
              chapterState.audioPlayer.resume();
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                isCellTextSelected
                    ? chapterState.formatTime(chapterState.position)
                    : '00:00',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                isCellTextSelected
                    ? chapterState.formatTime(
                        chapterState.duration - chapterState.position,
                      )
                    : '00:00',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: GestureDetector(
                onTap: isCellTextSelected
                    ? () async {
                        // Get the currently selected book ID
                        int currentIndex = chapterState.getSelectedBookIndex();

                        // Calculate the index of the previous book in the list
                        int previousBookIndex =
                            (currentIndex - 1 + chapterState.books.length) %
                                chapterState.books.length;

                        chapterState.setSelectedBookIndex(previousBookIndex);
                        String previousBookId =
                            chapterState.books[previousBookIndex]["_id"];

                        // Set the selected book index to the previous book
                        chapterState.setSelectedBookId(previousBookId);

                        // Fetch chapters for the selected book
                        await chapterState.getChapterBybookId(previousBookId);

                        if (chapterState.chapter.isNotEmpty) {
                          setState(() {
                            int lastChapterIndex =
                                chapterState.chapter.length - 1;
                            // Set the selected book index to the last chapter of the previous book
                            chapterState.setSelectedCellIndices(
                                previousBookId, lastChapterIndex);

                            String audioUrl = chapterState
                                .chapter[lastChapterIndex]['audioUrl'];
                            chapterState.play(audioUrl, previousBookId);

                            String chapterId =
                                chapterState.chapter[lastChapterIndex]["_id"];
                            String deviceId = _deviceId;

                            // Call getBookmarkbychapterIddeviceId API
                            chapterState.getBookMarkbychapterIddeviceId(
                                chapterId, deviceId);
                          });
                        } else {
                          chapterState.clearSelectedCellIndices();
                          chapterState.stopPlaying();
                        }
                      }
                    : () => showToast(
                        "No audio is playing, please play any chapter first"),
                child: SvgPicture.asset(
                  // ignore: deprecated_member_use
                  color: Colors.red[700],
                  "assets/images/svg/Previous_Book.svg",
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            GestureDetector(
              onTap: isCellTextSelected
                  ? () {
                      playPreviousChapter();
                    }
                  : () => showToast(
                      "No audio is playing, please play any chapter first"),
              child: SvgPicture.asset(
                // ignore: deprecated_member_use
                color: Colors.red[700],
                "assets/images/svg/02._Previous_Chapter.svg",
                height: 30,
                width: 30,
              ),
            ),
            chapterState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.red[700],
                    child: IconButton(
                      icon: Icon(
                        chapterState.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 35,
                      ),
                      color: isCellTextSelected
                          ? Colors.white
                          : const Color.fromARGB(255, 247, 142, 152),
                      onPressed: isCellTextSelected
                          ? () async {
                              if (chapterState.isPlaying) {
                                chapterState.audioPlayer.pause();
                              } else {
                                chapterState.audioPlayer.resume();
                              }
                            }
                          : () => showToast(
                              "No audio is playing, please play any chapter first"),
                    ),
                  ),
            GestureDetector(
              onTap: isCellTextSelected
                  ? () {
                      playNextChapter();
                    }
                  : () => showToast(
                      " No audio is playing, please play any chapter first"),
              child: SvgPicture.asset(
                "assets/images/svg/04._Previous_Chapter.svg",
                // ignore: deprecated_member_use
                color: Colors.red[700],
                height: 30,
                width: 30,
              ),
            ),
            GestureDetector(
              onTap: isCellTextSelected
                  ? () async {
                      // Get the currently selected book ID
                      int currentIndex = chapterState.getSelectedBookIndex();

                      // Calculate the index of the previous book in the list
                      int nextBookIndex =
                          (currentIndex + 1 + chapterState.books.length) %
                              chapterState.books.length;

                      chapterState.setSelectedBookIndex(nextBookIndex);
                      String nextBookId =
                          chapterState.books[nextBookIndex]["_id"];

                      // Set the selected book index to the previous book
                      chapterState.setSelectedBookId(nextBookId);

                      // Fetch chapters for the selected book
                      await chapterState.getChapterBybookId(nextBookId);

                      if (chapterState.chapter.isNotEmpty) {
                        setState(() {
                          chapterState.setSelectedCellIndices(nextBookId, 0);

                          String audioUrl = chapterState.chapter[0]['audioUrl'];
                          chapterState.play(audioUrl, nextBookId);
                          String chapterId = chapterState.chapter[0]["_id"];
                          String deviceId = _deviceId;

                          // Call getBookmarkbychapterIddeviceId API
                          chapterState.getBookMarkbychapterIddeviceId(
                              chapterId, deviceId);
                        });
                      } else {
                        chapterState.clearSelectedCellIndices();
                        chapterState.stopPlaying();
                      }
                    }
                  : () => showToast(
                      "No audio is playing, please play any chapter first"),
              child: SvgPicture.asset(
                "assets/images/svg/Previous_Book.svg",
                height: 30,
                width: 30,
                // ignore: deprecated_member_use
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
