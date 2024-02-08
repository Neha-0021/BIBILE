import 'dart:async';

import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioState extends ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isLoading = false;

  String currentPlayingId = "";
  ConcatenatingAudioSource? audioSource;
  final BookState bookState = BookState();

  StreamController<Duration> positionController = StreamController<Duration>();

  Future<void> playChapter(List<dynamic> chapters, int index, bookName) async {
    stop(); // Stop playback before starting a new one

    isLoading = true;
    notifyListeners();

    await audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: chapters.map((chapter) {
          String audioUrl = chapter['audioUrl'];
          return AudioSource.uri(
            Uri.parse(audioUrl),
            tag: MediaItem(
              id: chapter['_id'] ?? "",
              album: bookName,
              title: chapter['chapterNumber'].toString() ?? "",
            ),
          );
        }).toList(),
      ),
      initialIndex: index,
    );

    isLoading = false;
    notifyListeners();

    audioPlayer.play();
    currentPlayingId =
        chapters[index]['_id'] ?? ""; // Set the current playing ID

    notifyListeners();
  }

  Future<void> playBookMark(
    String audioUrl,
    String chapterID,
  ) async {
    stop();
    bookState.clearSelectedCellIndices();
    isLoading = true;
    notifyListeners();

    await audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: chapterID ?? "",
          album: "",
          title: "",
        ),
      ),
    );

    isLoading = false;
    notifyListeners();

    currentPlayingId = chapterID ?? ""; // Set the current playing ID
    await audioPlayer.play();

    notifyListeners();
  }

  void stop() {
    audioPlayer.stop();
    notifyListeners();
  }

  void playPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    notifyListeners();
  }

  Duration get currentPosition => audioPlayer.position;

  @override
  void dispose() {
    audioPlayer.dispose();
    positionController.close();
    super.dispose();
  }
}
