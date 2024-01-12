import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';

class TextPage extends StatefulWidget {
  final String title;
  final String style;

  const TextPage({super.key, required this.title, required this.style});
  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  @override
  void initState() {
    super.initState();
    // Use Provider to call the API and update state
    final text = Provider.of<BookState>(context, listen: false);
    text.getTextbystyle(widget.style);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookState>(
        builder: (context, bookState, child) => Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.title,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: Colors.red,
              ),
              body: ListView.builder(
                itemCount: bookState.texts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Html(
                      data: bookState.texts[index]['content'],
                    ),
                  );
                },
              ),
            ));
  }
}
