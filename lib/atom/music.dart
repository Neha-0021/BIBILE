import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bible_app/state-management/AudioPlayers.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _MusicPlayerState extends State<MusicPlayer>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  String _deviceId = 'Unknown';
  final AudioState audioState = AudioState();

  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Use the 'vsync' provided by this mixin to create a Ticker
    ticker = this.createTicker((elapsed) {
      // Update your UI here
      setState(() {});
    })
      ..start();
  }

  @override
  void dispose() {
    ticker.dispose();
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
    final chapterState = Provider.of<BookState>(context, listen: false);
    final audioState = Provider.of<AudioState>(context, listen: false);
    List<String> chapterTitles = chapterState.chapter
        .map((chapter) => (chapter['chapterNumber']).toString())
        .toList();

    bool isCellTextSelected = chapterState.selectedChapterId != null;
    Future<void> playPreviousChapter() async {
      audioState.audioPlayer.stop();
      int currentIndex =
          chapterState.getChapterIndexById(chapterState.selectedChapterId!);
      int previousIndex = currentIndex - 1;
      if (previousIndex < 0) {
        // If the current chapter is the first one, set the previous index to the last chapter
        previousIndex = chapterState.chapter.length - 1;
      }
      chapterState
          .setSelectedChapterId(chapterState.chapter[previousIndex]["_id"]);

      // Additional parameters for the previous chapter
      String chapterId = chapterState.chapter[previousIndex]["_id"];
      String bookName = chapterState.getSelectedBookTitle() ?? "";

      await audioState.playChapter(
        chapterState.chapter,
        previousIndex,
        bookName,
      );

      // Fetch chapterId and deviceId
      String deviceId = _deviceId;
      chapterState.getBookMarkbychapterIddeviceId(chapterId, deviceId);
    }

    Future<void> playNextChapter() async {
      audioState.audioPlayer.stop();
      int currentIndex =
          chapterState.getChapterIndexById(chapterState.selectedChapterId!);
      int nextIndex = (currentIndex + 1) % chapterState.chapter.length;
      chapterState.setSelectedChapterId(chapterState.chapter[nextIndex]["_id"]);

      // Additional parameters for the next chapter
      String chapterId = chapterState.chapter[nextIndex]["_id"];
      String bookName = chapterState.getSelectedBookTitle() ?? "";

      await audioState.playChapter(
        chapterState.chapter,
        nextIndex, // Use nextIndex instead of getSelectedCellIndex
        bookName,
      );

      // Fetch chapterId and deviceId
      String deviceId = _deviceId;
      chapterState.getBookMarkbychapterIddeviceId(chapterId, deviceId);
    }

    String selectedChapterId = chapterState.selectedChapterId ?? "";
    String bookTitle = "";

    // Find the index of the selected chapter
    int selectedIndex = chapterState.getChapterIndexById(selectedChapterId);

    // Determine if a chapter is currently selected
    bool isChapterSelected = selectedIndex != -1;

    if (isChapterSelected) {
      // Get the book ID of the selected chapter
      String bookId = chapterState.chapter[selectedIndex]["bookId"];

      // Get the title of the book using the book ID
      bookTitle = chapterState.books.firstWhere((book) => book['_id'] == bookId,
              orElse: () => {})['title'] ??
          "";
    }

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
                    if (isChapterSelected)
                      TextSpan(
                        text: selectedIndex == 0
                            ? '$bookTitle Introduction'
                            : ' $bookTitle $selectedIndex',
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
        if (audioState.audioPlayer.positionStream != null)
          StreamBuilder<Duration>(
            stream: audioState.audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = isCellTextSelected
                  ? snapshot.data ?? Duration.zero
                  : Duration.zero;
              final duration = isCellTextSelected
                  ? audioState.audioPlayer.duration ?? Duration.zero
                  : Duration.zero;
              return Column(
                children: [
                  Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    activeColor:
                        isCellTextSelected ? Colors.red[700] : Colors.grey,
                    onChanged: (value) {
                      final newPosition = Duration(seconds: value.toInt());
                      audioState.audioPlayer.seek(newPosition);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          isCellTextSelected
                              ? '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} '
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
                              ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
                              : '00:00',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
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
                        String currentBookId = chapterState.selectedBookId;
                        String currentChapterId =
                            chapterState.selectedChapterId ?? "";

                        // Get the index of the current book
                        int currentIndex = chapterState.books
                            .indexWhere((book) => book["_id"] == currentBookId);

                        // Calculate the index of the previous book
                        int previousBookIndex =
                            (currentIndex - 1 + chapterState.books.length) %
                                chapterState.books.length;

                        // Get the ID of the previous book
                        String previousBookId =
                            chapterState.books[previousBookIndex]["_id"];

                        // Set the selected book ID to the previous book ID
                        chapterState.setSelectedBookId(previousBookId);

                        // Load chapters for the previous book
                        await chapterState.getChapterBybookId(previousBookId);

                        // Get the last chapter index for the previous book
                        int lastChapterIndex = chapterState.chapter.length - 1;

                        // Set the selected chapter ID to the last chapter ID of the previous book
                        chapterState.setSelectedChapterId(
                            chapterState.chapter[lastChapterIndex]["_id"]);

                        // Play the last chapter of the previous book
                        await audioState.playChapter(
                          chapterState.chapter,
                          lastChapterIndex,
                          chapterState.getSelectedBookTitle() ?? "",
                        );

                        // Get chapter ID and device ID for bookmark
                        String chapterId =
                            chapterState.chapter[lastChapterIndex]["_id"];
                        String deviceId = _deviceId;
                        chapterState.getBookMarkbychapterIddeviceId(
                            chapterId, deviceId);
                      }
                    : () => showToast(
                        "No audio is playing, please play any chapter first"),
                child: SvgPicture.asset(
                  "assets/images/svg/Previous_Book.svg",
                  height: 30,
                  width: 30,
                  color: Colors.red[700],
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
            audioState.isLoading
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
                      icon: Icon(audioState.audioPlayer.playing
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: isCellTextSelected
                          ? () {
                              audioState.playPause();
                            }
                          : () => showToast(
                              "No audio is playing, please play any chapter first"),
                      color: isCellTextSelected
                          ? Colors.white
                          : const Color.fromARGB(255, 247, 142, 152),
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
                      String currentBookId = chapterState.selectedBookId;
                      String currentChapterId =
                          chapterState.selectedChapterId ?? "";

                      // Get the index of the current book
                      int currentIndex = chapterState.books
                          .indexWhere((book) => book["_id"] == currentBookId);

                      // Calculate the index of the next book
                      int nextBookIndex =
                          (currentIndex + 1) % chapterState.books.length;

                      // Get the ID of the next book
                      String nextBookId =
                          chapterState.books[nextBookIndex]["_id"];

                      // Set the selected book ID to the next book ID
                      chapterState.setSelectedBookId(nextBookId);

                      // Load chapters for the next book
                      await chapterState.getChapterBybookId(nextBookId);

                      // Get the first chapter index for the next book
                      int firstChapterIndex = 0;

                      // Set the selected chapter ID to the first chapter ID of the next book
                      if (chapterState.chapter.isNotEmpty) {
                        chapterState.setSelectedChapterId(
                            chapterState.chapter[firstChapterIndex]["_id"]);

                        // Play the first chapter of the next book
                        await audioState.playChapter(
                          chapterState.chapter,
                          firstChapterIndex,
                          chapterState.getSelectedBookTitle() ?? "",
                        );

                        // Get chapter ID and device ID for bookmark
                        String chapterId =
                            chapterState.chapter[firstChapterIndex]["_id"];
                        String deviceId = _deviceId;
                        chapterState.getBookMarkbychapterIddeviceId(
                            chapterId, deviceId);
                      } else {
                        audioState.stop();
                      }
                    }
                  : () => showToast(
                      "No audio is playing, please play any chapter first"),
              child: SvgPicture.asset(
                "assets/images/svg/Previous_Book.svg",
                height: 30,
                width: 30,
                color: Colors.red[700],
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
