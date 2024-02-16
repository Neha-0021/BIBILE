import 'package:bible_app/state-management/AudioPlayers.dart';
import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BookMarkCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BookMarkCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioState = Provider.of<AudioState>(context, listen: true);

    bool isCurrentBookmarkPlaying = audioState.audioPlayer.playing &&
        audioState.currentPlayingId == data["_id"];

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
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.red[700],
                  child: IconButton(
                    icon: Icon((isCurrentBookmarkPlaying
                        ? Icons.pause
                        : Icons.play_arrow)),
                    color: Colors.white,
                    onPressed: () async {
                      final bookState =
                          Provider.of<BookState>(context, listen: false);

                      if (audioState.audioPlayer.playing &&
                          audioState.currentPlayingId == data["_id"]) {
                        audioState.stop();
                      } else {
                        String bookmarkId = data["_id"];
                        String audioUrl = data["chapterDetails"]["audioUrl"];

                        bookState.setSelectedBookId("");

                        audioState.playBookMark(audioUrl, bookmarkId);
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      if (isCurrentBookmarkPlaying) {
                        audioState.stop();
                      }
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
