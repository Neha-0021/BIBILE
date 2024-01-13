import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

class AudioPlayerService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _currentPlayingBookmarkId;

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  AudioPlayer get audioPlayer => _audioPlayer;
  String? get currentPlayingBookmarkId => _currentPlayingBookmarkId;

  Future<void> togglePlayPause(String bookmarkId, String audioUrl) async {
    if (_currentPlayingBookmarkId == bookmarkId) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      _isLoading = true;
      await _audioPlayer.stop();

      await _audioPlayer.play(UrlSource(audioUrl));
      _currentPlayingBookmarkId = bookmarkId;

      _isLoading = false;
    }

    _isPlaying = !_isPlaying;

    notifyListeners();
  }
}

class BookMarkCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BookMarkCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/book.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${data["bookDetails"]["title"]} - ${data["chapterDetails"]["chapterNumber"]}",
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Consumer<AudioPlayerService>(
                  builder: (context, audioPlayerService, _) {
                    bool isPlaying = audioPlayerService.isPlaying;
                    String? currentPlayingBookmarkId =
                        audioPlayerService.currentPlayingBookmarkId;
                    bool isThisCardPlaying =
                        currentPlayingBookmarkId == data["_id"];
                    IconData icon = isThisCardPlaying && isPlaying
                        ? Icons.pause
                        : Icons.play_arrow;

                    return CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 20,
                      child: IconButton(
                        icon: Icon(
                          icon,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Provider.of<AudioPlayerService>(context,
                                  listen: false)
                              .togglePlayPause(data["_id"],
                                  data["chapterDetails"]["audioUrl"]);
                        },
                      ),
                    );
                  },
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Provider.of<BookState>(context, listen: false)
                          .removeBookmarkById(data["_id"], context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
