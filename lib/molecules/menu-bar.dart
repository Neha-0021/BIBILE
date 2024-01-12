import 'dart:io';

import 'package:bible_app/molecules/preface.dart';
import 'package:bible_app/pages/home-page.dart';
import 'package:bible_app/state-management/book-chapters-state.dart';
import 'package:bible_app/utils/bottom-bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();

    String platform = Platform.isAndroid ? "android" : "ios";

    final bookState = Provider.of<BookState>(context, listen: false);
    bookState.getShareLinkbyPlatform(platform);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookState>(
        builder: (context, shareState, child) => Drawer(
                child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFFA91B1A),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/icon.png',
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Preface",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TextPage(
                            title: 'Preface',
                            style: 'preface',
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "Presentation",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TextPage(
                            title: 'Presentation',
                            style: 'presentation',
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "General Introduction",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TextPage(
                            title: 'General Introduction',
                            style: 'general_information',
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "List of Collaborators",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TextPage(
                            title: 'List of Collaborators',
                            style: 'list_of_collaborators',
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "New Community Bible",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BottomBar(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "Lexicon",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TextPage(
                            title: 'Lexicon',
                            style: 'lexicon',
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "Share App",
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () async {
                    Share.share(shareState.shareableLink);
                  },
                ),
                ListTile(
                  title: Text(
                    "Contact Us",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TextPage(
                            title: 'Contact Us',
                            style: 'contact_us',
                          );
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "Copyright",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TextPage(
                            title: 'Copyright',
                            style: 'copyright',
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            )));
  }
}
