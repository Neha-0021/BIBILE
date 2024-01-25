import 'package:bible_app/state-management/book_chapters_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BookMarkCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const BookMarkCard({Key? key, required this.data}) : super(key: key);

  @override
  _BookMarkCardState createState() => _BookMarkCardState();
}

class _BookMarkCardState extends State<BookMarkCard> {
  @override
  Widget build(BuildContext context) {
    final chapterState = Provider.of<BookState>(context);

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
                    "${widget.data["bookDetails"]["title"]} - ${widget.data["chapterDetails"]["chapterNumber"]}",
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
                    icon: Icon(
                      chapterState.isPlaying &&
                              chapterState.selectedBookId == widget.data["_id"]
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 35,
                    ),
                    color: Colors.white,
                    onPressed: () async {
                      String bookmarkId = widget.data["_id"];
                      String audioUrl =
                          widget.data["chapterDetails"]["audioUrl"];

                      if (chapterState.isPlaying &&
                          chapterState.selectedBookId == bookmarkId) {
                        chapterState.stopPlaying();
                      } else {
                        chapterState.play(audioUrl, bookmarkId);
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
                      Provider.of<BookState>(context, listen: false)
                          .removeBookmarkById(widget.data["_id"], context);
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
