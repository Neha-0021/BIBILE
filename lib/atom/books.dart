import 'package:bible_app/atom/music.dart';
import 'package:bible_app/molecules/chapters.dart';
import 'package:bible_app/state-management/book_chapters_state.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Books extends StatefulWidget {
  final String selectedType;

  const Books({super.key, required this.selectedType});

  @override
  // ignore: library_private_types_in_public_api
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    fetchBooks();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchBooks() async {
    final bookState = Provider.of<BookState>(context, listen: false);

    if (widget.selectedType == 'new') {
      await bookState.getBooksByType('new');
    } else if (widget.selectedType == 'old') {
      await bookState.getBooksByType('old');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookState = Provider.of<BookState>(context);

    List<String> bookTitles = bookState.books
        .map((book) => (book['title'] ?? '').toString())
        .toList();

    double screenWidth = MediaQuery.of(context).size.width;
    int initialColumns = (screenWidth / 100).floor();

    int columns = initialColumns > 0 ? initialColumns : 1;

    int rows = (bookTitles.length / columns).ceil();

    return Consumer<BookState>(
      builder: (context, bookState, child) => Scaffold(
        body: SafeArea(
          child: Container(
            color: const Color(0xFFf5f5f5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(60.0),
                    bottomRight: Radius.circular(60.0),
                  ),
                  child: Container(
                    color: Colors.red[700],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 40),
                      child: Text(
                        widget.selectedType == 'new'
                            ? 'New Testament'
                            : widget.selectedType == 'old'
                                ? 'Old Testament'
                                : 'All Testament',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          )
                        : bookTitles.isEmpty
                            ? Center(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Container(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 40),
                                          child: Text(
                                            widget.selectedType == 'new'
                                                ? 'New Testament audio version is under development. It will be available soon.'
                                                : 'Old Testament audio version is under development. It will be available soon.',
                                            style: GoogleFonts.lato(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ))))
                            : SingleChildScrollView(
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
                                          if (index < bookTitles.length) {
                                            return GestureDetector(
                                              onTap: () {
                                                bookState.setSelectedBookIndex(
                                                    index);
                                                if (index <
                                                    bookState.books.length) {
                                                  String selectedBookId =
                                                      bookState.books[index]
                                                          ["_id"];
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return Chapters(
                                                            bookId:
                                                                selectedBookId);
                                                      },
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: index ==
                                                            bookState
                                                                .getSelectedBookIndex()
                                                        ? Colors.red
                                                        : Colors.transparent,
                                                    width: 4.0,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    bookTitles[index],
                                                    style: GoogleFonts.lato(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
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
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: MusicPlayer(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
